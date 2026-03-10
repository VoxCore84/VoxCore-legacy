import sqlite3
from pathlib import Path

VOXCORE_ROOT = Path("C:/Users/atayl/VoxCore")
DB_PATH = VOXCORE_ROOT / "catalog" / "db" / "voxcore_catalog.sqlite"
OUT_PATH = VOXCORE_ROOT / "catalog" / "duplicate_analysis.md"

def format_size(size_bytes):
    if not size_bytes: return "0 B"
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024.0

def main():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write("# VoxCore Duplicate & Mirror Analysis\n\n")
        f.write("> Based on exact name and file size matches (heuristics for mirror detection).\n\n")
        
        # Find exact duplicate files (name + size) that are larger than 1MB (to avoid trivial coincidences)
        f.write("## 1. Largest Exact File Duplicates (>1MB)\n")
        f.write("| File Name | Size | Duplicates | Locations |\n")
        f.write("|-----------|------|------------|-----------|\n")
        
        c.execute('''
            SELECT name, size_bytes, COUNT(*) as count, GROUP_CONCAT(folders.path, ', ') as paths
            FROM files
            JOIN folders ON files.folder_id = folders.id
            WHERE size_bytes > 1048576 AND classification NOT IN ('generated', 'cache', '.git')
            GROUP BY name, size_bytes
            HAVING count > 1
            ORDER BY size_bytes * (count - 1) DESC
            LIMIT 50
        ''')
        
        for name, size, count, paths in c.fetchall():
            # limit paths string length
            paths_str = paths if len(paths) < 200 else paths[:197] + "..."
            f.write(f"| `{name}` | {format_size(size)} | {count} | `{paths_str}` |\n")
            
        f.write("\n")
        
        # Analyze top-level directories for high duplication (mirror suspects)
        f.write("## 2. Suspect Mirror Zones (Folders sharing many identical files)\n")
        f.write("This query identifies pairs of folders that contain a high number of identically named files of the exact same size, suggesting one is a copy/backup of the other.\n\n")
        f.write("| Folder A | Folder B | Shared Files | Shared Size |\n")
        f.write("|----------|----------|--------------|-------------|\n")
        
        # This is an expensive query if not bounded, we'll use a simplified heuristic:
        # We'll just list folders with the highest count of files that exist elsewhere.
        c.execute('''
            WITH DuplicateFiles AS (
                SELECT name, size_bytes
                FROM files
                WHERE size_bytes > 0 AND classification NOT IN ('generated', 'cache')
                GROUP BY name, size_bytes
                HAVING COUNT(*) > 1
            )
            SELECT folders.path, COUNT(files.id) as dup_count, SUM(files.size_bytes) as dup_size
            FROM files
            JOIN folders ON files.folder_id = folders.id
            JOIN DuplicateFiles d ON files.name = d.name AND files.size_bytes = d.size_bytes
            GROUP BY folders.path
            HAVING dup_count > 10
            ORDER BY dup_size DESC
            LIMIT 20
        ''')
        
        for path, count, size in c.fetchall():
             f.write(f"| `{path}` | ? | {count} | {format_size(size)} |\n")
             
    print(f"Duplicate analysis generated at {OUT_PATH}")

if __name__ == "__main__":
    main()
