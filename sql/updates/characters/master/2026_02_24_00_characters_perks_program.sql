CREATE TABLE IF NOT EXISTS `account_perks_vendor_item` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `perksItemId` INT UNSIGNED NOT NULL,
    `mountID` INT UNSIGNED NOT NULL DEFAULT 0,
    `battlePetSpeciesID` INT UNSIGNED NOT NULL DEFAULT 0,
    `transmogSetID` INT UNSIGNED NOT NULL DEFAULT 0,
    `itemModifiedAppearanceID` INT UNSIGNED NOT NULL DEFAULT 0,
    `transmogIllusionID` INT UNSIGNED NOT NULL DEFAULT 0,
    `toyID` INT UNSIGNED NOT NULL DEFAULT 0,
    `warbandSceneID` INT UNSIGNED NOT NULL DEFAULT 0,
    `cost` INT UNSIGNED NOT NULL DEFAULT 0,
    `originalCost` INT UNSIGNED NOT NULL DEFAULT 0,
    `flags` INT UNSIGNED NOT NULL DEFAULT 0,
    `availableMonth` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `availableYear` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_perks_time_item` (`availableYear`, `availableMonth`, `perksItemId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `account_perks_program_history` (
    `battlenetAccountId` INT UNSIGNED NOT NULL,
    `perksItemId` INT UNSIGNED NOT NULL,
    `purchaseTimestamp` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    `costPaid` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`battlenetAccountId`, `perksItemId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `account_perks_program_frozen` (
    `battlenetAccountId` INT UNSIGNED NOT NULL,
    `perksItemId` INT UNSIGNED NOT NULL,
    `frozenMonth` TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `frozenYear` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`battlenetAccountId`),
    KEY `idx_frozen_item` (`perksItemId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `account_perks_currency` (
    `battlenetAccountId` INT UNSIGNED NOT NULL,
    `tenderBalance` INT UNSIGNED NOT NULL DEFAULT 0,
    `tenderEarnedThisMonth` INT UNSIGNED NOT NULL DEFAULT 0,
    `lastMonthlyGrant` BIGINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`battlenetAccountId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
