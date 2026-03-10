import json
import os
from pathlib import Path
from flask import Flask, render_template, request, redirect, url_for, flash

from brain_reader import parse_central_brain
from manifest_reader import get_latest_manifest, get_recent_manifests, get_manifest_by_id, get_orchestrator_config
from launch_job import delegate_to_orchestrator, VOXCORE_ROOT

app = Flask(__name__)
app.secret_key = "voxcore_local_command_center"

def get_cc_config():
    config_path = VOXCORE_ROOT / "config" / "command_center.json"
    if config_path.exists():
        with open(config_path, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

@app.route("/")
def index():
    cc_config = get_cc_config()
    brain_state = parse_central_brain()
    latest_run = get_latest_manifest()
    recent_runs = get_recent_manifests(limit=cc_config.get("recent_runs_limit", 10))
    enabled_jobs = cc_config.get("enabled_jobs", [])
    
    return render_template(
        "index.html", 
        brain=brain_state, 
        latest=latest_run, 
        recent=recent_runs,
        enabled_jobs=enabled_jobs
    )

@app.route("/jobs/<job_name>", methods=["GET", "POST"])
def launch_form(job_name):
    cc_config = get_cc_config()
    if job_name not in cc_config.get("enabled_jobs", []):
        flash(f"Job '{job_name}' is not enabled in Command Center config.", "danger")
        return redirect(url_for("index"))
        
    job_cfg = cc_config.get("jobs", {}).get(job_name, {})
    
    if request.method == "POST":
        success, msg = delegate_to_orchestrator(job_name, request.form)
        if success:
            flash(msg, "success")
        else:
            flash(msg, "danger")
        return redirect(url_for("index"))

    return render_template(f"job_{job_name}.html", job_name=job_name, cfg=job_cfg)

@app.route("/runs/<run_id>")
def run_detail(run_id):
    manifest = get_manifest_by_id(run_id)
    if not manifest:
        flash("Manifest not found.", "warning")
        return redirect(url_for("index"))
        
    poll_ms = get_cc_config().get("active_run_poll_ms", 3000)
    is_executing = manifest.get("status") == "executing"
    
    return render_template("run_detail.html", run=manifest, poll_ms=poll_ms, is_executing=is_executing)

if __name__ == "__main__":
    cc_config = get_cc_config()
    host = cc_config.get("host", "127.0.0.1")
    port = cc_config.get("port", 8765)
    
    print(f"Starting Triad Command Center on http://{host}:{port}")
    app.run(host=host, port=port, debug=False)
