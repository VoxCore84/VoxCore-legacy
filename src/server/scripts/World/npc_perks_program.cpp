/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#include "CreatureScript.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "WorldSession.h"
#include "NPCPackets.h"

namespace
{
class npc_perks_program_vendor final : public CreatureScript
{
public:
    npc_perks_program_vendor() : CreatureScript("npc_perks_program_vendor") { }

    bool OnGossipHello(Player* player, Creature* creature) override
    {
        if (!player || !creature)
            return true;

        WorldPackets::NPC::NPCInteractionOpenResult interaction;
        interaction.Npc = creature->GetGUID();
        interaction.InteractionType = PlayerInteractionType::PerksProgramVendor;
        interaction.Success = true;
        player->SendDirectMessage(interaction.Write());

        player->GetSession()->SendCloseGossip();
        return true;
    }
};
}

void AddSC_npc_perks_program()
{
    new npc_perks_program_vendor();
}
