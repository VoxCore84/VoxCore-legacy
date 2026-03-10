import sys
import subprocess
from pathlib import Path
from adapters.base import BaseAdapter
from utils import VOXCORE_ROOT

class ArchitectSpecAdapter(BaseAdapter):
    def execute(self):
        architect_script = VOXCORE_ROOT / "tools" / "api_architect" / "run_architect.py"
        
        cmd = [sys.executable, str(architect_script)]
        
        if self.args.intake:
            cmd.extend(["--intake", self.args.intake])
        if self.args.mode:
            cmd.extend(["--mode", self.args.mode])
        if self.args.force:
            cmd.append("--force")
        if hasattr(self.args, "model") and self.args.model:
            cmd.extend(["--model", getattr(self.args, "model")])
            
        # Optional flags that the Architect API Producer might expect, like dry-run simulation
        if getattr(self.args, "dry_run", False) and not self.args.mode:
            # This allows safe downstream API simulation without charging the key,
            # even if the user just ran the orchestrator with --dry-run
            pass

        print(f"ORCHESTRATOR: Dispatching to Architect API Producer: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(cmd, cwd=str(VOXCORE_ROOT), timeout=self.timeout_sec)
            exit_code = result.returncode
            
            fingerprint = None
            if exit_code != 0:
                fingerprint = {
                    "exit_code": exit_code,
                    "signature": "Architect producer failed. Likely 429 quota block or malformed context schema."
                }
            
            return exit_code, fingerprint
            
        except subprocess.TimeoutExpired:
            print(f"ERROR: Architect Spec job timed out after {self.timeout_sec} seconds.")
            return 124, {"exit_code": 124, "signature": "Subprocess timeout"}
        except Exception as e:
            print(f"ERROR executing architect adapter: {e}")
            return 1, {"exit_code": 1, "signature": f"Adapter crash: {str(e)}"}
