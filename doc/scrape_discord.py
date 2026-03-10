import requests
import json
import time
import os
import re

# DO NOT COMMIT THE REAL TOKEN
TOKEN = "YOUR_DISCORD_TOKEN_HERE"
GUILD_ID = "1231835263861395487" # DraconicWoW
OUTPUT_DIR = "C:/Users/atayl/VoxCore/doc"

headers = {
    'Authorization': TOKEN,
    'Content-Type': 'application/json'
}

def get_channels():
    resp = requests.get(f"https://discord.com/api/v9/guilds/{GUILD_ID}/channels", headers=headers)
    if resp.status_code != 200:
        print(f"Failed to fetch channels: {resp.status_code} {resp.text}")
        return []
    
    channels = []
    for c in resp.json():
        if c.get('type') == 0: # Text channels
            # Sanitize name for filename
            clean_name = re.sub(r'[^a-zA-Z0-9_\-]', '', c.get('name', 'unknown'))
            channels.append((clean_name, c['id']))
            
    return channels

def fetch_messages(channel_id, limit=10000):
    messages = []
    last_message_id = None
    
    print(f"Fetching up to {limit} messages from channel {channel_id}...")
    
    while len(messages) < limit:
        url = f"https://discord.com/api/v9/channels/{channel_id}/messages?limit=100"
        if last_message_id:
            url += f"&before={last_message_id}"
            
        response = requests.get(url, headers=headers)
        
        if response.status_code == 429:
            retry_after = response.json().get('retry_after', 1)
            print(f"Rate limited. Waiting {retry_after} seconds...")
            time.sleep(retry_after)
            continue
        elif response.status_code == 403:
            print(f"Forbidden to read channel {channel_id}. Skipping.")
            break
        elif response.status_code != 200:
            print(f"Failed to fetch messages: {response.status_code} {response.text}")
            break
            
        data = response.json()
        if not data:
            break
            
        for msg in data:
            content = msg.get('content', '')
            author_name = msg.get('author', {}).get('username', 'Unknown')
            timestamp = msg.get('timestamp', '')
            
            messages.append({
                "content": content,
                "author": {"name": author_name},
                "timestamp": timestamp
            })
            
        last_message_id = data[-1]['id']
        print(f"Fetched {len(messages)} messages so far...")
        time.sleep(0.5) # rate limit buffer
        
    return messages

if __name__ == "__main__":
    channels = get_channels()
    print(f"Found {len(channels)} text channels in DraconicWoW server.")
    
    for name, channel_id in channels:
        output_file = os.path.join(OUTPUT_DIR, f"discord_export_{name}.json")
        print(f"\n--- Scraping #{name} ---")
        msgs = fetch_messages(channel_id, limit=10000)
        
        out_data = {"messages": msgs}
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(out_data, f, indent=2, ensure_ascii=False)
            
        print(f"Successfully saved {len(msgs)} messages to {output_file}")
