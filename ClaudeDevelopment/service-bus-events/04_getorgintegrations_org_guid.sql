-- =============================================================================
-- XMS Service Bus messaging — core.GetOrgIntegrations: return the org XMS GUID
-- =============================================================================
-- Dependency #3 of the design spec asked for "a new org XMS GUID column on the
-- org table in the CORE database, plus a GetOrgIntegrations extension".
--
-- NO NEW COLUMN IS NEEDED. core.Organisations.OrganisationCode is already a
-- UNIQUEIDENTIFIER and is already the XMS org GUID: core.CreateOrganisation
-- builds the org database name as
--     @DatabaseName = @OrganisationPrefix + '_XMS_' + @OrganisationCodeStr
-- (3_CoreStoredProceduresAndFunctions.sql), which is why org DBs are named
-- e.g. 20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57. The GUID embedded in
-- every org DB name IS OrganisationCode.
--
-- So this dependency collapses to appending one column to GetOrgIntegrations.
--
-- APPEND ONLY — NEVER REORDER. The function app consumes this result set
-- positionally as the org_int tuple (db_name, schema_name, api_config, org_guid).
-- Reordering breaks every integration. The 4th element is exactly what
-- shared/services/sql.py get_org_guid_maps() reads:
--     if len(org_int) >= 4 and org_int[3]:
-- and it tolerates legacy 3-tuples, so deploying this is backward-compatible in
-- both directions (old app + new proc, and new app + old proc both work).
--
-- Run against the CORE database only. Idempotent (CREATE OR ALTER).
--
-- RELEASE ACTION: fold this change back into the master file
-- 3_CoreStoredProceduresAndFunctions.sql (~line 989) so it is not lost on the
-- next full core deploy.
-- =============================================================================

CREATE OR ALTER PROCEDURE [core].[GetOrgIntegrations]
    @DatabaseName NVARCHAR(4000) = NULL,
    @SchemaName NVARCHAR(4000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        O.DatabaseName AS OrganisationDatabase,
        I.SchemaName AS IntegrationSchema,
        I.APIEndpointDetail,
        O.OrganisationCode AS OrganisationGuid   -- 4th column: XMS org GUID (envelope tenantId)
    FROM
        core.Integrations I
    INNER JOIN
        core.OrganisationIntegrations OI
        ON I.IntegrationID = OI.IntegrationID
    INNER JOIN
        core.Organisations O
        ON O.OrganisationID = OI.OrganisationID
    WHERE (@DatabaseName IS NULL OR O.DatabaseName = @DatabaseName)
    AND (@SchemaName IS NULL OR I.SchemaName = @SchemaName)
    ORDER BY 1,2;
END
GO

PRINT 'core.GetOrgIntegrations updated — OrganisationGuid appended as column 4';
GO
