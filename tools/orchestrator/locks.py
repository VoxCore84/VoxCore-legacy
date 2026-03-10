import os
import json
import time
import getpass
from pathlib import Path
from utils import VOXCORE_ROOT

class OrchestratorLockPathException(Exception):
    pass

class OrchestratorLock:
    def __init__(self, lock_file_rel_path, run_id, job_name):
        self.lock_path = VOXCORE_ROOT / lock_file_rel_path
        self.run_id = run_id
        self.job_name = job_name
        self._acquired = False
        
        # Ensure lock directory exists
        self.lock_path.parent.mkdir(parents=True, exist_ok=True)

    def acquire(self, force=False):
        if self.lock_path.exists():
            if force:
                print(f"WARNING: Forcing lock break on {self.lock_path}...")
                try:
                    self.lock_path.unlink()
                except Exception as e:
                    print(f"ERROR: Failed to force break lock: {e}")
                    return False
            else:
                try:
                    with open(self.lock_path, "r", encoding="utf-8") as f:
                        lock_data = json.load(f)
                    print(f"ERROR: Orchestrator is currently locked by another run.")
                    print(f"Lock Data: {json.dumps(lock_data, indent=2)}")
                    print("Wait for the existing run to finish, or use --clear-stale-lock if confident it is dead.")
                except Exception:
                    print(f"ERROR: Orchestrator lock file exists but is unreadable at {self.lock_path}.")
                return False

        # Write new lock
        lock_data = {
            "run_id": self.run_id,
            "job_name": self.job_name,
            "pid": os.getpid(),
            "user": getpass.getuser(),
            "acquired_at": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
        }
        
        try:
            with open(self.lock_path, "w", encoding="utf-8") as f:
                json.dump(lock_data, f, indent=2)
            self._acquired = True
            return True
        except Exception as e:
            print(f"ERROR: Failed to write lock file: {e}")
            return False

    def release(self):
        if self._acquired and self.lock_path.exists():
            try:
                self.lock_path.unlink()
                self._acquired = False
                return True
            except Exception as e:
                print(f"ERROR: Failed to release lock file: {e}")
                return False
        return True
