#include "Chat.h"
#include "ChatCommand.h"
#include "Creature.h"
#include "DatabaseEnv.h"
#include "GameObject.h"
#include "Map.h"
#include "ObjectMgr.h"
#include "PhasingHandler.h"
#include "Player.h"
#include "RBAC.h"
#include "ScriptMgr.h"
#include "TemporarySummon.h"

#include <cmath>
#include <unordered_map>

using namespace Trinity::ChatCommands;

// ---------------------------------------------------------------------------
// VoxPlacer — GM interactive placement tool
//
// Workflow:
//   1. .vp start <entry>   — spawn a temp creature preview at your feet
//      .vp gob <entry>     — spawn a temp gameobject preview
//      .vp clone            — clone whatever you have targeted
//   2. .vp here / .vp nudge / .vp rotate / .vp scale — adjust placement
//   3. .vp confirm          — persist to DB
//      .vp cancel           — discard preview
// ---------------------------------------------------------------------------

namespace
{

// ---- Per-player preview state --------------------------------------------

struct PlacementPreview
{
    ObjectGuid previewGuid;     // GUID of the temp creature / GO
    uint32 entry       = 0;     // creature_template or gameobject_template entry
    bool isGameObject  = false; // true = GO, false = creature
    float scale        = 1.0f;  // custom scale (1.0 = default)
    ObjectGuid sourceGuid;      // original creature GUID if cloned (for copying addon data)
    bool isClone       = false; // true if this was a .vp clone
};

static std::unordered_map<ObjectGuid, PlacementPreview> s_previews;

// ---- Helpers -------------------------------------------------------------

constexpr float DEG_TO_RAD = static_cast<float>(M_PI) / 180.0f;
constexpr float RAD_TO_DEG = 180.0f / static_cast<float>(M_PI);

// Spell visual kit for the golden glow indicator on creature previews.
constexpr uint32 PREVIEW_VISUAL_KIT = 39872;

/// Send the canonical position message after any move/rotate.
static void SendPositionMessage(ChatHandler* handler, Position const& pos)
{
    handler->PSendSysMessage("[VoxPlacer] Position: %.1f, %.1f, %.1f  Facing: %.1f\xC2\xB0",
        pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ(),
        pos.GetOrientation() * RAD_TO_DEG);
}

/// Cancel and despawn an existing preview for the given player (if any).
/// Returns true if a preview was cleaned up.
static bool CancelPreview(Player* player)
{
    auto it = s_previews.find(player->GetGUID());
    if (it == s_previews.end())
        return false;

    PlacementPreview& pv = it->second;
    Map* map = player->GetMap();

    if (pv.isGameObject)
    {
        if (GameObject* go = map->GetGameObject(pv.previewGuid))
            go->Delete();
    }
    else
    {
        if (Creature* cr = map->GetCreature(pv.previewGuid))
            if (cr->IsSummon())
                cr->ToTempSummon()->UnSummon();
    }

    s_previews.erase(it);
    return true;
}

/// Look up a live creature preview. Returns nullptr and sends an error if
/// there is no active creature preview.
static Creature* GetCreaturePreview(ChatHandler* handler, PlacementPreview const& pv)
{
    if (pv.isGameObject)
    {
        handler->SendSysMessage("[VoxPlacer] Current preview is a gameobject — this operation is creature-only.");
        handler->SetSentErrorMessage(true);
        return nullptr;
    }

    Creature* cr = handler->GetSession()->GetPlayer()->GetMap()->GetCreature(pv.previewGuid);
    if (!cr)
    {
        handler->SendSysMessage("[VoxPlacer] Preview creature no longer exists. Use .vp cancel and start again.");
        handler->SetSentErrorMessage(true);
    }
    return cr;
}

/// Look up a live GO preview.
static GameObject* GetGameObjectPreview(ChatHandler* handler, PlacementPreview const& pv)
{
    if (!pv.isGameObject)
    {
        handler->SendSysMessage("[VoxPlacer] Current preview is a creature — this operation is GO-only.");
        handler->SetSentErrorMessage(true);
        return nullptr;
    }

    GameObject* go = handler->GetSession()->GetPlayer()->GetMap()->GetGameObject(pv.previewGuid);
    if (!go)
    {
        handler->SendSysMessage("[VoxPlacer] Preview gameobject no longer exists. Use .vp cancel and start again.");
        handler->SetSentErrorMessage(true);
    }
    return go;
}

/// Despawn the old GO preview and respawn it at `pos` with `orientation`.
/// Updates `pv.previewGuid` and returns the new GO (or nullptr on failure).
static GameObject* RespawnGOPreview(Player* player, PlacementPreview& pv, Position const& pos)
{
    Map* map = player->GetMap();

    // Remove old GO
    if (GameObject* oldGo = map->GetGameObject(pv.previewGuid))
        oldGo->Delete();

    // Summon fresh at new location — use a very long respawn so it sticks around
    QuaternionData rot = QuaternionData::fromEulerAnglesZYX(pos.GetOrientation(), 0.0f, 0.0f);
    GameObject* go = player->SummonGameObject(pv.entry, pos, rot, 86400s);
    if (!go)
        return nullptr;

    if (pv.scale != 1.0f)
        go->SetObjectScale(pv.scale);

    pv.previewGuid = go->GetGUID();
    return go;
}

} // anonymous namespace

