import pymysql
import json

DB_PASS = "trinity" # Default uniserver paswword
OUTPUT_FILE = "C:/Users/atayl/VoxCore/tools/discord_bot/data/gm_commands.json"

def extract_commands():
    print("Connecting to local TrinityCore database (auth)...")
    try:
        connection = pymysql.connect(
            host='127.0.0.1',
            user='trinity',
            password=DB_PASS,
            database='auth',
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
    except Exception as e:
        print(f"Failed to connect to MySQL: {e}")
        return

    commands = []
    
    try:
        with connection.cursor() as cursor:
            # The 'command' table in auth holds all GM commands in TC
            sql = "SELECT name, help FROM command ORDER BY name ASC"
            cursor.execute(sql)
            result = cursor.fetchall()
            
            for row in result:
                commands.append({
                    "name": "." + row['name'],
                    "syntax": "", # Syntax is often baked into the help text
                    "description": row['help'].replace('\r', '').replace('\n', ' ')
                })
                
    finally:
        connection.close()

    print(f"Extracted {len(commands)} GM Commands from database.")
    
    if commands:
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            json.dump({"gm_commands": commands}, f, indent=2, ensure_ascii=False)
        print(f"Successfully saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    extract_commands()
