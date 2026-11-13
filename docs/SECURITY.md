# MDFL Security Baseline

## Trust boundaries
- Browser/Android clients are untrusted.
- Uploaded files and all embedded metadata are untrusted.
- The API authenticates the user and derives owner_id from verified identity; never accept owner_id from request JSON.
- The worker runs with no outbound network access, read-only root filesystem where possible, resource limits, and a temporary isolated workspace.

## Evidence integrity
- Hash the exact received bytes before parsing.
- Preserve the original object byte-for-byte.
- Re-download the stored object and hash it independently.
- Keep capture timestamps, server receipt timestamps, and processing timestamps separate.
- Hashes prove byte equality relative to a digest, not image authenticity or capture location.

## Storage
- Private buckets only.
- Object path format: <auth-user-uuid>/<evidence-uuid>/original.
- Storage policies must enforce the first path segment equals auth.uid().
- No public object URLs. Signed URLs should be short-lived and created only after authorization.
- Permanent retention is not a backup strategy: configure encrypted backups and test restore.

## API
- JWT verification at the gateway.
- Rate limits and per-user quotas.
- Maximum upload size and strict allowlist.
- Validate magic bytes and decode in a sandbox.
- Do not execute uploads or trust filenames.
- Restrict CORS to deployed client origins.
- Keep all secrets in backend secret manager.
- Add audit events for upload, view, download, export and deletion.

## Deployment blockers
This repository's API endpoint is a development scaffold. It currently has no auth, no persistence, no Supabase integration, no queue, no malware scanning, and HEIC decoding depends on installed image libraries. Do not expose it publicly until those controls are implemented and tested.
