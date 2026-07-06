-- ============================================
-- STAGE_DDL Parameters Export
-- Source: UAT [core].[int_troap001].[GlobalParameters]
-- Generated: 2026-07-06 15:17:46
-- Total Records: 48
-- ============================================

-- ParameterKey=DL_Address / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Address' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Address]
(
    [AddressId] NVARCHAR(MAX),
    [AddressTypeId] NVARCHAR(MAX),
    [OrganisationName] NVARCHAR(MAX),
    [BuildingNameNumber] NVARCHAR(MAX),
    [AddressLine1] NVARCHAR(MAX),
    [AddressLine2] NVARCHAR(MAX),
    [AddressLine3] NVARCHAR(MAX),
    [AddressLine4] NVARCHAR(MAX),
    [AddressLine5] NVARCHAR(MAX),
    [TownCity] NVARCHAR(MAX),
    [County] NVARCHAR(MAX),
    [Country] NVARCHAR(MAX),
    [PostCode] NVARCHAR(MAX),
    [ContactTelephone] NVARCHAR(MAX),
    [SpecialInstructions] NVARCHAR(MAX),
    [IsResidential] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [DeliveryZone] NVARCHAR(MAX),
    [ProviderAddressKey] NVARCHAR(MAX),
    [AddressName] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Address',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:15.493',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.426',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Address' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Address', N'CREATE TABLE [int_troap001].[DL_Address]
(
    [AddressId] NVARCHAR(MAX),
    [AddressTypeId] NVARCHAR(MAX),
    [OrganisationName] NVARCHAR(MAX),
    [BuildingNameNumber] NVARCHAR(MAX),
    [AddressLine1] NVARCHAR(MAX),
    [AddressLine2] NVARCHAR(MAX),
    [AddressLine3] NVARCHAR(MAX),
    [AddressLine4] NVARCHAR(MAX),
    [AddressLine5] NVARCHAR(MAX),
    [TownCity] NVARCHAR(MAX),
    [County] NVARCHAR(MAX),
    [Country] NVARCHAR(MAX),
    [PostCode] NVARCHAR(MAX),
    [ContactTelephone] NVARCHAR(MAX),
    [SpecialInstructions] NVARCHAR(MAX),
    [IsResidential] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [DeliveryZone] NVARCHAR(MAX),
    [ProviderAddressKey] NVARCHAR(MAX),
    [AddressName] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Address', 1, N'dbadmin', '2026-03-11 12:04:15.493', N'dbadmin', '2026-03-17 15:59:38.426', 1);
END
GO
-- ParameterKey=DL_Allergen / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Allergen' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Allergen]
(
    [AllergenId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [AllergenDescription] NVARCHAR(MAX),
    [Abbreviation] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DateDeleted] NVARCHAR(MAX),
    [DeletedBy] NVARCHAR(MAX),
    [AllergenGuid] NVARCHAR(MAX),
    [CssClass] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Allergen',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:15.540',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.503',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Allergen' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Allergen', N'CREATE TABLE [int_troap001].[DL_Allergen]
(
    [AllergenId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [AllergenDescription] NVARCHAR(MAX),
    [Abbreviation] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DateDeleted] NVARCHAR(MAX),
    [DeletedBy] NVARCHAR(MAX),
    [AllergenGuid] NVARCHAR(MAX),
    [CssClass] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Allergen', 1, N'dbadmin', '2026-03-11 12:04:15.540', N'dbadmin', '2026-03-17 15:59:38.503', 1);
END
GO
-- ParameterKey=DL_AllowedStores / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_AllowedStores' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_AllowedStores]
(
    [Id] NVARCHAR(MAX),
    [SiteId] NVARCHAR(MAX),
    [SalesAreaId] NVARCHAR(MAX),
    [SiteUrl] NVARCHAR(MAX),
    [SiteCode] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_AllowedStores',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:15.620',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.596',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_AllowedStores' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_AllowedStores', N'CREATE TABLE [int_troap001].[DL_AllowedStores]
(
    [Id] NVARCHAR(MAX),
    [SiteId] NVARCHAR(MAX),
    [SalesAreaId] NVARCHAR(MAX),
    [SiteUrl] NVARCHAR(MAX),
    [SiteCode] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_AllowedStores', 1, N'dbadmin', '2026-03-11 12:04:15.620', N'dbadmin', '2026-03-17 15:59:38.596', 1);
END
GO
-- ParameterKey=DL_AvailabilityRule / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_AvailabilityRule' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_AvailabilityRule]
(
    [AvailabilityRuleId] NVARCHAR(MAX),
    [AvailabilityRuleName] NVARCHAR(MAX),
    [AllowOnBankHoliday] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_AvailabilityRule',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:15.713',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.690',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_AvailabilityRule' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_AvailabilityRule', N'CREATE TABLE [int_troap001].[DL_AvailabilityRule]
(
    [AvailabilityRuleId] NVARCHAR(MAX),
    [AvailabilityRuleName] NVARCHAR(MAX),
    [AllowOnBankHoliday] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_AvailabilityRule', 1, N'dbadmin', '2026-03-11 12:04:15.713', N'dbadmin', '2026-03-17 15:59:38.690', 1);
END
GO
-- ParameterKey=DL_AvailabilityRuleValidDays / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_AvailabilityRuleValidDays' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_AvailabilityRuleValidDays]
(
    [ValidDayId] NVARCHAR(MAX),
    [AvailabilityRuleId] NVARCHAR(MAX),
    [DayOfWeek] NVARCHAR(MAX),
    [StartHour] NVARCHAR(MAX),
    [StartMinute] NVARCHAR(MAX),
    [EndHour] NVARCHAR(MAX),
    [EndMinute] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_AvailabilityRuleValidDays',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:15.810',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.783',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_AvailabilityRuleValidDays' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_AvailabilityRuleValidDays', N'CREATE TABLE [int_troap001].[DL_AvailabilityRuleValidDays]
(
    [ValidDayId] NVARCHAR(MAX),
    [AvailabilityRuleId] NVARCHAR(MAX),
    [DayOfWeek] NVARCHAR(MAX),
    [StartHour] NVARCHAR(MAX),
    [StartMinute] NVARCHAR(MAX),
    [EndHour] NVARCHAR(MAX),
    [EndMinute] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_AvailabilityRuleValidDays', 1, N'dbadmin', '2026-03-11 12:04:15.810', N'dbadmin', '2026-03-17 15:59:38.783', 1);
END
GO
-- ParameterKey=DL_Basket / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Basket' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Basket]
(
    [BasketId] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [CustomerGuid] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [VoucherErrorCode] NVARCHAR(MAX),
    [VoucherActualCode] NVARCHAR(MAX),
    [IsVoucherValid] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [OrderStatusId] NVARCHAR(MAX),
    [ClientApplication] NVARCHAR(MAX),
    [ShipmentTypeID] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [UserAgent] NVARCHAR(MAX),
    [ReferrerUrl] NVARCHAR(MAX),
    [EntryUrl] NVARCHAR(MAX),
    [SessionId] NVARCHAR(MAX),
    [BookingReference] NVARCHAR(MAX),
    [CanModify] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Basket',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:15.910',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.873',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Basket' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Basket', N'CREATE TABLE [int_troap001].[DL_Basket]
(
    [BasketId] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [CustomerGuid] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [VoucherErrorCode] NVARCHAR(MAX),
    [VoucherActualCode] NVARCHAR(MAX),
    [IsVoucherValid] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [OrderStatusId] NVARCHAR(MAX),
    [ClientApplication] NVARCHAR(MAX),
    [ShipmentTypeID] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [UserAgent] NVARCHAR(MAX),
    [ReferrerUrl] NVARCHAR(MAX),
    [EntryUrl] NVARCHAR(MAX),
    [SessionId] NVARCHAR(MAX),
    [BookingReference] NVARCHAR(MAX),
    [CanModify] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Basket', 1, N'dbadmin', '2026-03-11 12:04:15.910', N'dbadmin', '2026-03-17 15:59:38.873', 1);
END
GO
-- ParameterKey=DL_BasketItem / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_BasketItem' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_BasketItem]
(
    [BasketItemId] NVARCHAR(MAX),
    [BasketItemParentId] NVARCHAR(MAX),
    [BasketId] NVARCHAR(MAX),
    [MicrosComboMealId] NVARCHAR(MAX),
    [MicrosComboGroupId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [Quantity] NVARCHAR(MAX),
    [PriceNet] NVARCHAR(MAX),
    [PriceVat] NVARCHAR(MAX),
    [RuleSetId] NVARCHAR(MAX),
    [RuleSetTypeId] NVARCHAR(MAX),
    [FreeDipQuantity] NVARCHAR(MAX),
    [ToppingCoverageId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [PriceInDeal] NVARCHAR(MAX),
    [BasketItemOrder] NVARCHAR(MAX),
    [BasketItemTypeId] NVARCHAR(MAX),
    [ProductSku] NVARCHAR(MAX),
    [MatchedQualifyingVoucherParentId] NVARCHAR(MAX),
    [MatchedOfferVoucherParentId] NVARCHAR(MAX),
    [QualifyingVoucherCount] NVARCHAR(MAX),
    [OfferVoucherCount] NVARCHAR(MAX),
    [DealId] NVARCHAR(MAX),
    [DealStepId] NVARCHAR(MAX),
    [RuleGroupId] NVARCHAR(MAX),
    [AllowChange] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_BasketItem',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.000',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:38.966',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_BasketItem' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_BasketItem', N'CREATE TABLE [int_troap001].[DL_BasketItem]
(
    [BasketItemId] NVARCHAR(MAX),
    [BasketItemParentId] NVARCHAR(MAX),
    [BasketId] NVARCHAR(MAX),
    [MicrosComboMealId] NVARCHAR(MAX),
    [MicrosComboGroupId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [Quantity] NVARCHAR(MAX),
    [PriceNet] NVARCHAR(MAX),
    [PriceVat] NVARCHAR(MAX),
    [RuleSetId] NVARCHAR(MAX),
    [RuleSetTypeId] NVARCHAR(MAX),
    [FreeDipQuantity] NVARCHAR(MAX),
    [ToppingCoverageId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [PriceInDeal] NVARCHAR(MAX),
    [BasketItemOrder] NVARCHAR(MAX),
    [BasketItemTypeId] NVARCHAR(MAX),
    [ProductSku] NVARCHAR(MAX),
    [MatchedQualifyingVoucherParentId] NVARCHAR(MAX),
    [MatchedOfferVoucherParentId] NVARCHAR(MAX),
    [QualifyingVoucherCount] NVARCHAR(MAX),
    [OfferVoucherCount] NVARCHAR(MAX),
    [DealId] NVARCHAR(MAX),
    [DealStepId] NVARCHAR(MAX),
    [RuleGroupId] NVARCHAR(MAX),
    [AllowChange] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_BasketItem', 1, N'dbadmin', '2026-03-11 12:04:16.000', N'dbadmin', '2026-03-17 15:59:38.966', 1);
END
GO
-- ParameterKey=DL_BrainTreePaymentIntent / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_BrainTreePaymentIntent' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentIntent]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [BrainTreeClientSecret] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [IsSuccess] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_BrainTreePaymentIntent',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.060',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.060',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_BrainTreePaymentIntent' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_BrainTreePaymentIntent', N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentIntent]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [BrainTreeClientSecret] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [IsSuccess] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_BrainTreePaymentIntent', 1, N'dbadmin', '2026-03-11 12:04:16.060', N'dbadmin', '2026-03-17 15:59:39.060', 1);
END
GO
-- ParameterKey=DL_BrainTreePaymentLog / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_BrainTreePaymentLog' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentLog]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [TransactionId] NVARCHAR(MAX),
    [RequestType] NVARCHAR(MAX),
    [Response] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_BrainTreePaymentLog',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.106',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.106',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_BrainTreePaymentLog' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_BrainTreePaymentLog', N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentLog]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [TransactionId] NVARCHAR(MAX),
    [RequestType] NVARCHAR(MAX),
    [Response] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_BrainTreePaymentLog', 1, N'dbadmin', '2026-03-11 12:04:16.106', N'dbadmin', '2026-03-17 15:59:39.106', 1);
END
GO
-- ParameterKey=DL_CouponDiscount / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CouponDiscount' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CouponDiscount]
(
    [Id] NVARCHAR(MAX),
    [ExternalId] NVARCHAR(MAX),
    [ProviderTypeId] NVARCHAR(MAX),
    [RewardId] NVARCHAR(MAX),
    [RewardType] NVARCHAR(MAX),
    [RewardBalance] NVARCHAR(MAX),
    [RewardPercent] NVARCHAR(MAX),
    [RewardPrice] NVARCHAR(MAX),
    [CampaignId] NVARCHAR(MAX),
    [DiscountId] NVARCHAR(MAX),
    [ClmAccountType] NVARCHAR(MAX),
    [VoucherRedemptionId] NVARCHAR(MAX),
    [DiscountName] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CouponDiscount',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.153',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.146',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CouponDiscount' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CouponDiscount', N'CREATE TABLE [int_troap001].[DL_CouponDiscount]
(
    [Id] NVARCHAR(MAX),
    [ExternalId] NVARCHAR(MAX),
    [ProviderTypeId] NVARCHAR(MAX),
    [RewardId] NVARCHAR(MAX),
    [RewardType] NVARCHAR(MAX),
    [RewardBalance] NVARCHAR(MAX),
    [RewardPercent] NVARCHAR(MAX),
    [RewardPrice] NVARCHAR(MAX),
    [CampaignId] NVARCHAR(MAX),
    [DiscountId] NVARCHAR(MAX),
    [ClmAccountType] NVARCHAR(MAX),
    [VoucherRedemptionId] NVARCHAR(MAX),
    [DiscountName] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CouponDiscount', 1, N'dbadmin', '2026-03-11 12:04:16.153', N'dbadmin', '2026-03-17 15:59:39.146', 1);
END
GO
-- ParameterKey=DL_Customer / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Customer' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Customer]
(
    [CustomerId] NVARCHAR(MAX),
    [CustomerGuid] NVARCHAR(MAX),
    [UserId] NVARCHAR(MAX),
    [Title] NVARCHAR(MAX),
    [Forename] NVARCHAR(MAX),
    [Surname] NVARCHAR(MAX),
    [ContactTelephone] NVARCHAR(MAX),
    [ContactFax] NVARCHAR(MAX),
    [ContactMobile] NVARCHAR(MAX),
    [ContactEmail] NVARCHAR(MAX),
    [MarketingSourceId] NVARCHAR(MAX),
    [MarketingHasOptIn] NVARCHAR(MAX),
    [ShopperIPAddress] NVARCHAR(MAX),
    [IsActive] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [MarketingSMSOptIn] NVARCHAR(MAX),
    [MarketingEmailOptIn] NVARCHAR(MAX),
    [MarketingPostOptIn] NVARCHAR(MAX),
    [DateOfBirth] NVARCHAR(MAX),
    [DealInterest] NVARCHAR(MAX),
    [TrackAndTraceOptOut] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Customer',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.200',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.233',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Customer' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Customer', N'CREATE TABLE [int_troap001].[DL_Customer]
(
    [CustomerId] NVARCHAR(MAX),
    [CustomerGuid] NVARCHAR(MAX),
    [UserId] NVARCHAR(MAX),
    [Title] NVARCHAR(MAX),
    [Forename] NVARCHAR(MAX),
    [Surname] NVARCHAR(MAX),
    [ContactTelephone] NVARCHAR(MAX),
    [ContactFax] NVARCHAR(MAX),
    [ContactMobile] NVARCHAR(MAX),
    [ContactEmail] NVARCHAR(MAX),
    [MarketingSourceId] NVARCHAR(MAX),
    [MarketingHasOptIn] NVARCHAR(MAX),
    [ShopperIPAddress] NVARCHAR(MAX),
    [IsActive] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [MarketingSMSOptIn] NVARCHAR(MAX),
    [MarketingEmailOptIn] NVARCHAR(MAX),
    [MarketingPostOptIn] NVARCHAR(MAX),
    [DateOfBirth] NVARCHAR(MAX),
    [DealInterest] NVARCHAR(MAX),
    [TrackAndTraceOptOut] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Customer', 1, N'dbadmin', '2026-03-11 12:04:16.200', N'dbadmin', '2026-03-17 15:59:39.233', 1);
END
GO
-- ParameterKey=DL_CustomerOpenCheck / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CustomerOpenCheck' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheck]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [TableNumber] NVARCHAR(MAX),
    [ExternalAccountId] NVARCHAR(MAX),
    [ExternalBasketId] NVARCHAR(MAX),
    [OpenCheckStatusId] NVARCHAR(MAX),
    [TotalAmount] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [SplitType] NVARCHAR(MAX),
    [JourneyTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CustomerOpenCheck',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.240',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.330',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CustomerOpenCheck' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CustomerOpenCheck', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheck]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [TableNumber] NVARCHAR(MAX),
    [ExternalAccountId] NVARCHAR(MAX),
    [ExternalBasketId] NVARCHAR(MAX),
    [OpenCheckStatusId] NVARCHAR(MAX),
    [TotalAmount] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [SplitType] NVARCHAR(MAX),
    [JourneyTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CustomerOpenCheck', 1, N'dbadmin', '2026-03-11 12:04:16.240', N'dbadmin', '2026-03-17 15:59:39.330', 1);
END
GO
-- ParameterKey=DL_CustomerOpenCheckBasket / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CustomerOpenCheckBasket' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckBasket]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [OpenCheckStatusId] NVARCHAR(MAX),
    [BasketId] NVARCHAR(MAX),
    [BasketTotal] NVARCHAR(MAX),
    [ExternalReference] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CustomerOpenCheckBasket',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.286',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.380',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CustomerOpenCheckBasket' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CustomerOpenCheckBasket', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckBasket]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [OpenCheckStatusId] NVARCHAR(MAX),
    [BasketId] NVARCHAR(MAX),
    [BasketTotal] NVARCHAR(MAX),
    [ExternalReference] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CustomerOpenCheckBasket', 1, N'dbadmin', '2026-03-11 12:04:16.286', N'dbadmin', '2026-03-17 15:59:39.380', 1);
END
GO
-- ParameterKey=DL_CustomerOpenCheckCharge / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CustomerOpenCheckCharge' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCharge]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [ChargeTypeId] NVARCHAR(MAX),
    [ExternalRefrence] NVARCHAR(MAX),
    [ChargePercentage] NVARCHAR(MAX),
    [ChargeAmount] NVARCHAR(MAX),
    [MonetaryChargeTypeId] NVARCHAR(MAX),
    [IsCustomTip] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [IsPaid] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CustomerOpenCheckCharge',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.380',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.476',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CustomerOpenCheckCharge' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CustomerOpenCheckCharge', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCharge]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [ChargeTypeId] NVARCHAR(MAX),
    [ExternalRefrence] NVARCHAR(MAX),
    [ChargePercentage] NVARCHAR(MAX),
    [ChargeAmount] NVARCHAR(MAX),
    [MonetaryChargeTypeId] NVARCHAR(MAX),
    [IsCustomTip] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [IsPaid] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CustomerOpenCheckCharge', 1, N'dbadmin', '2026-03-11 12:04:16.380', N'dbadmin', '2026-03-17 15:59:39.476', 1);
END
GO
-- ParameterKey=DL_CustomerOpenCheckCouponDiscount / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CustomerOpenCheckCouponDiscount' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCouponDiscount]
(
    [Id] NVARCHAR(MAX),
    [CouponDiscountId] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Used] NVARCHAR(MAX),
    [MemberId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CustomerOpenCheckCouponDiscount',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.473',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.573',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CustomerOpenCheckCouponDiscount' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CustomerOpenCheckCouponDiscount', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCouponDiscount]
(
    [Id] NVARCHAR(MAX),
    [CouponDiscountId] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Used] NVARCHAR(MAX),
    [MemberId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CustomerOpenCheckCouponDiscount', 1, N'dbadmin', '2026-03-11 12:04:16.473', N'dbadmin', '2026-03-17 15:59:39.573', 1);
END
GO
-- ParameterKey=DL_CustomerOpenCheckDiscount / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CustomerOpenCheckDiscount' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckDiscount]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [DiscountId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [Amount] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CustomerOpenCheckDiscount',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.570',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.620',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CustomerOpenCheckDiscount' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CustomerOpenCheckDiscount', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckDiscount]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [DiscountId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [Amount] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CustomerOpenCheckDiscount', 1, N'dbadmin', '2026-03-11 12:04:16.570', N'dbadmin', '2026-03-17 15:59:39.620', 1);
END
GO
-- ParameterKey=DL_CustomerOpenCheckPromotion / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_CustomerOpenCheckPromotion' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckPromotion]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [DiscountApplyingToOrderLineFamily] NVARCHAR(MAX),
    [FullPrice] NVARCHAR(MAX),
    [PromotedPrice] NVARCHAR(MAX),
    [PromotionalSaving] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_CustomerOpenCheckPromotion',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.670',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.683',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_CustomerOpenCheckPromotion' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_CustomerOpenCheckPromotion', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckPromotion]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [DiscountApplyingToOrderLineFamily] NVARCHAR(MAX),
    [FullPrice] NVARCHAR(MAX),
    [PromotedPrice] NVARCHAR(MAX),
    [PromotionalSaving] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_CustomerOpenCheckPromotion', 1, N'dbadmin', '2026-03-11 12:04:16.670', N'dbadmin', '2026-03-17 15:59:39.683', 1);
END
GO
-- ParameterKey=DL_Device / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Device' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Device]
(
    [Id] NVARCHAR(MAX),
    [DeviceMake] NVARCHAR(MAX),
    [DeviceName] NVARCHAR(MAX),
    [DeviceIdentifier] NVARCHAR(MAX),
    [IpAddress] NVARCHAR(MAX),
    [DeviceTypeId] NVARCHAR(MAX),
    [HostAddress] NVARCHAR(MAX),
    [UserName] NVARCHAR(MAX),
    [Password] NVARCHAR(MAX),
    [ApiKey] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [DeviceProviderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Device',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.756',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.776',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Device' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Device', N'CREATE TABLE [int_troap001].[DL_Device]
(
    [Id] NVARCHAR(MAX),
    [DeviceMake] NVARCHAR(MAX),
    [DeviceName] NVARCHAR(MAX),
    [DeviceIdentifier] NVARCHAR(MAX),
    [IpAddress] NVARCHAR(MAX),
    [DeviceTypeId] NVARCHAR(MAX),
    [HostAddress] NVARCHAR(MAX),
    [UserName] NVARCHAR(MAX),
    [Password] NVARCHAR(MAX),
    [ApiKey] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [DeviceProviderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Device', 1, N'dbadmin', '2026-03-11 12:04:16.756', N'dbadmin', '2026-03-17 15:59:39.776', 1);
END
GO
-- ParameterKey=DL_lstChargeType / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstChargeType' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstChargeType]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstChargeType',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.853',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.813',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstChargeType' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstChargeType', N'CREATE TABLE [int_troap001].[DL_lstChargeType]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstChargeType', 1, N'dbadmin', '2026-03-11 12:04:16.853', N'dbadmin', '2026-03-17 15:59:41.813', 1);
END
GO
-- ParameterKey=DL_lstOpenCheckStatus / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstOpenCheckStatus' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstOpenCheckStatus]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstOpenCheckStatus',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-04-08 14:04:32.346',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstOpenCheckStatus' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstOpenCheckStatus', N'CREATE TABLE [int_troap001].[DL_lstOpenCheckStatus]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstOpenCheckStatus', 1, N'dbadmin', '2026-04-08 14:04:32.346', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_lstOrderStatus / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstOrderStatus' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstOrderStatus]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstOrderStatus',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-04-08 14:04:32.380',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstOrderStatus' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstOrderStatus', N'CREATE TABLE [int_troap001].[DL_lstOrderStatus]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstOrderStatus', 1, N'dbadmin', '2026-04-08 14:04:32.380', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_lstPaymentStatus / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstPaymentStatus' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstPaymentStatus]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstPaymentStatus',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-04-08 14:04:32.453',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstPaymentStatus' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstPaymentStatus', N'CREATE TABLE [int_troap001].[DL_lstPaymentStatus]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstPaymentStatus', 1, N'dbadmin', '2026-04-08 14:04:32.453', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_lstPaymentType / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstPaymentType' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstPaymentType]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsAvailable] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstPaymentType',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:16.953',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.720',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstPaymentType' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstPaymentType', N'CREATE TABLE [int_troap001].[DL_lstPaymentType]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsAvailable] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstPaymentType', 1, N'dbadmin', '2026-03-11 12:04:16.953', N'dbadmin', '2026-03-17 15:59:41.720', 1);
END
GO
-- ParameterKey=DL_lstRefundReason / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstRefundReason' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstRefundReason]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstRefundReason',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-04-08 14:04:32.530',
        [ModifiedBy] = NULL,
        [ModifiedDate] = NULL,
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstRefundReason' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstRefundReason', N'CREATE TABLE [int_troap001].[DL_lstRefundReason]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstRefundReason', 1, N'dbadmin', '2026-04-08 14:04:32.530', NULL, NULL, 1);
END
GO
-- ParameterKey=DL_lstShipmentType / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_lstShipmentType' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_lstShipmentType]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [TimeToFire] NVARCHAR(MAX),
    [IsAvailable] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_lstShipmentType',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.053',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.826',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_lstShipmentType' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_lstShipmentType', N'CREATE TABLE [int_troap001].[DL_lstShipmentType]
(
    [Id] NVARCHAR(MAX),
    [DisplayTitle] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [TimeToFire] NVARCHAR(MAX),
    [IsAvailable] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_lstShipmentType', 1, N'dbadmin', '2026-03-11 12:04:17.053', N'dbadmin', '2026-03-17 15:59:39.826', 1);
END
GO
-- ParameterKey=DL_Menu / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Menu' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Menu]
(
    [MenuId] NVARCHAR(MAX),
    [MenuName] NVARCHAR(MAX),
    [MenuDescription] NVARCHAR(MAX),
    [DateEffective] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsActive] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsSimpleMenu] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Menu',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.146',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.913',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Menu' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Menu', N'CREATE TABLE [int_troap001].[DL_Menu]
(
    [MenuId] NVARCHAR(MAX),
    [MenuName] NVARCHAR(MAX),
    [MenuDescription] NVARCHAR(MAX),
    [DateEffective] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsActive] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsSimpleMenu] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Menu', 1, N'dbadmin', '2026-03-11 12:04:17.146', N'dbadmin', '2026-03-17 15:59:39.913', 1);
END
GO
-- ParameterKey=DL_MenuCategory / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MenuCategory' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_MenuCategory]
(
    [MenuCategoryId] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [RulesetId] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DisplayOnWebsite] NVARCHAR(MAX),
    [AllowOptionalByStore] NVARCHAR(MAX),
    [StartDate] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [CategoryDescription] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MenuCategory',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.240',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:39.946',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MenuCategory' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MenuCategory', N'CREATE TABLE [int_troap001].[DL_MenuCategory]
(
    [MenuCategoryId] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [RulesetId] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DisplayOnWebsite] NVARCHAR(MAX),
    [AllowOptionalByStore] NVARCHAR(MAX),
    [StartDate] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [CategoryDescription] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_MenuCategory', 1, N'dbadmin', '2026-03-11 12:04:17.240', N'dbadmin', '2026-03-17 15:59:39.946', 1);
END
GO
-- ParameterKey=DL_MenuCategoryGroup / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MenuCategoryGroup' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_MenuCategoryGroup]
(
    [Id] NVARCHAR(MAX),
    [MenuCategoryId] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [GroupName] NVARCHAR(MAX),
    [GroupDescription] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MenuCategoryGroup',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.330',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.036',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MenuCategoryGroup' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MenuCategoryGroup', N'CREATE TABLE [int_troap001].[DL_MenuCategoryGroup]
(
    [Id] NVARCHAR(MAX),
    [MenuCategoryId] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [GroupName] NVARCHAR(MAX),
    [GroupDescription] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_MenuCategoryGroup', 1, N'dbadmin', '2026-03-11 12:04:17.330', N'dbadmin', '2026-03-17 15:59:40.036', 1);
END
GO
-- ParameterKey=DL_MenuPriceBand / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MenuPriceBand' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_MenuPriceBand]
(
    [Id] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [PriceBandId] NVARCHAR(MAX),
    [IsDefault] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MenuPriceBand',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.423',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.130',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MenuPriceBand' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MenuPriceBand', N'CREATE TABLE [int_troap001].[DL_MenuPriceBand]
(
    [Id] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [PriceBandId] NVARCHAR(MAX),
    [IsDefault] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_MenuPriceBand', 1, N'dbadmin', '2026-03-11 12:04:17.423', N'dbadmin', '2026-03-17 15:59:40.130', 1);
END
GO
-- ParameterKey=DL_MenuProduct / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_MenuProduct' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_MenuProduct]
(
    [MenuId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_MenuProduct',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.513',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.223',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_MenuProduct' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_MenuProduct', N'CREATE TABLE [int_troap001].[DL_MenuProduct]
(
    [MenuId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_MenuProduct', 1, N'dbadmin', '2026-03-11 12:04:17.513', N'dbadmin', '2026-03-17 15:59:40.223', 1);
END
GO
-- ParameterKey=DL_Order / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Order' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Order]
(
    [OrderId] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [BillingAddressId] NVARCHAR(MAX),
    [DeliveryAddressId] NVARCHAR(MAX),
    [MicrosCheckNo] NVARCHAR(MAX),
    [MicrosCheckSeq] NVARCHAR(MAX),
    [MicrosRevenueCentre] NVARCHAR(MAX),
    [MicrosOrderTypeId] NVARCHAR(MAX),
    [MicrosEmployeeId] NVARCHAR(MAX),
    [MicrosDateToFire] NVARCHAR(MAX),
    [MicrosTenderMediaId] NVARCHAR(MAX),
    [MicrosStatusId] NVARCHAR(MAX),
    [TotalPriceNet] NVARCHAR(MAX),
    [TotalPriceVat] NVARCHAR(MAX),
    [TotalPriceTotal] NVARCHAR(MAX),
    [CurrencyId] NVARCHAR(MAX),
    [PaymentMethodId] NVARCHAR(MAX),
    [OrderStatusId] NVARCHAR(MAX),
    [PaymentStatusId] NVARCHAR(MAX),
    [ShipmentTypeId] NVARCHAR(MAX),
    [MicrosResponse] NVARCHAR(MAX),
    [CustomerEmail] NVARCHAR(MAX),
    [DeliveryInstructions] NVARCHAR(MAX),
    [DeliveryContact] NVARCHAR(MAX),
    [UserAgent] NVARCHAR(MAX),
    [ShopperIPAddress] NVARCHAR(MAX),
    [StoreServerIPAddress] NVARCHAR(MAX),
    [StoreServerDnsName] NVARCHAR(MAX),
    [DateOrderRequired] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsValidForReorder] NVARCHAR(MAX),
    [DomainName] NVARCHAR(MAX),
    [VoucherActualCode] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [DateCancelled] NVARCHAR(MAX),
    [ActualMicrosFireDate] NVARCHAR(MAX),
    [RetryCount] NVARCHAR(MAX),
    [ClientApplication] NVARCHAR(MAX),
    [Token] NVARCHAR(MAX),
    [AlcoholAgeVerifiedDate] NVARCHAR(MAX),
    [TableNumber] NVARCHAR(MAX),
    [AdditionalInfo] NVARCHAR(MAX),
    [SessionId] NVARCHAR(MAX),
    [BookingReference] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Order',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.606',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.316',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Order' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Order', N'CREATE TABLE [int_troap001].[DL_Order]
(
    [OrderId] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [CustomerId] NVARCHAR(MAX),
    [BillingAddressId] NVARCHAR(MAX),
    [DeliveryAddressId] NVARCHAR(MAX),
    [MicrosCheckNo] NVARCHAR(MAX),
    [MicrosCheckSeq] NVARCHAR(MAX),
    [MicrosRevenueCentre] NVARCHAR(MAX),
    [MicrosOrderTypeId] NVARCHAR(MAX),
    [MicrosEmployeeId] NVARCHAR(MAX),
    [MicrosDateToFire] NVARCHAR(MAX),
    [MicrosTenderMediaId] NVARCHAR(MAX),
    [MicrosStatusId] NVARCHAR(MAX),
    [TotalPriceNet] NVARCHAR(MAX),
    [TotalPriceVat] NVARCHAR(MAX),
    [TotalPriceTotal] NVARCHAR(MAX),
    [CurrencyId] NVARCHAR(MAX),
    [PaymentMethodId] NVARCHAR(MAX),
    [OrderStatusId] NVARCHAR(MAX),
    [PaymentStatusId] NVARCHAR(MAX),
    [ShipmentTypeId] NVARCHAR(MAX),
    [MicrosResponse] NVARCHAR(MAX),
    [CustomerEmail] NVARCHAR(MAX),
    [DeliveryInstructions] NVARCHAR(MAX),
    [DeliveryContact] NVARCHAR(MAX),
    [UserAgent] NVARCHAR(MAX),
    [ShopperIPAddress] NVARCHAR(MAX),
    [StoreServerIPAddress] NVARCHAR(MAX),
    [StoreServerDnsName] NVARCHAR(MAX),
    [DateOrderRequired] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsValidForReorder] NVARCHAR(MAX),
    [DomainName] NVARCHAR(MAX),
    [VoucherActualCode] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [DateCancelled] NVARCHAR(MAX),
    [ActualMicrosFireDate] NVARCHAR(MAX),
    [RetryCount] NVARCHAR(MAX),
    [ClientApplication] NVARCHAR(MAX),
    [Token] NVARCHAR(MAX),
    [AlcoholAgeVerifiedDate] NVARCHAR(MAX),
    [TableNumber] NVARCHAR(MAX),
    [AdditionalInfo] NVARCHAR(MAX),
    [SessionId] NVARCHAR(MAX),
    [BookingReference] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Order', 1, N'dbadmin', '2026-03-11 12:04:17.606', N'dbadmin', '2026-03-17 15:59:40.316', 1);
END
GO
-- ParameterKey=DL_OrderItem / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_OrderItem' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_OrderItem]
(
    [OrderItemId] NVARCHAR(MAX),
    [OrderItemParentId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [MicrosComboMealId] NVARCHAR(MAX),
    [MicrosComboGroupId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [ProductSku] NVARCHAR(MAX),
    [ProductDescription] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductBaseSizeSku] NVARCHAR(MAX),
    [ProductBoxSizeSku] NVARCHAR(MAX),
    [ProductToppingCoverageSku] NVARCHAR(MAX),
    [ToppingCoverageId] NVARCHAR(MAX),
    [Quantity] NVARCHAR(MAX),
    [PriceNet] NVARCHAR(MAX),
    [PriceVat] NVARCHAR(MAX),
    [PriceTotal] NVARCHAR(MAX),
    [IsValidForReorder] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [RuleSetId] NVARCHAR(MAX),
    [RuleSetTypeId] NVARCHAR(MAX),
    [ProductBaseId] NVARCHAR(MAX),
    [ProductSizeId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [RuleGroupId] NVARCHAR(MAX),
    [ExternalId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_OrderItem',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.666',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.360',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_OrderItem' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_OrderItem', N'CREATE TABLE [int_troap001].[DL_OrderItem]
(
    [OrderItemId] NVARCHAR(MAX),
    [OrderItemParentId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [MicrosComboMealId] NVARCHAR(MAX),
    [MicrosComboGroupId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [ProductSku] NVARCHAR(MAX),
    [ProductDescription] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductBaseSizeSku] NVARCHAR(MAX),
    [ProductBoxSizeSku] NVARCHAR(MAX),
    [ProductToppingCoverageSku] NVARCHAR(MAX),
    [ToppingCoverageId] NVARCHAR(MAX),
    [Quantity] NVARCHAR(MAX),
    [PriceNet] NVARCHAR(MAX),
    [PriceVat] NVARCHAR(MAX),
    [PriceTotal] NVARCHAR(MAX),
    [IsValidForReorder] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [RuleSetId] NVARCHAR(MAX),
    [RuleSetTypeId] NVARCHAR(MAX),
    [ProductBaseId] NVARCHAR(MAX),
    [ProductSizeId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [RuleGroupId] NVARCHAR(MAX),
    [ExternalId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_OrderItem', 1, N'dbadmin', '2026-03-11 12:04:17.666', N'dbadmin', '2026-03-17 15:59:40.360', 1);
END
GO
-- ParameterKey=DL_OrderPayment / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_OrderPayment' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_OrderPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [PaymentMethodId] NVARCHAR(MAX),
    [PaymentStatusId] NVARCHAR(MAX),
    [Amount] NVARCHAR(MAX),
    [Token] NVARCHAR(MAX),
    [Response] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [ThreeDSRef] NVARCHAR(MAX),
    [TransactionRef] NVARCHAR(MAX),
    [PaymentProviderTypeId] NVARCHAR(MAX),
    [RetryCount] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsLock] NVARCHAR(MAX),
    [LockTime] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_OrderPayment',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.766',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.453',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_OrderPayment' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_OrderPayment', N'CREATE TABLE [int_troap001].[DL_OrderPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [PaymentMethodId] NVARCHAR(MAX),
    [PaymentStatusId] NVARCHAR(MAX),
    [Amount] NVARCHAR(MAX),
    [Token] NVARCHAR(MAX),
    [Response] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [ThreeDSRef] NVARCHAR(MAX),
    [TransactionRef] NVARCHAR(MAX),
    [PaymentProviderTypeId] NVARCHAR(MAX),
    [RetryCount] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [IsLock] NVARCHAR(MAX),
    [LockTime] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_OrderPayment', 1, N'dbadmin', '2026-03-11 12:04:17.766', N'dbadmin', '2026-03-17 15:59:40.453', 1);
END
GO
-- ParameterKey=DL_OrderRefundQueue / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_OrderRefundQueue' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_OrderRefundQueue]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [RefundAmount] NVARCHAR(MAX),
    [RefundReasonId] NVARCHAR(MAX),
    [Reason] NVARCHAR(MAX),
    [CreatedBy] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [DateProcessed] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [CompletedBy] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_OrderRefundQueue',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.856',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.543',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_OrderRefundQueue' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_OrderRefundQueue', N'CREATE TABLE [int_troap001].[DL_OrderRefundQueue]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [RefundAmount] NVARCHAR(MAX),
    [RefundReasonId] NVARCHAR(MAX),
    [Reason] NVARCHAR(MAX),
    [CreatedBy] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [DateProcessed] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [CompletedBy] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_OrderRefundQueue', 1, N'dbadmin', '2026-03-11 12:04:17.856', N'dbadmin', '2026-03-17 15:59:40.543', 1);
END
GO
-- ParameterKey=DL_OrderSplitBill / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_OrderSplitBill' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_OrderSplitBill]
(
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DtbeNumberPeople] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_OrderSplitBill',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:17.953',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.640',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_OrderSplitBill' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_OrderSplitBill', N'CREATE TABLE [int_troap001].[DL_OrderSplitBill]
(
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DtbeNumberPeople] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_OrderSplitBill', 1, N'dbadmin', '2026-03-11 12:04:17.953', N'dbadmin', '2026-03-17 15:59:40.640', 1);
END
GO
-- ParameterKey=DL_OrderSplitBillItem / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_OrderSplitBillItem' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_OrderSplitBillItem]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderSplitBillPaymentId] NVARCHAR(MAX),
    [OrderItemId] NVARCHAR(MAX),
    [IsPaid] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_OrderSplitBillItem',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.030',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.686',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_OrderSplitBillItem' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_OrderSplitBillItem', N'CREATE TABLE [int_troap001].[DL_OrderSplitBillItem]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderSplitBillPaymentId] NVARCHAR(MAX),
    [OrderItemId] NVARCHAR(MAX),
    [IsPaid] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_OrderSplitBillItem', 1, N'dbadmin', '2026-03-11 12:04:18.030', N'dbadmin', '2026-03-17 15:59:40.686', 1);
END
GO
-- ParameterKey=DL_OrderSplitBillPayment / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_OrderSplitBillPayment' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_OrderSplitBillPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_OrderSplitBillPayment',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.126',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.776',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_OrderSplitBillPayment' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_OrderSplitBillPayment', N'CREATE TABLE [int_troap001].[DL_OrderSplitBillPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_OrderSplitBillPayment', 1, N'dbadmin', '2026-03-11 12:04:18.126', N'dbadmin', '2026-03-17 15:59:40.776', 1);
END
GO
-- ParameterKey=DL_Price / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Price' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Price]
(
    [PriceId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [CurrencyId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [PriceNet] NVARCHAR(MAX),
    [PriceVat] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [PriceInDeal] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Price',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.216',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.856',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Price' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Price', N'CREATE TABLE [int_troap001].[DL_Price]
(
    [PriceId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [CurrencyId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [PriceNet] NVARCHAR(MAX),
    [PriceVat] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [PriceInDeal] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Price', 1, N'dbadmin', '2026-03-11 12:04:18.216', N'dbadmin', '2026-03-17 15:59:40.856', 1);
END
GO
-- ParameterKey=DL_Product / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Product' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Product]
(
    [ProductId] NVARCHAR(MAX),
    [ProductSku] NVARCHAR(MAX),
    [ProductName] NVARCHAR(MAX),
    [ProductDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductSizeId] NVARCHAR(MAX),
    [ProductBaseId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [ToppingModifierId] NVARCHAR(MAX),
    [ToppingsAllowed] NVARCHAR(MAX),
    [DefaultToppingCount] NVARCHAR(MAX),
    [NoOfFreeDips] NVARCHAR(MAX),
    [IsVeggie] NVARCHAR(MAX),
    [HotLevel] NVARCHAR(MAX),
    [AllowHalf] NVARCHAR(MAX),
    [ProductBaseSizeSku] NVARCHAR(MAX),
    [ProductBoxSizeSku] NVARCHAR(MAX),
    [ProductWholeSku] NVARCHAR(MAX),
    [ProductLeftHalfSku] NVARCHAR(MAX),
    [ProductRightHalfSku] NVARCHAR(MAX),
    [DateEffective] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsNew] NVARCHAR(MAX),
    [IsDealOnly] NVARCHAR(MAX),
    [ShowDefaultOnly] NVARCHAR(MAX),
    [MvId] NVARCHAR(MAX),
    [ProductToppingGroupId] NVARCHAR(MAX),
    [ProductMenuCategoryId] NVARCHAR(MAX),
    [IsInSpecialDeal] NVARCHAR(MAX),
    [IsInHutValue] NVARCHAR(MAX),
    [AllowOptionalByStore] NVARCHAR(MAX),
    [Browseable] NVARCHAR(MAX),
    [CondimentType] NVARCHAR(MAX),
    [IsVegan] NVARCHAR(MAX),
    [ProductGuid] NVARCHAR(MAX),
    [IsGlutenFree] NVARCHAR(MAX),
    [AllowOutOfStock] NVARCHAR(MAX),
    [AvailabilityRuleId] NVARCHAR(MAX),
    [Calories] NVARCHAR(MAX),
    [ImageClass] NVARCHAR(MAX),
    [IsCarbonNeutral] NVARCHAR(MAX),
    [ExtendedDescription] NVARCHAR(MAX),
    [HideAllergenIcons] NVARCHAR(MAX),
    [ServingSuggestion] NVARCHAR(MAX),
    [Units] NVARCHAR(MAX),
    [AllowMultipleQuantity] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Product',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.313',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.953',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Product' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Product', N'CREATE TABLE [int_troap001].[DL_Product]
(
    [ProductId] NVARCHAR(MAX),
    [ProductSku] NVARCHAR(MAX),
    [ProductName] NVARCHAR(MAX),
    [ProductDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductSizeId] NVARCHAR(MAX),
    [ProductBaseId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [ToppingModifierId] NVARCHAR(MAX),
    [ToppingsAllowed] NVARCHAR(MAX),
    [DefaultToppingCount] NVARCHAR(MAX),
    [NoOfFreeDips] NVARCHAR(MAX),
    [IsVeggie] NVARCHAR(MAX),
    [HotLevel] NVARCHAR(MAX),
    [AllowHalf] NVARCHAR(MAX),
    [ProductBaseSizeSku] NVARCHAR(MAX),
    [ProductBoxSizeSku] NVARCHAR(MAX),
    [ProductWholeSku] NVARCHAR(MAX),
    [ProductLeftHalfSku] NVARCHAR(MAX),
    [ProductRightHalfSku] NVARCHAR(MAX),
    [DateEffective] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [IsNew] NVARCHAR(MAX),
    [IsDealOnly] NVARCHAR(MAX),
    [ShowDefaultOnly] NVARCHAR(MAX),
    [MvId] NVARCHAR(MAX),
    [ProductToppingGroupId] NVARCHAR(MAX),
    [ProductMenuCategoryId] NVARCHAR(MAX),
    [IsInSpecialDeal] NVARCHAR(MAX),
    [IsInHutValue] NVARCHAR(MAX),
    [AllowOptionalByStore] NVARCHAR(MAX),
    [Browseable] NVARCHAR(MAX),
    [CondimentType] NVARCHAR(MAX),
    [IsVegan] NVARCHAR(MAX),
    [ProductGuid] NVARCHAR(MAX),
    [IsGlutenFree] NVARCHAR(MAX),
    [AllowOutOfStock] NVARCHAR(MAX),
    [AvailabilityRuleId] NVARCHAR(MAX),
    [Calories] NVARCHAR(MAX),
    [ImageClass] NVARCHAR(MAX),
    [IsCarbonNeutral] NVARCHAR(MAX),
    [ExtendedDescription] NVARCHAR(MAX),
    [HideAllergenIcons] NVARCHAR(MAX),
    [ServingSuggestion] NVARCHAR(MAX),
    [Units] NVARCHAR(MAX),
    [AllowMultipleQuantity] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Product', 1, N'dbadmin', '2026-03-11 12:04:18.313', N'dbadmin', '2026-03-17 15:59:40.953', 1);
END
GO
-- ParameterKey=DL_ProductBase / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ProductBase' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_ProductBase]
(
    [ProductBaseId] NVARCHAR(MAX),
    [ProductBaseName] NVARCHAR(MAX),
    [ProductBaseDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [IsSaleable] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ProductBase',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.360',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:40.993',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ProductBase' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ProductBase', N'CREATE TABLE [int_troap001].[DL_ProductBase]
(
    [ProductBaseId] NVARCHAR(MAX),
    [ProductBaseName] NVARCHAR(MAX),
    [ProductBaseDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [IsSaleable] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_ProductBase', 1, N'dbadmin', '2026-03-11 12:04:18.360', N'dbadmin', '2026-03-17 15:59:40.993', 1);
END
GO
-- ParameterKey=DL_ProductCategory / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ProductCategory' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_ProductCategory]
(
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductCategoryName] NVARCHAR(MAX),
    [ProductCategoryDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ProductCategory',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.430',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.090',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ProductCategory' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ProductCategory', N'CREATE TABLE [int_troap001].[DL_ProductCategory]
(
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductCategoryName] NVARCHAR(MAX),
    [ProductCategoryDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_ProductCategory', 1, N'dbadmin', '2026-03-11 12:04:18.430', N'dbadmin', '2026-03-17 15:59:41.090', 1);
END
GO
-- ParameterKey=DL_Store / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_Store' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_Store]
(
    [StoreId] NVARCHAR(MAX),
    [StoreName] NVARCHAR(MAX),
    [StorePostCode] NVARCHAR(MAX),
    [StoreGridEast] NVARCHAR(MAX),
    [StoreGridNorth] NVARCHAR(MAX),
    [StoreLongitude] NVARCHAR(MAX),
    [StoreLatitude] NVARCHAR(MAX),
    [AddressId] NVARCHAR(MAX),
    [StoreTypeId] NVARCHAR(MAX),
    [DefaultCurrencyId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [StoreServiceTypeId] NVARCHAR(MAX),
    [PrimaryContactTelephone] NVARCHAR(MAX),
    [ContactEmail] NVARCHAR(MAX),
    [ServerIPAddress] NVARCHAR(MAX),
    [ServerDNSName] NVARCHAR(MAX),
    [MaxAdvanceOrderInDays] NVARCHAR(MAX),
    [AllowInternetOrdering] NVARCHAR(MAX),
    [MinOrderValue] NVARCHAR(MAX),
    [MaxOrderValue] NVARCHAR(MAX),
    [LastOrderTimeInMins] NVARCHAR(MAX),
    [DdaAdditionInfo] NVARCHAR(MAX),
    [DdaFacilities] NVARCHAR(MAX),
    [DdaReason] NVARCHAR(MAX),
    [OpeningHours] NVARCHAR(MAX),
    [DateStoreActive] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [BrandId] NVARCHAR(MAX),
    [AllowPriceOverride] NVARCHAR(MAX),
    [AllowOpeningExtraHours] NVARCHAR(MAX),
    [VatNumber] NVARCHAR(MAX),
    [MerchantCodeId] NVARCHAR(MAX),
    [AllowOptionalProductOverride] NVARCHAR(MAX),
    [HutMessage] NVARCHAR(MAX),
    [StoreUrlName] NVARCHAR(MAX),
    [SEOKeywords] NVARCHAR(MAX),
    [FSARating] NVARCHAR(MAX),
    [DeliverooUrl] NVARCHAR(MAX),
    [IsActive] NVARCHAR(MAX),
    [POSProvider] NVARCHAR(MAX),
    [StoreGroupId] NVARCHAR(MAX),
    [SmartQLocationId] NVARCHAR(MAX),
    [ClosureDate] NVARCHAR(MAX),
    [UserCanOpen] NVARCHAR(MAX),
    [SalesAreaName] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_Store',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.530',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.126',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_Store' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_Store', N'CREATE TABLE [int_troap001].[DL_Store]
(
    [StoreId] NVARCHAR(MAX),
    [StoreName] NVARCHAR(MAX),
    [StorePostCode] NVARCHAR(MAX),
    [StoreGridEast] NVARCHAR(MAX),
    [StoreGridNorth] NVARCHAR(MAX),
    [StoreLongitude] NVARCHAR(MAX),
    [StoreLatitude] NVARCHAR(MAX),
    [AddressId] NVARCHAR(MAX),
    [StoreTypeId] NVARCHAR(MAX),
    [DefaultCurrencyId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [StoreServiceTypeId] NVARCHAR(MAX),
    [PrimaryContactTelephone] NVARCHAR(MAX),
    [ContactEmail] NVARCHAR(MAX),
    [ServerIPAddress] NVARCHAR(MAX),
    [ServerDNSName] NVARCHAR(MAX),
    [MaxAdvanceOrderInDays] NVARCHAR(MAX),
    [AllowInternetOrdering] NVARCHAR(MAX),
    [MinOrderValue] NVARCHAR(MAX),
    [MaxOrderValue] NVARCHAR(MAX),
    [LastOrderTimeInMins] NVARCHAR(MAX),
    [DdaAdditionInfo] NVARCHAR(MAX),
    [DdaFacilities] NVARCHAR(MAX),
    [DdaReason] NVARCHAR(MAX),
    [OpeningHours] NVARCHAR(MAX),
    [DateStoreActive] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [UpdatedBy] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [BrandId] NVARCHAR(MAX),
    [AllowPriceOverride] NVARCHAR(MAX),
    [AllowOpeningExtraHours] NVARCHAR(MAX),
    [VatNumber] NVARCHAR(MAX),
    [MerchantCodeId] NVARCHAR(MAX),
    [AllowOptionalProductOverride] NVARCHAR(MAX),
    [HutMessage] NVARCHAR(MAX),
    [StoreUrlName] NVARCHAR(MAX),
    [SEOKeywords] NVARCHAR(MAX),
    [FSARating] NVARCHAR(MAX),
    [DeliverooUrl] NVARCHAR(MAX),
    [IsActive] NVARCHAR(MAX),
    [POSProvider] NVARCHAR(MAX),
    [StoreGroupId] NVARCHAR(MAX),
    [SmartQLocationId] NVARCHAR(MAX),
    [ClosureDate] NVARCHAR(MAX),
    [UserCanOpen] NVARCHAR(MAX),
    [SalesAreaName] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_Store', 1, N'dbadmin', '2026-03-11 12:04:18.530', N'dbadmin', '2026-03-17 15:59:41.126', 1);
END
GO
-- ParameterKey=DL_StoreOpeningHours / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_StoreOpeningHours' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_StoreOpeningHours]
(
    [StoreId] NVARCHAR(MAX),
    [DayOfWeek] NVARCHAR(MAX),
    [OpenTimeHour] NVARCHAR(MAX),
    [OpenTimeMin] NVARCHAR(MAX),
    [CloseTimeHour] NVARCHAR(MAX),
    [CloseTimeMin] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [StartDate] NVARCHAR(MAX),
    [StoreOpeningHoursGroupId] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_StoreOpeningHours',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.573',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.170',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_StoreOpeningHours' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_StoreOpeningHours', N'CREATE TABLE [int_troap001].[DL_StoreOpeningHours]
(
    [StoreId] NVARCHAR(MAX),
    [DayOfWeek] NVARCHAR(MAX),
    [OpenTimeHour] NVARCHAR(MAX),
    [OpenTimeMin] NVARCHAR(MAX),
    [CloseTimeHour] NVARCHAR(MAX),
    [CloseTimeMin] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [StartDate] NVARCHAR(MAX),
    [StoreOpeningHoursGroupId] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_StoreOpeningHours', 1, N'dbadmin', '2026-03-11 12:04:18.573', N'dbadmin', '2026-03-17 15:59:41.170', 1);
END
GO
-- ParameterKey=DL_StoreOpeningHoursGroup / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_StoreOpeningHoursGroup' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_StoreOpeningHoursGroup]
(
    [StoreOpeningHoursGroupId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [DisplayOnSite] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DateDeleted] NVARCHAR(MAX),
    [DeletedBy] NVARCHAR(MAX),
    [DisplayAsWeek] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_StoreOpeningHoursGroup',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.676',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.260',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_StoreOpeningHoursGroup' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_StoreOpeningHoursGroup', N'CREATE TABLE [int_troap001].[DL_StoreOpeningHoursGroup]
(
    [StoreOpeningHoursGroupId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [Description] NVARCHAR(MAX),
    [DisplayOnSite] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DateDeleted] NVARCHAR(MAX),
    [DeletedBy] NVARCHAR(MAX),
    [DisplayAsWeek] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_StoreOpeningHoursGroup', 1, N'dbadmin', '2026-03-11 12:04:18.676', N'dbadmin', '2026-03-17 15:59:41.260', 1);
END
GO
-- ParameterKey=DL_StoreOrderType / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_StoreOrderType' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_StoreOrderType]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_StoreOrderType',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.773',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.360',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_StoreOrderType' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_StoreOrderType', N'CREATE TABLE [int_troap001].[DL_StoreOrderType]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_StoreOrderType', 1, N'dbadmin', '2026-03-11 12:04:18.773', N'dbadmin', '2026-03-17 15:59:41.360', 1);
END
GO
-- ParameterKey=DL_StoreProductOutOfStock / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_StoreProductOutOfStock' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_StoreProductOutOfStock]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [CreatedBy] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [ShowOnWebsite] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_StoreProductOutOfStock',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.866',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.450',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_StoreProductOutOfStock' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_StoreProductOutOfStock', N'CREATE TABLE [int_troap001].[DL_StoreProductOutOfStock]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [CreatedBy] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [ShowOnWebsite] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_StoreProductOutOfStock', 1, N'dbadmin', '2026-03-11 12:04:18.866', N'dbadmin', '2026-03-17 15:59:41.450', 1);
END
GO
-- ParameterKey=DL_ZonalMenu / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ZonalMenu' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_ZonalMenu]
(
    [Id] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [ExternalMenuId] NVARCHAR(MAX),
    [CanOrder] NVARCHAR(MAX),
    [StandardImageId] NVARCHAR(MAX),
    [MenuCategoryDisabled] NVARCHAR(MAX),
    [CustomField] NVARCHAR(MAX),
    [ImageId] NVARCHAR(MAX),
    [VersionId] NVARCHAR(MAX),
    [SquareImageId] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [CreatedDate] NVARCHAR(MAX),
    [UpdatedDate] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [MenuName] NVARCHAR(MAX),
    [MenuCategoryId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ZonalMenu',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:18.956',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.546',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ZonalMenu' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ZonalMenu', N'CREATE TABLE [int_troap001].[DL_ZonalMenu]
(
    [Id] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [ExternalMenuId] NVARCHAR(MAX),
    [CanOrder] NVARCHAR(MAX),
    [StandardImageId] NVARCHAR(MAX),
    [MenuCategoryDisabled] NVARCHAR(MAX),
    [CustomField] NVARCHAR(MAX),
    [ImageId] NVARCHAR(MAX),
    [VersionId] NVARCHAR(MAX),
    [SquareImageId] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [CreatedDate] NVARCHAR(MAX),
    [UpdatedDate] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [MenuName] NVARCHAR(MAX),
    [MenuCategoryId] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_ZonalMenu', 1, N'dbadmin', '2026-03-11 12:04:18.956', N'dbadmin', '2026-03-17 15:59:41.546', 1);
END
GO
-- ParameterKey=DL_ZonalProduct / Category=STAGE_DDL
IF EXISTS (SELECT 1 FROM [core].[int_troap001].[GlobalParameters] WHERE [ParameterKey] = N'DL_ZonalProduct' AND [Category] = N'STAGE_DDL')
BEGIN
    UPDATE [core].[int_troap001].[GlobalParameters]
    SET
        [ParameterValue] = N'CREATE TABLE [int_troap001].[DL_ZonalProduct]
(
    [ZonalProductId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [CreatedDate] NVARCHAR(MAX),
    [UpdatedDate] NVARCHAR(MAX),
    [DefaultCourseId] NVARCHAR(MAX),
    [CategoryId] NVARCHAR(MAX),
    [SubcategoryId] NVARCHAR(MAX),
    [DivisionId] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [ExternalProductSku] NVARCHAR(MAX),
    [ShowCourseDialog] NVARCHAR(MAX),
    [IsInstruction] NVARCHAR(MAX),
    [MinimumCustomerAge] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        [DataType] = N'STRING',
        [Description] = N'DL_ZonalProduct',
        [IsActive] = 1,
        [CreatedBy] = N'dbadmin',
        [CreatedDate] = '2026-03-11 12:04:19.046',
        [ModifiedBy] = N'dbadmin',
        [ModifiedDate] = '2026-03-17 15:59:41.636',
        [Version] = 1
    WHERE [ParameterKey] = N'DL_ZonalProduct' AND [Category] = N'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO [core].[int_troap001].[GlobalParameters] ([ParameterKey], [ParameterValue], [DataType], [Category], [Description], [IsActive], [CreatedBy], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version])
    VALUES (N'DL_ZonalProduct', N'CREATE TABLE [int_troap001].[DL_ZonalProduct]
(
    [ZonalProductId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [CreatedDate] NVARCHAR(MAX),
    [UpdatedDate] NVARCHAR(MAX),
    [DefaultCourseId] NVARCHAR(MAX),
    [CategoryId] NVARCHAR(MAX),
    [SubcategoryId] NVARCHAR(MAX),
    [DivisionId] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [ExternalProductSku] NVARCHAR(MAX),
    [ShowCourseDialog] NVARCHAR(MAX),
    [IsInstruction] NVARCHAR(MAX),
    [MinimumCustomerAge] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [LOADTS_UTC] [datetime2](7) NULL,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', N'STRING', N'STAGE_DDL', N'DL_ZonalProduct', 1, N'dbadmin', '2026-03-11 12:04:19.046', N'dbadmin', '2026-03-17 15:59:41.636', 1);
END
GO
