import os
from pathlib import Path

# Resolve Desktop dynamically
desktop_dir = Path(os.path.expanduser("~/OneDrive/Desktop"))
if not desktop_dir.exists():
    desktop_dir = Path(os.path.expanduser("~/Desktop"))

output_file = desktop_dir / "CommandCenter_Context.txt"

# Resolve Project Root dynamically (since script is in VoxCore/tools/)
VOXCORE_ROOT = Path(__file__).resolve().parent.parent

payload = """# VoxCore Command Center Context

Below is the current source code for the VoxCore Command Center web dashboard.
Please read this file. I need a specification to overhaul its UI to be cleaner, less cluttered, and explicitly add a new 'Task Tracker' module that reads and displays tasks from a local JSON or Markdown file.

"""

files_to_bundle = [
    VOXCORE_ROOT / "tools" / "command-center" / "app.py",
    VOXCORE_ROOT / "tools" / "command-center" / "templates" / "index.html"
]

for file_path in files_to_bundle:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    filename = os.path.basename(file_path)
    if "index.html" in filename:
        ext = "html"
    else:
        ext = "python"
        
    payload += f"\n## File: `{filename}`\n```{ext}\n"
    payload += content
    payload += "\n```\n"

with open(output_file, "w", encoding="utf-8") as f:
    f.write(payload)

print("Generated Context Payload for ChatGPT on Desktop.")
