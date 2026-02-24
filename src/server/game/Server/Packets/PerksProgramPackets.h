/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#ifndef TRINITYCORE_PERKS_PROGRAM_PACKETS_H
#define TRINITYCORE_PERKS_PROGRAM_PACKETS_H

#include "Packet.h"
#include "ObjectGuid.h"
#include "PerksProgramPacketsCommon.h"

namespace WorldPackets::PerksProgram
{
class PerksProgramStatusRequest final : public ClientPacket
{
public:
    explicit PerksProgramStatusRequest(WorldPacket&& packet) : ClientPacket(CMSG_PERKS_PROGRAM_STATUS_REQUEST, std::move(packet)) { }
    void Read() override;

    ObjectGuid Vendor;
};

class PerksProgramRequestPurchase final : public ClientPacket
{
public:
    explicit PerksProgramRequestPurchase(WorldPacket&& packet) : ClientPacket(CMSG_PERKS_PROGRAM_REQUEST_PURCHASE, std::move(packet)) { }
    void Read() override;

    int32 VendorItemID = 0;
};

class PerksProgramSetFrozenVendorItem final : public ClientPacket
{
public:
    explicit PerksProgramSetFrozenVendorItem(WorldPacket&& packet) : ClientPacket(CMSG_PERKS_PROGRAM_SET_FROZEN_VENDOR_ITEM, std::move(packet)) { }
    void Read() override;

    int32 VendorItemID = 0;
};

class PerksProgramVendorUpdate final : public ServerPacket
{
public:
    explicit PerksProgramVendorUpdate() : ServerPacket(SMSG_PERKS_PROGRAM_VENDOR_UPDATE) { }
    WorldPacket const* Write() override;

    std::vector<PerksVendorItem> VendorItems;
    PerksVendorItem FrozenItem;
    bool HasFrozenItem = false;
};

class PerksProgramResult final : public ServerPacket
{
public:
    explicit PerksProgramResult() : ServerPacket(SMSG_PERKS_PROGRAM_RESULT, 4) { }
    WorldPacket const* Write() override;

    enum class ResultCode : int32
    {
        Success = 0,
        Error = 1,
        ItemUnavailable = 2,
        NotEnoughTender = 3,
        AlreadyOwned = 4,
        FreezeLimitReached = 5
    };

    ResultCode Result = ResultCode::Success;
    int32 VendorItemID = 0;
};
}

#endif
