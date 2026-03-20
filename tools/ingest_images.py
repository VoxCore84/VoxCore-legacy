"""
Batch image ingestion via Claude API (Vision).

STANDARD PROCEDURE for bulk image analysis. Never read images directly into
Claude Code conversation context — it burns tokens and triggers the 2000px
dimension limit every 10-20 files.

Instead: this script sends each image to Claude API off-context, writes all
descriptions to a single markdown digest file, which Claude Code then reads
as plain text.

Usage:
    python tools/ingest_images.py <image_dir>
    python tools/ingest_images.py <image_dir> --output custom_digest.md
    python tools/ingest_images.py <image_dir> --model claude-sonnet-4-6 --workers 5
    python tools/ingest_images.py <image_dir> --prompt "Extract only text verbatim"

Performance (Haiku 4.5, 10 workers): ~100 images/min, ~$0.02-0.05 per run.
"""
import argparse
import base64
import io
import sys
import time
import concurrent.futures
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Lazy imports for PIL (only needed if resizing)
PIL_AVAILABLE = False
try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    pass

import anthropic

EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".tiff", ".tif"}
MAX_BASE64_BYTES = 5 * 1024 * 1024  # 5 MB API limit

DEFAULT_SYSTEM_PROMPT = """You are analyzing a screenshot/photo saved from a phone. Describe what this image contains in detail:
- If it's a social media post, capture the author, platform, and full text content
- If it's an article or webpage, capture the title, source, and key points
- If it's an infographic or diagram, describe the structure and all text/data
- If it's a conversation or email, capture participants and content
- If it's a document, capture the title, type, and key content
- Capture ALL visible text verbatim when possible
Be thorough but concise. Focus on the informational content, not visual styling."""


def load_api_key():
    """Load ANTHROPIC_API_KEY from tools/ai_studio/.env."""
    for env_path in [
        PROJECT_ROOT / "tools" / "ai_studio" / ".env",
        PROJECT_ROOT / "config" / ".env",
    ]:
        if env_path.exists():
            with open(env_path) as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("ANTHROPIC_API_KEY="):
                        return line.split("=", 1)[1].strip().strip('"').strip("'")
    # Fall back to environment variable
    import os
    key = os.environ.get("ANTHROPIC_API_KEY")
    if key:
        return key
    raise RuntimeError("ANTHROPIC_API_KEY not found in .env or environment")


def get_media_type(ext: str) -> str:
    ext = ext.lower()
    if ext in (".jpg", ".jpeg"):
        return "image/jpeg"
    elif ext == ".png":
        return "image/png"
    elif ext == ".gif":
        return "image/gif"
    elif ext == ".webp":
        return "image/webp"
    return "image/jpeg"


def encode_image(filepath: Path) -> tuple[str, str]:
    """Read and base64-encode an image. Resize if >5MB. Returns (base64_data, media_type)."""
    with open(filepath, "rb") as f:
        raw = f.read()

    media_type = get_media_type(filepath.suffix)
    data = base64.standard_b64encode(raw).decode("utf-8")

    # If under 5MB, return as-is
    if len(raw) <= MAX_BASE64_BYTES:
        return data, media_type

    # Resize if PIL available
    if not PIL_AVAILABLE:
        raise ValueError(f"{filepath.name} is {len(raw)/1024/1024:.1f}MB (>5MB limit). Install Pillow to auto-resize: pip install Pillow")

    img = Image.open(filepath)
    img.thumbnail((2000, 2000), Image.LANCZOS)
    buf = io.BytesIO()
    fmt = "PNG" if filepath.suffix.lower() == ".png" else "JPEG"
    img.save(buf, format=fmt, quality=85)
    data = base64.standard_b64encode(buf.getvalue()).decode("utf-8")
    return data, media_type


