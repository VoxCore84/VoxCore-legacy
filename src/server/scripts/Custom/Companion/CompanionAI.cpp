#include "CompanionAI.h"
#include "CompanionMgr.h"
#include "MovementDefines.h"
#include "MotionMaster.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "TemporarySummon.h"
#include <cmath>

CompanionAI::CompanionAI(Creature* creature) : ScriptedAI(creature) { }

Player* CompanionAI::GetOwner() const
{
    if (TempSummon const* summon = me->ToTempSummon())
        return summon->GetSummonerUnit() ? summon->GetSummonerUnit()->ToPlayer() : nullptr;
    return nullptr;
}

// ---------------------------------------------------------------------------
// Target validation — prevent friendly fire on owner & squad mates
// ---------------------------------------------------------------------------
bool CompanionAI::IsValidCompanionTarget(Unit* target) const
{
    if (!target || !target->IsAlive())
        return false;

    if (!me->IsValidAttackTarget(target))
        return false;

    Player* owner = GetOwner();
    if (!owner)
        return false;

    // Don't attack owner
    if (target->GetGUID() == owner->GetGUID())
        return false;

    // Don't attack other companions in the same squad
    if (TempSummon const* ts = target->ToTempSummon())
        if (ts->GetSummonerGUID() == owner->GetGUID())
            return false;

    return true;
}

// ---------------------------------------------------------------------------
// Target selection strategies
// ---------------------------------------------------------------------------
Unit* CompanionAI::SelectDefendTarget()
{
    Player* owner = GetOwner();
    if (!owner)
        return nullptr;

    // Find closest attacker targeting the owner
    Unit* closest = nullptr;
    float closestDist = Companion::COMBAT_SEARCH_RANGE;

    for (Unit* attacker : owner->getAttackers())
    {
        if (!IsValidCompanionTarget(attacker))
            continue;

        float dist = me->GetDistance(attacker);
        if (dist < closestDist)
        {
            closest = attacker;
            closestDist = dist;
        }
    }

    return closest;
}

Unit* CompanionAI::SelectAssistTarget()
{
    Player* owner = GetOwner();
    if (!owner)
        return nullptr;

    // Assist the owner's current target
    Unit* ownerVictim = owner->GetVictim();
    if (ownerVictim && IsValidCompanionTarget(ownerVictim))
        return ownerVictim;

    // Fall back to the owner's selected target
    ObjectGuid targetGuid = owner->GetTarget();
    if (!targetGuid.IsEmpty())
    {
        if (Unit* selected = ObjectAccessor::GetUnit(*me, targetGuid))
            if (IsValidCompanionTarget(selected))
                return selected;
    }

    return nullptr;
}

Unit* CompanionAI::SelectHealTarget()
{
    Player* owner = GetOwner();
    if (!owner)
        return nullptr;

    Unit* lowestTarget = nullptr;
    float lowestPct = Companion::HEAL_HP_THRESHOLD;

    // Check owner
    float ownerPct = owner->GetHealthPct();
    if (ownerPct < lowestPct && owner->IsAlive() && me->IsWithinDist(owner, Companion::HEAL_SEARCH_RANGE))
    {
        lowestTarget = owner;
        lowestPct = ownerPct;
    }

    // Check squad companions
    Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(owner->GetGUID().GetCounter());
    if (state)
    {
        for (auto const& ac : state->active)
        {
            Creature* companion = ObjectAccessor::GetCreature(*me, ac.creatureGuid);
            if (!companion || !companion->IsAlive())
                continue;

            if (!me->IsWithinDist(companion, Companion::HEAL_SEARCH_RANGE))
                continue;

            float pct = companion->GetHealthPct();
            if (pct < lowestPct)
            {
                lowestTarget = companion;
                lowestPct = pct;
            }
        }
    }

    return lowestTarget;
}

