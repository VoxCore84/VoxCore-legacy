/*
 * This file is part of the TrinityCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.
 */

#include "PerksProgram.h"
#include "DatabaseEnv.h"
#include "GameTime.h"
#include "Log.h"

PerksProgramMgr* PerksProgramMgr::instance()
{
    static PerksProgramMgr instance;
    return &instance;
}

void PerksProgramMgr::LoadVendorItems()
{
    _vendorItems.clear();

    tm const* now = GameTime::GetDateAndTime();
    uint8 month = now ? now->tm_mon + 1 : 1;
    uint16 year = now ? now->tm_year + 1900 : 1970;

    PreparedStatement* stmt = CharacterDatabase.GetPreparedStatement(CHAR_SEL_PERKS_VENDOR_ITEMS_CURRENT);
    stmt->setUInt8(0, month);
    stmt->setUInt16(1, year);

    if (PreparedQueryResult result = CharacterDatabase.Query(stmt))
    {
        do
        {
            Field* fields = result->Fetch();
            PerksProgramCurrentVendorItem item;
            item.DisplayOrder = fields[0].GetUInt32();
            item.VendorItemID = fields[1].GetInt32();
            item.MountID = fields[2].GetInt32();
            item.BattlePetSpeciesID = fields[3].GetInt32();
            item.TransmogSetID = fields[4].GetInt32();
            item.ItemModifiedAppearanceID = fields[5].GetInt32();
            item.TransmogIllusionID = fields[6].GetInt32();
            item.ToyID = fields[7].GetInt32();
            item.WarbandSceneID = fields[8].GetInt32();
            item.Price = fields[9].GetInt32();
            item.OriginalPrice = fields[10].GetInt32();
            item.DisplayFlags = fields[11].GetUInt32();

            _vendorItems[item.VendorItemID] = item;
        } while (result->NextRow());
    }

    TC_LOG_INFO("server.loading", "Loaded {} Trading Post entries for {:02d}/{:04d}.", _vendorItems.size(), month, year);
}

std::vector<PerksProgramCurrentVendorItem> PerksProgramMgr::GetCurrentVendorItems() const
{
    std::vector<PerksProgramCurrentVendorItem> items;
    items.reserve(_vendorItems.size());

    for (auto const& [_, item] : _vendorItems)
        items.push_back(item);

    return items;
}

PerksProgramCurrentVendorItem const* PerksProgramMgr::GetVendorItem(int32 vendorItemId) const
{
    auto itr = _vendorItems.find(vendorItemId);
    if (itr == _vendorItems.end())
        return nullptr;

    return &itr->second;
}
