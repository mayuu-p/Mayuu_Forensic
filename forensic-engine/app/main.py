from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image, UnidentifiedImageError

app = FastAPI(title="MDFL Forensic Engine", version="0.1.0")

# Local development origins only. Set MDFL_CORS_ORIGINS to a comma-separated
# allowlist of exact HTTPS origins before deploying a trusted frontend.
allowed_origins = [origin.strip() for origin in os.getenv(
    "MDFL_CORS_ORIGINS", "http://localhost:5173,http://127.0.0.1:5173,http://localhost:4173"
).split(",") if origin.strip()]
app.add_middleware(
    CORSMiddleware, allow_origins=allowed_origins, allow_credentials=False,
    allow_methods=["GET", "POST"], allow_headers=["Content-Type"],
)

MAX_BYTES = 25 * 1024 * 1024
ALLOWED_FORMATS = {"JPEG": "image/jpeg", "PNG": "image/png", "HEIF": "image/heic", "HEIC": "image/heic"}
EXIFTOOL = os.getenv("EXIFTOOL_PATH", "exiftool")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "mdfl-forensic-engine"}


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def extract_metadata(path: Path) -> dict[str, Any]:
    executable = shutil.which(EXIFTOOL)
    if not executable:
        return {"warning": "ExifTool is not installed; metadata extraction skipped."}
    try:
        result = subprocess.run(
            [executable, "-json", "-n", "-G1", "-a", "-s", str(path)],
            check=True, capture_output=True, text=True, timeout=12,
            env={"PATH": os.environ.get("PATH", "")},
        )
        rows = json.loads(result.stdout or "[]")
        return rows[0] if rows else {}
    except (subprocess.SubprocessError, json.JSONDecodeError) as exc:
        return {"warning": f"Metadata extraction failed safely: {type(exc).__name__}"}


@app.post("/v1/analyze")
async def analyze_photo(file: UploadFile = File(...)) -> dict[str, Any]:
    # Development endpoint only. Production must place this behind authenticated
    # API gateway/JWT verification, per-user quotas, and isolated worker execution.
    filename = Path(file.filename or "upload").name
    suffix = Path(filename).suffix.lower()
    if suffix not in {".jpg", ".jpeg", ".png", ".heic", ".heif"}:
        raise HTTPException(415, "Unsupported extension")

    with tempfile.TemporaryDirectory(prefix="mdfl-") as temp_dir:
        target = Path(temp_dir) / "evidence.bin"
        size = 0
        try:
            with target.open("xb") as output:
                while chunk := await file.read(1024 * 1024):
                    size += len(chunk)
                    if size > MAX_BYTES:
                        raise HTTPException(413, "File exceeds 25 MiB limit")
                    output.write(chunk)

            if size == 0:
                raise HTTPException(400, "Empty file")

            digest = sha256_file(target)
            detected_mime = None
            try:
                with Image.open(target) as image:
                    image.verify()
                    detected_mime = Image.MIME.get(image.format)
                    detected_format = image.format
            except (UnidentifiedImageError, OSError):
                # HEIC may not be supported by the Pillow build. Do not trust extension.
                raise HTTPException(415, "Image signature/decode validation failed")

            expected_mime = ALLOWED_FORMATS.get(detected_format)
            if not expected_mime or (detected_mime and detected_mime != expected_mime):
                raise HTTPException(415, "File content does not match an allowed image type")

            metadata = extract_metadata(target)
            lat = metadata.get("EXIF:GPSLatitude", metadata.get("GPS:GPSLatitude"))
            lon = metadata.get("EXIF:GPSLongitude", metadata.get("GPS:GPSLongitude"))
            gps_valid = (
                isinstance(lat, (int, float)) and -90 <= lat <= 90
                and isinstance(lon, (int, float)) and -180 <= lon <= 180
            )
            return {
                "filename": filename,
                "mime_type": expected_mime,
                "size_bytes": size,
                "sha256_original": digest,
                "metadata": metadata,
                "gps": {"available": bool(gps_valid), "latitude": lat if gps_valid else None,
                        "longitude": lon if gps_valid else None},
                "notice": "EXIF and GPS values are untrusted metadata and may be missing or edited.",
                "mode": "development-no-persistence",
            }
        finally:
            await file.close()
