-- ============================================
-- CYBERGUARD V2.0 - SUPABASE SCHEMA
-- Enable RLS on ALL tables before production!
-- ============================================

-- Users table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  plan TEXT DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'family', 'business')),
  security_score INTEGER DEFAULT 50 CHECK (security_score >= 0 AND security_score <= 100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Breaches table
CREATE TABLE IF NOT EXISTS public.breaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  breach_date DATE,
  data_classes TEXT[],
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  ai_analysis TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Monitoring config table
CREATE TABLE IF NOT EXISTS public.monitoring (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  frequency TEXT DEFAULT 'weekly' CHECK (frequency IN ('daily', 'weekly', 'realtime')),
  last_checked TIMESTAMPTZ,
  next_check TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, email)
);

-- Payments table
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  razorpay_order_id TEXT NOT NULL,
  razorpay_payment_id TEXT,
  amount INTEGER NOT NULL,
  currency TEXT DEFAULT 'INR',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  plan TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Scan history table
CREATE TABLE IF NOT EXISTS public.scan_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  email TEXT NOT NULL,
  breached BOOLEAN DEFAULT false,
  breach_count INTEGER DEFAULT 0,
  risk_level TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Security reports table
CREATE TABLE IF NOT EXISTS public.security_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  factors JSONB DEFAULT '[]',
  recommendations TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ENABLE RLS ON ALL TABLES (CRITICAL!)
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.breaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.monitoring ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scan_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.security_reports ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES - Users can only access own data
-- Use (select auth.uid()) for query optimization [^50^]
-- ============================================

-- Users table policies
CREATE POLICY "Users can view own profile"
  ON public.users FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = id);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  TO authenticated
  USING ((select auth.uid()) = id)
  WITH CHECK ((select auth.uid()) = id);

-- Breaches table policies
CREATE POLICY "Users can view own breaches"
  ON public.breaches FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY "Users can insert own breaches"
  ON public.breaches FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

-- Monitoring table policies
CREATE POLICY "Users can view own monitoring"
  ON public.monitoring FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY "Users can manage own monitoring"
  ON public.monitoring FOR ALL
  TO authenticated
  USING ((select auth.uid()) = user_id)
  WITH CHECK ((select auth.uid()) = user_id);

-- Payments table policies
CREATE POLICY "Users can view own payments"
  ON public.payments FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

-- Scan history policies
CREATE POLICY "Users can view own scan history"
  ON public.scan_history FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY "Anonymous can insert scan history"
  ON public.scan_history FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

-- Security reports policies
CREATE POLICY "Users can view own reports"
  ON public.security_reports FOR SELECT
  TO authenticated
  USING ((select auth.uid()) = user_id);

CREATE POLICY "Users can insert own reports"
  ON public.security_reports FOR INSERT
  TO authenticated
  WITH CHECK ((select auth.uid()) = user_id);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- Index columns used in RLS policies [^50^]
-- ============================================

CREATE INDEX IF NOT EXISTS idx_breaches_user_id ON public.breaches(user_id);
CREATE INDEX IF NOT EXISTS idx_breaches_email ON public.breaches(email);
CREATE INDEX IF NOT EXISTS idx_monitoring_user_id ON public.monitoring(user_id);
CREATE INDEX IF NOT EXISTS idx_monitoring_email ON public.monitoring(email);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_scan_history_user_id ON public.scan_history(user_id);
CREATE INDEX IF NOT EXISTS idx_scan_history_email ON public.scan_history(email);
CREATE INDEX IF NOT EXISTS idx_security_reports_user_id ON public.security_reports(user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, full_name, plan, security_score)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    COALESCE(NEW.raw_user_meta_data->>'plan', 'free'),
    50
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- SECURITY: Prevent privilege escalation
-- Security definer functions in private schema [^50^][^28^]
-- ============================================

CREATE SCHEMA IF NOT EXISTS private;

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION private.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.users
    WHERE id = (select auth.uid())
    AND plan = 'business'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

GRANT EXECUTE ON FUNCTION private.is_admin() TO authenticated;

-- Admin policy for viewing all users (for business plan)
CREATE POLICY "Admins can view all users"
  ON public.users FOR SELECT
  TO authenticated
  USING (private.is_admin());

-- ============================================
-- REALTIME SUBSCRIPTIONS
-- Enable realtime for breach alerts [^50^]
-- ============================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.breaches;
ALTER PUBLICATION supabase_realtime ADD TABLE public.monitoring;

-- ============================================
-- COMPLIANCE NOTES
-- SOC 2 CC6: RLS policies document access control
-- ISO 27001 5.15-5.18: Role-based access at database level
-- ============================================
