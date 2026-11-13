# Mayuu Digital Forensics Lab (MDFL)

A privacy-first, owner-operated photo evidence workspace. MDFL analyzes only images explicitly selected and uploaded by the authenticated user. It does not locate senders, access devices, or infer missing GPS data.

## Current repository status

This repository starts as an implementation scaffold. The Supabase project previously selected for MDFL (Dairy Mangement) is inactive and could not be inspected or restored because the free-project active limit was reached. **No Supabase schema, buckets, policies, or secrets have been changed.** Do not point this app at that project until its schema and storage have been inspected and an MDFL migration has been approved.

## Architecture

- `web/`: React + TypeScript web client (planned)
- `android/`: Kotlin + Jetpack Compose Android client (planned)
- `forensic-engine/`: Python FastAPI processing service
- `supabase/migrations/`: reviewed SQL migrations; not applied yet

### Evidence workflow

1. User signs in and explicitly selects an image.
2. API validates size, content signature, decodeability, and supported format.
3. Server calculates SHA-256 over the exact uploaded bytes.
4. Original bytes are stored privately and never transformed or overwritten.
5. Isolated worker extracts available EXIF/GPS metadata.
6. Stored object is downloaded and independently hashed; the two hashes are compared.
7. Results and append-only audit events are persisted.
8. UI displays GPS only when embedded coordinates exist; otherwise it says GPS unavailable.

## Security rules

- Never expose Supabase service-role/secret keys in browser or Android builds.
- Enable RLS on every exposed table; enforce ownership on rows and Storage paths.
- Keep evidence buckets private. Use short-lived signed URLs only when needed.
- Treat EXIF timestamps and GPS as untrusted, editable metadata, not proof of authenticity.
- Keep server receipt time separate from EXIF capture time.
- Process untrusted files in a resource-limited isolated worker; never execute uploads.
- Permanent retention means retained until the owner explicitly deletes evidence. Maintain backups and a documented deletion process.
- Do not deploy or apply the SQL migration until the existing Supabase project has been inspected.

## Local forensic engine

Requirements: Python 3.11+, ExifTool installed in the host/container.

```bash
cd forensic-engine
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Health endpoint: `GET /health`. The initial API scaffold accepts an explicitly uploaded file and returns server-side SHA-256 plus extracted metadata. It is a development scaffold, not production-hardened; production requires authenticated gateway integration, private object storage, queue isolation, rate limits, malware scanning, and durable audit persistence.

## Supabase setup status

The SQL under `supabase/migrations/` is a proposed schema only. Review it against the actual database before applying. Bucket creation and Storage RLS policies are intentionally documented separately and must be configured only after the project is accessible and inspected.

## Roadmap

- [x] Repository scaffold and security/architecture documentation
- [x] Initial forensic API with upload validation, SHA-256 and EXIF extraction
- [ ] Inspect existing Supabase project and reconcile migration
- [ ] Create private buckets and ownership-scoped Storage policies
- [ ] Add authenticated job queue and persistent metadata/audit records
- [ ] Build React dashboard
- [ ] Build Android client
- [ ] Add chain-of-custody exports, integration tests and deployment hardening

## Disclaimer

MDFL is an evidence organization and metadata inspection tool. Metadata can be absent, stripped, or falsified. Hashes establish byte-level integrity relative to a recorded digest; they do not establish who captured an image, where it was captured, or whether its contents are truthful.
