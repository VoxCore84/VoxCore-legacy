import urllib.request
import json
import re

URL = "https://raw.githubusercontent.com/wiki/TrinityCore/TrinityCore/GM-Commands.md"
OUTPUT_FILE = "C:/Users/atayl/VoxCore/tools/discord_bot/data/gm_commands.json"

def scrape_commands():
    print(f"Fetching GM Commands from {URL}...")
    try:
        req = urllib.request.Request(URL, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            markdown = response.read().decode('utf-8')
    except Exception as e:
        print(f"Failed to fetch wiki page: {e}")
        return

    commands = []
    
    # Parse markdown tables. Format: | Name | Syntax | Description |
    # Or sometimes they are headers or list items.
    
    lines = markdown.split('\n')
    in_table = False
    
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Check if line is a table row
        if line.startswith('|'):
            if '---' in line:
                continue # Skip separator row
                
            parts = [p.strip() for p in line.split('|') if p.strip()]
            
            # Usually tables have Name (or Command), Syntax, Description
            if len(parts) >= 2:
                # Sometimes the first part is just "Name", we skip headers
                if parts[0].lower() in ['name', 'command', 'commands']:
                    continue
                    
                cmd_name = parts[0].replace('`', '')
                syntax = parts[1].replace('`', '') if len(parts) > 1 else ""
                desc = parts[2] if len(parts) > 2 else ""
                
                # Clean up markdown links in description
                desc = re.sub(r'\[(.*?)\]\(.*?\)', r'\1', desc)
                
                if cmd_name.startswith('.'):
                    commands.append({
                        "name": cmd_name,
                        "syntax": syntax,
                        "description": desc
                    })
    
    print(f"Parsed {len(commands)} GM Commands.")
    
    if commands:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump({"gm_commands": commands}, f, indent=2, ensure_ascii=False)
        print(f"Successfully saved to {OUTPUT_FILE}")
    else:
        print("No commands found. The markdown format might have changed or we are parsing the wrong URL.")

if __name__ == "__main__":
    scrape_commands()
