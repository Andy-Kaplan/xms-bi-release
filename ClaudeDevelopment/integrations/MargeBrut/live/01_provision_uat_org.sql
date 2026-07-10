/* =============================================================================
   01_provision_uat_org.sql
   -----------------------------------------------------------------------------
   Target server  : xms-mssqlman-ne-uat (SQL MI), via PowerShell runner
   Target database: core
   Purpose        : Provision the new UAT organisation "Three Rocks Hotel" and
                    map it to the Mews (POS) and Growyze (INVENTORY)
                    integrations, for the Marge Brut live-dashboard build
                    (Task 9). Downstream steps (DEPLOY.txt in this folder)
                    load Mews/Growyze data into this org and wire Marge Brut
                    off it instead of the mocked Oak & Vine dashboard.

   Organisations and integrations MUST be added via stored procedures, never
   direct INSERT (CLAUDE.md). Uses core.AddOrganisation, core.AddIntegration,
   core.MapOrganisationToIntegration -- signatures confirmed 2026-07-10
   against 3_CoreStoredProceduresAndFunctions.sql (repo root) and read-only
   MCP queries against xms-bi-uat/core and xms-bi-dev/core.

   IMPORTANT FINDING (2026-07-10): unlike Growyze -- already on UAT as
   Growyze001 / IntegrationID 5 -- **Mews001 does NOT exist on UAT at all**.
   It was deployed straight to DEV by the fetcher team (IntegrationID 8,
   IntegrationType 'POS', SchemaName int_mews001; see memory/bizon-integration.md)
   and never provisioned on UAT. The task brief this script was written
   against assumed both integrations already existed on UAT -- that was
   wrong for Mews, confirmed by querying core.Integrations on both
   environments (UAT: 6 rows, no Mews; DEV: 8 rows, row 8 = Mews001).
   This script therefore ALSO creates the Mews001 integration record
   (Section 2) and seeds its landing-table DDL config (Section 3) before
   mapping the new org to it -- otherwise the mapping trigger would fire
   against an empty STAGE_DDL config and create an empty int_mews001 schema
   in the org's client DB with no DL_* tables at all, and the Mews DV
   mapping scripts in ../../Mews/ would have nothing to stage from.

   Run order matters: STAGE_DDL rows (Section 3) MUST be in place before
   MapOrganisationToIntegration (Section 5), because
   trg_OrganisationIntegrations_AfterInsert only fires on the INSERT that
   creates the org<->integration mapping row -- a later re-run of
   MapOrganisationToIntegration against an EXISTING mapping just UPDATEs
   the row and does NOT refire the trigger, so a second chance to backfill
   the DL tables does not exist without re-mapping.

   Sections:
     1. AddOrganisation      -- "Three Rocks Hotel" (auto-generated GUID)
     2. AddIntegration       -- Mews001 (guarded; Growyze001 untouched)
     3. Seed STAGE_DDL       -- 22 DL_* table DDLs for int_mews001, copied
                                 verbatim from DEV core.int_mews001.GlobalParameters
                                 (Category='STAGE_DDL') on 2026-07-10
     4. Look up IDs          -- OrganisationID / IntegrationID x2
     5. Map organisation     -- org -> Mews001, org -> Growyze001
     6. Verification SELECT  -- prints the values later steps need

   Idempotent: guarded IF NOT EXISTS / MERGE throughout -- safe to re-run.
   CAPTURE the OrganisationCode (GUID) + DatabaseName printed by Section 6:
   they feed live/15_report_config.sql's @OrgId/@DbPrefix and the
   sp_DataVaultLoad call in this folder's DEPLOY.txt.
   ============================================================================= */

SET NOCOUNT ON;
GO

