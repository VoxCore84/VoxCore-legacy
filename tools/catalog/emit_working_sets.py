import sqlite3
from pathlib import Path

VOXCORE_ROOT = Path("C:/Users/atayl/VoxCore")
DB_PATH = VOXCORE_ROOT / "catalog" / "db" / "voxcore_catalog.sqlite"
OUT_PATH = VOXCORE_ROOT / "catalog" / "VoxCore_Enterprise_Catalog.md"

def format_size(size_bytes):
    if not size_bytes: return "0 B"
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024.0

def main():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    # 1. Global Totals
    c.execute("SELECT COUNT(*), SUM(size_bytes) FROM files")
    total_files, total_size = c.fetchone()
    
    c.execute("SELECT COUNT(*) FROM folders")
    total_folders = c.fetchone()[0]
    
    # 2. Classification Breakdown
    c.execute('''
        SELECT classification, COUNT(*), SUM(size_bytes)
        FROM files
        GROUP BY classification
        ORDER BY COUNT(*) DESC
    ''')
    classes = c.fetchall()
    
    # 3. Top-Level Directory Breakdown (where parent = root, id 1)
    c.execute('''
        WITH RootDirs AS (
            SELECT id, path FROM folders WHERE parent_id = 1
        )
        SELECT r.path, COUNT(f.id), SUM(f.size_bytes)
        FROM RootDirs r
        JOIN folders child ON child.path LIKE r.path || '%'
        JOIN files f ON f.folder_id = child.id
        GROUP BY r.path
        ORDER BY COUNT(f.id) DESC
    ''')
    top_dirs = c.fetchall()
    
    conn.close()
    
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write("# VoxCore Enterprise Catalog Baseline\n\n")
        f.write("> Automatically generated from SQLite baseline scan.\n\n")
        
        f.write("## 1. Global Footprint\n")
        f.write(f"- **Total Files**: {total_files:,}\n")
        f.write(f"- **Total Folders**: {total_folders:,}\n")
        f.write(f"- **Total Size**: {format_size(total_size)}\n\n")
        
        f.write("## 2. File Classifications\n")
        f.write("| Classification | Files | Size |\n")
        f.write("|----------------|-------|------|\n")
        for cls, count, size in classes:
            f.write(f"| `{cls}` | {count:,} | {format_size(size)} |\n")
        f.write("\n")
        
        f.write("## 3. Subsystem Breakdown (Top-Level Directories)\n")
        f.write("| Directory | Files | Size |\n")
        f.write("|-----------|-------|------|\n")
        for path, count, size in top_dirs:
            f.write(f"| `{path}` | {count:,} | {format_size(size)} |\n")
        f.write("\n")
        
        f.write("## 4. Subsystem Working Sets Identified\n")
        f.write("The database contains precise relational maps. Next steps include using this data to identify duplicate mirror locations and launching AI Summary queries against specific active modules.\n")
        
    print(f"Enterprise Catalog Report generated at {OUT_PATH}")

if __name__ == "__main__":
    main()
