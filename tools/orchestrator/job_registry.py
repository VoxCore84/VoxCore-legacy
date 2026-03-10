import importlib
import traceback

def get_approved_jobs(config_data):
    """Returns a list of approved routing targets from the orchestrator JSON."""
    return list(config_data.get("jobs", {}).keys())

def resolve_adapter(job_name, config_data):
    """
    Dynamically loads the adapter class defined for the given job.
    Relies entirely on the job registry within orchestrator.json.
    """
    job_cfg = config_data.get("jobs", {}).get(job_name)
    if not job_cfg:
        return None
        
    adapter_name = job_cfg.get("adapter")
    if not adapter_name:
        return None
        
    try:
        module = importlib.import_module(f"adapters.{adapter_name}")
        class_name = "".join(x.capitalize() for x in adapter_name.split("_")) + "Adapter"
        return getattr(module, class_name)
    except Exception as e:
        print(f"ERROR: Failed to load adapter {adapter_name} for job {job_name}: {e}")
        traceback.print_exc()
        return None
