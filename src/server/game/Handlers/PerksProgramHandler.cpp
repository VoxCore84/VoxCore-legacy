/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#include "WorldSession.h"
#include "PerksProgram.h"
#include "PerksProgramPackets.h"

void WorldSession::HandlePerksProgramStatusRequest(WorldPackets::PerksProgram::PerksProgramStatusRequest& packet)
{
    if (!GetPlayer())
        return;

    GetPlayer()->PlayerTalkClass->GetInteractionData().StartInteraction(packet.Vendor, PlayerInteractionType::PerksProgramVendor);

    WorldPackets::PerksProgram::PerksProgramVendorUpdate response;
    for (PerksProgramCurrentVendorItem const& itemData : sPerksProgramMgr->GetCurrentVendorItems())
    {
        WorldPackets::PerksProgram::PerksVendorItem item;
        item.VendorItemID = itemData.VendorItemID;
        item.MountID = itemData.MountID;
        item.BattlePetSpeciesID = itemData.BattlePetSpeciesID;
        item.TransmogSetID = itemData.TransmogSetID;
        item.ItemModifiedAppearanceID = itemData.ItemModifiedAppearanceID;
        item.TransmogIllusionID = itemData.TransmogIllusionID;
        item.ToyID = itemData.ToyID;
        item.WarbandSceneID = itemData.WarbandSceneID;
        item.Price = itemData.Price;
        item.OriginalPrice = itemData.OriginalPrice;
        item.DoesNotExpire = true;
        response.VendorItems.push_back(item);
    }

    SendPacket(response.Write());
}

void WorldSession::HandlePerksProgramRequestPurchase(WorldPackets::PerksProgram::PerksProgramRequestPurchase& packet)
{
    WorldPackets::PerksProgram::PerksProgramResult result;
    result.VendorItemID = packet.VendorItemID;

    if (!sPerksProgramMgr->GetVendorItem(packet.VendorItemID))
        result.Result = WorldPackets::PerksProgram::PerksProgramResult::ResultCode::ItemUnavailable;

    SendPacket(result.Write());
}

void WorldSession::HandlePerksProgramSetFrozenVendorItem(WorldPackets::PerksProgram::PerksProgramSetFrozenVendorItem& packet)
{
    WorldPackets::PerksProgram::PerksProgramResult result;
    result.VendorItemID = packet.VendorItemID;

    if (!sPerksProgramMgr->GetVendorItem(packet.VendorItemID))
        result.Result = WorldPackets::PerksProgram::PerksProgramResult::ResultCode::ItemUnavailable;

    SendPacket(result.Write());
}

void WorldSession::HandlePerksProgramRequestPendingRewards(WorldPackets::Misc::PerksProgramReqestPendingRewards& /*packet*/)
{
    WorldPackets::PerksProgram::PerksProgramResult result;
    SendPacket(result.Write());
}
