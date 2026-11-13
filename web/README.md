# MDFL Web Dashboard

React + TypeScript + Vite dashboard for explicit image upload, server-side SHA-256, EXIF inspection and embedded GPS display.

## Run locally

```bash
cd web
npm install
# Optional: set VITE_MDFL_API_URL in .env.local (default http://localhost:8000)
npm run dev
```

Start the forensic API separately using the instructions in the repository root. The UI is a local development preview: it has no authentication, persistent evidence vault, Supabase integration, or multi-user access control yet. Do not expose it to the public internet. The API currently accepts JPEG/PNG images; HEIC decoding depends on the backend image codec configuration.
