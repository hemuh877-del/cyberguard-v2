# CyberGuard V2.0 🛡️

> AI-Powered Personal Cybersecurity Guardian — Know if your data has been leaked before hackers use it.

[![Next.js](https://img.shields.io/badge/Next.js-15-black)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.7-blue)](https://typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.4-cyan)](https://tailwindcss.com)
[![Supabase](https://img.shields.io/badge/Supabase-2.x-green)](https://supabase.com)

## Features

- 🔍 **Free Breach Scanner** — Check any email against 12B+ leaked records
- 🤖 **AI Threat Analysis** — GPT-4o explains breaches in plain language
- 🔔 **Real-time Monitoring** — Continuous dark web surveillance
- 🎣 **Phishing Detection** — AI-powered link safety checker
- 📊 **Security Score** — Live 0-100 rating with actionable fixes
- 💳 **Razorpay Payments** — UPI, cards, netbanking (India-focused)
- 🔐 **Passkey Auth** — FIDO2/WebAuthn + Google OAuth + Email
- 📱 **PWA Ready** — Works offline, installable on mobile

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Next.js 15 (App Router) |
| Styling | Tailwind CSS + Framer Motion |
| Auth | Supabase Auth (OAuth + Passkeys + Email) |
| Database | Supabase PostgreSQL + Realtime |
| Payments | Razorpay (India) |
| Email | Resend (transactional) |
| AI | OpenAI GPT-4o |
| Hosting | Vercel (Edge Functions) |

## Quick Start

```bash
# Clone repository
git clone https://github.com/yourusername/cyberguard-v2.git
cd cyberguard-v2

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your API keys

# Run development server
npm run dev
```

## Project Structure

```
cyberguard-v2/
├── app/                    # Next.js App Router
│   ├── api/               # API routes (scan, payments, auth)
│   ├── dashboard/         # Protected dashboard page
│   ├── auth/             # Auth callback handler
│   ├── globals.css       # Global styles
│   ├── layout.tsx        # Root layout
│   └── page.tsx          # Landing page
├── components/
│   ├── sections/          # Landing page sections
│   ├── dashboard/         # Dashboard components
│   ├── scanner/           # Breach scanner
│   ├── ui/               # Reusable UI components
│   ├── auth-modal.tsx     # Auth modal
│   └── auth-provider.tsx  # Auth context
├── lib/                   # Utilities & API clients
│   ├── supabase.ts       # Supabase client
│   ├── openai.ts         # OpenAI integration
│   ├── razorpay.ts       # Payment processing
│   ├── resend.ts         # Email service
│   └── utils.ts          # Helper functions
├── types/                 # TypeScript definitions
├── schema.sql            # Supabase database schema
├── middleware.ts         # Next.js middleware
└── DEPLOY.md             # Deployment guide
```

## Database Schema

Run `schema.sql` in Supabase SQL Editor to create:
- `users` — Extended auth profiles
- `breaches` — Breach records
- `monitoring` — Monitoring configurations
- `payments` — Payment transactions
- `scan_history` — Scan logs
- `security_reports` — Generated reports

All tables have **RLS enabled** with user-scoped policies.

## API Routes

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/scan` | POST | Scan email for breaches |
| `/api/ai/analyze` | POST | AI threat analysis |
| `/api/payments/create-order` | POST | Create Razorpay order |
| `/api/payments/verify` | POST | Verify payment |
| `/api/monitoring` | GET/POST | Manage monitoring |
| `/api/webhooks/supabase` | POST | Supabase realtime webhooks |

## Security

- ✅ Row Level Security (RLS) on all tables
- ✅ JWT verification at Edge (middleware)
- ✅ Rate limiting for auth endpoints
- ✅ Input validation with Zod
- ✅ Secure cookie settings
- ✅ API key rotation support

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## License

MIT License — see [LICENSE](LICENSE) for details.

## Support

- 📧 Email: support@cyberguard.in
- 💬 Discord: [Join our community](https://discord.gg/cyberguard)
- 🐦 Twitter: [@CyberGuardAI](https://twitter.com/CyberGuardAI)

---

Built with ❤️ in India for the world.
