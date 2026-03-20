Batch-extract text from PDFs, DOCX, EML, and MSG files in a directory tree.

Run: `python tools/bulk_extract.py $ARGUMENTS`

If no arguments provided, ask which directory to process.

Common usage patterns:
- Single dump: `python tools/bulk_extract.py <dir> --output extracted.txt`
- JSON format: `python tools/bulk_extract.py <dir> --format json --output extracted.json`
- Per-file: `python tools/bulk_extract.py <dir> --per-file --outdir ./extracted/`
- Specific types: `python tools/bulk_extract.py <dir> --types .pdf,.docx`

Requirements: `pip install python-docx PyPDF2` (eml uses stdlib).

After extraction, report how many files were processed and output size.
