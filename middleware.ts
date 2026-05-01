import { NextRequest, NextResponse } from 'next/server'
import { createServerClient, type CookieOptions } from '@supabase/ssr'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({ name, value, ...options })
          response = NextResponse.next({
            request: { headers: request.headers },
          })
          response.cookies.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          request.cookies.set({ name, value: '', ...options })
          response = NextResponse.next({
            request: { headers: request.headers },
          })
          response.cookies.set({ name, value: '', ...options })
        },
      },
    }
  )

  // Refresh session if expired
  const { data: { user } } = await supabase.auth.getUser()

  // Protected routes - redirect to home if not authenticated
  if (request.nextUrl.pathname.startsWith('/dashboard')) {
    if (!user) {
      return NextResponse.redirect(new URL('/', request.url))
    }
  }

  // Auth routes - redirect to dashboard if already authenticated
  if (request.nextUrl.pathname === '/auth' || request.nextUrl.pathname === '/login') {
    if (user) {
      return NextResponse.redirect(new URL('/dashboard', request.url))
    }
  }

  // Rate limiting for auth endpoints
  if (request.nextUrl.pathname === '/api/auth/login' && request.method === 'POST') {
    const attempts = parseInt(request.cookies.get('auth-attempts')?.value ?? '0', 10)
    const lastAttempt = parseInt(request.cookies.get('auth-last-attempt')?.value ?? '0', 10)
    const WINDOW_MS = 15 * 60 * 1000 // 15 minutes
    const MAX_ATTEMPTS = 5

    if (Date.now() - lastAttempt < WINDOW_MS && attempts >= MAX_ATTEMPTS) {
      return new NextResponse(
        JSON.stringify({ error: 'Too many attempts. Try again in 15 minutes.' }),
        {
          status: 429,
          headers: {
            'Content-Type': 'application/json',
            'Retry-After': '900',
          },
        }
      )
    }
  }

  // Inject user context header for Server Components [^52^]
  if (user) {
    response.headers.set('x-user-id', user.id)
    response.headers.set('x-user-email', user.email || '')
  }

  return response
}

export const config = {
  matcher: [
    '/dashboard/:path*',
    '/api/scan',
    '/api/payments/:path*',
    '/api/monitoring',
    '/auth',
    '/login',
  ],
}
