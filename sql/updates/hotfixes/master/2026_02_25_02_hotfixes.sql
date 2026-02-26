-- Fix: Remove stale TransmogHoliday hotfix entries that cause client validation errors.
--
-- The hotfix_data table contains 283 TransmogHoliday entries with Status=3
-- (Invalid) and 2 with Status=2 (RecordRemoved). These reference records that
-- don't exist in the 12.x TransmogHoliday.db2 store.
--
-- When the client connects, the server sends these as hotfix records. The client
-- logs VALIDATION_RESULT_INVALID for each Status=3 entry (283 errors per login)
-- and VALIDATION_RESULT_DELETE for each Status=2 entry.
--
-- Fix: Remove all stale entries. The server will stop sending invalid hotfix
-- data for TransmogHoliday.
--
-- TableHash 0x5481AF88 = TransmogHoliday.db2

DELETE FROM `hotfix_data` WHERE `TableHash` = 0x5481AF88 AND `Status` IN (2, 3);
