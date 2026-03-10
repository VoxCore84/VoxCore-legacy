import sys
import subprocess
from pathlib import Path
from adapters.base import BaseAdapter
from utils import VOXCORE_ROOT
from write_manifest import add_transition

class HeadlessBuildAdapter(BaseAdapter):
    def execute(self):
        build_script = VOXCORE_ROOT / "tools" / "build" / "build.py"
        
        cmd = [sys.executable, str(build_script)]
        
        if self.args.preset:
            cmd.extend(["--preset", self.args.preset])
        if self.args.target:
            cmd.extend(["--target", self.args.target])
        if self.args.configuration:
            cmd.extend(["--configuration", self.args.configuration])
        if getattr(self.args, 'dry_run', False):
            # This is different from orchestrator dry-run, which skips adapters entirely.
            # But just in case `build.py` has a dry-run flag someday.
            pass
            
        print(f"ORCHESTRATOR: Dispatching to Headless Build: {' '.join(cmd)}")
        
        try:
            # We enforce the timeout on the subprocess
            result = subprocess.run(cmd, cwd=str(VOXCORE_ROOT), timeout=self.timeout_sec)
            exit_code = result.returncode
            
            fingerprint = None
            if exit_code != 0:
                fingerprint = {
                    "exit_code": exit_code,
                    "signature": "Build failure. Check extract_compile_errors.py output."
                }
                
            return exit_code, fingerprint
            
        except subprocess.TimeoutExpired:
            print(f"ERROR: Build job timed out after {self.timeout_sec} seconds.")
            return 124, {"exit_code": 124, "signature": "Subprocess timeout"}
        except subprocess.CalledProcessError as e:
            return e.returncode, {"exit_code": e.returncode, "signature": "Process error"}
        except Exception as e:
            print(f"ERROR executing build adapter: {e}")
            return 1, {"exit_code": 1, "signature": f"Adapter crash: {str(e)}"}
