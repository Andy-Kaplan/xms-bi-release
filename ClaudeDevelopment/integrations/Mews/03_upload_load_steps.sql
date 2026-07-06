/* ============================================================================
   Mews Integration - Generate Load Steps
   Translates core.int_mews001.EntityMappings rows into StagingControl rows
   with step_type = 'Load'. Idempotent (regenerates on re-run).
   Run AFTER 01 + 02. Developer-executed (EXEC not allowed via MCP).
   ============================================================================ */
EXEC [core].[UploadEntityMappings] @intSchema = N'int_mews001';
GO
