import csv
from pathlib import Path

def categorize_file(filepath):
    """
    Returns a dictionary of classification metadata based on the file path.
    """
    path_lower = filepath.lower()
    
    # Defaults
    meta = {
        'runtime_executed': 'No',
        'generated_or_archive': 'No',
        'docs_reference_only': 'No',
        'intentional_example': 'No',
        'triage_class': 'runtime_defer', # New Phase 3 persistent state
        'canonical_source': 'Yes'
    }
    
    # 1. Archives & Generated Files
    if '4_archive\\discorddata' in path_lower or 'z_voxcore_session_logs' in path_lower:
        meta['generated_or_archive'] = 'Yes'
        meta['triage_class'] = 'archive_skip'
        return meta
        
    # 2. Docs & Prompts
    if path_lower.endswith('.md') or path_lower.endswith('.txt'):
        if 'paths.local.env.example' in path_lower:
            meta['intentional_example'] = 'Yes'
            meta['triage_class'] = 'intentional_example'
            return meta
            
        meta['docs_reference_only'] = 'Yes'
        meta['triage_class'] = 'docs_reference_only'
        # Treat ai studio docs as reference too now that Phase 2 E is deferred
        return meta

    # 3. Dedicated Known Duplicate Trees
    if 'ai_studio\\projects\\discordbot\\z_sourcecode' in path_lower:
        meta['canonical_source'] = 'No'
        meta['triage_class'] = 'archive_skip'
        meta['runtime_executed'] = 'Yes'
        return meta
        
    if 'ai_studio\\projects\\tongueandquill\\z_sourcecode' in path_lower:
        meta['canonical_source'] = 'No'
        meta['triage_class'] = 'archive_skip'
        meta['runtime_executed'] = 'Yes'
        return meta

    # 4. Phase 2C & Phase 2D specific residuals (The ones left are vetted False Positives or External)
    if 'tools\\shortcuts\\build_scripts_rel.bat' in path_lower:
        meta['runtime_executed'] = 'Yes'
        meta['triage_class'] = 'accepted_external_dependency'
        return meta

    false_positive_files = [
        'tools\\ai_studio\\orchestrator.py',
        'tools\\packet_tools\\packet_scope.py',
        'tools\\shortcuts\\create_shortcuts.py' # Uses wago path but is vetted dynamic
    ]
    if any(fp in path_lower for fp in false_positive_files):
        meta['runtime_executed'] = 'Yes'
        meta['triage_class'] = 'false_positive'
        return meta
        
    # 5. Other Executables -> Defer
    if path_lower.endswith('.py') or path_lower.endswith('.bat') or path_lower.endswith('.json'):
        meta['runtime_executed'] = 'Yes'
        meta['triage_class'] = 'runtime_defer'
            
    return meta

def main():
    repo_root = Path(r"C:\Users\atayl\VoxCore")
    input_csv = repo_root / "logs" / "audit" / "hardcoded_path_inventory.csv"
    output_csv = repo_root / "logs" / "audit" / "hardcoded_path_inventory_classified.csv"
    
    if not input_csv.exists():
        print(f"Error: Could not find input CSV at {input_csv}")
        return
        
    print(f"Reading from {input_csv}...")
    
    rows = []
    with open(input_csv, "r", newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        fieldnames = list(reader.fieldnames) if reader.fieldnames is not None else []
        
        # Ensure our target fields exist
        new_fields = [
            'runtime_executed', 
            'generated_or_archive', 
            'docs_reference_only', 
            'intentional_example', 
            'auto_fixable', # Override existing if needed
            'manual_review_required', # Override existing if needed
            'triage_class', 
            'canonical_source'
        ]
        
        for field in new_fields:
            if field not in fieldnames:
                fieldnames.append(field)
                
        for row in reader:
            filepath = row['file_path']
            meta = categorize_file(filepath)
            
            # Apply metadata
            row.update(meta)
            
            # Adjust auto_fixable and manual_review_required based on architect's guidance
            # If it's an archive or generated, we don't want to auto-fix it
            if meta['triage_class'] in ('archive_skip', 'docs_reference_only', 'intentional_example', 'false_positive', 'accepted_external_dependency'):
                row['auto_fixable'] = 'No'
                
            rows.append(row)
            
    print(f"Writing classified data to {output_csv}...")
    with open(output_csv, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
        
    print(f"Successfully wrote {len(rows)} classified finding rows.")

if __name__ == "__main__":
    main()