// ---------------------------------------------------------------------------
// Per-role combat behaviors
// ---------------------------------------------------------------------------
void CompanionAI::UpdateTankBehavior(Unit* target)
{
    if (!me->HasUnitState(UNIT_STATE_CASTING))
    {
        Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(GetOwner()->GetGUID().GetCounter());
        Companion::RosterEntry const* roster = nullptr;
        if (state)
            for (auto const& ac : state->active)
                if (ac.creatureGuid == me->GetGUID()) { roster = ac.rosterEntry; break; }

        if (roster && roster->spell1 && _spell1Cooldown == 0)
        {
            me->CastSpell(target, roster->spell1, false);
            _spell1Cooldown = roster->cooldown1;
        }
    }

    me->GetMotionMaster()->MoveChase(target);
    AttackStart(target);
}

void CompanionAI::UpdateMeleeBehavior(Unit* target)
{
    if (!me->HasUnitState(UNIT_STATE_CASTING))
    {
        Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(GetOwner()->GetGUID().GetCounter());
        Companion::RosterEntry const* roster = nullptr;
        if (state)
            for (auto const& ac : state->active)
                if (ac.creatureGuid == me->GetGUID()) { roster = ac.rosterEntry; break; }

        if (roster && roster->spell1 && _spell1Cooldown == 0)
        {
            me->CastSpell(target, roster->spell1, false);
            _spell1Cooldown = roster->cooldown1;
        }
    }

    me->GetMotionMaster()->MoveChase(target);
    AttackStart(target);
}

void CompanionAI::UpdateRangedBehavior(Unit* target)
{
    if (!me->HasUnitState(UNIT_STATE_CASTING))
    {
        Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(GetOwner()->GetGUID().GetCounter());
        Companion::RosterEntry const* roster = nullptr;
        if (state)
            for (auto const& ac : state->active)
                if (ac.creatureGuid == me->GetGUID()) { roster = ac.rosterEntry; break; }

        if (roster && roster->spell1 && _spell1Cooldown == 0)
        {
            me->CastSpell(target, roster->spell1, false);
            _spell1Cooldown = roster->cooldown1;
        }
        else if (roster && roster->spell2 && _spell2Cooldown == 0)
        {
            me->CastSpell(target, roster->spell2, false);
            _spell2Cooldown = roster->cooldown2;
        }
    }

    // Keep at range
    if (me->GetDistance(target) < 20.0f)
        me->GetMotionMaster()->MoveChase(target, ChaseRange(25.0f));
    else
        AttackStart(target);
}

void CompanionAI::UpdateCasterBehavior(Unit* target)
{
    if (!me->HasUnitState(UNIT_STATE_CASTING))
    {
        Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(GetOwner()->GetGUID().GetCounter());
        Companion::RosterEntry const* roster = nullptr;
        if (state)
            for (auto const& ac : state->active)
                if (ac.creatureGuid == me->GetGUID()) { roster = ac.rosterEntry; break; }

        if (roster && roster->spell1 && _spell1Cooldown == 0)
        {
            me->CastSpell(target, roster->spell1, false);
            _spell1Cooldown = roster->cooldown1;
        }
        else if (roster && roster->spell2 && _spell2Cooldown == 0)
        {
            me->CastSpell(target, roster->spell2, false);
            _spell2Cooldown = roster->cooldown2;
        }
    }

    // Keep at range
    if (me->GetDistance(target) < 25.0f)
        me->GetMotionMaster()->MoveChase(target, ChaseRange(30.0f));
    else
        AttackStart(target);
}

void CompanionAI::UpdateHealerAI()
{
    Unit* healTarget = SelectHealTarget();
    if (!healTarget)
        return;

    if (me->HasUnitState(UNIT_STATE_CASTING))
        return;

    Player* owner = GetOwner();
    if (!owner)
        return;

    Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(owner->GetGUID().GetCounter());
    Companion::RosterEntry const* roster = nullptr;
    if (state)
        for (auto const& ac : state->active)
            if (ac.creatureGuid == me->GetGUID()) { roster = ac.rosterEntry; break; }

    if (!roster)
        return;

    // Heal spells — spell1 is primary heal
    if (roster->spell1 && _spell1Cooldown == 0)
    {
        me->CastSpell(healTarget, roster->spell1, false);
        _spell1Cooldown = roster->cooldown1;
    }
    else if (roster->spell2 && _spell2Cooldown == 0)
    {
        me->CastSpell(healTarget, roster->spell2, false);
        _spell2Cooldown = roster->cooldown2;
    }
}

