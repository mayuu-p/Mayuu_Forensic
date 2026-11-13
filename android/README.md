# MDFL Android client

Planned native client: Kotlin + Jetpack Compose.

Implementation requirements:
- Use Android Photo Picker for explicit image selection.
- Request photo-location metadata access only where supported and explain why.
- Never request continuous/background location; MDFL reads embedded image metadata only.
- Upload through authenticated HTTPS API; never bundle Supabase service-role credentials.
- Display GPS as unavailable when metadata is absent.
- Use Android Keystore-backed secure token storage and PKCE-compatible auth flow.
- Show upload/processing status and hash verification result.
- Do not claim a file is authentic based only on EXIF or SHA-256.
