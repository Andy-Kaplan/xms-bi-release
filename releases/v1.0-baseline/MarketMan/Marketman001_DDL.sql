-- ============================================
-- STAGE_DDL Parameters Export
-- Source: UAT [core].[int_marketman001].[GlobalParameters]
-- Generated: 2026-06-02 10:45:23
-- Total Records: 34
-- ============================================

-- ParameterKey=DL_ACTUAL_VS_THEO / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ACTUAL_VS_THEO' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_ACTUAL_VS_THEO]
(
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ACTUAL_VS_THEO',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.023',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ACTUAL_VS_THEO' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ACTUAL_VS_THEO', N'CREATE TABLE [int_marketman001].[DL_ACTUAL_VS_THEO]
(
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_ACTUAL_VS_THEO', 1, N'dbadmin', '2026-01-07 10:31:47.023', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS]
(
    [RequestID] nvarchar(MAX) NULL,
    [COGSCategory] nvarchar(MAX) NULL,
    [COGSCategoryID] nvarchar(MAX) NULL,
    [CategorySales] nvarchar(MAX) NULL,
    [ActualUsage] nvarchar(MAX) NULL,
    [ActualUsagePercent] nvarchar(MAX) NULL,
    [ActualGrossProfit] nvarchar(MAX) NULL,
    [ActualGPPercent] nvarchar(MAX) NULL,
    [TheoreticalUsage] nvarchar(MAX) NULL,
    [TheoreticalUsagePercent] nvarchar(MAX) NULL,
    [TheoreticalGrossProfit] nvarchar(MAX) NULL,
    [TheoreticalGPPercent] nvarchar(MAX) NULL,
    [CategoryVariance] nvarchar(MAX) NULL,
    [GPPercentVariance] nvarchar(MAX) NULL,
    [WasteValue] nvarchar(MAX) NULL,
    [VarianceValueExcludingWaste] nvarchar(MAX) NULL,
    [VariancePercentExcludingWaste] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.133',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS', N'CREATE TABLE [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS]
(
    [RequestID] nvarchar(MAX) NULL,
    [COGSCategory] nvarchar(MAX) NULL,
    [COGSCategoryID] nvarchar(MAX) NULL,
    [CategorySales] nvarchar(MAX) NULL,
    [ActualUsage] nvarchar(MAX) NULL,
    [ActualUsagePercent] nvarchar(MAX) NULL,
    [ActualGrossProfit] nvarchar(MAX) NULL,
    [ActualGPPercent] nvarchar(MAX) NULL,
    [TheoreticalUsage] nvarchar(MAX) NULL,
    [TheoreticalUsagePercent] nvarchar(MAX) NULL,
    [TheoreticalGrossProfit] nvarchar(MAX) NULL,
    [TheoreticalGPPercent] nvarchar(MAX) NULL,
    [CategoryVariance] nvarchar(MAX) NULL,
    [GPPercentVariance] nvarchar(MAX) NULL,
    [WasteValue] nvarchar(MAX) NULL,
    [VarianceValueExcludingWaste] nvarchar(MAX) NULL,
    [VariancePercentExcludingWaste] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_ACTUAL_VS_THEO_ACTUALTHEOCATEGORIESTOTALSROWS', 1, N'dbadmin', '2026-01-07 10:31:47.133', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
(
    [RequestID] nvarchar(MAX) NULL,
    [CostByBlendedAverageByReportingUOM] nvarchar(MAX) NULL,
    [TheoreticalUsageCostInReportingUOM] nvarchar(MAX) NULL,
    [VarianceValueInReportingUOM] nvarchar(MAX) NULL,
    [VarianceValueExcludingWasteInReportingUOM] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerID] nvarchar(MAX) NULL,
    [BueyrGuid] nvarchar(MAX) NULL,
    [Category] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [UOM] nvarchar(MAX) NULL,
    [ReportingUOM] nvarchar(MAX) NULL,
    [ActualUsage] nvarchar(MAX) NULL,
    [ActualUsageInReportingUOM] nvarchar(MAX) NULL,
    [COGS] nvarchar(MAX) NULL,
    [SalesUsage] nvarchar(MAX) NULL,
    [SalesUsageInReportingUOM] nvarchar(MAX) NULL,
    [DeliveryNotesUsage] nvarchar(MAX) NULL,
    [DeliveryNotesUsageInReportingUOM] nvarchar(MAX) NULL,
    [Production] nvarchar(MAX) NULL,
    [ProductionInReportingUOM] nvarchar(MAX) NULL,
    [TheoreticalUsage] nvarchar(MAX) NULL,
    [TheoreticalUsageInReportingUOM] nvarchar(MAX) NULL,
    [CostByBlendedAverage] nvarchar(MAX) NULL,
    [TheoreticalUsageCost] nvarchar(MAX) NULL,
    [VarianceQTY] nvarchar(MAX) NULL,
    [VarianceQTYInReportingUOM] nvarchar(MAX) NULL,
    [VarianceValue] nvarchar(MAX) NULL,
    [VarianceValueExcludingWaste] nvarchar(MAX) NULL,
    [VariancePercent] nvarchar(MAX) NULL,
    [RecordedWaste] nvarchar(MAX) NULL,
    [WasteValue] nvarchar(MAX) NULL,
    [RecordedWasteInReportingUOM] nvarchar(MAX) NULL,
    [WasteValueInReportingUOM] nvarchar(MAX) NULL,
    [NoneRecordedVarianceQTY] nvarchar(MAX) NULL,
    [NoneRecordedVarianceQTYReportingUOM] nvarchar(MAX) NULL,
    [COGSCategory] nvarchar(MAX) NULL,
    [COGSCategoryID] nvarchar(MAX) NULL,
    [IsHasTwoCounts] nvarchar(MAX) NULL,
    [OpeningInventory] nvarchar(MAX) NULL,
    [OpeningInventoryInReportingUOM] nvarchar(MAX) NULL,
    [ClosingInventory] nvarchar(MAX) NULL,
    [ClosingInventoryInReportingUOM] nvarchar(MAX) NULL,
    [PurchaseQty] nvarchar(MAX) NULL,
    [PurchaseQtyInReportingUOM] nvarchar(MAX) NULL,
    [TransferQty] nvarchar(MAX) NULL,
    [TransferQtyInReportingUOM] nvarchar(MAX) NULL,
    [OpeningValue] nvarchar(MAX) NULL,
    [ClosingValue] nvarchar(MAX) NULL,
    [PurchaseValue] nvarchar(MAX) NULL,
    [TransferValue] nvarchar(MAX) NULL,
    [OnHandUOMConversationRatio] nvarchar(MAX) NULL,
    [IsHavingAutomatedZeroCount] nvarchar(MAX) NULL,
    [HasOpenRefundNote] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.220',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS', N'CREATE TABLE [int_marketman001].[DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS]
(
    [RequestID] nvarchar(MAX) NULL,
    [CostByBlendedAverageByReportingUOM] nvarchar(MAX) NULL,
    [TheoreticalUsageCostInReportingUOM] nvarchar(MAX) NULL,
    [VarianceValueInReportingUOM] nvarchar(MAX) NULL,
    [VarianceValueExcludingWasteInReportingUOM] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerID] nvarchar(MAX) NULL,
    [BueyrGuid] nvarchar(MAX) NULL,
    [Category] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [UOM] nvarchar(MAX) NULL,
    [ReportingUOM] nvarchar(MAX) NULL,
    [ActualUsage] nvarchar(MAX) NULL,
    [ActualUsageInReportingUOM] nvarchar(MAX) NULL,
    [COGS] nvarchar(MAX) NULL,
    [SalesUsage] nvarchar(MAX) NULL,
    [SalesUsageInReportingUOM] nvarchar(MAX) NULL,
    [DeliveryNotesUsage] nvarchar(MAX) NULL,
    [DeliveryNotesUsageInReportingUOM] nvarchar(MAX) NULL,
    [Production] nvarchar(MAX) NULL,
    [ProductionInReportingUOM] nvarchar(MAX) NULL,
    [TheoreticalUsage] nvarchar(MAX) NULL,
    [TheoreticalUsageInReportingUOM] nvarchar(MAX) NULL,
    [CostByBlendedAverage] nvarchar(MAX) NULL,
    [TheoreticalUsageCost] nvarchar(MAX) NULL,
    [VarianceQTY] nvarchar(MAX) NULL,
    [VarianceQTYInReportingUOM] nvarchar(MAX) NULL,
    [VarianceValue] nvarchar(MAX) NULL,
    [VarianceValueExcludingWaste] nvarchar(MAX) NULL,
    [VariancePercent] nvarchar(MAX) NULL,
    [RecordedWaste] nvarchar(MAX) NULL,
    [WasteValue] nvarchar(MAX) NULL,
    [RecordedWasteInReportingUOM] nvarchar(MAX) NULL,
    [WasteValueInReportingUOM] nvarchar(MAX) NULL,
    [NoneRecordedVarianceQTY] nvarchar(MAX) NULL,
    [NoneRecordedVarianceQTYReportingUOM] nvarchar(MAX) NULL,
    [COGSCategory] nvarchar(MAX) NULL,
    [COGSCategoryID] nvarchar(MAX) NULL,
    [IsHasTwoCounts] nvarchar(MAX) NULL,
    [OpeningInventory] nvarchar(MAX) NULL,
    [OpeningInventoryInReportingUOM] nvarchar(MAX) NULL,
    [ClosingInventory] nvarchar(MAX) NULL,
    [ClosingInventoryInReportingUOM] nvarchar(MAX) NULL,
    [PurchaseQty] nvarchar(MAX) NULL,
    [PurchaseQtyInReportingUOM] nvarchar(MAX) NULL,
    [TransferQty] nvarchar(MAX) NULL,
    [TransferQtyInReportingUOM] nvarchar(MAX) NULL,
    [OpeningValue] nvarchar(MAX) NULL,
    [ClosingValue] nvarchar(MAX) NULL,
    [PurchaseValue] nvarchar(MAX) NULL,
    [TransferValue] nvarchar(MAX) NULL,
    [OnHandUOMConversationRatio] nvarchar(MAX) NULL,
    [IsHavingAutomatedZeroCount] nvarchar(MAX) NULL,
    [HasOpenRefundNote] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_ACTUAL_VS_THEO_ACTUALTHEODATAROWS', 1, N'dbadmin', '2026-01-07 10:31:47.220', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_BUYER_USERS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_BUYER_USERS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_BUYER_USERS]
(
    [ID] nvarchar(MAX) NULL,
    [FirstName] nvarchar(MAX) NULL,
    [LastName] nvarchar(MAX) NULL,
    [Email] nvarchar(MAX) NULL,
    [MobilePhone] nvarchar(MAX) NULL,
    [UserName] nvarchar(MAX) NULL,
    [Role] nvarchar(MAX) NULL,
    [BuyerUserGuid] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_BUYER_USERS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.270',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_BUYER_USERS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_BUYER_USERS', N'CREATE TABLE [int_marketman001].[DL_BUYER_USERS]
(
    [ID] nvarchar(MAX) NULL,
    [FirstName] nvarchar(MAX) NULL,
    [LastName] nvarchar(MAX) NULL,
    [Email] nvarchar(MAX) NULL,
    [MobilePhone] nvarchar(MAX) NULL,
    [UserName] nvarchar(MAX) NULL,
    [Role] nvarchar(MAX) NULL,
    [BuyerUserGuid] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_BUYER_USERS', 1, N'dbadmin', '2026-01-07 10:31:47.270', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_CATEGORIES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CATEGORIES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_CATEGORIES]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [ExpenseAccount] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CATEGORIES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.303',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CATEGORIES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CATEGORIES', N'CREATE TABLE [int_marketman001].[DL_CATEGORIES]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [ExpenseAccount] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_CATEGORIES', 1, N'dbadmin', '2026-01-07 10:31:47.303', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_DOCS_BY_DATE / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_DOCS_BY_DATE' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_DOCS_BY_DATE]
(
    [DocNumber] nvarchar(MAX) NULL,
    [Guid] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [VendorName] nvarchar(MAX) NULL,
    [DocTypeID] nvarchar(MAX) NULL,
    [DocType] nvarchar(MAX) NULL,
    [DateUTC] nvarchar(MAX) NULL,
    [DueDateUTC] nvarchar(MAX) NULL,
    [PriceTotalWithVAT] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [Comments] nvarchar(MAX) NULL,
    [VendorGuid] nvarchar(MAX) NULL,
    [OrderNumber] nvarchar(MAX) NULL,
    [OpenCredits] nvarchar(MAX) NULL,
    [IsAccountingSynced] nvarchar(MAX) NULL,
    [DocStatusID] nvarchar(MAX) NULL,
    [DocStatusType] nvarchar(MAX) NULL,
    [PriceDiscountValue] nvarchar(MAX) NULL,
    [PriceDiscountPercentage] nvarchar(MAX) NULL,
    [PriceCredit] nvarchar(MAX) NULL,
    [QuantityCredit] nvarchar(MAX) NULL,
    [VendorIRSNumber] nvarchar(MAX) NULL,
    [ExpenseAccount] nvarchar(MAX) NULL,
    [IsLocked] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_DOCS_BY_DATE',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.416',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_DOCS_BY_DATE' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_DOCS_BY_DATE', N'CREATE TABLE [int_marketman001].[DL_DOCS_BY_DATE]
(
    [DocNumber] nvarchar(MAX) NULL,
    [Guid] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [VendorName] nvarchar(MAX) NULL,
    [DocTypeID] nvarchar(MAX) NULL,
    [DocType] nvarchar(MAX) NULL,
    [DateUTC] nvarchar(MAX) NULL,
    [DueDateUTC] nvarchar(MAX) NULL,
    [PriceTotalWithVAT] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [Comments] nvarchar(MAX) NULL,
    [VendorGuid] nvarchar(MAX) NULL,
    [OrderNumber] nvarchar(MAX) NULL,
    [OpenCredits] nvarchar(MAX) NULL,
    [IsAccountingSynced] nvarchar(MAX) NULL,
    [DocStatusID] nvarchar(MAX) NULL,
    [DocStatusType] nvarchar(MAX) NULL,
    [PriceDiscountValue] nvarchar(MAX) NULL,
    [PriceDiscountPercentage] nvarchar(MAX) NULL,
    [PriceCredit] nvarchar(MAX) NULL,
    [QuantityCredit] nvarchar(MAX) NULL,
    [VendorIRSNumber] nvarchar(MAX) NULL,
    [ExpenseAccount] nvarchar(MAX) NULL,
    [IsLocked] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_DOCS_BY_DATE', 1, N'dbadmin', '2026-01-07 10:31:47.416', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_DOCS_BY_DATE_HISTORYLOG / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_DOCS_BY_DATE_HISTORYLOG' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_DOCS_BY_DATE_HISTORYLOG]
(
    [DocNumber] nvarchar(MAX) NULL,
    [ID] nvarchar(MAX) NULL,
    [DocID] nvarchar(MAX) NULL,
    [ActionTitle] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [CreatedDate] nvarchar(MAX) NULL,
    [CreatedDateUTC] nvarchar(MAX) NULL,
    [TotalPrice] nvarchar(MAX) NULL,
    [CreatedByBuyer] nvarchar(MAX) NULL,
    [BuyerUserName] nvarchar(MAX) NULL,
    [BuyerGUID] nvarchar(MAX) NULL,
    [ActionID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_DOCS_BY_DATE_HISTORYLOG',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.470',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_DOCS_BY_DATE_HISTORYLOG' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_DOCS_BY_DATE_HISTORYLOG', N'CREATE TABLE [int_marketman001].[DL_DOCS_BY_DATE_HISTORYLOG]
(
    [DocNumber] nvarchar(MAX) NULL,
    [ID] nvarchar(MAX) NULL,
    [DocID] nvarchar(MAX) NULL,
    [ActionTitle] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [CreatedDate] nvarchar(MAX) NULL,
    [CreatedDateUTC] nvarchar(MAX) NULL,
    [TotalPrice] nvarchar(MAX) NULL,
    [CreatedByBuyer] nvarchar(MAX) NULL,
    [BuyerUserName] nvarchar(MAX) NULL,
    [BuyerGUID] nvarchar(MAX) NULL,
    [ActionID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_DOCS_BY_DATE_HISTORYLOG', 1, N'dbadmin', '2026-01-07 10:31:47.470', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_DOCS_BY_DATE_ITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_DOCS_BY_DATE_ITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_DOCS_BY_DATE_ITEMS]
(
    [DocNumber] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [SKU] nvarchar(MAX) NULL,
    [OrderQuantity] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [Price] nvarchar(MAX) NULL,
    [ReceiveQuantity] nvarchar(MAX) NULL,
    [PriceTotal] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [PriceTotalWithVAT] nvarchar(MAX) NULL,
    [CatalogItemID] nvarchar(MAX) NULL,
    [CatalogItemCode] nvarchar(MAX) NULL,
    [DiscountPercent] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [TaxValue] nvarchar(MAX) NULL,
    [ItemMeasureTypeID] nvarchar(MAX) NULL,
    [ItemMeasureTypeName] nvarchar(MAX) NULL,
    [PackQuantity] nvarchar(MAX) NULL,
    [PacksPerCase] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_DOCS_BY_DATE_ITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.566',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_DOCS_BY_DATE_ITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_DOCS_BY_DATE_ITEMS', N'CREATE TABLE [int_marketman001].[DL_DOCS_BY_DATE_ITEMS]
(
    [DocNumber] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [SKU] nvarchar(MAX) NULL,
    [OrderQuantity] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [Price] nvarchar(MAX) NULL,
    [ReceiveQuantity] nvarchar(MAX) NULL,
    [PriceTotal] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [PriceTotalWithVAT] nvarchar(MAX) NULL,
    [CatalogItemID] nvarchar(MAX) NULL,
    [CatalogItemCode] nvarchar(MAX) NULL,
    [DiscountPercent] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [TaxValue] nvarchar(MAX) NULL,
    [ItemMeasureTypeID] nvarchar(MAX) NULL,
    [ItemMeasureTypeName] nvarchar(MAX) NULL,
    [PackQuantity] nvarchar(MAX) NULL,
    [PacksPerCase] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_DOCS_BY_DATE_ITEMS', 1, N'dbadmin', '2026-01-07 10:31:47.566', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_COUNTS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_COUNTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_COUNTS]
(
    [ID] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [CountDateUTC] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [Commments] nvarchar(MAX) NULL,
    [IsLocked] nvarchar(MAX) NULL,
    [CountDateType] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_COUNTS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.663',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_COUNTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_COUNTS', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_COUNTS]
(
    [ID] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [CountDateUTC] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [Commments] nvarchar(MAX) NULL,
    [IsLocked] nvarchar(MAX) NULL,
    [CountDateType] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_COUNTS', 1, N'dbadmin', '2026-01-07 10:31:47.663', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_COUNTS_LINES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_COUNTS_LINES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_COUNTS_LINES]
(
    [ID] nvarchar(MAX) NULL,
    [LineID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [ParentItemID] nvarchar(MAX) NULL,
    [TotalCount] nvarchar(MAX) NULL,
    [TotalValue] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_COUNTS_LINES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.776',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_COUNTS_LINES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_COUNTS_LINES', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_COUNTS_LINES]
(
    [ID] nvarchar(MAX) NULL,
    [LineID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [ParentItemID] nvarchar(MAX) NULL,
    [TotalCount] nvarchar(MAX) NULL,
    [TotalValue] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_COUNTS_LINES', 1, N'dbadmin', '2026-01-07 10:31:47.776', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS]
(
    [ID] nvarchar(MAX) NULL,
    [Lines_id] nvarchar(MAX) NULL,
    [CountDefID] nvarchar(MAX) NULL,
    [CountDefName] nvarchar(MAX) NULL,
    [CountDefAmount] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.880',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS]
(
    [ID] nvarchar(MAX) NULL,
    [Lines_id] nvarchar(MAX) NULL,
    [CountDefID] nvarchar(MAX) NULL,
    [CountDefName] nvarchar(MAX) NULL,
    [CountDefAmount] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_COUNTS_LINES_COUNTDEFDETAILS', 1, N'dbadmin', '2026-01-07 10:31:47.880', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_ITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_ITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_ITEMS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [AboutTheItem] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [ReportingUOM] nvarchar(MAX) NULL,
    [MinOnHand] nvarchar(MAX) NULL,
    [ParLevel] nvarchar(MAX) NULL,
    [MinOrderQty] nvarchar(MAX) NULL,
    [MaxOrderQty] nvarchar(MAX) NULL,
    [DateRangeType] nvarchar(MAX) NULL,
    [OnHand] nvarchar(MAX) NULL,
    [BOMPrice] nvarchar(MAX) NULL,
    [DebitAccountName] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [CountDefOptions] nvarchar(MAX) NULL,
    [MaxTakeAllowed] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [Page_Skip] nvarchar(MAX) NULL,
    [Page_Take] nvarchar(MAX) NULL,
    [Page_Total] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_ITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:47.990',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_ITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_ITEMS', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_ITEMS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [AboutTheItem] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [ReportingUOM] nvarchar(MAX) NULL,
    [MinOnHand] nvarchar(MAX) NULL,
    [ParLevel] nvarchar(MAX) NULL,
    [MinOrderQty] nvarchar(MAX) NULL,
    [MaxOrderQty] nvarchar(MAX) NULL,
    [DateRangeType] nvarchar(MAX) NULL,
    [OnHand] nvarchar(MAX) NULL,
    [BOMPrice] nvarchar(MAX) NULL,
    [DebitAccountName] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [CountDefOptions] nvarchar(MAX) NULL,
    [MaxTakeAllowed] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [Page_Skip] nvarchar(MAX) NULL,
    [Page_Take] nvarchar(MAX) NULL,
    [Page_Total] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_ITEMS', 1, N'dbadmin', '2026-01-07 10:31:47.990', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_ITEMS_PURCHASEITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_ITEMS_PURCHASEITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [SupplierName] nvarchar(MAX) NULL,
    [VendorName] nvarchar(MAX) NULL,
    [PackQty] nvarchar(MAX) NULL,
    [PacksPerCase] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [ProductCode] nvarchar(MAX) NULL,
    [Price] nvarchar(MAX) NULL,
    [MinOrderQty] nvarchar(MAX) NULL,
    [PriceType] nvarchar(MAX) NULL,
    [Ratio] nvarchar(MAX) NULL,
    [VendorGuid] nvarchar(MAX) NULL,
    [CatalogItemCode] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [TaxValue] nvarchar(MAX) NULL,
    [PriceWithVat] nvarchar(MAX) NULL,
    [ScanBarcode] nvarchar(MAX) NULL,
    [IsMainPurchaseOption] nvarchar(MAX) NULL,
    [DeletedFromSupplier] nvarchar(MAX) NULL,
    [IsForOrdering] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_ITEMS_PURCHASEITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.040',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_ITEMS_PURCHASEITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_ITEMS_PURCHASEITEMS', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_ITEMS_PURCHASEITEMS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [SupplierName] nvarchar(MAX) NULL,
    [VendorName] nvarchar(MAX) NULL,
    [PackQty] nvarchar(MAX) NULL,
    [PacksPerCase] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [ProductCode] nvarchar(MAX) NULL,
    [Price] nvarchar(MAX) NULL,
    [MinOrderQty] nvarchar(MAX) NULL,
    [PriceType] nvarchar(MAX) NULL,
    [Ratio] nvarchar(MAX) NULL,
    [VendorGuid] nvarchar(MAX) NULL,
    [CatalogItemCode] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [TaxValue] nvarchar(MAX) NULL,
    [PriceWithVat] nvarchar(MAX) NULL,
    [ScanBarcode] nvarchar(MAX) NULL,
    [IsMainPurchaseOption] nvarchar(MAX) NULL,
    [DeletedFromSupplier] nvarchar(MAX) NULL,
    [IsForOrdering] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_ITEMS_PURCHASEITEMS', 1, N'dbadmin', '2026-01-07 10:31:48.040', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_PREPS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_PREPS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_PREPS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [IsSelfStock] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [MinOnHand] nvarchar(MAX) NULL,
    [ParLevel] nvarchar(MAX) NULL,
    [ProdQuantity] nvarchar(MAX) NULL,
    [OnHand] nvarchar(MAX) NULL,
    [BOMPrice] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [MaxTakeAllowed] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [Page_Skip] nvarchar(MAX) NULL,
    [Page_Take] nvarchar(MAX) NULL,
    [Page_Total] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_PREPS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.143',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_PREPS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_PREPS', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_PREPS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [IsSelfStock] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [MinOnHand] nvarchar(MAX) NULL,
    [ParLevel] nvarchar(MAX) NULL,
    [ProdQuantity] nvarchar(MAX) NULL,
    [OnHand] nvarchar(MAX) NULL,
    [BOMPrice] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [MaxTakeAllowed] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [Page_Skip] nvarchar(MAX) NULL,
    [Page_Take] nvarchar(MAX) NULL,
    [Page_Total] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_PREPS', 1, N'dbadmin', '2026-01-07 10:31:48.143', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_INVENTORY_PREPS_SUBITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_INVENTORY_PREPS_SUBITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS]
(
    [header_item_id] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [ItemTypeName] nvarchar(MAX) NULL,
    [UsageNet] nvarchar(MAX) NULL,
    [LossPercent] nvarchar(MAX) NULL,
    [ActualUsage] nvarchar(MAX) NULL,
    [SortIndex] nvarchar(MAX) NULL,
    [ItemMeasureTypeID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_INVENTORY_PREPS_SUBITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.186',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_INVENTORY_PREPS_SUBITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_INVENTORY_PREPS_SUBITEMS', N'CREATE TABLE [int_marketman001].[DL_INVENTORY_PREPS_SUBITEMS]
(
    [header_item_id] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [ItemTypeName] nvarchar(MAX) NULL,
    [UsageNet] nvarchar(MAX) NULL,
    [LossPercent] nvarchar(MAX) NULL,
    [ActualUsage] nvarchar(MAX) NULL,
    [SortIndex] nvarchar(MAX) NULL,
    [ItemMeasureTypeID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_INVENTORY_PREPS_SUBITEMS', 1, N'dbadmin', '2026-01-07 10:31:48.186', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_MENU_ITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MENU_ITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_MENU_ITEMS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [POSCodes] nvarchar(MAX) NULL,
    [SalePriceWithoutVAT] nvarchar(MAX) NULL,
    [SalePriceWithVAT] nvarchar(MAX) NULL,
    [Type] nvarchar(MAX) NULL,
    [MinOnHand] nvarchar(MAX) NULL,
    [ParLevel] nvarchar(MAX) NULL,
    [BOMPrice] nvarchar(MAX) NULL,
    [BOMPriceFC] nvarchar(MAX) NULL,
    [MaxFC] nvarchar(MAX) NULL,
    [PrepTime] nvarchar(MAX) NULL,
    [CookTime] nvarchar(MAX) NULL,
    [CookingInstructions] nvarchar(MAX) NULL,
    [AboutTheItem] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [MaxTakeAllowed] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [Page_Skip] nvarchar(MAX) NULL,
    [Page_Take] nvarchar(MAX) NULL,
    [Page_Total] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MENU_ITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.280',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MENU_ITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MENU_ITEMS', N'CREATE TABLE [int_marketman001].[DL_MENU_ITEMS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [CategoryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [POSCodes] nvarchar(MAX) NULL,
    [SalePriceWithoutVAT] nvarchar(MAX) NULL,
    [SalePriceWithVAT] nvarchar(MAX) NULL,
    [Type] nvarchar(MAX) NULL,
    [MinOnHand] nvarchar(MAX) NULL,
    [ParLevel] nvarchar(MAX) NULL,
    [BOMPrice] nvarchar(MAX) NULL,
    [BOMPriceFC] nvarchar(MAX) NULL,
    [MaxFC] nvarchar(MAX) NULL,
    [PrepTime] nvarchar(MAX) NULL,
    [CookTime] nvarchar(MAX) NULL,
    [CookingInstructions] nvarchar(MAX) NULL,
    [AboutTheItem] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [MaxTakeAllowed] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [Page_Skip] nvarchar(MAX) NULL,
    [Page_Take] nvarchar(MAX) NULL,
    [Page_Total] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_MENU_ITEMS', 1, N'dbadmin', '2026-01-07 10:31:48.280', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_MENU_ITEMS_LOCATIONSYNCINFOS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MENU_ITEMS_LOCATIONSYNCINFOS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_MENU_ITEMS_LOCATIONSYNCINFOS]
(
    [ID] nvarchar(MAX) NULL,
    [TypeID] nvarchar(MAX) NULL,
    [POSCode] nvarchar(MAX) NULL,
    [Type] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MENU_ITEMS_LOCATIONSYNCINFOS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.376',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MENU_ITEMS_LOCATIONSYNCINFOS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MENU_ITEMS_LOCATIONSYNCINFOS', N'CREATE TABLE [int_marketman001].[DL_MENU_ITEMS_LOCATIONSYNCINFOS]
(
    [ID] nvarchar(MAX) NULL,
    [TypeID] nvarchar(MAX) NULL,
    [POSCode] nvarchar(MAX) NULL,
    [Type] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_MENU_ITEMS_LOCATIONSYNCINFOS', 1, N'dbadmin', '2026-01-07 10:31:48.376', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_MENU_ITEMS_SUBITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MENU_ITEMS_SUBITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_MENU_ITEMS_SUBITEMS](
 [ID] [nvarchar](max) NULL,
 [ItemID] [nvarchar](max) NULL,
 [ItemName] [nvarchar](max) NULL,
 [ItemTypeName] [nvarchar](max) NULL,
 [UsageNet] [nvarchar](max) NULL,
 [LossPercent] [nvarchar](max) NULL,
 [ActualUsage] [nvarchar](max) NULL,
 [SortIndex] [nvarchar](max) NULL,
 [ItemMeasureTypeID] [nvarchar](max) NULL,
 [storeId] [nvarchar](max) NULL,
 [LOADTS_UTC] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MENU_ITEMS_SUBITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 11:52:44.830',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MENU_ITEMS_SUBITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MENU_ITEMS_SUBITEMS', N'CREATE TABLE [int_marketman001].[DL_MENU_ITEMS_SUBITEMS](
 [ID] [nvarchar](max) NULL,
 [ItemID] [nvarchar](max) NULL,
 [ItemName] [nvarchar](max) NULL,
 [ItemTypeName] [nvarchar](max) NULL,
 [UsageNet] [nvarchar](max) NULL,
 [LossPercent] [nvarchar](max) NULL,
 [ActualUsage] [nvarchar](max) NULL,
 [SortIndex] [nvarchar](max) NULL,
 [ItemMeasureTypeID] [nvarchar](max) NULL,
 [storeId] [nvarchar](max) NULL,
 [LOADTS_UTC] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_MENU_ITEMS_SUBITEMS', 1, N'dbadmin', '2026-01-07 11:52:44.830', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_MENU_PROFITABILITY / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MENU_PROFITABILITY' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_MENU_PROFITABILITY]
(
    [ID] nvarchar(MAX) NULL,
    [PosCode] nvarchar(MAX) NULL,
    [MenuItemName] nvarchar(MAX) NULL,
    [MenuItemCategory] nvarchar(MAX) NULL,
    [MenuItemPrice] nvarchar(MAX) NULL,
    [QuantitySold] nvarchar(MAX) NULL,
    [NetItemPrice] nvarchar(MAX) NULL,
    [TotalSales] nvarchar(MAX) NULL,
    [RecipeIngredientsCost] nvarchar(MAX) NULL,
    [RecipeIngredientsCostPercent] nvarchar(MAX) NULL,
    [NetIngredientsCost] nvarchar(MAX) NULL,
    [NetIngredientsCostPercent] nvarchar(MAX) NULL,
    [TotalIngredientsCost] nvarchar(MAX) NULL,
    [Profit] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MENU_PROFITABILITY',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.480',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MENU_PROFITABILITY' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MENU_PROFITABILITY', N'CREATE TABLE [int_marketman001].[DL_MENU_PROFITABILITY]
(
    [ID] nvarchar(MAX) NULL,
    [PosCode] nvarchar(MAX) NULL,
    [MenuItemName] nvarchar(MAX) NULL,
    [MenuItemCategory] nvarchar(MAX) NULL,
    [MenuItemPrice] nvarchar(MAX) NULL,
    [QuantitySold] nvarchar(MAX) NULL,
    [NetItemPrice] nvarchar(MAX) NULL,
    [TotalSales] nvarchar(MAX) NULL,
    [RecipeIngredientsCost] nvarchar(MAX) NULL,
    [RecipeIngredientsCostPercent] nvarchar(MAX) NULL,
    [NetIngredientsCost] nvarchar(MAX) NULL,
    [NetIngredientsCostPercent] nvarchar(MAX) NULL,
    [TotalIngredientsCost] nvarchar(MAX) NULL,
    [Profit] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_MENU_PROFITABILITY', 1, N'dbadmin', '2026-01-07 10:31:48.480', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_ORDERS_BY_SENTDATE / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ORDERS_BY_SENTDATE' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_ORDERS_BY_SENTDATE]
(
    [OrderNumber] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [VendorName] nvarchar(MAX) NULL,
    [OrderStatusID] nvarchar(MAX) NULL,
    [OrderStatus] nvarchar(MAX) NULL,
    [OrderStatusUIName] nvarchar(MAX) NULL,
    [DeliveryDateUTC] nvarchar(MAX) NULL,
    [SentDateUTC] nvarchar(MAX) NULL,
    [PriceTotalWithVAT] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [Comments] nvarchar(MAX) NULL,
    [VendorGuid] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ORDERS_BY_SENTDATE',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.560',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ORDERS_BY_SENTDATE' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ORDERS_BY_SENTDATE', N'CREATE TABLE [int_marketman001].[DL_ORDERS_BY_SENTDATE]
(
    [OrderNumber] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [VendorName] nvarchar(MAX) NULL,
    [OrderStatusID] nvarchar(MAX) NULL,
    [OrderStatus] nvarchar(MAX) NULL,
    [OrderStatusUIName] nvarchar(MAX) NULL,
    [DeliveryDateUTC] nvarchar(MAX) NULL,
    [SentDateUTC] nvarchar(MAX) NULL,
    [PriceTotalWithVAT] nvarchar(MAX) NULL,
    [PriceTotalWithoutVAT] nvarchar(MAX) NULL,
    [Comments] nvarchar(MAX) NULL,
    [VendorGuid] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_ORDERS_BY_SENTDATE', 1, N'dbadmin', '2026-01-07 10:31:48.560', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_ORDERS_BY_SENTDATE_HISTORYLOG / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ORDERS_BY_SENTDATE_HISTORYLOG' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_ORDERS_BY_SENTDATE_HISTORYLOG]
(
    [OrderNumber] nvarchar(MAX) NULL,
    [ID] nvarchar(MAX) NULL,
    [OrderId] nvarchar(MAX) NULL,
    [ActionId] nvarchar(MAX) NULL,
    [ActionTitle] nvarchar(MAX) NULL,
    [CreatedByBuyer] nvarchar(MAX) NULL,
    [BuyerUserName] nvarchar(MAX) NULL,
    [CreatedDate] nvarchar(MAX) NULL,
    [CreatedDateUTC] nvarchar(MAX) NULL,
    [Vendor] nvarchar(MAX) NULL,
    [VendorGUID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ORDERS_BY_SENTDATE_HISTORYLOG',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.650',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ORDERS_BY_SENTDATE_HISTORYLOG' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ORDERS_BY_SENTDATE_HISTORYLOG', N'CREATE TABLE [int_marketman001].[DL_ORDERS_BY_SENTDATE_HISTORYLOG]
(
    [OrderNumber] nvarchar(MAX) NULL,
    [ID] nvarchar(MAX) NULL,
    [OrderId] nvarchar(MAX) NULL,
    [ActionId] nvarchar(MAX) NULL,
    [ActionTitle] nvarchar(MAX) NULL,
    [CreatedByBuyer] nvarchar(MAX) NULL,
    [BuyerUserName] nvarchar(MAX) NULL,
    [CreatedDate] nvarchar(MAX) NULL,
    [CreatedDateUTC] nvarchar(MAX) NULL,
    [Vendor] nvarchar(MAX) NULL,
    [VendorGUID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_ORDERS_BY_SENTDATE_HISTORYLOG', 1, N'dbadmin', '2026-01-07 10:31:48.650', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_ORDERS_BY_SENTDATE_ITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ORDERS_BY_SENTDATE_ITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS]
(
    [OrderNumber] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [SKU] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [Price] nvarchar(MAX) NULL,
    [PriceTotal] nvarchar(MAX) NULL,
    [BarcodeManufacture] nvarchar(MAX) NULL,
    [CatalogItemID] nvarchar(MAX) NULL,
    [CatalogItemCode] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [TaxValue] nvarchar(MAX) NULL,
    [PriceTotalWithVat] nvarchar(MAX) NULL,
    [ItemMeasureTypeID] nvarchar(MAX) NULL,
    [ItemMeasureTypeName] nvarchar(MAX) NULL,
    [PackQuantity] nvarchar(MAX) NULL,
    [PacksPerCase] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ORDERS_BY_SENTDATE_ITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.750',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ORDERS_BY_SENTDATE_ITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ORDERS_BY_SENTDATE_ITEMS', N'CREATE TABLE [int_marketman001].[DL_ORDERS_BY_SENTDATE_ITEMS]
(
    [OrderNumber] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [SKU] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [Price] nvarchar(MAX) NULL,
    [PriceTotal] nvarchar(MAX) NULL,
    [BarcodeManufacture] nvarchar(MAX) NULL,
    [CatalogItemID] nvarchar(MAX) NULL,
    [CatalogItemCode] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [TaxValue] nvarchar(MAX) NULL,
    [PriceTotalWithVat] nvarchar(MAX) NULL,
    [ItemMeasureTypeID] nvarchar(MAX) NULL,
    [ItemMeasureTypeName] nvarchar(MAX) NULL,
    [PackQuantity] nvarchar(MAX) NULL,
    [PacksPerCase] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_ORDERS_BY_SENTDATE_ITEMS', 1, N'dbadmin', '2026-01-07 10:31:48.750', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_PRODUCTION_EVENTS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_PRODUCTION_EVENTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_PRODUCTION_EVENTS]
(
    [EventID] nvarchar(MAX) NULL,
    [ReportedBy] nvarchar(MAX) NULL,
    [CreateDate] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [EventDate] nvarchar(MAX) NULL,
    [Comments] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_PRODUCTION_EVENTS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.853',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_PRODUCTION_EVENTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_PRODUCTION_EVENTS', N'CREATE TABLE [int_marketman001].[DL_PRODUCTION_EVENTS]
(
    [EventID] nvarchar(MAX) NULL,
    [ReportedBy] nvarchar(MAX) NULL,
    [CreateDate] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [EventDate] nvarchar(MAX) NULL,
    [Comments] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_PRODUCTION_EVENTS', 1, N'dbadmin', '2026-01-07 10:31:48.853', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_PRODUCTION_EVENTS_PRODUCTIONITEMS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_PRODUCTION_EVENTS_PRODUCTIONITEMS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS]
(
    [EventID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [UOM] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_PRODUCTION_EVENTS_PRODUCTIONITEMS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:48.960',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_PRODUCTION_EVENTS_PRODUCTIONITEMS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_PRODUCTION_EVENTS_PRODUCTIONITEMS', N'CREATE TABLE [int_marketman001].[DL_PRODUCTION_EVENTS_PRODUCTIONITEMS]
(
    [EventID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [UpdateDate] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [UOM] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [IsDeleted] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_PRODUCTION_EVENTS_PRODUCTIONITEMS', 1, N'dbadmin', '2026-01-07 10:31:48.960', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_BY_DATE / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_BY_DATE' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_SALES_BY_DATE]
(
    [SaleSummaryID] nvarchar(MAX) NULL,
    [BuyerPOSID] nvarchar(MAX) NULL,
    [BuyerPOSName] nvarchar(MAX) NULL,
    [Date] nvarchar(MAX) NULL,
    [TotalWithVAT] nvarchar(MAX) NULL,
    [TotalWithoutVAT] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_BY_DATE',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.046',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_BY_DATE' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_BY_DATE', N'CREATE TABLE [int_marketman001].[DL_SALES_BY_DATE]
(
    [SaleSummaryID] nvarchar(MAX) NULL,
    [BuyerPOSID] nvarchar(MAX) NULL,
    [BuyerPOSName] nvarchar(MAX) NULL,
    [Date] nvarchar(MAX) NULL,
    [TotalWithVAT] nvarchar(MAX) NULL,
    [TotalWithoutVAT] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_SALES_BY_DATE', 1, N'dbadmin', '2026-01-07 10:31:49.046', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_SALES_BY_DATE_CATEGORYSUMMARIES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_SALES_BY_DATE_CATEGORYSUMMARIES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_SALES_BY_DATE_CATEGORYSUMMARIES]
(
    [SaleSummaryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [TotalWithVAT] nvarchar(MAX) NULL,
    [TotalWithoutVAT] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_SALES_BY_DATE_CATEGORYSUMMARIES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.153',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_SALES_BY_DATE_CATEGORYSUMMARIES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_SALES_BY_DATE_CATEGORYSUMMARIES', N'CREATE TABLE [int_marketman001].[DL_SALES_BY_DATE_CATEGORYSUMMARIES]
(
    [SaleSummaryID] nvarchar(MAX) NULL,
    [CategoryName] nvarchar(MAX) NULL,
    [TotalWithVAT] nvarchar(MAX) NULL,
    [TotalWithoutVAT] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_SALES_BY_DATE_CATEGORYSUMMARIES', 1, N'dbadmin', '2026-01-07 10:31:49.153', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_STORE / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_STORE' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_STORE]
(
    [storeId] nvarchar(MAX) NULL,
    [StoreName] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_STORE',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.250',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_STORE' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_STORE', N'CREATE TABLE [int_marketman001].[DL_STORE]
(
    [storeId] nvarchar(MAX) NULL,
    [StoreName] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_STORE', 1, N'dbadmin', '2026-01-07 10:31:49.250', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_TAX_LEVELS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_TAX_LEVELS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_TAX_LEVELS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [Rate] nvarchar(MAX) NULL,
    [IsDefault] nvarchar(MAX) NULL,
    [LocaleGroupID] nvarchar(MAX) NULL,
    [IsZero] nvarchar(MAX) NULL,
    [IsExempt] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_TAX_LEVELS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.356',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_TAX_LEVELS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_TAX_LEVELS', N'CREATE TABLE [int_marketman001].[DL_TAX_LEVELS]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [Rate] nvarchar(MAX) NULL,
    [IsDefault] nvarchar(MAX) NULL,
    [LocaleGroupID] nvarchar(MAX) NULL,
    [IsZero] nvarchar(MAX) NULL,
    [IsExempt] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_TAX_LEVELS', 1, N'dbadmin', '2026-01-07 10:31:49.356', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_TRANSFERS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_TRANSFERS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_TRANSFERS]
(
    [ID] nvarchar(MAX) NULL,
    [BuyerFromName] nvarchar(MAX) NULL,
    [BuyerFromGuid] nvarchar(MAX) NULL,
    [BuyerToName] nvarchar(MAX) NULL,
    [BuyerToGuid] nvarchar(MAX) NULL,
    [DateUTC] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [Commments] nvarchar(MAX) NULL,
    [TransferStatusID] nvarchar(MAX) NULL,
    [TransferStatus] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_TRANSFERS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.410',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_TRANSFERS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_TRANSFERS', N'CREATE TABLE [int_marketman001].[DL_TRANSFERS]
(
    [ID] nvarchar(MAX) NULL,
    [BuyerFromName] nvarchar(MAX) NULL,
    [BuyerFromGuid] nvarchar(MAX) NULL,
    [BuyerToName] nvarchar(MAX) NULL,
    [BuyerToGuid] nvarchar(MAX) NULL,
    [DateUTC] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [Commments] nvarchar(MAX) NULL,
    [TransferStatusID] nvarchar(MAX) NULL,
    [TransferStatus] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_TRANSFERS', 1, N'dbadmin', '2026-01-07 10:31:49.410', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_TRANSFERS_LINES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_TRANSFERS_LINES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_TRANSFERS_LINES]
(
    [ID] nvarchar(MAX) NULL,
    [LineID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_TRANSFERS_LINES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.510',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_TRANSFERS_LINES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_TRANSFERS_LINES', N'CREATE TABLE [int_marketman001].[DL_TRANSFERS_LINES]
(
    [ID] nvarchar(MAX) NULL,
    [LineID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_TRANSFERS_LINES', 1, N'dbadmin', '2026-01-07 10:31:49.510', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_UOM_TYPES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_UOM_TYPES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_UOM_TYPES]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_UOM_TYPES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.590',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_UOM_TYPES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_UOM_TYPES', N'CREATE TABLE [int_marketman001].[DL_UOM_TYPES]
(
    [ID] nvarchar(MAX) NULL,
    [Name] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_UOM_TYPES', 1, N'dbadmin', '2026-01-07 10:31:49.590', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_VENDORS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_VENDORS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_VENDORS]
(
    [Name] nvarchar(MAX) NULL,
    [Guid] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [CreditAccountName] nvarchar(MAX) NULL,
    [DebitAccountName] nvarchar(MAX) NULL,
    [IncomeAccountName] nvarchar(MAX) NULL,
    [VendorIRSNumber] nvarchar(MAX) NULL,
    [EnabledForOrders] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_VENDORS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.683',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_VENDORS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_VENDORS', N'CREATE TABLE [int_marketman001].[DL_VENDORS]
(
    [Name] nvarchar(MAX) NULL,
    [Guid] nvarchar(MAX) NULL,
    [TaxLevelID] nvarchar(MAX) NULL,
    [CreditAccountName] nvarchar(MAX) NULL,
    [DebitAccountName] nvarchar(MAX) NULL,
    [IncomeAccountName] nvarchar(MAX) NULL,
    [VendorIRSNumber] nvarchar(MAX) NULL,
    [EnabledForOrders] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_VENDORS', 1, N'dbadmin', '2026-01-07 10:31:49.683', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_WASTE_EVENTS / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_WASTE_EVENTS' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_WASTE_EVENTS]
(
    [ID] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [DateUTC] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [Commments] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_WASTE_EVENTS',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.790',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_WASTE_EVENTS' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_WASTE_EVENTS', N'CREATE TABLE [int_marketman001].[DL_WASTE_EVENTS]
(
    [ID] nvarchar(MAX) NULL,
    [BuyerName] nvarchar(MAX) NULL,
    [BuyerGuid] nvarchar(MAX) NULL,
    [DateUTC] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [Commments] nvarchar(MAX) NULL,
    [IsSuccess] nvarchar(MAX) NULL,
    [ErrorMessage] nvarchar(MAX) NULL,
    [ErrorCode] nvarchar(MAX) NULL,
    [RequestID] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_WASTE_EVENTS', 1, N'dbadmin', '2026-01-07 10:31:49.790', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_WASTE_EVENTS_LINES / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_marketman001].[GlobalParameters] WHERE [ParameterKey] = N'DL_WASTE_EVENTS_LINES' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_marketman001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_marketman001].[DL_WASTE_EVENTS_LINES]
(
    [ID] nvarchar(MAX) NULL,
    [LineID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_WASTE_EVENTS_LINES',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-01-07 10:31:49.886',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_WASTE_EVENTS_LINES' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_marketman001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_WASTE_EVENTS_LINES', N'CREATE TABLE [int_marketman001].[DL_WASTE_EVENTS_LINES]
(
    [ID] nvarchar(MAX) NULL,
    [LineID] nvarchar(MAX) NULL,
    [ItemID] nvarchar(MAX) NULL,
    [ItemName] nvarchar(MAX) NULL,
    [Quantity] nvarchar(MAX) NULL,
    [TotalPriceWithoutVAT] nvarchar(MAX) NULL,
    [UOMID] nvarchar(MAX) NULL,
    [UOMName] nvarchar(MAX) NULL,
    [storeId] nvarchar(MAX) NULL,
    [LOADTS_UTC] datetime2 NULL
);', N'STRING', N'STAGE_DDL', N'DL_WASTE_EVENTS_LINES', 1, N'dbadmin', '2026-01-07 10:31:49.886', NULL, NULL, 1);
END
GO