void CompanionAI::ReturnToFormation()
{
    Player* owner = GetOwner();
    if (!owner)
        return;

    Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(owner->GetGUID().GetCounter());
    if (!state || !state->control.following)
        return;

    // Find our roster entry and compute formation offset
    uint8 roleCount[Companion::ROLE_MAX] = {};
    uint8 roleIndex[Companion::ROLE_MAX] = {};
    uint8 myRoleIdx = 0;
    Companion::Role myRole = Companion::ROLE_TANK;

    for (auto const& ac : state->active)
        if (ac.rosterEntry)
            roleCount[ac.rosterEntry->role]++;

    bool found = false;
    for (auto const& ac : state->active)
    {
        if (!ac.rosterEntry)
            continue;
        if (ac.creatureGuid == me->GetGUID())
        {
            myRole = ac.rosterEntry->role;
            myRoleIdx = roleIndex[myRole];
            found = true;
            break;
        }
        roleIndex[ac.rosterEntry->role]++;
    }

    if (!found)
        return;

    Companion::FormationOffset offset = sCompanionMgr->GetFormationOffset(myRole, myRoleIdx, roleCount[myRole]);
    me->GetMotionMaster()->MoveFollow(owner, offset.dist, ChaseAngle(offset.angle + float(M_PI)));
}

