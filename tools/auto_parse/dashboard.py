"""HTML dashboard generator -- single-file dark-themed debug dashboard."""

from __future__ import annotations

import html
from collections import Counter
from datetime import datetime
from pathlib import Path
from typing import TYPE_CHECKING

from .parsers.base import Severity
from .writers import atomic_write

if TYPE_CHECKING:
    from .config import Config
    from .engine import SessionState


def generate_dashboard(state: SessionState, config: Config) -> None:
    """Write dashboard.html with current session state."""
    path = config.paths.output_dir / "dashboard.html"
    refresh = config.dashboard.refresh_seconds

    # Gather data
    total = len(state.all_entries)
    fatals = sum(1 for e in state.all_entries if e.severity >= Severity.FATAL)
    errors = sum(1 for e in state.all_entries if e.severity == Severity.ERROR)
    warns = sum(1 for e in state.all_entries if e.severity == Severity.WARN)
    gm_count = len(state.get_entries("GM"))
    crash_count = len(state.get_entries("Crash"))
    now = datetime.now().strftime("%H:%M:%S")

    # Timeline (last 100)
    timeline = state.get_timeline(limit=100)
    timeline_html = ""
    for e in reversed(timeline):
        sev_class = _sev_class(e.severity)
        text = _esc(e.text[:160])
        timeline_html += (
            f'<div class="tl-row {sev_class}">'
            f'<span class="ts">{e.timestamp}</span>'
            f'<span class="src">{e.source}</span>'
            f'<span class="txt">{text}</span>'
            f'</div>\n'
        )

    # DB error categories
    db_counts = state.get_category_counts("DBError")
    db_html = ""
    for cat, count in db_counts.most_common(20):
        db_html += f'<div class="db-row"><span class="cat">{_esc(cat)}</span><span class="cnt">{count:,}</span></div>\n'

    # GM command frequency
    gm_entries = state.get_entries("GM")
    verb_counts: Counter = Counter()
    for e in gm_entries:
        verb_counts[e.metadata.get("verb", "?")] += 1
    gm_html = ""
    for verb, count in verb_counts.most_common(15):
        gm_html += f'<div class="gm-row"><span class="verb">{_esc(verb)}</span><span class="cnt">{count}</span></div>\n'

    # Crashes
    crashes = state.get_entries("Crash")
    crash_html = ""
    for e in crashes:
        m = e.metadata
        crash_html += (
            f'<div class="crash-row">'
            f'<span class="ts">{m.get("date", "?")} {e.timestamp}</span>'
            f'<span class="txt">{_esc(e.text[:120])}</span>'
            f'</div>\n'
        )

    # Alerts (last 20)
    alerts = state.alerts[-20:]
    alert_html = ""
    for e in reversed(alerts):
        sev_class = _sev_class(e.severity)
        alert_html += (
            f'<div class="alert-row {sev_class}">'
            f'<span class="ts">{e.timestamp}</span>'
            f'<span class="txt">{_esc(e.text[:160])}</span>'
            f'</div>\n'
        )

    server_status = "RUNNING" if state.server_was_running else "STOPPED"
    server_class = "running" if state.server_was_running else "stopped"
    poll_ms = f"{state.last_poll_ms:.0f}" if state.last_poll_ms else "--"

    html = _TEMPLATE.format(
        refresh=refresh,
        now=now,
        server_status=server_status,
        server_class=server_class,
        uptime=state.uptime_str,
        poll_count=state.poll_count,
        poll_ms=poll_ms,
        total=total,
        fatals=fatals,
        errors=errors,
        warns=warns,
        gm_count=gm_count,
        crash_count=crash_count,
        timeline_html=timeline_html or '<div class="empty">No activity yet</div>',
        db_html=db_html or '<div class="empty">No DB errors</div>',
        gm_html=gm_html or '<div class="empty">No GM commands</div>',
        crash_html=crash_html or '<div class="empty">No crash dumps</div>',
        alert_html=alert_html or '<div class="empty">No alerts</div>',
    )

    atomic_write(path, html)


def _esc(s: str) -> str:
    return html.escape(s)


def _sev_class(sev: Severity) -> str:
    if sev >= Severity.FATAL:
        return "fatal"
    if sev >= Severity.ERROR:
        return "error"
    if sev >= Severity.WARN:
        return "warn"
    return "info"


