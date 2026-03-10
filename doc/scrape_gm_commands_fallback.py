import urllib.request
import json
import re

# We will scrape the Command table directly from the TrinityCore master branch C++ source code
URL = "https://raw.githubusercontent.com/TrinityCore/TrinityCore/master/src/server/scripts/Commands/cs_tele.cpp"
# Wait, actually the commands are spread across many cpp files.
# Let's just download a pre-compiled JSON of TrinityCore commands from a reliable source or use a quick static list for now
# since the wiki is down and the local DB is off.

OUTPUT_FILE = "C:/Users/atayl/VoxCore/tools/discord_bot/data/gm_commands.json"

# A basic fallback list of the most common GM Commands for DraconicBot
FALLBACK_COMMANDS = [
    {
        "name": ".additem",
        "syntax": ".additem [itemId] [amount]",
        "description": "Adds the specified amount of the item to your inventory."
    },
    {
        "name": ".tele",
        "syntax": ".tele [location]",
        "description": "Teleports you to the specified location (e.g. .tele stormwind)."
    },
    {
        "name": ".npc add",
        "syntax": ".npc add [creatureId]",
        "description": "Spawns a creature at your exact location permanently."
    },
    {
        "name": ".learn",
        "syntax": ".learn [spellId]",
        "description": "Teaches your character the specified spell."
    },
    {
        "name": ".levelup",
        "syntax": ".levelup [levels]",
        "description": "Increases your character's level by the specified amount."
    },
    {
        "name": ".modify speed",
        "syntax": ".modify speed [1-10]",
        "description": "Changes your character's run speed."
    },
    {
        "name": ".server info",
        "syntax": ".server info",
        "description": "Displays the connected players and server uptime."
    },
    {
        "name": ".go creature",
        "syntax": ".go creature [creatureId]",
        "description": "Teleports your character to the specified creature."
    },
    {
        "name": ".go object",
        "syntax": ".go object [objectId]",
        "description": "Teleports your character to the specified gameobject."
    },
    {
        "name": ".lookup item",
        "syntax": ".lookup item [name]",
        "description": "Searches for an item by name and returns its ID."
    }
]

def generate_fallback():
    print(f"Generating fallback GM Commands List...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump({"gm_commands": FALLBACK_COMMANDS}, f, indent=2, ensure_ascii=False)
    print(f"Successfully saved {len(FALLBACK_COMMANDS)} commands to {OUTPUT_FILE}")

if __name__ == "__main__":
    generate_fallback()
