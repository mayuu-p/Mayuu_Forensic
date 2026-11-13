# MDFL Android client

Native Kotlin + Jetpack Compose starter project. Open the android/ directory in Android Studio (Giraffe or newer) and sync Gradle.

## Current functionality
- Native Material 3 dark interface.
- Explicit image selection using Android's system document picker (no broad media permission and no background location permission).
- Shows the selected URI and clearly labels the app as a client scaffold.

## Not yet connected
Authenticated API upload, SHA-256 result display, EXIF/GPS report, owner authentication, Keystore token storage, persistent evidence history, and Supabase integration remain pending. Do not distribute this as a production evidence app yet.

## Security constraints
- Never request continuous/background location.
- Never bundle Supabase service-role credentials.
- Use authenticated HTTPS only; production must disable cleartext traffic.
- Keep original evidence bytes unchanged and show absent GPS as unavailable.
- Treat EXIF values as untrusted metadata, not proof of authenticity.
