# MDFL Web Dashboard

React + TypeScript + Vite dashboard connected to Supabase Auth, Postgres and a private Storage bucket.

## Configure

Create `web/.env.local` (never commit it):

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

The browser only uses a Supabase publishable key. Never put a secret/service-role key in this app.

## Database setup

In Supabase SQL Editor, run migrations in order:

1. `supabase/migrations/0001_mdfl_core.sql`
2. `supabase/migrations/0002_mdfl_client_storage.sql`

Enable email/password authentication. For a private single-owner dashboard, disable public sign-ups after creating your owner account. The second migration creates the private `mdfl-evidence` bucket and owner-scoped Storage policies.

## Run locally

```bash
npm install
npm run dev
```

## Features

- Supabase email/password authentication and persisted sessions
- Private evidence upload to owner-scoped Storage
- Browser SHA-256 digest, EXIF metadata and embedded GPS inspection
- Persistent evidence list, manual delete, live Postgres subscription with 15-second refresh fallback
- Responsive owner dashboard

## Important security/forensic limits

This is a browser-side analysis client. Hashing and EXIF extraction happen in the browser; they are not an independent trusted forensic pipeline. A user controlling the browser can tamper with client-submitted metadata. For court-grade chain of custody, add an authenticated server-side ingest service that hashes the exact received and stored bytes, writes audit events, and isolates parsers. GPS/EXIF values can be edited or spoofed. The app never infers missing coordinates.
