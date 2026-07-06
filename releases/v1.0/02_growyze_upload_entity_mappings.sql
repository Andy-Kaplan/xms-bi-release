-- =============================================================================
-- Release v1.0 / Script 02
-- File:    02_growyze_upload_entity_mappings.sql
-- Target:  Managed Instance, core database
-- Scope:   Core-only -- call UploadEntityMappings to materialise the Load
--          steps in StagingControl that drive DV loading.
--
-- Why this is required
-- --------------------
-- Per docs/release-guide.md section 4: when an integration's EntityMappings
-- are modified (and _Final.sql is not re-run), UploadEntityMappings MUST be
-- called explicitly in the delta script. Without it, the auto-generated
-- "Load" rows in StagingControl still point at the old source table and the
-- DV pipeline continues to read from stage.GRYZ_LINEITEM rather than
-- stage.GRYZ_LINEITEM_PRODUCT.
--
-- Idempotent: UploadEntityMappings is itself a refresh -- safe to re-run.
-- =============================================================================

EXEC [core].[UploadEntityMappings] @IntegrationSchema = N'int_growyze001';
GO


-- -----------------------------------------------------------------------------
-- Verification (run manually post-deploy)
-- -----------------------------------------------------------------------------
-- The Load step for LINEITEM_PRODUCT should now reference GRYZ_LINEITEM_PRODUCT:
--
-- SELECT step_name, staging_table, step_type
-- FROM [core].[int_growyze001].[StagingControl]
-- WHERE step_type = N'Load' AND step_name LIKE N'%LINEITEM_PRODUCT%';
-- =============================================================================
