import sys

# Simulation of the Lua logic being added to BestiaryForge

TYPE_NPC = 0x00000800
HOSTILE_FLAG = 0x00000040
TYPE_PLAYER = 0x00000400

passed = 0
failed = 0

def _bitband(a, b):
    try:
        return a & b
    except:
        return 0

def extract_creature_entry(guid):
    if not guid: return None
    parts = guid.split("-")
    if len(parts) >= 6 and parts[0] in ["Creature", "Vehicle"]:
        try:
            return int(parts[5])
        except:
            return None
    return None

def on_combat_log_event(*args, api_fallback=None):
    # Simulate args processing
    if len(args) == 1 and isinstance(args[0], list):
        args = args[0]
        
    ts = subevent = hideCaster = None
    sourceGUID = sourceName = sourceFlags = sourceRaidFlags = None
    destGUID = destName = destFlags = destRaidFlags = None
    spellId = spellName = spellSchool = None
    
    if len(args) >= 2:
        try:
            ts = args[0]
            subevent = args[1]
            hideCaster = args[2]
            sourceGUID = args[3]
            sourceName = args[4]
            sourceFlags = args[5]
            sourceRaidFlags = args[6]
            destGUID = args[7]
            destName = args[8]
            destFlags = args[9]
            destRaidFlags = args[10]
            spellId = args[11]
            spellName = args[12]
            spellSchool = args[13]
        except IndexError:
            pass  # Ignore unpacking errors on short lists just like lua unpack
    elif len(args) == 0:
        if api_fallback:
            try:
                res = api_fallback()
                ts = res[0]
                subevent = res[1]
                hideCaster = res[2]
                sourceGUID = res[3]
                sourceName = res[4]
                sourceFlags = res[5]
                sourceRaidFlags = res[6]
                destGUID = res[7]
                destName = res[8]
                destFlags = res[9]
                destRaidFlags = res[10]
                spellId = res[11]
                spellName = res[12]
                spellSchool = res[13]
            except Exception:
                pass
        else:
            return "NO_PAYLOAD_AND_NO_API"
            
    if not subevent: return "NIL_SUBEVENT"
    if not spellId or spellId == 0: return "NIL_SPELL"
    if sourceFlags is None or not isinstance(sourceFlags, int): return "NIL_SOURCE_FLAGS"
    
    # Types checking 
    if _bitband(sourceFlags, TYPE_PLAYER) != 0: return "IS_PLAYER"
    if _bitband(sourceFlags, TYPE_NPC) == 0: return "NOT_NPC"
    if _bitband(sourceFlags, HOSTILE_FLAG) == 0: return "NOT_HOSTILE"
    
    creatureEntry = extract_creature_entry(sourceGUID)
    if not creatureEntry: return "BAD_GUID"
    
    return "SUCCESS_PROCESSED"

def run_test(name, expected, *args, api_fallback=None):
    global passed, failed
    res = on_combat_log_event(*args, api_fallback=api_fallback)
    if res == expected:
        print(f"[PASS] {name}")
        passed += 1
    else:
        print(f"[FAIL] {name} (Expected: {expected}, Got: {res})")
        failed += 1

print("--- Running BestiaryForge Python Adversarial Tests ---")

run_test("Empty args, no API", "NO_PAYLOAD_AND_NO_API")
run_test("Missing data (too short)", "NIL_SUBEVENT", 123456)
run_test("Valid payload (Player cast)", "IS_PLAYER", 123456, "SPELL_CAST_SUCCESS", False, "Player-123-456", "PlayerOne", TYPE_PLAYER, 0, "Creature-0-0-0-0-999", "Target", 0, 0, 1337, "Fireball", 0)

valid_npc_flags = TYPE_NPC | HOSTILE_FLAG
run_test("Valid hostile NPC payload in varargs", "SUCCESS_PROCESSED", 123456, "SPELL_CAST_SUCCESS", False, "Creature-0-0-0-0-12345", "Dragon", valid_npc_flags, 0, "Player-123-456", "Target", 0, 0, 1337, "FireBreath", 4)

run_test("Valid hostile NPC payload in TABLE", "SUCCESS_PROCESSED", [123456, "SPELL_CAST_SUCCESS", False, "Creature-0-0-0-0-99999", "Ogre", valid_npc_flags, 0, "Player-123-456", "Target", 0, 0, 999, "Smash", 1])

def mock_api():
    return (123456, "SPELL_CAST_SUCCESS", False, "Creature-0-0-0-0-11111", "Goblin", valid_npc_flags, 0, "Player-123-456", "Target", 0, 0, 555, "Stab", 1)
run_test("Empty args, API fallback exists", "SUCCESS_PROCESSED", api_fallback=mock_api)

run_test("Malformed GUID string", "BAD_GUID", 123456, "SPELL_CAST_SUCCESS", False, "GARBAGE-STRING", "Glitch", valid_npc_flags, 0, "Player-123-456", "Target", 0, 0, 1337, "GlitchBolt", 0)

run_test("Garbage types in payload (Flags=string)", "NIL_SOURCE_FLAGS", [123456, "SPELL_CAST_SUCCESS", False, "Creature-0-0-0-0-99999", "Ogre", "BAD_FLAG", 0, "Player-123-456", "Target", 0, 0, 999, "Smash", 1])

print("-" * 47)
print(f"Tests complete. Passed: {passed}, Failed: {failed}")
if failed > 0: sys.exit(1)