_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="{refresh}">
<title>VoxCore Debug Dashboard</title>
<style>
:root {{
    --bg: #0d1117; --bg2: #161b22; --bg3: #21262d;
    --fg: #c9d1d9; --fg2: #8b949e; --border: #30363d;
    --red: #f85149; --orange: #d29922; --green: #3fb950;
    --blue: #58a6ff; --purple: #bc8cff;
}}
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{ font-family: 'Segoe UI', Consolas, monospace; background: var(--bg); color: var(--fg); padding: 12px; }}
h1 {{ font-size: 18px; color: var(--blue); margin-bottom: 4px; }}
.header {{ display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; background: var(--bg2); border: 1px solid var(--border); border-radius: 6px; margin-bottom: 10px; }}
.header .status {{ font-size: 14px; }}
.running {{ color: var(--green); }}
.stopped {{ color: var(--red); }}
.meta {{ color: var(--fg2); font-size: 12px; }}
.grid {{ display: grid; grid-template-columns: 260px 1fr; gap: 10px; }}
.panel {{ background: var(--bg2); border: 1px solid var(--border); border-radius: 6px; padding: 10px; }}
.panel h2 {{ font-size: 13px; color: var(--purple); margin-bottom: 8px; text-transform: uppercase; letter-spacing: 1px; }}
.badge {{ display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 12px; font-weight: 600; margin: 2px; }}
.badge.fatal {{ background: #8b1a1a; color: #ff7b72; }}
.badge.error {{ background: #6e3a00; color: #d29922; }}
.badge.warn {{ background: #3d3200; color: #e3b341; }}
.badge.info {{ background: #0d2137; color: var(--blue); }}
.sidebar {{ display: flex; flex-direction: column; gap: 10px; }}
.tl-row, .db-row, .gm-row, .crash-row, .alert-row {{
    font-size: 12px; padding: 3px 6px; border-bottom: 1px solid var(--border);
    display: flex; gap: 8px; font-family: Consolas, monospace;
}}
.tl-row .ts, .crash-row .ts, .alert-row .ts {{ color: var(--fg2); min-width: 60px; flex-shrink: 0; }}
.tl-row .src {{ color: var(--purple); min-width: 55px; flex-shrink: 0; }}
.tl-row .txt, .crash-row .txt, .alert-row .txt {{ flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }}
.db-row .cat {{ flex: 1; }}
.db-row .cnt, .gm-row .cnt {{ color: var(--orange); min-width: 50px; text-align: right; }}
.gm-row .verb {{ flex: 1; }}
.fatal {{ color: var(--red); }}
.error {{ color: var(--orange); }}
.warn {{ color: #e3b341; }}
.info {{ color: var(--fg); }}
.empty {{ color: var(--fg2); font-style: italic; font-size: 12px; padding: 8px; }}
.timeline-scroll {{ max-height: 60vh; overflow-y: auto; }}
.stats {{ display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 8px; }}
</style>
</head>
<body>
<div class="header">
    <div>
        <h1>VoxCore Debug Dashboard</h1>
        <span class="meta">Uptime: {uptime} &middot; Polls: {poll_count} &middot; Last poll: {poll_ms}ms &middot; Updated: {now}</span>
    </div>
    <div class="status {server_class}">&#9679; Server {server_status}</div>
</div>
<div class="grid">
    <div class="sidebar">
        <div class="panel">
            <h2>Summary</h2>
            <div class="stats">
                <span class="badge fatal">FATAL {fatals}</span>
                <span class="badge error">ERROR {errors}</span>
                <span class="badge warn">WARN {warns}</span>
                <span class="badge info">TOTAL {total}</span>
            </div>
            <div style="font-size:12px;color:var(--fg2)">GM commands: {gm_count}<br>Crash dumps: {crash_count}</div>
        </div>
        <div class="panel">
            <h2>Alerts</h2>
            {alert_html}
        </div>
        <div class="panel">
            <h2>Crashes</h2>
            {crash_html}
        </div>
        <div class="panel">
            <h2>GM Commands</h2>
            {gm_html}
        </div>
    </div>
    <div style="display:flex;flex-direction:column;gap:10px">
        <div class="panel" style="flex:1">
            <h2>Timeline (last 100)</h2>
            <div class="timeline-scroll">{timeline_html}</div>
        </div>
        <div class="panel">
            <h2>DB Errors (categorized)</h2>
            {db_html}
        </div>
    </div>
</div>
</body>
</html>"""
