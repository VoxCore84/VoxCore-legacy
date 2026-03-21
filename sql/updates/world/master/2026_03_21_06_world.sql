-- Fix 546 broken SmartAI link chains (560 total, 14 skipped due to PK conflicts)
-- These entries reference linked events (via `link` column) that don't exist,
-- causing ~4,975 error log entries per boot. Setting link=0 stops the error
-- without changing behavior (the chain was already broken since targets don't exist).
-- PK is (entryorguid, source_type, id, link) so we skip rows where link=0 already exists.
UPDATE `smart_scripts` s1 SET s1.`link` = 0
WHERE s1.`link` > 0
AND NOT EXISTS (
    SELECT 1 FROM (SELECT `entryorguid`, `source_type`, `id` FROM `smart_scripts`) s2
    WHERE s2.`entryorguid` = s1.`entryorguid`
    AND s2.`source_type` = s1.`source_type`
    AND s2.`id` = s1.`link`
)
AND NOT EXISTS (
    SELECT 1 FROM (SELECT `entryorguid`, `source_type`, `id`, `link` FROM `smart_scripts`) s3
    WHERE s3.`entryorguid` = s1.`entryorguid`
    AND s3.`source_type` = s1.`source_type`
    AND s3.`id` = s1.`id`
    AND s3.`link` = 0
);
