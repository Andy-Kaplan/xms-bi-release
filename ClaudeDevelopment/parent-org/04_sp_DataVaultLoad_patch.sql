-- ============================================================================
-- 04_sp_DataVaultLoad_patch.sql
-- Patches sp_DataVaultLoad in core.core.DeploymentObjects to signal parent
-- organisation completion after the presentation build completes.
--
-- This enables the quorum gate: each child org signals completion so that
-- sp_SignalChildCompletion can check whether all children are done and
-- trigger the parent org presentation build.
--
-- Prerequisites: 02_sp_SignalChildCompletion.sql must be deployed first.
-- Idempotent: safe to re-run (checks for existing signal code).
-- ============================================================================

PRINT 'Patching sp_DataVaultLoad to add parent org completion signal...';

IF NOT EXISTS (
    SELECT 1
    FROM [core].[DeploymentObjects]
    WHERE ObjectName = 'sp_DataVaultLoad'
      AND CAST(CreationScript AS NVARCHAR(MAX)) LIKE '%sp_SignalChildCompletion%'
)
BEGIN
    UPDATE [core].[DeploymentObjects]
    SET CreationScript = CAST(
        REPLACE(
            CAST(CreationScript AS NVARCHAR(MAX)),
            N'EXEC core.[sp_InitEntityDeltaParameters]

                IF @LoggingLevel = ''DEBUG''',
            N'EXEC core.[sp_InitEntityDeltaParameters]

                -- Signal parent org completion for quorum gate
                BEGIN TRY
                    DECLARE @ChildOrgCode UNIQUEIDENTIFIER;
                    SELECT @ChildOrgCode = o.[OrganisationCode]
                    FROM [core].[core].[Organisations] o
                    WHERE o.[DatabaseName] = DB_NAME()
                      AND o.[IsActive] = 1;

                    IF @ChildOrgCode IS NOT NULL
                    BEGIN
                        EXEC [core].[core].[sp_SignalChildCompletion] @ChildOrganisationCode = @ChildOrgCode;
                    END;
                END TRY
                BEGIN CATCH
                    -- Non-fatal: log but don''t fail the pipeline
                    PRINT ''Warning: Parent org signal failed: '' + ERROR_MESSAGE();
                END CATCH;

                IF @LoggingLevel = ''DEBUG'''
        ) AS TEXT)
    WHERE ObjectName = 'sp_DataVaultLoad';

    PRINT 'sp_DataVaultLoad patched successfully: parent org signal added after presentation build.';
END
ELSE
BEGIN
    PRINT 'sp_DataVaultLoad already contains sp_SignalChildCompletion signal - no patch needed.';
END
