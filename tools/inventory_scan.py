import os
from pathlib import Path

def get_dir_size(start_path):
    total_size = 0
    total_files = 0
    
    # Ignore these massive or artifact directories completely
    ignored = {'.git', 'build', 'dep', '.vs', '.cache', 'out'}
    
    try:
        for dirpath, dirnames, filenames in os.walk(start_path):
            dirnames[:] = [d for d in dirnames if d not in ignored]
            
            for f in filenames:
                fp = os.path.join(dirpath, f)
                if not os.path.islink(fp):
                    try:
                        total_size += os.path.getsize(fp)
                        total_files += 1
                    except OSError:
                        pass
    except OSError:
        pass
        
    return total_size, total_files

def main():
    root = Path('c:/Users/atayl/VoxCore')
    print("Scanning VoxCore Directory Structure...")
    print(f"{'Directory':<30} | {'Files':<10} | {'Size (MB)':<10}")
    print("-" * 55)
    
    total_size_mb = 0
    total_files_all = 0
    
    for item in sorted(os.listdir(root)):
        path = root / item
        if path.is_dir() and item not in {'.git', 'build', 'dep', '.vs', '.cache', 'out'}:
            size, count = get_dir_size(str(path))
            size_mb = size / (1024 * 1024)
            print(f"{item:<30} | {count:<10} | {size_mb:<10.2f}")
            total_size_mb += size_mb
            total_files_all += count
            
    print("-" * 55)
    print(f"{'TOTAL (Filtered)':<30} | {total_files_all:<10} | {total_size_mb:<10.2f}")

if __name__ == '__main__':
    main()
