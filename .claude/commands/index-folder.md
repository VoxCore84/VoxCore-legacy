Index a directory tree into a structured JSON manifest for agent consumption.

Run: `python tools/folder_index.py $ARGUMENTS`

If no arguments provided, ask which directory to index.

Common usage patterns:
- Full manifest: `python tools/folder_index.py <dir> --output <dir>/manifest.json`
- Quick summary: `python tools/folder_index.py <dir> --summary`
- Specific types: `python tools/folder_index.py <dir> --types .pdf,.docx,.eml`
- Shallow scan: `python tools/folder_index.py <dir> --max-depth 2 --summary`

After indexing, report the summary stats (total files, size, breakdown by extension and directory).
