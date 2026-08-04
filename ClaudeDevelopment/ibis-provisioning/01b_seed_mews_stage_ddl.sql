/* ============================================================================
   O19 · 01b — Seed the int_mews001 STAGE_DDL into the target env's core DB
   ----------------------------------------------------------------------------
   Run against : core                    Envs: Test, UAT, Prod
   Executed by : Andy, via the PowerShell runner
   Order       : AFTER 01 (which registers Mews001 + creates the int_mews001
                 schema and its GlobalParameters table) and BEFORE 03 (mapping),
                 because the org↔integration trigger reads these rows to build
                 the DL_* tables in each org DB at mapping time.
   Idempotent  : MERGE on ParameterKey — safe to re-run.

   SOURCE: extracted verbatim from DEV [core].[int_mews001].[GlobalParameters]
   (Category='STAGE_DDL', 22 rows) on 2026-07-22. Whitespace inside each DDL
   was collapsed to single spaces (CREATE TABLE is whitespace-insensitive);
   column names/order are byte-faithful to DEV so they match the fetcher's
   JSON:API landing shape. ParameterID is an identity column and is omitted.

   ⚠ GDPR — DL_CUSTOMERS is DELIBERATELY OMITTED (Andy, 2026-07-24). The Mews
   CRM lane is GDPR-removed at the staging/DV level (Mews/05_remove_crm_pii.sql)
   and Marge Brut needs turnover + consumption, not CRM. Dropping the DL table
   here physically prevents PII (name/email/phone/address/DOB) ever landing for
   the Ibis orgs. Result is 21 DL_* rows (not the 22 present in DEV). If the CRM
   lane is ever wanted, restore the DL_CUSTOMERS row from git history AND drop
   the customers endpoint ban with the fetcher team.
   ============================================================================ */
SET NOCOUNT ON;

IF OBJECT_ID(N'[core].[int_mews001].[GlobalParameters]') IS NULL
BEGIN
    RAISERROR('int_mews001.GlobalParameters not found — run 01_register_mews_integration.sql first.', 16, 1);
    RETURN;
END

