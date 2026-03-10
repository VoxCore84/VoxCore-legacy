import os
import sqlite3
import time
from pathlib import Path
import json

VOXCORE_ROOT = Path("C:/Users/atayl/VoxCore")
DB_PATH = VOXCORE_ROOT / "catalog" / "db" / "voxcore_catalog.sqlite"
CONFIG_PATH = VOXCORE_ROOT / "config" / "catalog.json"

def init_db():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    
    c.executescript("""
        CREATE TABLE IF NOT EXISTS folders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT UNIQUE NOT NULL,
            parent_id INTEGER,
            ignored BOOLEAN DEFAULT 0
        );
        
        CREATE TABLE IF NOT EXISTS files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER,
            name TEXT NOT NULL,
            extension TEXT,
            size_bytes INTEGER,
            mtime REAL,
            classification TEXT,
            FOREIGN KEY(folder_id) REFERENCES folders(id),
            UNIQUE(folder_id, name)
        );
        
        CREATE INDEX IF NOT EXISTS idx_folder_path ON folders(path);
        CREATE INDEX IF NOT EXISTS idx_file_ext ON files(extension);
        CREATE INDEX IF NOT EXISTS idx_file_class ON files(classification);
    """)
    conn.commit()
    return conn

def load_config():
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH, 'r') as f:
            return json.load(f)
    print(f"Warning: Config not found at {CONFIG_PATH}, using defaults.")
    return {"scan_rules": {"ignore_completely": [".git"]}, "taxonomy": {}}

def get_classification(config, name, extension, rel_path):
    tax = config.get("taxonomy", {})
    
    # Check paths first
    path_parts = Path(rel_path).parts
    for class_name, rules in tax.items():
        if "paths" in rules:
            if any(p in path_parts for p in rules["paths"]):
                return class_name
                
    # Then extensions
    if extension:
        for class_name, rules in tax.items():
            if "extensions" in rules and extension in rules["extensions"]:
                return class_name
                
    return "unclassified"

def scan_repository(conn, config):
    print(f"Starting Enterprise Census on {VOXCORE_ROOT}...")
    start_time = time.time()
    
    ignore_rules = set(config.get("scan_rules", {}).get("ignore_completely", []))
    
    c = conn.cursor()
    c.execute("DELETE FROM files")
    c.execute("DELETE FROM folders")
    conn.commit()
    
    folders_to_insert = []
    files_to_insert = []
    
    folder_cache = {} # path -> id
    next_folder_id = 1
    
    # Insert root folder
    folders_to_insert.append((next_folder_id, ".", None, False))
    folder_cache["."] = next_folder_id
    next_folder_id += 1
    
    files_processed = 0
    dirs_processed = 0
    
    for dirpath, dirnames, filenames in os.walk(VOXCORE_ROOT):
        rel_dir = os.path.relpath(dirpath, VOXCORE_ROOT)
        if rel_dir == ".": rel_dir = ""
        
        # Determine if we should ignore this folder based on rules
        path_parts = Path(rel_dir).parts if rel_dir else []
        is_ignored = any(p in ignore_rules for p in path_parts)
        
        # Don't prune the walk so we can still catalog that the ignored folder exists
        
        # Ensure current folder is in cache
        curr_folder_path = rel_dir if rel_dir else "."
        if curr_folder_path not in folder_cache:
            parent_path = str(Path(curr_folder_path).parent)
            parent_id = folder_cache.get(parent_path, 1)
            
            folders_to_insert.append((next_folder_id, curr_folder_path, parent_id, is_ignored))
            folder_cache[curr_folder_path] = next_folder_id
            curr_folder_id = next_folder_id
            next_folder_id += 1
        else:
            curr_folder_id = folder_cache[curr_folder_path]
            
        dirs_processed += 1
        
        # if directory itself is ignored, don't catalog its files, just its structure
        if is_ignored:
            continue
            
        for f in filenames:
            fp = os.path.join(dirpath, f)
            try:
                stat = os.stat(fp)
                ext = Path(f).suffix.lower()
                cls = get_classification(config, f, ext, rel_dir)
                
                files_to_insert.append((
                    curr_folder_id,
                    f,
                    ext,
                    stat.st_size,
                    stat.st_mtime,
                    cls
                ))
                files_processed += 1
                
                if files_processed % 100000 == 0:
                    print(f"  Indexed {files_processed} files...")
            except OSError:
                pass

    print(f"Committing {dirs_processed} folders and {files_processed} files to SQLite...")
    
    c.executemany("INSERT INTO folders (id, path, parent_id, ignored) VALUES (?, ?, ?, ?)", folders_to_insert)
    c.executemany("INSERT INTO files (folder_id, name, extension, size_bytes, mtime, classification) VALUES (?, ?, ?, ?, ?, ?)", files_to_insert)
    
    conn.commit()
    
    elapsed = time.time() - start_time
    print(f"Census complete in {elapsed:.2f} seconds.")

def emit_working_sets(conn):
    print("Exporting working sets...")
    export_dir = VOXCORE_ROOT / "catalog" / "exports"
    export_dir.mkdir(parents=True, exist_ok=True)
    
    c = conn.cursor()
    c.execute('''
        SELECT classification, COUNT(*), SUM(size_bytes) 
        FROM files 
        GROUP BY classification
    ''')
    
    summary = c.fetchall()
    
    with open(export_dir / "classification_summary.txt", "w") as f:
        f.write("VoxCore File Classification Summary:\n")
        f.write("-" * 50 + "\n")
        for cls, count, size in summary:
            size_mb = size / (1024*1024) if size else 0
            f.write(f"{cls:<20} | {count:>10} files | {size_mb:>10.2f} MB\n")
            print(f"  {cls:<20}: {count} files")

if __name__ == "__main__":
    cfg = load_config()
    db = init_db()
    scan_repository(db, cfg)
    emit_working_sets(db)
    db.close()
