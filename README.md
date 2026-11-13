# Mayuu Digital Forensics Lab (MDFL)

A privacy-first, owner-operated photo evidence workspace. MDFL analyzes only images explicitly selected and uploaded by the user. It does not locate senders, access devices, or infer missing GPS data.

## Current status

The React web dashboard starter and Android Compose starter are committed. The Python API is a local development scaffold. The selected Supabase project (Dairy Mangement) remains inactive and could not be restored because the organization reached its free-project active limit. No Supabase schema, buckets, policies, or secrets have been changed.

## Repository

- web/: React + TypeScript + Vite dashboard. Supports explicit JPEG/PNG upload to the local API, SHA-256 display, EXIF field inspection, and embedded GPS display.
- android/: Kotlin + Jetpack Compose starter with native system image picker. Authenticated upload and report display are not connected yet.
- forensic-engine/: Python FastAPI processing service. Development-only, no authentication or persistence.
- supabase/migrations/: proposed SQL only; not applied.

## Run web dashboard

```bash
cd web
npm install
npm run dev
```

API default: http://localhost:8000. Override with VITE_MDFL_API_URL in web/.env.local.

## Run forensic API

Requirements: Python 3.11+ and ExifTool.

```bash
cd forensic-engine
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Health endpoint: GET /health. The current development endpoint accepts JPEG/PNG images and returns server-side SHA-256 plus available metadata. It has no authentication, no persistent storage, and must not be exposed publicly.

## Android

Open android/ in Android Studio and sync Gradle. The current native starter includes a dark interface and system image picker only. See android/README.md.

## Security baseline

- Never expose Supabase service-role/secret keys in browser or Android builds.
- Keep evidence storage private and enforce owner-scoped RLS and Storage policies.
- Treat EXIF timestamps and GPS as untrusted, editable metadata, not proof of authenticity.
- Keep server receipt time separate from EXIF capture time.
- Hash exact original bytes; do not modify or overwrite source evidence.
- Do not deploy or apply the proposed SQL until the Supabase project has been inspected.

## Remaining work

- [x] Repository scaffold, security documentation and proposed SQL
- [x] Development forensic API with upload validation, SHA-256 and metadata extraction
- [x] React web dashboard starter
- [x] Android Compose starter and native image picker
- [ ] Restore/inspect Supabase and reconcile schema
- [ ] Authenticated API, private storage, queue, durable audit history and owner-only access
- [ ] Connect Android upload and analysis flow
- [ ] Integration tests, chain-of-custody export and production deployment hardening

## Important limitations

Metadata may be absent, stripped, edited or falsified. SHA-256 establishes byte-level equality relative to a recorded digest; it does not prove who captured an image, where it was captured, or whether its contents are truthful.