// ---------------------------------------------------------------------------
// Main AI update — runs on the creature's own update cycle
// ---------------------------------------------------------------------------
void CompanionAI::UpdateAI(uint32 diff)
{
    // Tick cooldowns
    if (_spell1Cooldown > diff) _spell1Cooldown -= diff; else _spell1Cooldown = 0;
    if (_spell2Cooldown > diff) _spell2Cooldown -= diff; else _spell2Cooldown = 0;
    if (_spell3Cooldown > diff) _spell3Cooldown -= diff; else _spell3Cooldown = 0;

    // Accumulate timer
    _updateTimer += diff;
    if (_updateTimer < Companion::AI_UPDATE_INTERVAL)
        return;
    _updateTimer = 0;

    // Validate owner
    Player* owner = GetOwner();
    if (!owner || !owner->IsInWorld())
    {
        TC_LOG_DEBUG("scripts.companion", "CompanionAI [{}]: No owner or owner not in world, despawning.", me->GetEntry());
        me->DespawnOrUnsummon();
        return;
    }

    // Leash check — teleport back if too far and out of combat
    if (!me->IsInCombat() && me->GetDistance(owner) > Companion::LEASH_DISTANCE)
    {
        me->NearTeleportTo(owner->GetPosition());
        ReturnToFormation();
        return;
    }

    // Get control state
    Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(owner->GetGUID().GetCounter());
    if (!state)
    {
        TC_LOG_DEBUG("scripts.companion", "CompanionAI [{}]: No player state found for owner {}.", me->GetEntry(), owner->GetGUID().GetCounter());
        return;
    }

    // Healer always checks for heal targets first
    Companion::RosterEntry const* myRoster = nullptr;
    for (auto const& ac : state->active)
        if (ac.creatureGuid == me->GetGUID()) { myRoster = ac.rosterEntry; break; }

    if (!myRoster)
    {
        TC_LOG_DEBUG("scripts.companion", "CompanionAI [{}]: Not found in active list (active size: {}).", me->GetEntry(), state->active.size());
        return;
    }

    TC_LOG_DEBUG("scripts.companion", "CompanionAI [{}] role={} mode={}: owner victim={}, owner target={}",
        me->GetEntry(), Companion::RoleToString(myRoster->role), Companion::ModeToString(state->control.mode),
        owner->GetVictim() ? owner->GetVictim()->GetEntry() : 0,
        !owner->GetTarget().IsEmpty() ? owner->GetTarget().GetCounter() : 0);

    if (myRoster->role == Companion::ROLE_HEALER)
    {
        UpdateHealerAI();
        // Healers don't initiate melee — if attacked, kite
        if (me->IsInCombat() && me->GetVictim())
        {
            if (me->GetDistance(me->GetVictim()) < 10.0f)
                me->GetMotionMaster()->MoveFollow(owner, 5.0f);
        }
        return;
    }

    // Mode-based behavior
    switch (state->control.mode)
    {
        case Companion::MODE_PASSIVE:
        {
            if (me->IsInCombat())
            {
                me->CombatStop(true);
                me->GetThreatManager().ClearAllThreat();
            }
            if (!me->HasUnitState(UNIT_STATE_FOLLOW))
                ReturnToFormation();
            break;
        }
        case Companion::MODE_DEFEND:
        {
            Unit* target = me->GetVictim();
            if (!target || !IsValidCompanionTarget(target))
                target = SelectDefendTarget();

            TC_LOG_DEBUG("scripts.companion", "CompanionAI [{}] DEFEND: target={}", me->GetEntry(), target ? target->GetEntry() : 0);

            if (target && myRoster)
            {
                switch (myRoster->role)
                {
                    case Companion::ROLE_TANK:   UpdateTankBehavior(target);   break;
                    case Companion::ROLE_MELEE:  UpdateMeleeBehavior(target);  break;
                    case Companion::ROLE_RANGED: UpdateRangedBehavior(target); break;
                    case Companion::ROLE_CASTER: UpdateCasterBehavior(target); break;
                    default: break;
                }
            }
            else if (!me->IsInCombat() && !me->HasUnitState(UNIT_STATE_FOLLOW))
            {
                ReturnToFormation();
            }
            break;
        }
        case Companion::MODE_ASSIST:
        {
            Unit* target = me->GetVictim();
            if (!target || !IsValidCompanionTarget(target))
                target = SelectAssistTarget();

            TC_LOG_DEBUG("scripts.companion", "CompanionAI [{}] ASSIST: target={}, ownerVictim={}, isValid={}",
                me->GetEntry(), target ? target->GetEntry() : 0,
                owner->GetVictim() ? owner->GetVictim()->GetEntry() : 0,
                owner->GetVictim() ? (IsValidCompanionTarget(owner->GetVictim()) ? "yes" : "no") : "n/a");

            if (target && myRoster)
            {
                switch (myRoster->role)
                {
                    case Companion::ROLE_TANK:   UpdateTankBehavior(target);   break;
                    case Companion::ROLE_MELEE:  UpdateMeleeBehavior(target);  break;
                    case Companion::ROLE_RANGED: UpdateRangedBehavior(target); break;
                    case Companion::ROLE_CASTER: UpdateCasterBehavior(target); break;
                    default: break;
                }
            }
            else if (!me->IsInCombat() && !me->HasUnitState(UNIT_STATE_FOLLOW))
            {
                ReturnToFormation();
            }
            break;
        }
        default:
            break;
    }
}

// ---------------------------------------------------------------------------
// Evade — don't despawn, just stop combat and return to formation
// ---------------------------------------------------------------------------
void CompanionAI::EnterEvadeMode(EvadeReason /*why*/)
{
    me->CombatStop(true);
    me->GetThreatManager().ClearAllThreat();
    ReturnToFormation();
}

void CompanionAI::JustDied(Unit* /*killer*/)
{
    // Companions will be respawned by the owner via .comp summon
    // Just clean up from the active list
    Player* owner = GetOwner();
    if (!owner)
        return;

    Companion::PlayerSquadState* state = sCompanionMgr->GetPlayerState(owner->GetGUID().GetCounter());
    if (!state)
        return;

    auto it = std::find_if(state->active.begin(), state->active.end(),
        [this](Companion::ActiveCompanion const& ac) { return ac.creatureGuid == me->GetGUID(); });
    if (it != state->active.end())
        state->active.erase(it);

    if (state->active.empty())
        state->summoned = false;
}
