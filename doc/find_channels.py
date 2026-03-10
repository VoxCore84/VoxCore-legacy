import requests
import json

TOKEN = ""
headers = {
    'Authorization': TOKEN,
    'Content-Type': 'application/json'
}

def find_channels():
    # 1. Get Guilds
    print("Fetching server list...")
    resp = requests.get("https://discord.com/api/v9/users/@me/guilds", headers=headers)
    if resp.status_code != 200:
        print(f"Failed to fetch guilds: {resp.status_code} {resp.text}")
        return
        
    guilds = resp.json()
    target_guild = None
    
    for g in guilds:
        print(f"Found Server: {g['name']} (ID: {g['id']})")
        if "draconic" in g['name'].lower():
            target_guild = g
            
    if not target_guild:
        print("\nCould not find a server with 'Draconic' in the name.")
        # Fallback to taking the first guild if only 1, or just asking
        return
        
    print(f"\nTargeting Server: {target_guild['name']} ({target_guild['id']})")
    
    # 2. Get Channels
    print("Fetching channel list...")
    resp = requests.get(f"https://discord.com/api/v9/guilds/{target_guild['id']}/channels", headers=headers)
    if resp.status_code != 200:
        print(f"Failed to fetch channels: {resp.status_code} {resp.text}")
        return
        
    channels = resp.json()
    print("\n--- Channels in DraconicWoW ---")
    for c in channels:
        if c.get('type') == 0: # Text channel
            name = c.get('name', '')
            if 'support' in name or 'troubleshoot' in name or 'help' in name or 'getting' in name or 'start' in name:
                print(f"** MATCH: #{name} (ID: {c['id']})")
            else:
                print(f"#{name} (ID: {c['id']})")

if __name__ == "__main__":
    find_channels()