----------------------------------------------------------------------
-- 1. AddOrganisation -- "Three Rocks Hotel"
----------------------------------------------------------------------
-- @OrganisationCode is left NULL so AddOrganisation mints a fresh GUID via
-- NEWID() -- avoids the hex-only GUID gotcha (CLAUDE.md) and matches every
-- other UAT org, whose GUID differs from its DEV counterpart of the same
-- name (memory/test-orgs.md). @OrganisationPrefix follows the observed
-- house convention (confirmed against all 18 existing UAT orgs): the
-- provisioning date, YYYYMMDD -- update it if this script runs on a
-- different day than authored.
IF NOT EXISTS (SELECT 1 FROM [core].[Organisations] WHERE [OrganisationName] = N'Three Rocks Hotel')
BEGIN
    EXEC [core].[AddOrganisation]
        @OrganisationName = N'Three Rocks Hotel',
        @OrganisationPrefix = N'20260710',   -- <<-- confirm/adjust to the actual run date
        @OrganisationCode = NULL,
        @CreateDatabaseImmediately = 1,
        @Notes = N'Provisioned for Marge Brut live dashboard (Task 9); mapped to Mews001 (POS) + Growyze001 (INVENTORY).';
END
ELSE
    PRINT 'Organisation "Three Rocks Hotel" already exists on this environment -- skipping AddOrganisation.';
GO

----------------------------------------------------------------------
-- 2. AddIntegration -- Mews001 (POS)
--    Mirrors the DEV record exactly (IntegrationDisplayName, Version) so
--    the schema name comes out as int_mews001 -- required because the DV
--    mapping scripts in ../../Mews/ hardcode int_mews001 in their
--    StagingControl/EntityMappings step SQL.
----------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM [core].[Integrations] WHERE [IntegrationName] = N'Mews001')
BEGIN
    EXEC [core].[AddIntegration]
        @IntegrationName = N'Mews001',
        @IntegrationDisplayName = N'Mews Version 1',
        @Description = NULL,
        @CreateSchemaImmediately = 1,
        @Version = N'1.0.0';

    -- AddIntegration has no @IntegrationType param (memory/uat-migration.md) --
    -- set it post-insert to match DEV's Mews001 record.
    UPDATE [core].[Integrations]
    SET [IntegrationType] = N'POS',
        [ModifiedBy] = SYSTEM_USER,
        [ModifiedDate] = GETDATE()
    WHERE [IntegrationName] = N'Mews001';
END
ELSE
    PRINT 'Integration "Mews001" already exists on this environment -- skipping AddIntegration.';
GO

