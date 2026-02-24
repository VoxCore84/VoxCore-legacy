/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#ifndef TRINITYCORE_PERKS_PROGRAM_H
#define TRINITYCORE_PERKS_PROGRAM_H

#include "Define.h"
#include "ObjectGuid.h"
#include <unordered_map>
#include <vector>

struct PerksProgramCurrentVendorItem
{
    int32 VendorItemID = 0;
    int32 MountID = 0;
    int32 BattlePetSpeciesID = 0;
    int32 TransmogSetID = 0;
    int32 ItemModifiedAppearanceID = 0;
    int32 TransmogIllusionID = 0;
    int32 ToyID = 0;
    int32 WarbandSceneID = 0;
    int32 Price = 0;
    int32 OriginalPrice = 0;
    uint32 DisplayOrder = 0;
    uint32 DisplayFlags = 0;
};

class PerksProgramMgr
{
public:
    static PerksProgramMgr* instance();

    void LoadVendorItems();
    std::vector<PerksProgramCurrentVendorItem> GetCurrentVendorItems() const;
    PerksProgramCurrentVendorItem const* GetVendorItem(int32 vendorItemId) const;

private:
    std::unordered_map<int32, PerksProgramCurrentVendorItem> _vendorItems;
};

#define sPerksProgramMgr PerksProgramMgr::instance()

#endif
