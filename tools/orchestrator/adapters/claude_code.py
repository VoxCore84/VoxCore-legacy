import sys
import os
import subprocess
from pathlib import Path
from adapters.base import BaseAdapter
from utils import VOXCORE_ROOT

class ClaudeCodeAdapter(BaseAdapter):
    """
    Safely bridges the Triad Orchestrator to the 'claude' CLI implementer hook.
    """
    
    def execute(self):
        spec_file = getattr(self.args, "spec_file", None)
        is_dry_run = getattr(self.args, "dry_run", False)
        
        if not spec_file:
            print("ERROR: Missing --spec_file argument for Claude Implementer.")
            return 1, {"exit_code": 1, "signature": "Input Error: Missing --spec_file"}
            
        spec_path = VOXCORE_ROOT / spec_file
        if not spec_path.exists():
            print(f"ERROR: Spec file not found: {spec_path}")
            return 1, {"exit_code": 1, "signature": "Path Error: Spec file not found"}

        prompt = f"Load and implement the requirements strictly defined in {spec_path}. Use your tooling to execute the tasks independently."

        if is_dry_run:
            print(f"DRY-RUN: Would invoke: claude -p '{prompt}'")
            return 0, None
            
        # Determine universal executable path depending on OS installation
        claude_cmd = "claude.cmd" if os.name == "nt" else "claude"
        cmd = [claude_cmd, "-p", prompt]
        
        print(f"PIPELINE BRIDGE: Spawning Implementer -> {' '.join(cmd)}")
        
        try:
            # We explicitly do NOT use shell=True per architectural safety constraints.
            # subprocess.run automatically waits for completion and handles timeouts cleanly.
            result = subprocess.run(
                cmd,
                cwd=str(VOXCORE_ROOT),
                text=True,
                capture_output=True,
                timeout=self.timeout_sec
            )
            
            # Pipe outputs to the orchestrator stdout so they show in logs
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr)
            
            exit_code = result.returncode
            fingerprint = None
            
            if exit_code != 0:
                stdout_tail = "\n".join(result.stdout.splitlines()[-20:]) if result.stdout else ""
                stderr_tail = "\n".join(result.stderr.splitlines()[-20:]) if result.stderr else ""
                fingerprint = {
                    "exit_code": exit_code,
                    "stdout_tail": stdout_tail,
                    "stderr_tail": stderr_tail,
                    "signature": "Claude subprocess returned non-zero."
                }
                
            return exit_code, fingerprint
            
        except subprocess.TimeoutExpired:
            print(f"ERROR: Claude Implementer job timed out after {self.timeout_sec} seconds.")
            return 124, {"exit_code": 124, "signature": "Subprocess timeout"}
        except FileNotFoundError:
            msg = f"Dependency Error: '{claude_cmd}' not found in PATH."
            print(f"ERROR: {msg}")
            return 1, {"exit_code": 1, "signature": msg}
        except Exception as e:
            print(f"ERROR executing claude adapter: {e}")
            return 1, {"exit_code": 1, "signature": f"Subprocess Crash: {str(e)}"}
