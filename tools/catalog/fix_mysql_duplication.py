import os
import shutil
import subprocess
from pathlib import Path

VOXCORE_ROOT = Path(r"C:\Users\atayl\VoxCore")
OUT_UNISERVERZ = VOXCORE_ROOT / r"out\build\x64-RelWithDebInfo\bin\RelWithDebInfo\UniServerZ"
RUNTIME_UNISERVERZ = VOXCORE_ROOT / r"runtime\UniServerZ"

def run_cmd(cmd, ignore_errors=False):
    print(f"Running: {cmd}")
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        if not ignore_errors:
            print(f"ERROR: {e}")
            raise

def main():
    print("--- Starting MySQL UniServerZ Deduplication Migration ---")
    
    print("Step 1: Stopping MySQL cautiously...")
    run_cmd("taskkill /IM mysqld_z.exe /F", ignore_errors=True)
    
    # Check if OUT_UNISERVERZ already junction
    is_junction = False
    if OUT_UNISERVERZ.exists():
        try:
            subprocess.run(f'fsutil reparsepoint query "{OUT_UNISERVERZ}"', shell=True, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            is_junction = True
        except subprocess.CalledProcessError:
            pass
            
    if is_junction:
        print("Output UniServerZ is already a junction. Skipping migration.")
        return

    print("Output UniServerZ is a real directory.")
    if not OUT_UNISERVERZ.exists():
        print(f"Source {OUT_UNISERVERZ} not found. Aborting.")
        return

    print(f"Step 2: Removing stale runtime copy at {RUNTIME_UNISERVERZ}...")
    if RUNTIME_UNISERVERZ.exists():
        shutil.rmtree(RUNTIME_UNISERVERZ)
    
    print(f"Step 3: Moving active data to runtime canonical location...")
    print(f"  From: {OUT_UNISERVERZ}")
    print(f"  To:   {RUNTIME_UNISERVERZ}")
    shutil.move(str(OUT_UNISERVERZ), str(RUNTIME_UNISERVERZ))
    
    print("Step 4: Creating junction...")
    run_cmd(f'mklink /J "{OUT_UNISERVERZ}" "{RUNTIME_UNISERVERZ}"')

    print("--- Migration successfully completed ---")

if __name__ == "__main__":
    main()
