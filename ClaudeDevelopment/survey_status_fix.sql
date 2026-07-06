/*
    Survey Data Vault Cleanup
    =========================
    Two operations on the Neighbours - Eastleigh organisation:

    STEP 1: Set 13 incomplete respondents to 'completed'
    ----------------------------------------------------
    These respondents have substantive answers (above threshold per
    community role) but were marked 'incomplete' by SurveyHero.

    Selection criteria (from survey_excel_extract.sql DENSE_RANK):
      - Church congregation member: answer_count > 68
      - Community Leader:           answer_count > 29
      - Resident:                   answer_count > 27
      - Worker:                     answer_count > 30
      - Response date >= 2025-11-14 (except Community Leader 755)
      - Status = 'incomplete'

    STEP 2: Soft-delete all touchpoint records before 2025-11-14
    ------------------------------------------------------------
    Sets IS_DELETED = 1 on 149 touchpoints and ~15,227 link rows
    from before the cutoff date.

    Target: Neighbours - Eastleigh organisation
    Layer:  datavault schema (HUB_TOUCHPOINT, SAT_TOUCHPOINT,
            LNK_ANSWER_QUESTION_TOUCHPOINT)

    NOTE: After running this script, the presentation layer must be
    rebuilt for changes to flow through to F_SURVEY_RESPONSE.
*/

BEGIN TRANSACTION;

-- ============================================================
-- STEP 1: Update 13 incomplete respondents to 'completed'
-- Expected: 13 rows updated
-- ============================================================

UPDATE [datavault].[SAT_TOUCHPOINT]
SET TOUCHPOINT_STATUS = N'completed'
WHERE CURRENT_FLAG = 1
  AND TOUCHPOINT_STATUS = N'incomplete'
  AND HUB_ID IN (
    -- #95  Church congregation member  69 answers  2025-11-15
    0x1D1F8F484F42DB354246B294FBC768A4F68CE9A5E001B6D7CFDBF21915F29036,
    -- #773 Church congregation member  73 answers  2026-02-08
    0xEFC90E930AA97237CDF86D503E771318441D993F46BB07F4B77C05A5B568C057,
    -- #17  Community Leader            31 answers  2026-01-12
    0x0572E11718C5E0ECA7525F4B57A482F6456D5102C2B96EA837883140B3763653,
    -- #756 Community Leader            30 answers  2025-10-17
    0xEB24EB8352CDA4456F9375CF8EAC7156109A37D18A61A819952052DB6B814129,
    -- #128 Resident                    28 answers  2025-11-16
    0x2ADAB31557B29B46334DE6818EAFB61B9236863F3F4F229F9310A6E0D95E7F65,
    -- #172 Resident                    31 answers  2025-11-30
    0x385BDCBDDBEA6EAEC430E38FD2EB1B3213529B9EC031258AF28BA34B933E42A0,
    -- #288 Resident                    31 answers  2025-11-15
    0x5B9CDD640E4236404F42F20060589114CC0116015D3B4086768FB317955D08DF,
    -- #330 Resident                    28 answers  2026-01-12
    0x682E4E6B9E494DC469ACEB14EEBC7F63B4B88983D8184D25458BBBE8F72CE9C4,
    -- #414 Resident                    31 answers  2025-11-22
    0x81A8AD3B26882F8447424BF91D6418256821D1A8A610224249DF4D71F5D9D8AB,
    -- #565 Resident                    31 answers  2026-01-21
    0xAE2286D09FCBCF9DA8DAB0A57535ABCF6A71340C4C9268FDDC1B31545DC476B8,
    -- #582 Resident                    34 answers  2025-11-15
    0xB389C391F850203658333EAFD20DC9454C275AA5C5C114DC9FE42357E72A9551,
    -- #219 Worker                      31 answers  2025-11-24
    0x46D42E9A9A5BB727EBA93BBB71807B304F25E37D92DCA0E22007487D258A7D3E,
    -- #627 Worker                      31 answers  2025-12-08
    0xC556AE5E51DAA10B45124DE278596BFA7CC445A51C58B837AB9A1E1AF12DB993
  );

PRINT 'Step 1 — Status updates: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' rows (expected 13)';

-- ============================================================
-- STEP 2: Soft-delete touchpoint records before 2025-11-14
-- Sets IS_DELETED = 1 on hubs, satellites, and links
-- Expected: 149 touchpoints, ~15,227 link rows
-- ============================================================

-- Collect the HUB_IDs to soft-delete into a temp table
SELECT HUB_ID
INTO #TouchpointsToRemove
FROM [datavault].[SAT_TOUCHPOINT]
WHERE TOUCHPOINT_DATETIME < '2025-11-14';

PRINT 'Touchpoints identified for soft-delete: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (expected 149)';

-- 2a. Soft-delete link rows
--UPDATE lnk
--SET lnk.IS_DELETED = 1
--FROM [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] lnk
--INNER JOIN #TouchpointsToRemove t ON lnk.TOUCHPOINT_HUB_ID = t.HUB_ID;

--PRINT 'Step 2a — Link rows soft-deleted: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (expected ~15,227)';

-- 2b. Soft-delete satellite rows
UPDATE s
SET s.IS_DELETED = 1
FROM [datavault].[SAT_TOUCHPOINT] s
INNER JOIN #TouchpointsToRemove t ON s.HUB_ID = t.HUB_ID;

PRINT 'Step 2b — Satellite rows soft-deleted: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (expected 149)';

-- 2c. Soft-delete hub rows
UPDATE h
SET h.IS_DELETED = 1
FROM [datavault].[HUB_TOUCHPOINT] h
INNER JOIN #TouchpointsToRemove t ON h.HUB_ID = t.HUB_ID;

PRINT 'Step 2c — Hub rows soft-deleted: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (expected 149)';

DROP TABLE #TouchpointsToRemove;

-- ============================================================
-- VERIFY: Check counts (IS_DELETED = 0 are active records)
-- Expected: 693 active hubs, 693 active sats
-- ============================================================
SELECT
    (SELECT COUNT(*) FROM [datavault].[HUB_TOUCHPOINT] WHERE IS_DELETED = 0)   AS [Active HUBs],
    (SELECT COUNT(*) FROM [datavault].[HUB_TOUCHPOINT] WHERE IS_DELETED = 1)   AS [Deleted HUBs],
    (SELECT COUNT(*) FROM [datavault].[SAT_TOUCHPOINT] WHERE IS_DELETED = 0)   AS [Active SATs],
    (SELECT COUNT(*) FROM [datavault].[SAT_TOUCHPOINT] WHERE IS_DELETED = 1)   AS [Deleted SATs];

-- ============================================================
-- STEP 3: Delete stale F_SURVEY_RESPONSE rows before cutoff
-- The presentation rebuild only processes the active date window,
-- so pre-cutoff fact rows remain. Delete them directly.
-- Expected: ~15,227 rows
-- ============================================================

DELETE FROM [presentation].[F_SURVEY_RESPONSE]
WHERE TOUCHPOINT_DATE < '2025-11-14';

PRINT 'Step 3 — Stale fact rows deleted: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' (expected ~15,227)';

-- Uncomment to commit once verified:
-- COMMIT;
-- Or rollback if something looks wrong:
-- ROLLBACK;