MERGE INTO [core].[int_mews001].[GlobalParameters] AS tgt
USING (VALUES
    (N'DL_AREAS', N'CREATE TABLE [int_mews001].[DL_AREAS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [isActive] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_AREAS'),
    (N'DL_BOOKINGS', N'CREATE TABLE [int_mews001].[DL_BOOKINGS](  [id] [nvarchar](max) NULL,  [bookingDatetime] [nvarchar](max) NULL,  [covers] [nvarchar](max) NULL,  [notes] [nvarchar](max) NULL,  [status] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [customerId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_BOOKINGS'),
    /* DL_CUSTOMERS deliberately omitted — GDPR (see header). */
    (N'DL_INVOICE_ITEMS', N'CREATE TABLE [int_mews001].[DL_INVOICE_ITEMS](  [id] [nvarchar](max) NULL,  [productName] [nvarchar](max) NULL,  [unitPriceInclTax] [nvarchar](max) NULL,  [subtotal] [nvarchar](max) NULL,  [quantity] [nvarchar](max) NULL,  [comp] [nvarchar](max) NULL,  [void] [nvarchar](max) NULL,  [isComp] [nvarchar](max) NULL,  [isVoid] [nvarchar](max) NULL,  [compVoidReason] [nvarchar](max) NULL,  [compVoidNotes] [nvarchar](max) NULL,  [discountAmount] [nvarchar](max) NULL,  [discount] [nvarchar](max) NULL,  [tax] [nvarchar](max) NULL,  [total] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [productId] [nvarchar](max) NULL,  [productVariantId] [nvarchar](max) NULL,  [revenueCenterId] [nvarchar](max) NULL,  [invoiceId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_INVOICE_ITEMS'),
    (N'DL_INVOICES', N'CREATE TABLE [int_mews001].[DL_INVOICES](  [id] [nvarchar](max) NULL,  [discount] [nvarchar](max) NULL,  [tax] [nvarchar](max) NULL,  [total] [nvarchar](max) NULL,  [subtotal] [nvarchar](max) NULL,  [cancelled] [nvarchar](max) NULL,  [cancelReason] [nvarchar](max) NULL,  [discountAmount] [nvarchar](max) NULL,  [description] [nvarchar](max) NULL,  [itemDiscountAmount] [nvarchar](max) NULL,  [tipAmount] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [userId] [nvarchar](max) NULL,  [orderId] [nvarchar](max) NULL,  [registerId] [nvarchar](max) NULL,  [originalInvoiceId] [nvarchar](max) NULL,  [promoCodeId] [nvarchar](max) NULL,  [revenueCenterId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_INVOICES'),
    (N'DL_MENUS', N'CREATE TABLE [int_mews001].[DL_MENUS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [status] [nvarchar](max) NULL,  [description] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_MENUS'),
    (N'DL_MODIFIER_SETS', N'CREATE TABLE [int_mews001].[DL_MODIFIER_SETS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [selection] [nvarchar](max) NULL,  [minimumCount] [nvarchar](max) NULL,  [maximumCount] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_MODIFIER_SETS'),
    (N'DL_MODIFIERS', N'CREATE TABLE [int_mews001].[DL_MODIFIERS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [price] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [modifierSetId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_MODIFIERS'),
    (N'DL_ORDER_ITEM_MODIFIERS', N'CREATE TABLE [int_mews001].[DL_ORDER_ITEM_MODIFIERS](  [id] [nvarchar](max) NULL,  [orderItemId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_ORDER_ITEM_MODIFIERS'),
    (N'DL_ORDER_ITEMS', N'CREATE TABLE [int_mews001].[DL_ORDER_ITEMS](  [id] [nvarchar](max) NULL,  [quantity] [nvarchar](max) NULL,  [total] [nvarchar](max) NULL,  [unitPriceInclTax] [nvarchar](max) NULL,  [tax] [nvarchar](max) NULL,  [subtotal] [nvarchar](max) NULL,  [discount] [nvarchar](max) NULL,  [discountType] [nvarchar](max) NULL,  [discountDescription] [nvarchar](max) NULL,  [isComp] [nvarchar](max) NULL,  [isVoid] [nvarchar](max) NULL,  [notes] [nvarchar](max) NULL,  [compVoidReason] [nvarchar](max) NULL,  [compVoidNotes] [nvarchar](max) NULL,  [productId] [nvarchar](max) NULL,  [productVariantId] [nvarchar](max) NULL,  [orderId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_ORDER_ITEMS'),
    (N'DL_ORDERS', N'CREATE TABLE [int_mews001].[DL_ORDERS](  [id] [nvarchar](max) NULL,  [notes] [nvarchar](max) NULL,  [covers] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [tableStatus] [nvarchar](max) NULL,  [status] [nvarchar](max) NULL,  [state] [nvarchar](max) NULL,  [depositAmount] [nvarchar](max) NULL,  [invoiceId] [nvarchar](max) NULL,  [customerId] [nvarchar](max) NULL,  [bookingId] [nvarchar](max) NULL,  [outletId] [nvarchar](max) NULL,  [revenueCenterId] [nvarchar](max) NULL,  [promoCodeId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_ORDERS'),
    (N'DL_OUTLETS', N'CREATE TABLE [int_mews001].[DL_OUTLETS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [address1] [nvarchar](max) NULL,  [address2] [nvarchar](max) NULL,  [city] [nvarchar](max) NULL,  [state] [nvarchar](max) NULL,  [index] [nvarchar](max) NULL,  [postalCode] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_OUTLETS'),
    (N'DL_PAYMENT_METHODS', N'CREATE TABLE [int_mews001].[DL_PAYMENT_METHODS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [active] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_PAYMENT_METHODS'),
    (N'DL_PRODUCT_BUNDLES', N'CREATE TABLE [int_mews001].[DL_PRODUCT_BUNDLES](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [description] [nvarchar](max) NULL,  [imageUrl] [nvarchar](max) NULL,  [priceRange_min] [nvarchar](max) NULL,  [priceRange_max] [nvarchar](max) NULL,  [retailPriceInclTax] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_PRODUCT_BUNDLES'),
    (N'DL_PRODUCT_TYPES', N'CREATE TABLE [int_mews001].[DL_PRODUCT_TYPES](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_PRODUCT_TYPES'),
    (N'DL_PRODUCT_VARIANTS', N'CREATE TABLE [int_mews001].[DL_PRODUCT_VARIANTS](  [id] [nvarchar](max) NULL,  [sku] [nvarchar](max) NULL,  [barcode] [nvarchar](max) NULL,  [selector] [nvarchar](max) NULL,  [tax] [nvarchar](max) NULL,  [retailPriceInclTax] [nvarchar](max) NULL,  [retailPriceExclTax] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [productId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_PRODUCT_VARIANTS'),
    (N'DL_PRODUCTS', N'CREATE TABLE [int_mews001].[DL_PRODUCTS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [description] [nvarchar](max) NULL,  [sku] [nvarchar](max) NULL,  [status] [nvarchar](max) NULL,  [barcode] [nvarchar](max) NULL,  [isAvailable] [nvarchar](max) NULL,  [tax] [nvarchar](max) NULL,  [retailPriceInclTax] [nvarchar](max) NULL,  [retailPriceExclTax] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [productTypeId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_PRODUCTS'),
    (N'DL_PROMO_CODES', N'CREATE TABLE [int_mews001].[DL_PROMO_CODES](  [id] [nvarchar](max) NULL,  [discountType] [nvarchar](max) NULL,  [amount] [nvarchar](max) NULL,  [channel] [nvarchar](max) NULL,  [code] [nvarchar](max) NULL,  [active] [nvarchar](max) NULL,  [description] [nvarchar](max) NULL,  [maxUsages] [nvarchar](max) NULL,  [startsAt] [nvarchar](max) NULL,  [endsAt] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_PROMO_CODES'),
    (N'DL_REGISTERS', N'CREATE TABLE [int_mews001].[DL_REGISTERS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [invoicesCount] [nvarchar](max) NULL,  [index] [nvarchar](max) NULL,  [virtual] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [outletId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_REGISTERS'),
    (N'DL_REVENUE_CENTERS', N'CREATE TABLE [int_mews001].[DL_REVENUE_CENTERS](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [isActive] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_REVENUE_CENTERS'),
    (N'DL_TABLES', N'CREATE TABLE [int_mews001].[DL_TABLES](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [numberOfSeats] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [areaId] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_TABLES'),
    (N'DL_TAXES', N'CREATE TABLE [int_mews001].[DL_TAXES](  [id] [nvarchar](max) NULL,  [name] [nvarchar](max) NULL,  [rate] [nvarchar](max) NULL,  [createdAt] [nvarchar](max) NULL,  [updatedAt] [nvarchar](max) NULL,  [LOADTS_UTC] [datetime2](7) NULL,  [INT_FETCH_DATE] [datetime2](7) NULL );', N'STRING', N'STAGE_DDL', N'DL_TAXES')
) AS src (ParameterKey, ParameterValue, DataType, Category, Description)
ON tgt.ParameterKey = src.ParameterKey
WHEN MATCHED THEN UPDATE SET
    tgt.ParameterValue = src.ParameterValue,
    tgt.DataType       = src.DataType,
    tgt.Category       = src.Category,
    tgt.Description    = src.Description,
    tgt.IsActive       = 1,
    tgt.ModifiedBy     = SYSTEM_USER,
    tgt.ModifiedDate   = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (src.ParameterKey, src.ParameterValue, src.DataType, src.Category, src.Description, 1, SYSTEM_USER, GETDATE(), 1);

/* Confirm — expect 21 rows (DL_CUSTOMERS omitted for GDPR) */
SELECT ParameterKey, LEN(ParameterValue) AS val_len, IsActive
FROM   [core].[int_mews001].[GlobalParameters]
WHERE  Category = N'STAGE_DDL'
ORDER  BY ParameterKey;
