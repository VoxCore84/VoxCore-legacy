import os
import re
import csv
from pathlib import Path
from collections import defaultdict

# Common roots to check. We don't want to scan the entire C drive, just inside VoxCore
DIRECTORIES_TO_SCAN = [
    "tools",
    "scripts",
    "config",
    "AI_Studio",
    ".agents"
]

EXCLUDED_DIRS = {
    ".git", ".vs", "build", "out", "bin", "obj", 
    "venv", ".venv", "node_modules", "logs", "cache", "wago", "ExtTools"
}

# Regex expansions based on Architect feedback:
# 1. Any C:\ or D:\ pathing
# 2. UNC network paths \\server\share
HARDCODED_PATTERN = re.compile(
    r'([a-zA-Z]:\\[^\s"\'>]+|\\\\[a-zA-Z0-9_-]+\\[^\s"\'>]+)', 
    re.IGNORECASE
)

OUTPUT_CSV = "hardcoded_path_inventory.csv"
OUTPUT_MD = "hardcoded_path_summary.md"

def get_project_root():
    """Simple relative resolution for the audit script itself"""
    current_dir = Path(__file__).resolve().parent
    for _ in range(5):
        if (current_dir / "AI_Studio").exists():
            return current_dir
        current_dir = current_dir.parent
    return Path.cwd()

def categorize_match(match_str):
    """Assigns an alias and confidence category to a raw literal match"""
    match_str_lower = match_str.lower()
    
    if "voxcore" in match_str_lower or "roleplaycore" in match_str_lower:
        return "VOXCORE_ROOT", "High", True, "Low"
    elif "excluded" in match_str_lower:
        return "EXCLUDED_ROOT", "High", True, "Low"
    elif "tongueandquill" in match_str_lower:
        return "TQ_ROOT", "Medium", True, "Medium"
    elif "packetlog" in match_str_lower:
        return "PACKETLOG_ROOT", "High", True, "Low"
    elif "microsoft visual studio" in match_str_lower:
        return "VISUAL_STUDIO_ROOT", "Medium", False, "High"
    elif match_str_lower.startswith(r"\\"):
        return "NETWORK_SHARE", "Low", False, "High"
    else:
        return "UNKNOWN_EXTERNAL", "Low", False, "High"

def scan_directory(root_dir, scan_dirs):
    inventory = []
    
    for relative_dir in scan_dirs:
        target_dir = root_dir / relative_dir
        if not target_dir.exists():
            print(f"Skipping {target_dir}, does not exist.")
            continue
            
        for root, dirs, files in os.walk(target_dir):
            # In-place modification to skip excluded directories
            dirs[:] = [d for d in dirs if d not in EXCLUDED_DIRS]
            
            for file in files:
                # Skip binary files, compiled assets, or git guts
                if file.endswith(('.exe', '.dll', '.bin', '.pdb', '.o', '.a', '.lib', '.csv', '.lock', '.log')):
                    continue
                    
                file_path = Path(root) / file
                
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        for line_number, line in enumerate(f, 1):
                            # Skip looking in comments if it's a python or bash file
                            if file.endswith(('.py', '.bat', '.sh')) and line.lstrip().startswith(('#', 'REM', '::')):
                                continue
                                
                            for match in HARDCODED_PATTERN.finditer(line):
                                match_str = match.group(0).rstrip('\\/')
                                
                                proposed_alias, confidence, auto_fixable, severity = categorize_match(match_str)
                                
                                inventory.append({
                                    'file_path': str(file_path.relative_to(root_dir)),
                                    'line_number': line_number,
                                    'hardcoded_literal': match_str,
                                    'match_category': 'Absolute Path', # Could be UNC vs Drive
                                    'proposed_alias': proposed_alias,
                                    'confidence': confidence,
                                    'auto_fixable': "Yes" if auto_fixable else "No",
                                    'manual_review_required': "No" if auto_fixable else "Yes",
                                    'severity_risk': severity,
                                    'context': line.strip()[:100] # trim long lines
                                })
                except UnicodeDecodeError:
                    pass 
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
                    
    return inventory

def write_inventory(inventory, log_dir):
    if not inventory:
        print("No hardcoded paths found.")
        return
        
    keys = [
        'file_path', 'line_number', 'hardcoded_literal', 'match_category', 
        'proposed_alias', 'confidence', 'auto_fixable', 'manual_review_required', 
        'severity_risk', 'context'
    ]
    
    csv_path = log_dir / OUTPUT_CSV
    md_path = log_dir / OUTPUT_MD
    
    # 1. Write CSV
    with open(csv_path, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=keys)
        writer.writeheader()
        writer.writerows(inventory)
        
    # 2. Write Markdown Summary
    file_counts = defaultdict(int)
    risk_counts = defaultdict(int)
    high_risk_files = set()
    
    for item in inventory:
        file_counts[item['file_path']] += 1
        risk_counts[item['severity_risk']] += 1
        if item['severity_risk'] == "High":
            high_risk_files.add(item['file_path'])
            
    with open(md_path, 'w', encoding='utf-8') as f:
        f.write("# Hardcoded Path Audit Summary\n\n")
        f.write(f"**Total Findings:** {len(inventory)}\n")
        f.write(f"**Files Affected:** {len(file_counts)}\n\n")
        
        f.write("## Risk Breakdown\n")
        for risk, count in risk_counts.items():
            f.write(f"- **{risk} Risk:** {count} instances\n")
            
        f.write("\n## High Risk Files Requiring Manual Review\n")
        if not high_risk_files:
            f.write("None detected.\n")
        else:
            for file in sorted(list(high_risk_files)):
                f.write(f"- `{file}`\n")
                
        f.write("\n## Top 10 Most Affected Files\n")
        top_files = sorted(file_counts.items(), key=lambda x: x[1], reverse=True)[:10]
        for file, count in top_files:
            f.write(f"- `{file}`: {count} hardcoded paths\n")
            
    print(f"Wrote {len(inventory)} findings to {csv_path}")
    print(f"Wrote summary report to {md_path}")

if __name__ == "__main__":
    root = get_project_root()
    log_dir = root / "logs" / "audit"
    log_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Scanning from root: {root}")
    findings = scan_directory(root, DIRECTORIES_TO_SCAN)
    write_inventory(findings, log_dir)
