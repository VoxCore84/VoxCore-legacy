from abc import ABC, abstractmethod

class BaseAdapter(ABC):
    """
    Abstract base class for all orchestrator job adapters.
    Adapters act as secure wrappers around standalone Triad scripts.
    They build commands, manage timeouts, capture stdout, and extract fingerprints.
    """
    def __init__(self, config_data, manifest, args):
        self.config_data = config_data
        self.manifest = manifest
        self.args = args
        self.job_cfg = config_data.get("jobs", {}).get(manifest["job_name"], {})
        
        # Pull timeout strictly from config file
        self.timeout_sec = self.job_cfg.get("timeout_sec", 1800)

    @abstractmethod
    def execute(self):
        """
        Executes the delegated command.
        Must return a tuple: (exit_code, fingerprint_dict_or_none)
        """
        pass