def process_image(client: anthropic.Anthropic, filepath: Path, model: str,
                  system_prompt: str, user_prompt: str) -> tuple[str, str]:
    """Process a single image, return (filename, description)."""
    try:
        data, media_type = encode_image(filepath)

        response = client.messages.create(
            model=model,
            max_tokens=1500,
            system=system_prompt,
            messages=[{
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": media_type,
                            "data": data,
                        },
                    },
                    {
                        "type": "text",
                        "text": user_prompt,
                    }
                ],
            }],
        )

        desc = response.content[0].text
        return (filepath.name, desc)
    except Exception as e:
        return (filepath.name, f"ERROR: {e}")


def main():
    parser = argparse.ArgumentParser(description="Batch image ingestion via Claude API")
    parser.add_argument("image_dir", help="Directory containing images to process")
    parser.add_argument("--output", "-o", help="Output markdown file (default: <dir>/image_digest.md)")
    parser.add_argument("--model", "-m", default="claude-haiku-4-5-20251001",
                        help="Model to use (default: claude-haiku-4-5-20251001)")
    parser.add_argument("--workers", "-w", type=int, default=10,
                        help="Concurrent API calls (default: 10)")
    parser.add_argument("--prompt", "-p", default="Describe this image thoroughly.",
                        help="User prompt sent with each image")
    parser.add_argument("--system", "-s", default=DEFAULT_SYSTEM_PROMPT,
                        help="System prompt (default: general image description)")
    parser.add_argument("--prefix", default=None,
                        help="Only process files starting with this prefix (e.g., IMG_)")
    args = parser.parse_args()

    image_dir = Path(args.image_dir).resolve()
    if not image_dir.is_dir():
        print(f"Error: {image_dir} is not a directory", file=sys.stderr)
        sys.exit(1)

    output_file = Path(args.output) if args.output else image_dir / "image_digest.md"

    api_key = load_api_key()
    client = anthropic.Anthropic(api_key=api_key)

    # Collect image files
    images = sorted([
        f for f in image_dir.iterdir()
        if f.suffix.lower() in EXTENSIONS
        and (args.prefix is None or f.name.startswith(args.prefix))
    ])

    if not images:
        print(f"No images found in {image_dir}")
        sys.exit(1)

    print(f"Found {len(images)} images to process")
    print(f"Model: {args.model}")
    print(f"Concurrency: {args.workers}")
    print(f"Output: {output_file}")
    print()

    results = {}
    completed = 0
    start_time = time.time()

    with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as executor:
        future_to_path = {
            executor.submit(process_image, client, img, args.model,
                            args.system, args.prompt): img
            for img in images
        }

        for future in concurrent.futures.as_completed(future_to_path):
            filepath = future_to_path[future]
            filename, desc = future.result()
            results[filename] = desc
            completed += 1
            elapsed = time.time() - start_time
            rate = completed / elapsed * 60 if elapsed > 0 else 0
            status = "OK" if not desc.startswith("ERROR") else "FAIL"
            print(f"  [{completed}/{len(images)}] {filename} -- {status} ({rate:.0f}/min)")

    # Write output sorted by filename
    elapsed_total = time.time() - start_time
    errors = sum(1 for v in results.values() if v.startswith("ERROR"))

    with open(output_file, "w", encoding="utf-8") as f:
        f.write(f"# Image Digest -- {image_dir.name}\n\n")
        f.write(f"**Generated**: {time.strftime('%Y-%m-%d %H:%M')}\n")
        f.write(f"**Source**: `{image_dir}`\n")
        f.write(f"**Images processed**: {len(results)}\n")
        f.write(f"**Errors**: {errors}\n")
        f.write(f"**Time**: {elapsed_total:.0f}s\n")
        f.write(f"**Model**: {args.model}\n\n---\n\n")

        for filename in sorted(results.keys()):
            desc = results[filename]
            f.write(f"## {filename}\n\n{desc}\n\n---\n\n")

    print(f"\nDone! {len(results)} images processed in {elapsed_total:.0f}s ({errors} errors)")
    print(f"Output: {output_file}")


if __name__ == "__main__":
    main()
