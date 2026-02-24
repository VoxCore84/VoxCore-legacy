/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#include "PerksProgramPackets.h"
#include "PacketOperators.h"

namespace WorldPackets::PerksProgram
{
void PerksProgramStatusRequest::Read()
{
    _worldPacket >> Vendor;
}

void PerksProgramRequestPurchase::Read()
{
    _worldPacket >> VendorItemID;
}

void PerksProgramSetFrozenVendorItem::Read()
{
    _worldPacket >> VendorItemID;
}

WorldPacket const* PerksProgramVendorUpdate::Write()
{
    _worldPacket << uint32(VendorItems.size());

    for (PerksVendorItem const& item : VendorItems)
        _worldPacket << item;

    _worldPacket << FrozenItem;
    _worldPacket.WriteBit(HasFrozenItem);
    _worldPacket.FlushBits();

    return &_worldPacket;
}

WorldPacket const* PerksProgramResult::Write()
{
    _worldPacket << int32(Result);
    _worldPacket << int32(VendorItemID);
    return &_worldPacket;
}
}
