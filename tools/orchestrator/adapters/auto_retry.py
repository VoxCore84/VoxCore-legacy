import time
import copy
from pathlib import Path
from adapters.base import BaseAdapter
from adapters.claude_code import ClaudeCodeAdapter
from adapters.headless_build import HeadlessBuildAdapter
from write_manifest import add_transition
from utils import VOXCORE_ROOT

class AutoRetryAdapter(BaseAdapter):
    """
    Orchestrates the Triad Feedback Loop natively.
    Runs Claude, then runs the Build. If the build fails, reads the errors
    and generates a new Architect Spec for Claude to fix it, recursively.
    """
    
    def execute(self):
        max_retries = 3
        current_attempt = 1
        spec_file = getattr(self.args, "spec_file", None)
        is_dry_run = getattr(self.args, "dry_run", False)
        
        while current_attempt <= max_retries:
            print(f"\n=======================================================")
            print(f"=== AUTO-RETRY LOOP: Attempt {current_attempt}/{max_retries} ===")
            print(f"=======================================================")
            
            # Step 1: Run Claude
            print(f"-> Phase 1: Dispatching to Claude (Spec: {spec_file})")
            claude_args = copy.copy(self.args)
            claude_args.spec_file = spec_file
            
            claude_adapter = ClaudeCodeAdapter(self.config_data, self.manifest, claude_args)
            c_exit, c_fingerprint = claude_adapter.execute()
            
            if c_exit != 0:
                print(f"ERROR: Claude Implementer failed with exit code {c_exit}. Aborting auto-retry.")
                return c_exit, c_fingerprint
                
            # Step 2: Run Build
            print("\n-> Phase 2: Dispatching to Headless Build")
            build_args = copy.copy(self.args)
            # The UI doesn't expose Target or Config for auto-retry yet, but it can pass presets
            
            build_adapter = HeadlessBuildAdapter(self.config_data, self.manifest, build_args)
            b_exit, b_fingerprint = build_adapter.execute()
            
            if b_exit == 0:
                print("\nSUCCESS: Build completed with 0 exit code! Triad Feedback Loop Complete.")
                return 0, None
                
            print(f"\nBUILD FAILED: Exit code {b_exit}. Checking for compile errors...")
            
            if is_dry_run:
                print("DRY-RUN: Halting loop iteration on failed build.")
                return b_exit, b_fingerprint
            
            # Step 3: Parse errors and create new spec
            compile_errors_path = VOXCORE_ROOT / "AI_Studio" / "Reports" / "Audits" / "latest_compile_errors.md"
            if not compile_errors_path.exists():
                print(f"CRITICAL: Build failed but no compile errors file was found at {compile_errors_path}! Aborting loop.")
                return b_exit, b_fingerprint
                
            # Read the errors (limit to prevent massive context explosion)
            error_text = compile_errors_path.read_text(encoding='utf-8', errors='replace')
            if len(error_text) > 20000:
                error_text = error_text[:20000] + "\n... [TRUNCATED - EXCEEDED 20KB] ..."
                
            # Create a localized fix-prompt spec
            timestamp = int(time.time())
            new_spec_rel = f"AI_Studio/1_Inbox/auto_fix_compile_error_{timestamp}.md"
            new_spec_abs = VOXCORE_ROOT / new_spec_rel
            
            prompt_content = f"""# Triad Feedback Loop — Auto-Retry Compile Fix Request

The previous implementation failed to compile. The Orchestrator caught a non-zero exit code and extracted the following error trace:

## Compile Log Extract
```text
{error_text}
```

## Instructions
1. Analyze the compile errors above.
2. Locate the source files mentioned in the VoxCore repository.
3. Fix the syntax/linking errors directly in the C++ or CMake code.
4. Do NOT attempt to trigger another build yourself. The Orchestrator will automatically rebuild once you exit.
5. Exit cleanly when you have saved the code fix.
"""
            new_spec_abs.parent.mkdir(parents=True, exist_ok=True)
            new_spec_abs.write_text(prompt_content, encoding='utf-8')
            
            print(f"-> Generated iterative fix spec at {new_spec_rel}")
            spec_file = new_spec_rel
            current_attempt += 1
            
        print(f"\nERROR: Max retries ({max_retries}) exhausted without a successful build.")
        return 1, {"exit_code": 1, "signature": "Max retries exhausted"}
