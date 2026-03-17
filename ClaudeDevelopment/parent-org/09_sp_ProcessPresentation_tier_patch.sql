-- ============================================================================
-- 09_sp_ProcessPresentation_tier_patch.sql
-- Patches sp_ProcessPresentation in core.core.DeploymentObjects to use
-- >= instead of = for @TierFilter, so a single call processes all tiers
-- at or above the filter value (e.g. @TierFilter = 100 runs 100, 101, 102).
--
-- Without this, sp_SignalChildCompletion's call to
--   sp_ProcessPresentation @TierFilter = 100
-- only processes Tier 100 and skips 101 + 102.
--
-- Prerequisites: sp_ProcessPresentation must exist in DeploymentObjects.
-- Post-deploy: run sp_DeployObjects on each parent org database.
-- Idempotent: safe to re-run.
-- ============================================================================

PRINT 'Patching sp_ProcessPresentation: @TierFilter = to >=...';

IF EXISTS (
    SELECT 1
    FROM [core].[DeploymentObjects]
    WHERE ObjectName = 'sp_ProcessPresentation'
      AND CAST(CreationScript AS NVARCHAR(MAX)) LIKE '%[[]tier] = @TierFilter%'
)
BEGIN
    UPDATE [core].[DeploymentObjects]
    SET CreationScript = CAST(
        REPLACE(
            CAST(CreationScript AS NVARCHAR(MAX)),
            N'[tier] = @TierFilter',
            N'[tier] >= @TierFilter'
        ) AS TEXT),
        ModifiedDate = GETDATE()
    WHERE ObjectName = 'sp_ProcessPresentation';

    PRINT 'sp_ProcessPresentation patched successfully: @TierFilter now uses >= comparison.';
END
ELSE IF EXISTS (
    SELECT 1
    FROM [core].[DeploymentObjects]
    WHERE ObjectName = 'sp_ProcessPresentation'
      AND CAST(CreationScript AS NVARCHAR(MAX)) LIKE '%[[]tier] >= @TierFilter%'
)
BEGIN
    PRINT 'sp_ProcessPresentation already uses >= comparison - no patch needed.';
END
ELSE
BEGIN
    PRINT 'WARNING: Could not find expected @TierFilter pattern in sp_ProcessPresentation.';
END
