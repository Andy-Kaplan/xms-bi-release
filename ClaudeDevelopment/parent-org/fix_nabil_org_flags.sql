-- ==============================================
-- Fix: Update DatabaseStatus and DatabaseCreated for Nabil Enterprises orgs
-- Date: 2026-03-16
-- Deploy to: core database (UAT)
--
-- Problem: All 6 Nabil orgs (parent + 5 children) have DatabaseStatus = 'FAILED'
-- and DatabaseCreated = 0 due to a STOCKORDER_START duplicate key error during
-- initial provisioning. The databases were physically created and are fully
-- operational (child DV loads run daily, presentation tables populated), but the
-- stale flags prevent:
--   1. sp_SignalChildCompletion quorum gate (requires parent DatabaseCreated = 1)
--   2. sp_BuildParentPresentationSQL child cursor (requires child DatabaseCreated = 1)
-- Result: parent fact tables (PF_*) are empty → dashboard shows no data.
--
-- Fix: Set DatabaseStatus = 'ACTIVE' and DatabaseCreated = 1 for all 6 orgs.
-- ==============================================

UPDATE [core].[Organisations]
SET [DatabaseStatus] = 'ACTIVE',
    [DatabaseCreated] = 1,
    [DatabaseCreatedDate] = [CreatedDate],  -- backfill with org creation date
    [Notes] = NULL,
    [ModifiedBy] = 'dbadmin',
    [ModifiedDate] = GETDATE()
WHERE [OrganisationID] IN (3, 4, 5, 6, 7, 8)
  AND [DatabaseStatus] = 'FAILED';

-- Verify
SELECT OrganisationID, OrganisationName, DatabaseStatus, DatabaseCreated, DatabaseCreatedDate
FROM [core].[Organisations]
WHERE OrganisationID IN (3, 4, 5, 6, 7, 8);