----------------------------------------------------------------------
-- 3. Seed core.int_mews001.GlobalParameters STAGE_DDL
--    22 DL_* landing-table DDLs, copied verbatim from DEV
--    core.int_mews001.GlobalParameters (Category='STAGE_DDL') on 2026-07-10.
--    Without this, mapping the org to Mews001 (Section 5) creates the
--    int_mews001 schema in the org DB but no DL_* tables -- the fetcher
--    would have nowhere to land data. MUST complete before Section 5.
----------------------------------------------------------------------
MERGE INTO core.[int_mews001].[GlobalParameters] AS tgt
USING (VALUES
(N'DL_AREAS', N'CREATE TABLE [int_mews001].[DL_AREAS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [isActive] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_BOOKINGS', N'CREATE TABLE [int_mews001].[DL_BOOKINGS](
    [id] [nvarchar](max) NULL,
    [bookingDatetime] [nvarchar](max) NULL,
    [covers] [nvarchar](max) NULL,
    [notes] [nvarchar](max) NULL,
    [status] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [customerId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_CUSTOMERS', N'CREATE TABLE [int_mews001].[DL_CUSTOMERS](
    [id] [nvarchar](max) NULL,
    [fullName] [nvarchar](max) NULL,
    [companyName] [nvarchar](max) NULL,
    [taxNumber] [nvarchar](max) NULL,
    [email] [nvarchar](max) NULL,
    [address1] [nvarchar](max) NULL,
    [address2] [nvarchar](max) NULL,
    [city] [nvarchar](max) NULL,
    [state] [nvarchar](max) NULL,
    [postalCode] [nvarchar](max) NULL,
    [country] [nvarchar](max) NULL,
    [notes] [nvarchar](max) NULL,
    [phone] [nvarchar](max) NULL,
    [mobile] [nvarchar](max) NULL,
    [countrySpecificCode] [nvarchar](max) NULL,
    [dateOfBirth] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_INVOICE_ITEMS', N'CREATE TABLE [int_mews001].[DL_INVOICE_ITEMS](
    [id] [nvarchar](max) NULL,
    [productName] [nvarchar](max) NULL,
    [unitPriceInclTax] [nvarchar](max) NULL,
    [subtotal] [nvarchar](max) NULL,
    [quantity] [nvarchar](max) NULL,
    [comp] [nvarchar](max) NULL,
    [void] [nvarchar](max) NULL,
    [isComp] [nvarchar](max) NULL,
    [isVoid] [nvarchar](max) NULL,
    [compVoidReason] [nvarchar](max) NULL,
    [compVoidNotes] [nvarchar](max) NULL,
    [discountAmount] [nvarchar](max) NULL,
    [discount] [nvarchar](max) NULL,
    [tax] [nvarchar](max) NULL,
    [total] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [productId] [nvarchar](max) NULL,
    [productVariantId] [nvarchar](max) NULL,
    [revenueCenterId] [nvarchar](max) NULL,
    [invoiceId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_INVOICES', N'CREATE TABLE [int_mews001].[DL_INVOICES](
    [id] [nvarchar](max) NULL,
    [discount] [nvarchar](max) NULL,
    [tax] [nvarchar](max) NULL,
    [total] [nvarchar](max) NULL,
    [subtotal] [nvarchar](max) NULL,
    [cancelled] [nvarchar](max) NULL,
    [cancelReason] [nvarchar](max) NULL,
    [discountAmount] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [itemDiscountAmount] [nvarchar](max) NULL,
    [tipAmount] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [userId] [nvarchar](max) NULL,
    [orderId] [nvarchar](max) NULL,
    [registerId] [nvarchar](max) NULL,
    [originalInvoiceId] [nvarchar](max) NULL,
    [promoCodeId] [nvarchar](max) NULL,
    [revenueCenterId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_MENUS', N'CREATE TABLE [int_mews001].[DL_MENUS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [status] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_MODIFIER_SETS', N'CREATE TABLE [int_mews001].[DL_MODIFIER_SETS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [selection] [nvarchar](max) NULL,
    [minimumCount] [nvarchar](max) NULL,
    [maximumCount] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_MODIFIERS', N'CREATE TABLE [int_mews001].[DL_MODIFIERS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [price] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [modifierSetId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_ORDER_ITEM_MODIFIERS', N'CREATE TABLE [int_mews001].[DL_ORDER_ITEM_MODIFIERS](
    [id] [nvarchar](max) NULL,
    [orderItemId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_ORDER_ITEMS', N'CREATE TABLE [int_mews001].[DL_ORDER_ITEMS](
    [id] [nvarchar](max) NULL,
    [quantity] [nvarchar](max) NULL,
    [total] [nvarchar](max) NULL,
    [unitPriceInclTax] [nvarchar](max) NULL,
    [tax] [nvarchar](max) NULL,
    [subtotal] [nvarchar](max) NULL,
    [discount] [nvarchar](max) NULL,
    [discountType] [nvarchar](max) NULL,
    [discountDescription] [nvarchar](max) NULL,
    [isComp] [nvarchar](max) NULL,
    [isVoid] [nvarchar](max) NULL,
    [notes] [nvarchar](max) NULL,
    [compVoidReason] [nvarchar](max) NULL,
    [compVoidNotes] [nvarchar](max) NULL,
    [productId] [nvarchar](max) NULL,
    [productVariantId] [nvarchar](max) NULL,
    [orderId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_ORDERS', N'CREATE TABLE [int_mews001].[DL_ORDERS](
    [id] [nvarchar](max) NULL,
    [notes] [nvarchar](max) NULL,
    [covers] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [tableStatus] [nvarchar](max) NULL,
    [status] [nvarchar](max) NULL,
    [state] [nvarchar](max) NULL,
    [depositAmount] [nvarchar](max) NULL,
    [invoiceId] [nvarchar](max) NULL,
    [customerId] [nvarchar](max) NULL,
    [bookingId] [nvarchar](max) NULL,
    [outletId] [nvarchar](max) NULL,
    [revenueCenterId] [nvarchar](max) NULL,
    [promoCodeId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_OUTLETS', N'CREATE TABLE [int_mews001].[DL_OUTLETS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [address1] [nvarchar](max) NULL,
    [address2] [nvarchar](max) NULL,
    [city] [nvarchar](max) NULL,
    [state] [nvarchar](max) NULL,
    [index] [nvarchar](max) NULL,
    [postalCode] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_PAYMENT_METHODS', N'CREATE TABLE [int_mews001].[DL_PAYMENT_METHODS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [active] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_PRODUCT_BUNDLES', N'CREATE TABLE [int_mews001].[DL_PRODUCT_BUNDLES](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [imageUrl] [nvarchar](max) NULL,
    [priceRange_min] [nvarchar](max) NULL,
    [priceRange_max] [nvarchar](max) NULL,
    [retailPriceInclTax] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_PRODUCT_TYPES', N'CREATE TABLE [int_mews001].[DL_PRODUCT_TYPES](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_PRODUCT_VARIANTS', N'CREATE TABLE [int_mews001].[DL_PRODUCT_VARIANTS](
    [id] [nvarchar](max) NULL,
    [sku] [nvarchar](max) NULL,
    [barcode] [nvarchar](max) NULL,
    [selector] [nvarchar](max) NULL,
    [tax] [nvarchar](max) NULL,
    [retailPriceInclTax] [nvarchar](max) NULL,
    [retailPriceExclTax] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [productId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_PRODUCTS', N'CREATE TABLE [int_mews001].[DL_PRODUCTS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [sku] [nvarchar](max) NULL,
    [status] [nvarchar](max) NULL,
    [barcode] [nvarchar](max) NULL,
    [isAvailable] [nvarchar](max) NULL,
    [tax] [nvarchar](max) NULL,
    [retailPriceInclTax] [nvarchar](max) NULL,
    [retailPriceExclTax] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [productTypeId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_PROMO_CODES', N'CREATE TABLE [int_mews001].[DL_PROMO_CODES](
    [id] [nvarchar](max) NULL,
    [discountType] [nvarchar](max) NULL,
    [amount] [nvarchar](max) NULL,
    [channel] [nvarchar](max) NULL,
    [code] [nvarchar](max) NULL,
    [active] [nvarchar](max) NULL,
    [description] [nvarchar](max) NULL,
    [maxUsages] [nvarchar](max) NULL,
    [startsAt] [nvarchar](max) NULL,
    [endsAt] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_REGISTERS', N'CREATE TABLE [int_mews001].[DL_REGISTERS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [invoicesCount] [nvarchar](max) NULL,
    [index] [nvarchar](max) NULL,
    [virtual] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [outletId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_REVENUE_CENTERS', N'CREATE TABLE [int_mews001].[DL_REVENUE_CENTERS](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [isActive] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_TABLES', N'CREATE TABLE [int_mews001].[DL_TABLES](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [numberOfSeats] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [areaId] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);'),
(N'DL_TAXES', N'CREATE TABLE [int_mews001].[DL_TAXES](
    [id] [nvarchar](max) NULL,
    [name] [nvarchar](max) NULL,
    [rate] [nvarchar](max) NULL,
    [createdAt] [nvarchar](max) NULL,
    [updatedAt] [nvarchar](max) NULL,
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);')
) AS src (ParameterKey, ParameterValue)
ON tgt.ParameterKey = src.ParameterKey AND tgt.Category = N'STAGE_DDL'
WHEN MATCHED THEN
    UPDATE SET ParameterValue = src.ParameterValue,
               IsActive = 1,
               ModifiedBy = SYSTEM_USER,
               ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (src.ParameterKey, src.ParameterValue, 'STRING', N'STAGE_DDL', src.ParameterKey, 1, SYSTEM_USER, GETDATE(), 1);

PRINT 'core.int_mews001.GlobalParameters: seeded 22 STAGE_DDL rows (copied from DEV 2026-07-10).';
GO

----------------------------------------------------------------------
-- 4. Look up the IDs Section 5 needs (works whether this is a fresh run
--    or a re-run against rows Sections 1-3 already created)
----------------------------------------------------------------------
DECLARE @OrgID INT, @MewsIntID INT, @GrowyzeIntID INT;

SELECT @OrgID = [OrganisationID] FROM [core].[Organisations] WHERE [OrganisationName] = N'Three Rocks Hotel';
SELECT @MewsIntID = [IntegrationID] FROM [core].[Integrations] WHERE [IntegrationName] = N'Mews001';
SELECT @GrowyzeIntID = [IntegrationID] FROM [core].[Integrations] WHERE [IntegrationName] = N'Growyze001';

IF @OrgID IS NULL
BEGIN
    RAISERROR('Organisation "Three Rocks Hotel" not found -- Section 1 must run first.', 16, 1);
    RETURN;
END
IF @MewsIntID IS NULL
BEGIN
    RAISERROR('Integration "Mews001" not found -- Section 2 must run first.', 16, 1);
    RETURN;
END
IF @GrowyzeIntID IS NULL
BEGIN
    RAISERROR('Integration "Growyze001" not found on this environment -- expected it to already exist on UAT.', 16, 1);
    RETURN;
END

----------------------------------------------------------------------
-- 5. MapOrganisationToIntegration -- org -> Mews001, org -> Growyze001
--    Fires trg_OrganisationIntegrations_AfterInsert, which creates the
--    int_mews001 / int_growyze001 schemas + DL_* tables in the new org's
--    client database from each integration's STAGE_DDL config (Section 3
--    for Mews; Growyze's config already exists from its prior UAT rollout).
----------------------------------------------------------------------
EXEC [core].[MapOrganisationToIntegration]
    @OrganisationID = @OrgID,
    @IntegrationID = @MewsIntID,
    @Notes = N'Marge Brut live dashboard (Task 9) -- POS source';

EXEC [core].[MapOrganisationToIntegration]
    @OrganisationID = @OrgID,
    @IntegrationID = @GrowyzeIntID,
    @Notes = N'Marge Brut live dashboard (Task 9) -- Inventory source';

PRINT 'Mapped "Three Rocks Hotel" to Mews001 and Growyze001.';
GO

----------------------------------------------------------------------
-- 6. Verification -- CAPTURE these values for later deploy steps
----------------------------------------------------------------------
SELECT
    o.[OrganisationID],
    o.[OrganisationName],
    o.[OrganisationCode]                       AS [OrgId_for_report_config],
    o.[OrganisationPrefix]                     AS [DbPrefix_for_report_config],
    o.[DatabaseName],
    o.[DatabaseCreationRequested],
    (SELECT COUNT(*) FROM [core].[OrganisationIntegrations] oi WHERE oi.[OrganisationID] = o.[OrganisationID]) AS [IntegrationMappingCount]
FROM [core].[Organisations] o
WHERE o.[OrganisationName] = N'Three Rocks Hotel';

SELECT i.[IntegrationName], i.[IntegrationID], i.[IntegrationType], i.[SchemaName], i.[SchemaCreated]
FROM [core].[OrganisationIntegrations] oi
JOIN [core].[Integrations] i ON i.[IntegrationID] = oi.[IntegrationID]
JOIN [core].[Organisations] o ON o.[OrganisationID] = oi.[OrganisationID]
WHERE o.[OrganisationName] = N'Three Rocks Hotel';
GO