// ---------------------------------------------------------------------------
// Command script class
// ---------------------------------------------------------------------------

class voxplacer_commandscript : public CommandScript
{
public:
    voxplacer_commandscript() : CommandScript("voxplacer_commandscript") { }

    ChatCommandTable GetCommands() const override
    {
        static ChatCommandTable vpSubTable =
        {
            { "clone",   HandleVpClone,   rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "start",   HandleVpStart,   rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "gob",     HandleVpGob,     rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "here",    HandleVpHere,    rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "nudge",   HandleVpNudge,   rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "rotate",  HandleVpRotate,  rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "confirm", HandleVpConfirm, rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "cancel",  HandleVpCancel,  rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
            { "scale",   HandleVpScale,   rbac::RBAC_PERM_COMMAND_NPC_ADD, Console::No },
        };

        static ChatCommandTable commandTable =
        {
            { "vp", vpSubTable },
        };

        return commandTable;
    }

    // -----------------------------------------------------------------------
    // .vp clone — clone the targeted creature or nearest gameobject
    // -----------------------------------------------------------------------
    static bool HandleVpClone(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();

        // Cancel any existing preview first
        CancelPreview(player);

        // Try creature target first
        if (Creature* target = handler->getSelectedCreature())
        {
            uint32 entry = target->GetEntry();
            CreatureTemplate const* cInfo = sObjectMgr->GetCreatureTemplate(entry);
            if (!cInfo)
            {
                handler->PSendSysMessage("[VoxPlacer] Creature template %u not found.", entry);
                handler->SetSentErrorMessage(true);
                return false;
            }

            TempSummon* preview = player->SummonCreature(entry, player->GetPosition(), TEMPSUMMON_MANUAL_DESPAWN);
            if (!preview)
            {
                handler->SendSysMessage("[VoxPlacer] Failed to summon creature preview.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            // Non-attackable but still selectable so the GM can see it
            preview->SetUnitFlag(UNIT_FLAG_NON_ATTACKABLE);
            preview->ReplaceAllNpcFlags(NPCFlags(UNIT_NPC_FLAG_NONE));

            // Golden glow indicator
            preview->SendPlaySpellVisualKit(PREVIEW_VISUAL_KIT, 0, 0);

            PlacementPreview pv;
            pv.previewGuid = preview->GetGUID();
            pv.entry       = entry;
            pv.isGameObject = false;
            pv.scale       = 1.0f;
            pv.sourceGuid  = target->GetGUID();
            pv.isClone     = true;
            s_previews[player->GetGUID()] = pv;

            handler->PSendSysMessage("[VoxPlacer] Cloned creature '%s' (entry %u). Move with .vp here/nudge/rotate, then .vp confirm.",
                cInfo->Name.c_str(), entry);
            SendPositionMessage(handler, player->GetPosition());
            return true;
        }

        // No creature selected — try to find the nearest gameobject via DB
        // (same approach as .gobject target with no args: find closest GO on
        // this map, sorted by distance)
        {
            float px = player->GetPositionX(), py = player->GetPositionY(), pz = player->GetPositionZ();
            constexpr float SEARCH_RANGE = 30.0f;
            QueryResult result = WorldDatabase.PQuery(
                "SELECT guid, id, position_x, position_y, position_z, orientation "
                "FROM gameobject WHERE map = '{}' "
                "AND position_x BETWEEN {} AND {} "
                "AND position_y BETWEEN {} AND {} "
                "ORDER BY (POW(position_x - {}, 2) + POW(position_y - {}, 2) + POW(position_z - {}, 2)) ASC LIMIT 1",
                player->GetMapId(),
                px - SEARCH_RANGE, px + SEARCH_RANGE,
                py - SEARCH_RANGE, py + SEARCH_RANGE,
                px, py, pz);

            if (result)
            {
                Field* fields = result->Fetch();
                uint32 goEntry = fields[1].GetUInt32();

                GameObjectTemplate const* goInfo = sObjectMgr->GetGameObjectTemplate(goEntry);
                if (!goInfo)
                {
                    handler->PSendSysMessage("[VoxPlacer] Nearest gameobject template %u not found.", goEntry);
                    handler->SetSentErrorMessage(true);
                    return false;
                }

                // Spawn a temp GO preview at the player's position
                QuaternionData rot = QuaternionData::fromEulerAnglesZYX(player->GetOrientation(), 0.0f, 0.0f);
                GameObject* go = player->SummonGameObject(goEntry, *player, rot, 86400s);
                if (!go)
                {
                    handler->SendSysMessage("[VoxPlacer] Failed to summon gameobject preview.");
                    handler->SetSentErrorMessage(true);
                    return false;
                }

                PlacementPreview pv;
                pv.previewGuid  = go->GetGUID();
                pv.entry        = goEntry;
                pv.isGameObject = true;
                pv.scale        = 1.0f;
                pv.sourceGuid   = ObjectGuid::Empty;
                pv.isClone      = true;
                s_previews[player->GetGUID()] = pv;

                handler->PSendSysMessage("[VoxPlacer] Cloned gameobject '%s' (entry %u). Move with .vp here/nudge/rotate, then .vp confirm.",
                    goInfo->name.c_str(), goEntry);
                SendPositionMessage(handler, player->GetPosition());
                return true;
            }
        }

        handler->SendSysMessage("[VoxPlacer] No creature selected and no gameobject found nearby. Target a creature or stand near a gameobject.");
        handler->SetSentErrorMessage(true);
        return false;
    }

    // -----------------------------------------------------------------------
    // .vp start <entry> — spawn a temp creature preview
    // -----------------------------------------------------------------------
    static bool HandleVpStart(ChatHandler* handler, uint32 entry)
    {
        Player* player = handler->GetSession()->GetPlayer();

        CreatureTemplate const* cInfo = sObjectMgr->GetCreatureTemplate(entry);
        if (!cInfo)
        {
            handler->PSendSysMessage("[VoxPlacer] Creature template %u does not exist.", entry);
            handler->SetSentErrorMessage(true);
            return false;
        }

        // Cancel any existing preview
        CancelPreview(player);

        TempSummon* preview = player->SummonCreature(entry, player->GetPosition(), TEMPSUMMON_MANUAL_DESPAWN);
        if (!preview)
        {
            handler->SendSysMessage("[VoxPlacer] Failed to summon creature preview.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        preview->SetUnitFlag(UNIT_FLAG_NON_ATTACKABLE);
        preview->ReplaceAllNpcFlags(NPCFlags(UNIT_NPC_FLAG_NONE));
        preview->SendPlaySpellVisualKit(PREVIEW_VISUAL_KIT, 0, 0);

        PlacementPreview pv;
        pv.previewGuid  = preview->GetGUID();
        pv.entry        = entry;
        pv.isGameObject = false;
        pv.scale        = 1.0f;
        pv.isClone      = false;
        s_previews[player->GetGUID()] = pv;

        handler->PSendSysMessage("[VoxPlacer] Creature preview '%s' (entry %u) spawned. Use .vp here/nudge/rotate/scale, then .vp confirm.",
            cInfo->Name.c_str(), entry);
        SendPositionMessage(handler, player->GetPosition());
        return true;
    }

    // -----------------------------------------------------------------------
    // .vp gob <entry> — spawn a temp gameobject preview
    // -----------------------------------------------------------------------
    static bool HandleVpGob(ChatHandler* handler, uint32 entry)
    {
        Player* player = handler->GetSession()->GetPlayer();

        GameObjectTemplate const* goInfo = sObjectMgr->GetGameObjectTemplate(entry);
        if (!goInfo)
        {
            handler->PSendSysMessage("[VoxPlacer] Gameobject template %u does not exist.", entry);
            handler->SetSentErrorMessage(true);
            return false;
        }

        // Cancel any existing preview
        CancelPreview(player);

        QuaternionData rot = QuaternionData::fromEulerAnglesZYX(player->GetOrientation(), 0.0f, 0.0f);
        GameObject* go = player->SummonGameObject(entry, *player, rot, 86400s);
        if (!go)
        {
            handler->SendSysMessage("[VoxPlacer] Failed to summon gameobject preview.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        PlacementPreview pv;
        pv.previewGuid  = go->GetGUID();
        pv.entry        = entry;
        pv.isGameObject = true;
        pv.scale        = 1.0f;
        pv.isClone      = false;
        s_previews[player->GetGUID()] = pv;

        handler->PSendSysMessage("[VoxPlacer] Gameobject preview '%s' (entry %u) spawned. Use .vp here/nudge/rotate/scale, then .vp confirm.",
            goInfo->name.c_str(), entry);
        SendPositionMessage(handler, player->GetPosition());
        return true;
    }

    // -----------------------------------------------------------------------
    // .vp here — move preview to player's current position + facing
    // -----------------------------------------------------------------------
    static bool HandleVpHere(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();

        auto it = s_previews.find(player->GetGUID());
        if (it == s_previews.end())
        {
            handler->SendSysMessage("[VoxPlacer] No active preview. Use .vp start, .vp gob, or .vp clone first.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        PlacementPreview& pv = it->second;
        Position const& dest = player->GetPosition();

        if (pv.isGameObject)
        {
            if (!RespawnGOPreview(player, pv, dest))
            {
                handler->SendSysMessage("[VoxPlacer] Failed to move gameobject preview.");
                handler->SetSentErrorMessage(true);
                return false;
            }
        }
        else
        {
            Creature* cr = GetCreaturePreview(handler, pv);
            if (!cr)
                return false;
            cr->NearTeleportTo(dest);
        }

        SendPositionMessage(handler, dest);
        return true;
    }

    // -----------------------------------------------------------------------
    // .vp nudge <dx> <dy> <dz> — offset preview position in world space
    // -----------------------------------------------------------------------
    static bool HandleVpNudge(ChatHandler* handler, float dx, float dy, float dz)
    {
        Player* player = handler->GetSession()->GetPlayer();

        auto it = s_previews.find(player->GetGUID());
        if (it == s_previews.end())
        {
            handler->SendSysMessage("[VoxPlacer] No active preview. Use .vp start, .vp gob, or .vp clone first.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        PlacementPreview& pv = it->second;

        if (pv.isGameObject)
        {
            GameObject* go = GetGameObjectPreview(handler, pv);
            if (!go)
                return false;

            Position newPos(go->GetPositionX() + dx, go->GetPositionY() + dy,
                            go->GetPositionZ() + dz, go->GetOrientation());

            if (!RespawnGOPreview(player, pv, newPos))
            {
                handler->SendSysMessage("[VoxPlacer] Failed to nudge gameobject preview.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            SendPositionMessage(handler, newPos);
        }
        else
        {
            Creature* cr = GetCreaturePreview(handler, pv);
            if (!cr)
                return false;

            Position newPos(cr->GetPositionX() + dx, cr->GetPositionY() + dy,
                            cr->GetPositionZ() + dz, cr->GetOrientation());
            cr->NearTeleportTo(newPos);
            SendPositionMessage(handler, newPos);
        }

        return true;
    }

    // -----------------------------------------------------------------------
    // .vp rotate <degrees> — rotate preview's facing
    // -----------------------------------------------------------------------
    static bool HandleVpRotate(ChatHandler* handler, float degrees)
    {
        Player* player = handler->GetSession()->GetPlayer();

        auto it = s_previews.find(player->GetGUID());
        if (it == s_previews.end())
        {
            handler->SendSysMessage("[VoxPlacer] No active preview. Use .vp start, .vp gob, or .vp clone first.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        PlacementPreview& pv = it->second;
        float radians = degrees * DEG_TO_RAD;

        if (pv.isGameObject)
        {
            GameObject* go = GetGameObjectPreview(handler, pv);
            if (!go)
                return false;

            float newOri = Position::NormalizeOrientation(go->GetOrientation() + radians);
            Position newPos(go->GetPositionX(), go->GetPositionY(), go->GetPositionZ(), newOri);

            if (!RespawnGOPreview(player, pv, newPos))
            {
                handler->SendSysMessage("[VoxPlacer] Failed to rotate gameobject preview.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            SendPositionMessage(handler, newPos);
        }
        else
        {
            Creature* cr = GetCreaturePreview(handler, pv);
            if (!cr)
                return false;

            float newOri = Position::NormalizeOrientation(cr->GetOrientation() + radians);
            cr->SetFacingTo(newOri);
            SendPositionMessage(handler, { cr->GetPositionX(), cr->GetPositionY(), cr->GetPositionZ(), newOri });
        }

        return true;
    }

    // -----------------------------------------------------------------------
    // .vp scale <factor> — set preview scale
    // -----------------------------------------------------------------------
    static bool HandleVpScale(ChatHandler* handler, float factor)
    {
        Player* player = handler->GetSession()->GetPlayer();

        if (factor <= 0.0f || factor > 50.0f)
        {
            handler->SendSysMessage("[VoxPlacer] Scale must be between 0.01 and 50.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        auto it = s_previews.find(player->GetGUID());
        if (it == s_previews.end())
        {
            handler->SendSysMessage("[VoxPlacer] No active preview. Use .vp start, .vp gob, or .vp clone first.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        PlacementPreview& pv = it->second;
        pv.scale = factor;

        if (pv.isGameObject)
        {
            GameObject* go = GetGameObjectPreview(handler, pv);
            if (!go)
                return false;
            go->SetObjectScale(factor);
        }
        else
        {
            Creature* cr = GetCreaturePreview(handler, pv);
            if (!cr)
                return false;
            cr->SetObjectScale(factor);
        }

        handler->PSendSysMessage("[VoxPlacer] Scale set to %.2f.", factor);
        return true;
    }

    // -----------------------------------------------------------------------
    // .vp confirm — persist the preview to the database
    // -----------------------------------------------------------------------
    static bool HandleVpConfirm(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();

        auto it = s_previews.find(player->GetGUID());
        if (it == s_previews.end())
        {
            handler->SendSysMessage("[VoxPlacer] No active preview to confirm.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        PlacementPreview pv = it->second;   // copy — we erase below
        Map* map = player->GetMap();

        if (pv.isGameObject)
        {
            // --- Gameobject confirm ------------------------------------------
            GameObject* preview = map->GetGameObject(pv.previewGuid);
            if (!preview)
            {
                handler->SendSysMessage("[VoxPlacer] Preview gameobject no longer exists.");
                s_previews.erase(it);
                handler->SetSentErrorMessage(true);
                return false;
            }

            // Capture position before despawning
            Position const pos = preview->GetPosition();
            float orientation = pos.GetOrientation();

            // Remove the temp preview
            preview->Delete();
            s_previews.erase(it);

            // Full .gobject add flow: Create → SaveToDB → reload from DB
            QuaternionData rot = QuaternionData::fromEulerAnglesZYX(orientation, 0.0f, 0.0f);
            GameObject* go = GameObject::CreateGameObject(pv.entry, map, pos, rot, 255, GO_STATE_READY);
            if (!go)
            {
                handler->SendSysMessage("[VoxPlacer] Failed to create permanent gameobject.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            if (pv.scale != 1.0f)
                go->SetObjectScale(pv.scale);

            PhasingHandler::InheritPhaseShift(go, player);
            go->SaveToDB(map->GetId(), { map->GetDifficultyID() });
            ObjectGuid::LowType spawnId = go->GetSpawnId();

            // Clean delete → fresh reload from DB
            delete go;
            go = GameObject::CreateGameObjectFromDB(spawnId, map);
            if (!go)
            {
                handler->SendSysMessage("[VoxPlacer] Failed to load gameobject from database.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            sObjectMgr->AddGameobjectToGrid(ASSERT_NOTNULL(sObjectMgr->GetGameObjectData(spawnId)));

            GameObjectTemplate const* goInfo = sObjectMgr->GetGameObjectTemplate(pv.entry);
            handler->PSendSysMessage("[VoxPlacer] Confirmed gameobject '%s' (entry %u). Spawn GUID: %s  Pos: %.1f, %.1f, %.1f",
                goInfo ? goInfo->name.c_str() : "unknown", pv.entry, std::to_string(spawnId).c_str(),
                pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ());
        }
        else
        {
            // --- Creature confirm --------------------------------------------
            Creature* preview = map->GetCreature(pv.previewGuid);
            if (!preview)
            {
                handler->SendSysMessage("[VoxPlacer] Preview creature no longer exists.");
                s_previews.erase(it);
                handler->SetSentErrorMessage(true);
                return false;
            }

            // Capture position before despawning
            Position const pos = preview->GetPosition();

            // Despawn the temp summon
            if (preview->IsSummon())
                preview->ToTempSummon()->UnSummon();
            s_previews.erase(it);

            // Full .npc add flow: Create → SaveToDB → delete → CreateFromDB
            Creature* creature = Creature::CreateCreature(pv.entry, map, pos);
            if (!creature)
            {
                handler->SendSysMessage("[VoxPlacer] Failed to create permanent creature.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            PhasingHandler::InheritPhaseShift(creature, player);
            creature->SaveToDB(map->GetId(), { map->GetDifficultyID() });
            ObjectGuid::LowType newGuid = creature->GetSpawnId();

            creature->CleanupsBeforeDelete();
            delete creature;

            // If this was a clone, copy per-spawn DB overrides from the source
            if (pv.isClone)
            {
                Creature* sourceCreature = map->GetCreature(pv.sourceGuid);
                ObjectGuid::LowType sourceSpawnId = sourceCreature ? sourceCreature->GetSpawnId() : 0;

                if (sourceSpawnId)
                {
                    // Copy per-spawn creature overrides (leave position from our placement)
                    WorldDatabase.DirectPExecute(
                        "UPDATE creature dst JOIN creature src ON src.guid = {} SET "
                        "dst.spawnDifficulties = src.spawnDifficulties, "
                        "dst.phaseUseFlags = src.phaseUseFlags, "
                        "dst.PhaseId = src.PhaseId, "
                        "dst.PhaseGroup = src.PhaseGroup, "
                        "dst.terrainSwapMap = src.terrainSwapMap, "
                        "dst.modelid = src.modelid, "
                        "dst.equipment_id = src.equipment_id, "
                        "dst.spawntimesecs = src.spawntimesecs, "
                        "dst.wander_distance = src.wander_distance, "
                        "dst.MovementType = src.MovementType, "
                        "dst.npcflag = src.npcflag, "
                        "dst.unit_flags = src.unit_flags, "
                        "dst.unit_flags2 = src.unit_flags2, "
                        "dst.unit_flags3 = src.unit_flags3, "
                        "dst.ScriptName = src.ScriptName, "
                        "dst.StringId = src.StringId, "
                        "dst.size = src.size "
                        "WHERE dst.guid = {}",
                        sourceSpawnId, newGuid);

                    // Copy creature_addon (PathId=0 — waypoints are position-relative)
                    WorldDatabase.DirectPExecute(
                        "INSERT IGNORE INTO creature_addon "
                        "(guid, PathId, mount, StandState, AnimTier, VisFlags, SheathState, PvPFlags, "
                        "emote, aiAnimKit, movementAnimKit, meleeAnimKit, visibilityDistanceType, auras) "
                        "SELECT {}, 0, mount, StandState, AnimTier, VisFlags, SheathState, PvPFlags, "
                        "emote, aiAnimKit, movementAnimKit, meleeAnimKit, visibilityDistanceType, auras "
                        "FROM creature_addon WHERE guid = {}",
                        newGuid, sourceSpawnId);

                    // Sync in-memory CreatureData with source overrides
                    CreatureData const* sourceData = sObjectMgr->GetCreatureData(sourceSpawnId);
                    if (sourceData)
                    {
                        CreatureData& newData = sObjectMgr->NewOrExistCreatureData(newGuid);
                        newData.display            = sourceData->display;
                        newData.equipmentId        = sourceData->equipmentId;
                        newData.wander_distance    = sourceData->wander_distance;
                        newData.currentwaypoint    = 0;
                        newData.curHealthPct        = sourceData->curHealthPct;
                        newData.movementType       = sourceData->movementType;
                        newData.npcflag            = sourceData->npcflag;
                        newData.unit_flags         = sourceData->unit_flags;
                        newData.unit_flags2        = sourceData->unit_flags2;
                        newData.unit_flags3        = sourceData->unit_flags3;
                        newData.size               = sourceData->size;
                        newData.phaseUseFlags      = sourceData->phaseUseFlags;
                        newData.phaseId            = sourceData->phaseId;
                        newData.phaseGroup         = sourceData->phaseGroup;
                        newData.terrainSwapMap     = sourceData->terrainSwapMap;
                        newData.spawntimesecs      = sourceData->spawntimesecs;
                        newData.spawnDifficulties  = sourceData->spawnDifficulties;
                        newData.scriptId           = sourceData->scriptId;
                        newData.StringId           = sourceData->StringId;
                    }
                }
            }

            // Apply custom scale to the DB spawn if non-default
            if (pv.scale != 1.0f)
            {
                WorldDatabase.DirectPExecute("UPDATE creature SET size = {} WHERE guid = {}",
                    pv.scale, newGuid);

                CreatureData& data = sObjectMgr->NewOrExistCreatureData(newGuid);
                data.size = pv.scale;
            }

            // Reload creature from DB
            creature = Creature::CreateCreatureFromDB(newGuid, map, true, true);
            if (!creature)
            {
                handler->SendSysMessage("[VoxPlacer] Failed to load creature from database.");
                handler->SetSentErrorMessage(true);
                return false;
            }

            // If cloned, live-sync addon visuals (same as npc_copy_command.cpp)
            if (pv.isClone)
            {
                Creature* sourceCreature = map->GetCreature(pv.sourceGuid);
                ObjectGuid::LowType sourceSpawnId = sourceCreature ? sourceCreature->GetSpawnId() : 0;

                if (sourceSpawnId)
                {
                    CreatureAddon const* srcAddon = sObjectMgr->GetCreatureAddon(sourceSpawnId);
                    if (srcAddon)
                    {
                        CreatureAddon const* templateAddon = sObjectMgr->GetCreatureTemplateAddon(pv.entry);
                        if (templateAddon)
                            for (uint32 aura : templateAddon->auras)
                                creature->RemoveAurasDueToSpell(aura);

                        if (srcAddon->mount)
                            creature->Mount(srcAddon->mount);
                        creature->SetStandState(UnitStandStateType(srcAddon->standState));
                        creature->ReplaceAllVisFlags(UnitVisFlags(srcAddon->visFlags));
                        creature->SetAnimTier(AnimTier(srcAddon->animTier), false);
                        creature->SetSheath(SheathState(srcAddon->sheathState));
                        creature->ReplaceAllPvpFlags(UnitPVPStateFlags(srcAddon->pvpFlags));
                        if (srcAddon->emote)
                            creature->SetEmoteState(Emote(srcAddon->emote));
                        creature->SetAIAnimKitId(srcAddon->aiAnimKit);
                        creature->SetMovementAnimKitId(srcAddon->movementAnimKit);
                        creature->SetMeleeAnimKitId(srcAddon->meleeAnimKit);
                        if (srcAddon->visibilityDistanceType != VisibilityDistanceType::Normal)
                            creature->SetVisibilityDistanceOverride(srcAddon->visibilityDistanceType);

                        for (uint32 aura : srcAddon->auras)
                            if (!creature->HasAura(aura))
                                creature->AddAura(aura, creature);
                    }
                }
            }

            sObjectMgr->AddCreatureToGrid(sObjectMgr->GetCreatureData(newGuid));

            CreatureTemplate const* cInfo = sObjectMgr->GetCreatureTemplate(pv.entry);
            handler->PSendSysMessage("[VoxPlacer] Confirmed creature '%s' (entry %u). Spawn GUID: %s  Pos: %.1f, %.1f, %.1f",
                cInfo ? cInfo->Name.c_str() : "unknown", pv.entry, std::to_string(newGuid).c_str(),
                pos.GetPositionX(), pos.GetPositionY(), pos.GetPositionZ());
        }

        return true;
    }

    // -----------------------------------------------------------------------
    // .vp cancel — discard the active preview
    // -----------------------------------------------------------------------
    static bool HandleVpCancel(ChatHandler* handler)
    {
        Player* player = handler->GetSession()->GetPlayer();

        if (CancelPreview(player))
        {
            handler->SendSysMessage("[VoxPlacer] Preview cancelled and despawned.");
        }
        else
        {
            handler->SendSysMessage("[VoxPlacer] No active preview to cancel.");
            handler->SetSentErrorMessage(true);
            return false;
        }

        return true;
    }
};

void AddSC_voxplacer_commands()
{
    new voxplacer_commandscript();
}
