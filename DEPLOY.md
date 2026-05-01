# CyberGuard V2.0 — Deployment Guide

## Prerequisites

- Node.js 18+ installed
- Vercel account (free tier works)
- Supabase project created
- Razorpay account (test mode)
- Resend account (for emails)
- OpenAI API key

## Step 1: Environment Variables

Create `.env.local` file (NEVER commit this):

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# OpenAI
OPENAI_API_KEY=sk-your-key

# Razorpay
RAZORPAY_KEY_ID=rzp_test_your-key
RAZORPAY_KEY_SECRET=your-secret
NEXT_PUBLIC_RAZORPAY_KEY=rzp_test_your-key

# Resend
RESEND_API_KEY=re_your-key
RESEND_FROM_EMAIL=alerts@your-domain.com

# App
NEXT_PUBLIC_APP_URL=https://your-domain.com
```

## Step 2: Database Setup

1. Go to Supabase Dashboard → SQL Editor
2. Copy contents of `schema.sql`
3. Run the SQL to create tables, RLS policies, and triggers

**CRITICAL: Verify RLS is enabled on all tables before production!**

## Step 3: Install Dependencies

```bash
npm install
```

## Step 4: Run Locally

```bash
npm run dev
```

App will be at `http://localhost:3000`

## Step 5: Deploy to Vercel

### Option A: Vercel CLI

```bash
npm i -g vercel
vercel login
vercel --prod
```

### Option B: Git Integration

1. Push code to GitHub (private repo recommended)
2. Import project in Vercel dashboard
3. Add environment variables in Project Settings
4. Deploy

## Step 6: Configure Vercel Settings [^54^]

### Security Headers
Add to `next.config.js`:

```javascript
async headers() {
  return [
    {
      source: '/(.*)',
      headers: [
        {
          key: 'X-Frame-Options',
          value: 'DENY',
        },
        {
          key: 'X-Content-Type-Options',
          value: 'nosniff',
        },
        {
          key: 'Referrer-Policy',
          value: 'strict-origin-when-cross-origin',
        },
      ],
    },
  ]
}
```

### Build Settings
- Framework Preset: Next.js
- Build Command: `next build`
- Output Directory: `.next`

## Step 7: Post-Deployment Checklist [^54^]

- [ ] Enable Deployment Protection
- [ ] Configure Custom Domain
- [ ] Enable Vercel WAF
- [ ] Set up Log Drains
- [ ] Enable Speed Insights
- [ ] Test all API endpoints
- [ ] Verify email delivery
- [ ] Test payment flow in test mode
- [ ] Enable SSL (auto-enabled on Vercel)

## Troubleshooting

### Build Errors
- Ensure all dependencies installed: `npm install`
- Check TypeScript errors: `npx tsc --noEmit`

### API Errors
- Verify environment variables in Vercel dashboard
- Check Supabase RLS policies are active
- Confirm Razorpay keys are in test mode

### Auth Issues
- Ensure Supabase auth redirect URL matches your domain
- Check middleware.ts matcher patterns

## Production Checklist

- [ ] Switch Razorpay to live keys
- [ ] Update Resend to verified domain
- [ ] Enable MFA in Supabase
- [ ] Review RLS policies
- [ ] Set up monitoring (Sentry, LogRocket)
- [ ] Configure backup strategy
- [ ] Document incident response plan

## Support

For issues, check:
1. Vercel Functions logs
2. Supabase Logs
3. Browser console for client errors
4. Razorpay Dashboard for payment issues
