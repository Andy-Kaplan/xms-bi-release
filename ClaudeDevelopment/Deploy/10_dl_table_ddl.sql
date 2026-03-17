-- =============================================================================
-- 10_dl_table_ddl.sql
-- DL Table DDL GlobalParameters for UAT Migration
-- Integrations: TROaP (44 tables), SurveyHero (8 tables), Growyze (10 tables)
-- Note: TBTBookingMetrics has no DL DDL records
-- Generated: 2026-03-11
-- =============================================================================

-- =============================================================================
-- TROAP001 - 44 DL Tables
-- =============================================================================

-- Table: DL_Address
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Address' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Address]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Address',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Address' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Address', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_Allergen
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Allergen' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Allergen]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Allergen',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Allergen' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Allergen', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_AllowedStores
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_AllowedStores' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_AllowedStores]
(
    [Id] NVARCHAR(MAX),
    [SiteId] NVARCHAR(MAX),
    [SalesAreaId] NVARCHAR(MAX),
    [SiteUrl] NVARCHAR(MAX),
    [SiteCode] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_AllowedStores',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_AllowedStores' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_AllowedStores', N'CREATE TABLE [int_troap001].[DL_AllowedStores]
(
    [Id] NVARCHAR(MAX),
    [SiteId] NVARCHAR(MAX),
    [SalesAreaId] NVARCHAR(MAX),
    [SiteUrl] NVARCHAR(MAX),
    [SiteCode] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_AllowedStores', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_AvailabilityRule
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_AvailabilityRule' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_AvailabilityRule]
(
    [AvailabilityRuleId] NVARCHAR(MAX),
    [AvailabilityRuleName] NVARCHAR(MAX),
    [AllowOnBankHoliday] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_AvailabilityRule',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_AvailabilityRule' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_AvailabilityRule', N'CREATE TABLE [int_troap001].[DL_AvailabilityRule]
(
    [AvailabilityRuleId] NVARCHAR(MAX),
    [AvailabilityRuleName] NVARCHAR(MAX),
    [AllowOnBankHoliday] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_AvailabilityRule', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_AvailabilityRuleValidDays
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_AvailabilityRuleValidDays' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_AvailabilityRuleValidDays]
(
    [ValidDayId] NVARCHAR(MAX),
    [AvailabilityRuleId] NVARCHAR(MAX),
    [DayOfWeek] NVARCHAR(MAX),
    [StartHour] NVARCHAR(MAX),
    [StartMinute] NVARCHAR(MAX),
    [EndHour] NVARCHAR(MAX),
    [EndMinute] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_AvailabilityRuleValidDays',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_AvailabilityRuleValidDays' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_AvailabilityRuleValidDays', N'CREATE TABLE [int_troap001].[DL_AvailabilityRuleValidDays]
(
    [ValidDayId] NVARCHAR(MAX),
    [AvailabilityRuleId] NVARCHAR(MAX),
    [DayOfWeek] NVARCHAR(MAX),
    [StartHour] NVARCHAR(MAX),
    [StartMinute] NVARCHAR(MAX),
    [EndHour] NVARCHAR(MAX),
    [EndMinute] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_AvailabilityRuleValidDays', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_Basket
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Basket' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Basket]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Basket',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Basket' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Basket', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_BasketItem
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_BasketItem' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_BasketItem]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_BasketItem',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_BasketItem' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_BasketItem', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_BrainTreePaymentIntent
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_BrainTreePaymentIntent' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentIntent]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [BrainTreeClientSecret] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [IsSuccess] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_BrainTreePaymentIntent',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_BrainTreePaymentIntent' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_BrainTreePaymentIntent', N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentIntent]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [BrainTreeClientSecret] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [IsSuccess] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_BrainTreePaymentIntent', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_BrainTreePaymentLog
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_BrainTreePaymentLog' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentLog]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [TransactionId] NVARCHAR(MAX),
    [RequestType] NVARCHAR(MAX),
    [Response] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_BrainTreePaymentLog',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_BrainTreePaymentLog' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_BrainTreePaymentLog', N'CREATE TABLE [int_troap001].[DL_BrainTreePaymentLog]
(
    [Id] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [TransactionId] NVARCHAR(MAX),
    [RequestType] NVARCHAR(MAX),
    [Response] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_BrainTreePaymentLog', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_CouponDiscount
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CouponDiscount' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CouponDiscount]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CouponDiscount',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CouponDiscount' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CouponDiscount', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_Customer
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Customer' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Customer]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Customer',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Customer' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Customer', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_CustomerOpenCheck
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CustomerOpenCheck' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheck]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CustomerOpenCheck',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CustomerOpenCheck' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CustomerOpenCheck', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_CustomerOpenCheckBasket
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CustomerOpenCheckBasket' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckBasket]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CustomerOpenCheckBasket',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CustomerOpenCheckBasket' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CustomerOpenCheckBasket', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_CustomerOpenCheckCharge
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CustomerOpenCheckCharge' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCharge]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CustomerOpenCheckCharge',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CustomerOpenCheckCharge' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CustomerOpenCheckCharge', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_CustomerOpenCheckCouponDiscount
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CustomerOpenCheckCouponDiscount' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCouponDiscount]
(
    [Id] NVARCHAR(MAX),
    [CouponDiscountId] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Used] NVARCHAR(MAX),
    [MemberId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CustomerOpenCheckCouponDiscount',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CustomerOpenCheckCouponDiscount' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_CustomerOpenCheckCouponDiscount', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckCouponDiscount]
(
    [Id] NVARCHAR(MAX),
    [CouponDiscountId] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Used] NVARCHAR(MAX),
    [MemberId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CustomerOpenCheckCouponDiscount', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_CustomerOpenCheckDiscount
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CustomerOpenCheckDiscount' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckDiscount]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [DiscountId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [Amount] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CustomerOpenCheckDiscount',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CustomerOpenCheckDiscount' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_CustomerOpenCheckDiscount', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckDiscount]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [DiscountId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [Amount] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CustomerOpenCheckDiscount', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_CustomerOpenCheckPromotion
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_CustomerOpenCheckPromotion' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckPromotion]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [DiscountApplyingToOrderLineFamily] NVARCHAR(MAX),
    [FullPrice] NVARCHAR(MAX),
    [PromotedPrice] NVARCHAR(MAX),
    [PromotionalSaving] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_CustomerOpenCheckPromotion',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_CustomerOpenCheckPromotion' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_CustomerOpenCheckPromotion', N'CREATE TABLE [int_troap001].[DL_CustomerOpenCheckPromotion]
(
    [Id] NVARCHAR(MAX),
    [CustomerOpenCheckId] NVARCHAR(MAX),
    [Name] NVARCHAR(MAX),
    [DiscountApplyingToOrderLineFamily] NVARCHAR(MAX),
    [FullPrice] NVARCHAR(MAX),
    [PromotedPrice] NVARCHAR(MAX),
    [PromotionalSaving] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_CustomerOpenCheckPromotion', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_Device
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Device' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Device]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Device',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Device' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Device', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_lstChargeType
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_lstChargeType' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_lstChargeType](
	[Id] [nvarchar](max) NULL,
	[DisplayTitle] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [nvarchar](max) NULL,
	[IsDeleted] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL
)',
        Description = N'DL_lstChargeType',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_lstChargeType' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_lstChargeType', N'CREATE TABLE [int_troap001].[DL_lstChargeType](
	[Id] [nvarchar](max) NULL,
	[DisplayTitle] [nvarchar](max) NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [nvarchar](max) NULL,
	[IsDeleted] [nvarchar](max) NULL,
	[LOADTS_UTC] [datetime2](7) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL
)', 'STRING', 'STAGE_DDL', N'DL_lstChargeType', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_lstPaymentType
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_lstPaymentType' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_lstPaymentType] (
    [Id]             NVARCHAR(MAX),
    [DisplayTitle]   NVARCHAR(MAX),
    [Description]    NVARCHAR(MAX),
    [SortOrder]      NVARCHAR(MAX),
    [DELETED_FLAG]   NVARCHAR(MAX),
    [IsAvailable]    NVARCHAR(MAX),
    [LOADTS_UTC]     DATETIME2,
    [INT_FETCH_DATE] DATETIME2 NULL
);',
        Description = N'DL_lstPaymentType',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_lstPaymentType' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_lstPaymentType', N'CREATE TABLE [int_troap001].[DL_lstPaymentType] (
    [Id]             NVARCHAR(MAX),
    [DisplayTitle]   NVARCHAR(MAX),
    [Description]    NVARCHAR(MAX),
    [SortOrder]      NVARCHAR(MAX),
    [DELETED_FLAG]   NVARCHAR(MAX),
    [IsAvailable]    NVARCHAR(MAX),
    [LOADTS_UTC]     DATETIME2,
    [INT_FETCH_DATE] DATETIME2 NULL
);', 'STRING', 'STAGE_DDL', N'DL_lstPaymentType', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_lstShipmentType
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_lstShipmentType' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_lstShipmentType]
(
    [Id]              NVARCHAR(MAX),
    [DisplayTitle]    NVARCHAR(MAX),
    [Description]     NVARCHAR(MAX),
    [SortOrder]       NVARCHAR(MAX),
    [DELETED_FLAG]    NVARCHAR(MAX),
    [TimeToFire]      NVARCHAR(MAX),
    [IsAvailable]     NVARCHAR(MAX),
    [OrderTypeId]     NVARCHAR(MAX),
    [LOADTS_UTC]      DATETIME2(7),
    [INT_FETCH_DATE]  DATETIME2(7) NULL
);',
        Description = N'DL_lstShipmentType',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_lstShipmentType' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_lstShipmentType', N'CREATE TABLE [int_troap001].[DL_lstShipmentType]
(
    [Id]              NVARCHAR(MAX),
    [DisplayTitle]    NVARCHAR(MAX),
    [Description]     NVARCHAR(MAX),
    [SortOrder]       NVARCHAR(MAX),
    [DELETED_FLAG]    NVARCHAR(MAX),
    [TimeToFire]      NVARCHAR(MAX),
    [IsAvailable]     NVARCHAR(MAX),
    [OrderTypeId]     NVARCHAR(MAX),
    [LOADTS_UTC]      DATETIME2(7),
    [INT_FETCH_DATE]  DATETIME2(7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_lstShipmentType', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_Menu
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Menu' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Menu]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Menu',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Menu' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Menu', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_MenuCategory
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_MenuCategory' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_MenuCategory]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_MenuCategory',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_MenuCategory' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_MenuCategory', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_MenuCategoryGroup
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_MenuCategoryGroup' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_MenuCategoryGroup]
(
    [Id] NVARCHAR(MAX),
    [MenuCategoryId] NVARCHAR(MAX),
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductGroupId] NVARCHAR(MAX),
    [GroupName] NVARCHAR(MAX),
    [GroupDescription] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [IsDeleted] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_MenuCategoryGroup',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_MenuCategoryGroup' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_MenuCategoryGroup', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_MenuPriceBand
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_MenuPriceBand' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_MenuPriceBand]
(
    [Id] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [PriceBandId] NVARCHAR(MAX),
    [IsDefault] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_MenuPriceBand',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_MenuPriceBand' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_MenuPriceBand', N'CREATE TABLE [int_troap001].[DL_MenuPriceBand]
(
    [Id] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [PriceBandId] NVARCHAR(MAX),
    [IsDefault] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_MenuPriceBand', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_MenuProduct
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_MenuProduct' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_MenuProduct]
(
    [MenuId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_MenuProduct',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_MenuProduct' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_MenuProduct', N'CREATE TABLE [int_troap001].[DL_MenuProduct]
(
    [MenuId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_MenuProduct', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_Order
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Order' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Order]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Order',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Order' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Order', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_OrderItem
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderItem' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderItem]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_OrderItem',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OrderItem' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_OrderItem', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_OrderPayment
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderPayment' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderPayment]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_OrderPayment',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OrderPayment' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_OrderPayment', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_OrderRefundQueue
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderRefundQueue' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderRefundQueue]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_OrderRefundQueue',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OrderRefundQueue' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_OrderRefundQueue', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_OrderSplitBill
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderSplitBill' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderSplitBill]
(
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DtbeNumberPeople] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_OrderSplitBill',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OrderSplitBill' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_OrderSplitBill', N'CREATE TABLE [int_troap001].[DL_OrderSplitBill]
(
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DtbeNumberPeople] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_OrderSplitBill', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_OrderSplitBillItem
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderSplitBillItem' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderSplitBillItem]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderSplitBillPaymentId] NVARCHAR(MAX),
    [OrderItemId] NVARCHAR(MAX),
    [IsPaid] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_OrderSplitBillItem',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OrderSplitBillItem' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_OrderSplitBillItem', N'CREATE TABLE [int_troap001].[DL_OrderSplitBillItem]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderSplitBillPaymentId] NVARCHAR(MAX),
    [OrderItemId] NVARCHAR(MAX),
    [IsPaid] NVARCHAR(MAX),
    [DateUpdated] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_OrderSplitBillItem', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_OrderSplitBillPayment
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderSplitBillPayment' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderSplitBillPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_OrderSplitBillPayment',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_OrderSplitBillPayment' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_OrderSplitBillPayment', N'CREATE TABLE [int_troap001].[DL_OrderSplitBillPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_OrderSplitBillPayment', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_Price
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Price' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Price]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Price',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Price' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Price', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_Product
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Product' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Product]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Product',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Product' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Product', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ProductBase
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_ProductBase' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_ProductBase]
(
    [ProductBaseId] NVARCHAR(MAX),
    [ProductBaseName] NVARCHAR(MAX),
    [ProductBaseDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [IsSaleable] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ProductBase',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ProductBase' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ProductBase', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ProductCategory
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_ProductCategory' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_ProductCategory]
(
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductCategoryName] NVARCHAR(MAX),
    [ProductCategoryDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ProductCategory',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ProductCategory' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ProductCategory', N'CREATE TABLE [int_troap001].[DL_ProductCategory]
(
    [ProductCategoryId] NVARCHAR(MAX),
    [ProductCategoryName] NVARCHAR(MAX),
    [ProductCategoryDescription] NVARCHAR(MAX),
    [MarketingDescription] NVARCHAR(MAX),
    [MarketingImage] NVARCHAR(MAX),
    [SortOrder] NVARCHAR(MAX),
    [DELETED_FLAG] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ProductCategory', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_Store
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_Store' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_Store]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_Store',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_Store' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_Store', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_StoreOpeningHours
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_StoreOpeningHours' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_StoreOpeningHours]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_StoreOpeningHours',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_StoreOpeningHours' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_StoreOpeningHours', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_StoreOpeningHoursGroup
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_StoreOpeningHoursGroup' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_StoreOpeningHoursGroup]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_StoreOpeningHoursGroup',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_StoreOpeningHoursGroup' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_StoreOpeningHoursGroup', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_StoreOrderType
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_StoreOrderType' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_StoreOrderType]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_StoreOrderType',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_StoreOrderType' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_StoreOrderType', N'CREATE TABLE [int_troap001].[DL_StoreOrderType]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [OrderTypeId] NVARCHAR(MAX),
    [MenuId] NVARCHAR(MAX),
    [StorePriceBandId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_StoreOrderType', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_StoreProductOutOfStock
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_StoreProductOutOfStock' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_StoreProductOutOfStock]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [CreatedBy] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [ShowOnWebsite] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_StoreProductOutOfStock',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_StoreProductOutOfStock' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_StoreProductOutOfStock', N'CREATE TABLE [int_troap001].[DL_StoreProductOutOfStock]
(
    [Id] NVARCHAR(MAX),
    [StoreId] NVARCHAR(MAX),
    [ProductId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [CreatedBy] NVARCHAR(MAX),
    [DateExpires] NVARCHAR(MAX),
    [ShowOnWebsite] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_StoreProductOutOfStock', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ZonalMenu
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_ZonalMenu' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_ZonalMenu]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ZonalMenu',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ZonalMenu' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ZonalMenu', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ZonalProduct
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_ZonalProduct' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_ZonalProduct]
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ZonalProduct',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ZonalProduct' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_troap001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
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
    [LOADTS_UTC] DATETIME2,
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ZonalProduct', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- =============================================================================
-- SURVEYHERO001 - 8 DL Tables
-- =============================================================================


-- Table: DL_ANSWERS
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    question_text NVARCHAR(MAX),
    answer_type NVARCHAR(50), 
    text_value NVARCHAR(MAX),
    number_value FLOAT, 
    file_value NVARCHAR(MAX), 
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'base answer data',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    question_text NVARCHAR(MAX),
    answer_type NVARCHAR(50), 
    text_value NVARCHAR(MAX),
    number_value FLOAT, 
    file_value NVARCHAR(MAX), 
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'base answer data', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ANSWERS_CHOICES
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS_CHOICES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_CHOICES] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ANSWERS_CHOICES (exploded choices from answers)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS_CHOICES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_CHOICES] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ANSWERS_CHOICES (exploded choices from answers)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ANSWERS_INPUT_TABLE
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS_INPUT_TABLE' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_INPUT_TABLE] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    row_id BIGINT,
    row_label NVARCHAR(MAX),
    column_id BIGINT,
    column_label NVARCHAR(MAX),
    answer_type NVARCHAR(50),
    number_value FLOAT,
    text_value NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ANSWERS_INPUT_TABLE (for input_table questions)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS_INPUT_TABLE' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS_INPUT_TABLE', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_INPUT_TABLE] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    row_id BIGINT,
    row_label NVARCHAR(MAX),
    column_id BIGINT,
    column_label NVARCHAR(MAX),
    answer_type NVARCHAR(50),
    number_value FLOAT,
    text_value NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ANSWERS_INPUT_TABLE (for input_table questions)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ANSWERS_RANKING
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ANSWERS_RANKING' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_RANKING] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    rank_order INT,
    is_not_applicable BIT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ANSWERS_RANKING (for ranking questions)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ANSWERS_RANKING' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ANSWERS_RANKING', N'CREATE TABLE [int_surveyhero001].[DL_ANSWERS_RANKING] (
    survey_id BIGINT,
    response_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    rank_order INT,
    is_not_applicable BIT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ANSWERS_RANKING (for ranking questions)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ELEMENTS
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ELEMENTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS] (
    survey_id BIGINT,
    element_id BIGINT,
    type NVARCHAR(50),
    question_text NVARCHAR(MAX),
    description_text NVARCHAR(MAX),
    question_type NVARCHAR(50),
    is_required BIT,
    settings_json NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'Information about the components of each survey',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ELEMENTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ELEMENTS', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS] (
    survey_id BIGINT,
    element_id BIGINT,
    type NVARCHAR(50),
    question_text NVARCHAR(MAX),
    description_text NVARCHAR(MAX),
    question_type NVARCHAR(50),
    is_required BIT,
    settings_json NVARCHAR(MAX),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'Information about the components of each survey', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ELEMENTS_CHOICES
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_ELEMENTS_CHOICES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_CHOICES] (
    survey_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    column_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'DL_ELEMENTS_CHOICES (exploded choices from elements)',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ELEMENTS_CHOICES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ELEMENTS_CHOICES', N'CREATE TABLE [int_surveyhero001].[DL_ELEMENTS_CHOICES] (
    survey_id BIGINT,
    element_id BIGINT,
    choice_id BIGINT,
    label NVARCHAR(MAX),
    image_url NVARCHAR(MAX),
    row_id BIGINT NULL,
    column_id BIGINT NULL,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ELEMENTS_CHOICES (exploded choices from elements)', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_RESPONSES
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_RESPONSES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES] (
    survey_id BIGINT,
    response_id BIGINT,
    collector_id BIGINT,
    started_on DATETIME2,
    last_updated_on DATETIME2,
    access_code NVARCHAR(255),
    email_address NVARCHAR(255),
    recipient_data NVARCHAR(MAX),
    link_parameters NVARCHAR(MAX),
    language NVARCHAR(50),
    ip_address NVARCHAR(50),
    meta_data_device NVARCHAR(50),
    meta_data_user_agent NVARCHAR(MAX),
    status NVARCHAR(50),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'All Responses to each survey',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RESPONSES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RESPONSES', N'CREATE TABLE [int_surveyhero001].[DL_RESPONSES] (
    survey_id BIGINT,
    response_id BIGINT,
    collector_id BIGINT,
    started_on DATETIME2,
    last_updated_on DATETIME2,
    access_code NVARCHAR(255),
    email_address NVARCHAR(255),
    recipient_data NVARCHAR(MAX),
    link_parameters NVARCHAR(MAX),
    language NVARCHAR(50),
    ip_address NVARCHAR(50),
    meta_data_device NVARCHAR(50),
    meta_data_user_agent NVARCHAR(MAX),
    status NVARCHAR(50),
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'All Responses to each survey', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_SURVEYS
IF EXISTS (SELECT 1 FROM core.[int_surveyhero001].[GlobalParameters] WHERE ParameterKey = N'DL_SURVEYS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_surveyhero001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS] (
    survey_id BIGINT,
    title NVARCHAR(500),
    internal_name NVARCHAR(500),
    created_on DATETIME2,
    number_of_questions INT,
    number_of_collectors INT,
    number_of_responses INT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);',
        Description = N'All surveys at endpoint',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_SURVEYS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_surveyhero001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_SURVEYS', N'CREATE TABLE [int_surveyhero001].[DL_SURVEYS] (
    survey_id BIGINT,
    title NVARCHAR(500),
    internal_name NVARCHAR(500),
    created_on DATETIME2,
    number_of_questions INT,
    number_of_collectors INT,
    number_of_responses INT,
    LOADTS_UTC DATETIME2 DEFAULT SYSUTCDATETIME(),
    [INT_FETCH_DATE] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'All surveys at endpoint', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- =============================================================================
-- GROWYZE001 - 10 DL Tables
-- =============================================================================

-- Widen ParameterValue from nvarchar(4000) to nvarchar(max) to match DEV.
-- DL_DISHES (4592 chars) and DL_INVOICES (4935 chars) exceed the 4000 limit.
-- This ALTER is safe to re-run — widening a column is a metadata-only operation.
IF COL_LENGTH('core.int_growyze001.GlobalParameters', 'ParameterValue') IS NOT NULL
BEGIN
    DECLARE @maxlen INT;
    SELECT @maxlen = CHARACTER_MAXIMUM_LENGTH
    FROM core.INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'int_growyze001'
      AND TABLE_NAME = 'GlobalParameters'
      AND COLUMN_NAME = 'ParameterValue';

    IF @maxlen IS NOT NULL AND @maxlen <> -1
        ALTER TABLE core.[int_growyze001].[GlobalParameters]
            ALTER COLUMN [ParameterValue] NVARCHAR(MAX) NULL;
END
GO

-- Table: DL_DELIVERYNOTES
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DELIVERYNOTES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES](
	[id] [nvarchar](max) NULL,
	[deliveryNoteNumber] [nvarchar](max) NULL,
	[po] [nvarchar](max) NULL,
	[deliveryDate] [nvarchar](max) NULL,
	[dateOfScanning] [nvarchar](max) NULL,
	[completedDate] [nvarchar](max) NULL,
	[approvedDate] [nvarchar](max) NULL,
	[inQueryDate] [nvarchar](max) NULL,
	[rejectedDate] [nvarchar](max) NULL,
	[supplier_id] [nvarchar](max) NULL,
	[supplier_name] [nvarchar](max) NULL,
	[supplier_contactName] [nvarchar](max) NULL,
	[supplier_email] [nvarchar](max) NULL,
	[supplier_emails] [nvarchar](max) NULL,
	[extractedFile] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[globalDiscrepancies] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[message] [nvarchar](max) NULL,
	[messageQueryToSupplier] [nvarchar](max) NULL,
	[hasReceivedQtyDiscrepancies] [nvarchar](max) NULL,
	[hasDNQtyDiscrepancies] [nvarchar](max) NULL,
	[hasReceivedOrderQtyDiscrepancies] [nvarchar](max) NULL,
	[hasNoOrderedProducts] [nvarchar](max) NULL,
	[hasNoDeliveredProducts] [nvarchar](max) NULL,
	[isCreatedManuallyWithoutOrder] [nvarchar](max) NULL,
	[commentFromOrder] [nvarchar](max) NULL,
	[isInvoiced] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[products_name] [nvarchar](max) NULL,
	[products_barcode] [nvarchar](max) NULL,
	[products_code] [nvarchar](max) NULL,
	[products_size] [nvarchar](max) NULL,
	[products_measure] [nvarchar](max) NULL,
	[products_category] [nvarchar](max) NULL,
	[products_subCategory] [nvarchar](max) NULL,
	[products_unit] [nvarchar](max) NULL,
	[products_orderQty] [nvarchar](max) NULL,
	[products_orderQtyInCase] [nvarchar](max) NULL,
	[products_orderCaseSize] [nvarchar](max) NULL,
	[products_dnQty] [nvarchar](max) NULL,
	[products_receivedQty] [nvarchar](max) NULL,
	[products_receivedQtyInCase] [nvarchar](max) NULL,
	[products_price] [nvarchar](max) NULL,
	[products_comment] [nvarchar](max) NULL,
	[products_isConfirmed] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaDNQty] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaReceivedQty] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaReceivedOrderedQty] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[products_productDiscrepancies] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_DELIVERYNOTES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DELIVERYNOTES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DELIVERYNOTES', N'CREATE TABLE [int_growyze001].[DL_DELIVERYNOTES](
	[id] [nvarchar](max) NULL,
	[deliveryNoteNumber] [nvarchar](max) NULL,
	[po] [nvarchar](max) NULL,
	[deliveryDate] [nvarchar](max) NULL,
	[dateOfScanning] [nvarchar](max) NULL,
	[completedDate] [nvarchar](max) NULL,
	[approvedDate] [nvarchar](max) NULL,
	[inQueryDate] [nvarchar](max) NULL,
	[rejectedDate] [nvarchar](max) NULL,
	[supplier_id] [nvarchar](max) NULL,
	[supplier_name] [nvarchar](max) NULL,
	[supplier_contactName] [nvarchar](max) NULL,
	[supplier_email] [nvarchar](max) NULL,
	[supplier_emails] [nvarchar](max) NULL,
	[extractedFile] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[globalDiscrepancies] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[message] [nvarchar](max) NULL,
	[messageQueryToSupplier] [nvarchar](max) NULL,
	[hasReceivedQtyDiscrepancies] [nvarchar](max) NULL,
	[hasDNQtyDiscrepancies] [nvarchar](max) NULL,
	[hasReceivedOrderQtyDiscrepancies] [nvarchar](max) NULL,
	[hasNoOrderedProducts] [nvarchar](max) NULL,
	[hasNoDeliveredProducts] [nvarchar](max) NULL,
	[isCreatedManuallyWithoutOrder] [nvarchar](max) NULL,
	[commentFromOrder] [nvarchar](max) NULL,
	[isInvoiced] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[products_name] [nvarchar](max) NULL,
	[products_barcode] [nvarchar](max) NULL,
	[products_code] [nvarchar](max) NULL,
	[products_size] [nvarchar](max) NULL,
	[products_measure] [nvarchar](max) NULL,
	[products_category] [nvarchar](max) NULL,
	[products_subCategory] [nvarchar](max) NULL,
	[products_unit] [nvarchar](max) NULL,
	[products_orderQty] [nvarchar](max) NULL,
	[products_orderQtyInCase] [nvarchar](max) NULL,
	[products_orderCaseSize] [nvarchar](max) NULL,
	[products_dnQty] [nvarchar](max) NULL,
	[products_receivedQty] [nvarchar](max) NULL,
	[products_receivedQtyInCase] [nvarchar](max) NULL,
	[products_price] [nvarchar](max) NULL,
	[products_comment] [nvarchar](max) NULL,
	[products_isConfirmed] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaDNQty] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaReceivedQty] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaReceivedOrderedQty] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[products_productDiscrepancies] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DELIVERYNOTES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_DISHES
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_DISHES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_DISHES](
	[id] [nvarchar](max) NULL,
	[mainDishId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[posId] [nvarchar](max) NULL,
	[barcode] [nvarchar](max) NULL,
	[method] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[category] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[totalCostPercent] [nvarchar](max) NULL,
	[totalCostPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profit] [nvarchar](max) NULL,
	[profitPercent] [nvarchar](max) NULL,
	[salePrice] [nvarchar](max) NULL,
	[targetMarginPercent] [nvarchar](max) NULL,
	[taxPercent] [nvarchar](max) NULL,
	[suggestedSalePrice] [nvarchar](max) NULL,
	[suggestedSalePriceWithTax] [nvarchar](max) NULL,
	[salePriceWithTax] [nvarchar](max) NULL,
	[calcSalePriceWithTax] [nvarchar](max) NULL,
	[profitBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profitPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[weight] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[featuredFile] [nvarchar](max) NULL,
	[folder] [nvarchar](max) NULL,
	[createdDate] [nvarchar](max) NULL,
	[updatedDate] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[waste_cost] [nvarchar](max) NULL,
	[waste_percent] [nvarchar](max) NULL,
	[hasDeletedIngredients] [nvarchar](max) NULL,
	[useSalesPriceFromLatestSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[sections_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_id] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierId] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierName] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_barcode] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_unit] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_category] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_subCategory] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_size] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_price] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_isDeleted] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_ingredients] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQtyInProductMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_cost] [nvarchar](max) NULL,
	[sections_elements_recipe] [nvarchar](max) NULL,
	[sections_elements_otherIngredient] [nvarchar](max) NULL,
	[sections_elements_type] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_allergens] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_mayContainAllergens] [nvarchar](max) NULL,
	[waste] [nvarchar](max) NULL,
	[sections_elements_ingredient] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_id] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_name] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_posId] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_category] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_totalCost] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_yield_size] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_yield_measure] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_portion_cost] [nvarchar](max) NULL,
	[sections_elements_recipe_usedQty] [nvarchar](max) NULL,
	[sections_elements_recipe_measure] [nvarchar](max) NULL,
	[sections_elements_recipe_wasteQty] [nvarchar](max) NULL,
	[sections_elements_recipe_wasteMeasure] [nvarchar](max) NULL,
	[sections_elements_recipe_pureQty] [nvarchar](max) NULL,
	[sections_elements_recipe_pureMeasure] [nvarchar](max) NULL,
	[sections_elements_recipe_cost] [nvarchar](max) NULL,
	[sections_elements_recipe_inconsistentCost] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_name] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_cost] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_measure] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_DISHES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_DISHES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_DISHES', N'CREATE TABLE [int_growyze001].[DL_DISHES](
	[id] [nvarchar](max) NULL,
	[mainDishId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[posId] [nvarchar](max) NULL,
	[barcode] [nvarchar](max) NULL,
	[method] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[category] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[totalCostPercent] [nvarchar](max) NULL,
	[totalCostPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profit] [nvarchar](max) NULL,
	[profitPercent] [nvarchar](max) NULL,
	[salePrice] [nvarchar](max) NULL,
	[targetMarginPercent] [nvarchar](max) NULL,
	[taxPercent] [nvarchar](max) NULL,
	[suggestedSalePrice] [nvarchar](max) NULL,
	[suggestedSalePriceWithTax] [nvarchar](max) NULL,
	[salePriceWithTax] [nvarchar](max) NULL,
	[calcSalePriceWithTax] [nvarchar](max) NULL,
	[profitBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profitPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[weight] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[featuredFile] [nvarchar](max) NULL,
	[folder] [nvarchar](max) NULL,
	[createdDate] [nvarchar](max) NULL,
	[updatedDate] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[waste_cost] [nvarchar](max) NULL,
	[waste_percent] [nvarchar](max) NULL,
	[hasDeletedIngredients] [nvarchar](max) NULL,
	[useSalesPriceFromLatestSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[sections_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_id] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierId] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierName] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_barcode] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_unit] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_category] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_subCategory] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_size] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_price] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_isDeleted] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_ingredients] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQtyInProductMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_cost] [nvarchar](max) NULL,
	[sections_elements_recipe] [nvarchar](max) NULL,
	[sections_elements_otherIngredient] [nvarchar](max) NULL,
	[sections_elements_type] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_allergens] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_mayContainAllergens] [nvarchar](max) NULL,
	[waste] [nvarchar](max) NULL,
	[sections_elements_ingredient] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_id] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_name] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_posId] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_category] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_totalCost] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_yield_size] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_yield_measure] [nvarchar](max) NULL,
	[sections_elements_recipe_recipe_portion_cost] [nvarchar](max) NULL,
	[sections_elements_recipe_usedQty] [nvarchar](max) NULL,
	[sections_elements_recipe_measure] [nvarchar](max) NULL,
	[sections_elements_recipe_wasteQty] [nvarchar](max) NULL,
	[sections_elements_recipe_wasteMeasure] [nvarchar](max) NULL,
	[sections_elements_recipe_pureQty] [nvarchar](max) NULL,
	[sections_elements_recipe_pureMeasure] [nvarchar](max) NULL,
	[sections_elements_recipe_cost] [nvarchar](max) NULL,
	[sections_elements_recipe_inconsistentCost] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_name] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_cost] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_measure] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_DISHES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_INVOICES
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_INVOICES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_INVOICES](
	[id] [nvarchar](max) NULL,
	[invoiceNumber] [nvarchar](max) NULL,
	[deliveryNoteNumber] [nvarchar](max) NULL,
	[deliveryNoteId] [nvarchar](max) NULL,
	[po] [nvarchar](max) NULL,
	[deliveryNotes] [nvarchar](max) NULL,
	[dateOfIssue] [nvarchar](max) NULL,
	[dateOfScanning] [nvarchar](max) NULL,
	[dueDate] [nvarchar](max) NULL,
	[approvedDate] [nvarchar](max) NULL,
	[inQueryDate] [nvarchar](max) NULL,
	[rejectedDate] [nvarchar](max) NULL,
	[supplier_id] [nvarchar](max) NULL,
	[supplier_name] [nvarchar](max) NULL,
	[supplier_contactName] [nvarchar](max) NULL,
	[supplier_email] [nvarchar](max) NULL,
	[supplier_emails] [nvarchar](max) NULL,
	[supplier_currency] [nvarchar](max) NULL,
	[extractedFile] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[xeroInvoice] [nvarchar](max) NULL,
	[sageInvoice] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[grossTotalCost] [nvarchar](max) NULL,
	[totalVat] [nvarchar](max) NULL,
	[expectedTotalCost] [nvarchar](max) NULL,
	[invoicedTotalCost] [nvarchar](max) NULL,
	[deltaTotalCost] [nvarchar](max) NULL,
	[deltaInvoicedExpectedTotalCost] [nvarchar](max) NULL,
	[globalDiscrepancies] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[message] [nvarchar](max) NULL,
	[messageQueryToSupplier] [nvarchar](max) NULL,
	[expectedPo] [nvarchar](max) NULL,
	[expectedDeliveryNoteNumber] [nvarchar](max) NULL,
	[hasQtyDiscrepancies] [nvarchar](max) NULL,
	[hasProductPriceDiscrepancies] [nvarchar](max) NULL,
	[hasNoReceivedProducts] [nvarchar](max) NULL,
	[hasNoInvoicedProducts] [nvarchar](max) NULL,
	[hasNoOrderedProducts] [nvarchar](max) NULL,
	[hasTotalCostDiscrepancy] [nvarchar](max) NULL,
	[commentFromOrders] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[products_description] [nvarchar](max) NULL,
	[products_barcode] [nvarchar](max) NULL,
	[products_code] [nvarchar](max) NULL,
	[products_size] [nvarchar](max) NULL,
	[products_measure] [nvarchar](max) NULL,
	[products_category] [nvarchar](max) NULL,
	[products_subCategory] [nvarchar](max) NULL,
	[products_unit] [nvarchar](max) NULL,
	[products_orderCaseSize] [nvarchar](max) NULL,
	[products_dnReceivedQty] [nvarchar](max) NULL,
	[products_receivedQtyInCase] [nvarchar](max) NULL,
	[products_invoiceQty] [nvarchar](max) NULL,
	[products_invoiceQtyInCase] [nvarchar](max) NULL,
	[products_invoicePrice] [nvarchar](max) NULL,
	[products_orderPrice] [nvarchar](max) NULL,
	[products_expectedTotalCost] [nvarchar](max) NULL,
	[products_invoicedTotalCost] [nvarchar](max) NULL,
	[products_comment] [nvarchar](max) NULL,
	[products_isConfirmed] [nvarchar](max) NULL,
	[products_isAcceptedPrice] [nvarchar](max) NULL,
	[products_isDuplicated] [nvarchar](max) NULL,
	[products_productDiscrepancies] [nvarchar](max) NULL,
	[products_xero] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_id] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_name] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_email] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_invoiceNumber] [nvarchar](max) NULL,
	[sageInvoice_invoiceDate] [nvarchar](max) NULL,
	[sageInvoice_dueDate] [nvarchar](max) NULL,
	[sageInvoice_netCost] [nvarchar](max) NULL,
	[sageInvoice_grossTotalCost] [nvarchar](max) NULL,
	[sageInvoice_totalVat] [nvarchar](max) NULL,
	[deliveryNotes_deliveryNoteId] [nvarchar](max) NULL,
	[deliveryNotes_deliveryNoteNumber] [nvarchar](max) NULL,
	[deliveryNotes_po] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaQty] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaPrice] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaInvoicedExpectedTotalCost] [nvarchar](max) NULL,
	[products_productDiscrepancies_notOrdered] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_name] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_code] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_type_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_type_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_name] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_percentage] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_lineItems_description] [nvarchar](max) NULL,
	[sageInvoice_lineItems_netCost] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_name] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_percentage] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_displayedAs] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_INVOICES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_INVOICES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_INVOICES', N'CREATE TABLE [int_growyze001].[DL_INVOICES](
	[id] [nvarchar](max) NULL,
	[invoiceNumber] [nvarchar](max) NULL,
	[deliveryNoteNumber] [nvarchar](max) NULL,
	[deliveryNoteId] [nvarchar](max) NULL,
	[po] [nvarchar](max) NULL,
	[deliveryNotes] [nvarchar](max) NULL,
	[dateOfIssue] [nvarchar](max) NULL,
	[dateOfScanning] [nvarchar](max) NULL,
	[dueDate] [nvarchar](max) NULL,
	[approvedDate] [nvarchar](max) NULL,
	[inQueryDate] [nvarchar](max) NULL,
	[rejectedDate] [nvarchar](max) NULL,
	[supplier_id] [nvarchar](max) NULL,
	[supplier_name] [nvarchar](max) NULL,
	[supplier_contactName] [nvarchar](max) NULL,
	[supplier_email] [nvarchar](max) NULL,
	[supplier_emails] [nvarchar](max) NULL,
	[supplier_currency] [nvarchar](max) NULL,
	[extractedFile] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[xeroInvoice] [nvarchar](max) NULL,
	[sageInvoice] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[grossTotalCost] [nvarchar](max) NULL,
	[totalVat] [nvarchar](max) NULL,
	[expectedTotalCost] [nvarchar](max) NULL,
	[invoicedTotalCost] [nvarchar](max) NULL,
	[deltaTotalCost] [nvarchar](max) NULL,
	[deltaInvoicedExpectedTotalCost] [nvarchar](max) NULL,
	[globalDiscrepancies] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[message] [nvarchar](max) NULL,
	[messageQueryToSupplier] [nvarchar](max) NULL,
	[expectedPo] [nvarchar](max) NULL,
	[expectedDeliveryNoteNumber] [nvarchar](max) NULL,
	[hasQtyDiscrepancies] [nvarchar](max) NULL,
	[hasProductPriceDiscrepancies] [nvarchar](max) NULL,
	[hasNoReceivedProducts] [nvarchar](max) NULL,
	[hasNoInvoicedProducts] [nvarchar](max) NULL,
	[hasNoOrderedProducts] [nvarchar](max) NULL,
	[hasTotalCostDiscrepancy] [nvarchar](max) NULL,
	[commentFromOrders] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[products_description] [nvarchar](max) NULL,
	[products_barcode] [nvarchar](max) NULL,
	[products_code] [nvarchar](max) NULL,
	[products_size] [nvarchar](max) NULL,
	[products_measure] [nvarchar](max) NULL,
	[products_category] [nvarchar](max) NULL,
	[products_subCategory] [nvarchar](max) NULL,
	[products_unit] [nvarchar](max) NULL,
	[products_orderCaseSize] [nvarchar](max) NULL,
	[products_dnReceivedQty] [nvarchar](max) NULL,
	[products_receivedQtyInCase] [nvarchar](max) NULL,
	[products_invoiceQty] [nvarchar](max) NULL,
	[products_invoiceQtyInCase] [nvarchar](max) NULL,
	[products_invoicePrice] [nvarchar](max) NULL,
	[products_orderPrice] [nvarchar](max) NULL,
	[products_expectedTotalCost] [nvarchar](max) NULL,
	[products_invoicedTotalCost] [nvarchar](max) NULL,
	[products_comment] [nvarchar](max) NULL,
	[products_isConfirmed] [nvarchar](max) NULL,
	[products_isAcceptedPrice] [nvarchar](max) NULL,
	[products_isDuplicated] [nvarchar](max) NULL,
	[products_productDiscrepancies] [nvarchar](max) NULL,
	[products_xero] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_id] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_name] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_email] [nvarchar](max) NULL,
	[sageInvoice_sageSupplier_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_invoiceNumber] [nvarchar](max) NULL,
	[sageInvoice_invoiceDate] [nvarchar](max) NULL,
	[sageInvoice_dueDate] [nvarchar](max) NULL,
	[sageInvoice_netCost] [nvarchar](max) NULL,
	[sageInvoice_grossTotalCost] [nvarchar](max) NULL,
	[sageInvoice_totalVat] [nvarchar](max) NULL,
	[deliveryNotes_deliveryNoteId] [nvarchar](max) NULL,
	[deliveryNotes_deliveryNoteNumber] [nvarchar](max) NULL,
	[deliveryNotes_po] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaQty] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaPrice] [nvarchar](max) NULL,
	[products_productDiscrepancies_deltaInvoicedExpectedTotalCost] [nvarchar](max) NULL,
	[products_productDiscrepancies_notOrdered] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_name] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_code] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_type_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_type_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_name] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_percentage] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_taxRate_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_lineItems_account_displayedAs] [nvarchar](max) NULL,
	[sageInvoice_lineItems_description] [nvarchar](max) NULL,
	[sageInvoice_lineItems_netCost] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_id] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_name] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_percentage] [nvarchar](max) NULL,
	[sageInvoice_lineItems_taxRate_displayedAs] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_INVOICES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ORDERS
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORDERS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORDERS](
	[id] [nvarchar](max) NULL,
	[po] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[supplier_id] [nvarchar](max) NULL,
	[supplier_accountNumber] [nvarchar](max) NULL,
	[supplier_name] [nvarchar](max) NULL,
	[supplier_contactName] [nvarchar](max) NULL,
	[supplier_email] [nvarchar](max) NULL,
	[supplier_currency] [nvarchar](max) NULL,
	[supplier_internalSupplier] [nvarchar](max) NULL,
	[isSentToSupplier] [nvarchar](max) NULL,
	[skippedSendingToSupplier] [nvarchar](max) NULL,
	[deliveryAddress_addressLine1] [nvarchar](max) NULL,
	[deliveryAddress_addressLine2] [nvarchar](max) NULL,
	[deliveryAddress_city] [nvarchar](max) NULL,
	[deliveryAddress_postCode] [nvarchar](max) NULL,
	[deliveryAddress_country] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[comments] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[placedDate] [nvarchar](max) NULL,
	[createdDate] [nvarchar](max) NULL,
	[completedDate] [nvarchar](max) NULL,
	[canceledDate] [nvarchar](max) NULL,
	[expectedDeliveryDate] [nvarchar](max) NULL,
	[approvedBy] [nvarchar](max) NULL,
	[extractedFile] [nvarchar](max) NULL,
	[isDelivered] [nvarchar](max) NULL,
	[approvers] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[items_productId] [nvarchar](max) NULL,
	[items_name] [nvarchar](max) NULL,
	[items_barcode] [nvarchar](max) NULL,
	[items_code] [nvarchar](max) NULL,
	[items_category] [nvarchar](max) NULL,
	[items_subCategory] [nvarchar](max) NULL,
	[items_unit] [nvarchar](max) NULL,
	[items_size] [nvarchar](max) NULL,
	[items_measure] [nvarchar](max) NULL,
	[items_price] [nvarchar](max) NULL,
	[items_estimatedCost] [nvarchar](max) NULL,
	[items_quantity] [nvarchar](max) NULL,
	[items_orderInCase] [nvarchar](max) NULL,
	[items_productCase] [nvarchar](max) NULL,
	[supplier_emails] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[items_productCase_code] [nvarchar](max) NULL,
	[items_productCase_size] [nvarchar](max) NULL,
	[items_productCase_price] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_ORDERS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORDERS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORDERS', N'CREATE TABLE [int_growyze001].[DL_ORDERS](
	[id] [nvarchar](max) NULL,
	[po] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[supplier_id] [nvarchar](max) NULL,
	[supplier_accountNumber] [nvarchar](max) NULL,
	[supplier_name] [nvarchar](max) NULL,
	[supplier_contactName] [nvarchar](max) NULL,
	[supplier_email] [nvarchar](max) NULL,
	[supplier_currency] [nvarchar](max) NULL,
	[supplier_internalSupplier] [nvarchar](max) NULL,
	[isSentToSupplier] [nvarchar](max) NULL,
	[skippedSendingToSupplier] [nvarchar](max) NULL,
	[deliveryAddress_addressLine1] [nvarchar](max) NULL,
	[deliveryAddress_addressLine2] [nvarchar](max) NULL,
	[deliveryAddress_city] [nvarchar](max) NULL,
	[deliveryAddress_postCode] [nvarchar](max) NULL,
	[deliveryAddress_country] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[comments] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[placedDate] [nvarchar](max) NULL,
	[createdDate] [nvarchar](max) NULL,
	[completedDate] [nvarchar](max) NULL,
	[canceledDate] [nvarchar](max) NULL,
	[expectedDeliveryDate] [nvarchar](max) NULL,
	[approvedBy] [nvarchar](max) NULL,
	[extractedFile] [nvarchar](max) NULL,
	[isDelivered] [nvarchar](max) NULL,
	[approvers] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[items_productId] [nvarchar](max) NULL,
	[items_name] [nvarchar](max) NULL,
	[items_barcode] [nvarchar](max) NULL,
	[items_code] [nvarchar](max) NULL,
	[items_category] [nvarchar](max) NULL,
	[items_subCategory] [nvarchar](max) NULL,
	[items_unit] [nvarchar](max) NULL,
	[items_size] [nvarchar](max) NULL,
	[items_measure] [nvarchar](max) NULL,
	[items_price] [nvarchar](max) NULL,
	[items_estimatedCost] [nvarchar](max) NULL,
	[items_quantity] [nvarchar](max) NULL,
	[items_orderInCase] [nvarchar](max) NULL,
	[items_productCase] [nvarchar](max) NULL,
	[supplier_emails] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[items_productCase_code] [nvarchar](max) NULL,
	[items_productCase_size] [nvarchar](max) NULL,
	[items_productCase_price] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORDERS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_ORGANIZATIONS
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_ORGANIZATIONS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_ORGANIZATIONS](
	[id] [nvarchar](max) NULL,
	[logo] [nvarchar](max) NULL,
	[companyName] [nvarchar](max) NULL,
	[address_addressLine1] [nvarchar](max) NULL,
	[address_addressLine2] [nvarchar](max) NULL,
	[address_city] [nvarchar](max) NULL,
	[address_postCode] [nvarchar](max) NULL,
	[address_country] [nvarchar](max) NULL,
	[address_zoneId] [nvarchar](max) NULL,
	[deliveryAddress] [nvarchar](max) NULL,
	[businessType] [nvarchar](max) NULL,
	[contactDetails_firstName] [nvarchar](max) NULL,
	[contactDetails_lastName] [nvarchar](max) NULL,
	[contactDetails_email] [nvarchar](max) NULL,
	[contactDetails_telephone] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[mainOrgId] [nvarchar](max) NULL,
	[subOrgIds] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_ORGANIZATIONS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_ORGANIZATIONS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_ORGANIZATIONS', N'CREATE TABLE [int_growyze001].[DL_ORGANIZATIONS](
	[id] [nvarchar](max) NULL,
	[logo] [nvarchar](max) NULL,
	[companyName] [nvarchar](max) NULL,
	[address_addressLine1] [nvarchar](max) NULL,
	[address_addressLine2] [nvarchar](max) NULL,
	[address_city] [nvarchar](max) NULL,
	[address_postCode] [nvarchar](max) NULL,
	[address_country] [nvarchar](max) NULL,
	[address_zoneId] [nvarchar](max) NULL,
	[deliveryAddress] [nvarchar](max) NULL,
	[businessType] [nvarchar](max) NULL,
	[contactDetails_firstName] [nvarchar](max) NULL,
	[contactDetails_lastName] [nvarchar](max) NULL,
	[contactDetails_email] [nvarchar](max) NULL,
	[contactDetails_telephone] [nvarchar](max) NULL,
	[type] [nvarchar](max) NULL,
	[mainOrgId] [nvarchar](max) NULL,
	[subOrgIds] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_ORGANIZATIONS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_PRODUCTS
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_PRODUCTS' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_PRODUCTS](
	[id] [nvarchar](max) NULL,
	[groupId] [nvarchar](max) NULL,
	[mainProductId] [nvarchar](max) NULL,
	[supplierId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[barcode] [nvarchar](max) NULL,
	[autoGenBarcode] [nvarchar](max) NULL,
	[posId] [nvarchar](max) NULL,
	[code] [nvarchar](max) NULL,
	[category] [nvarchar](max) NULL,
	[subCategory] [nvarchar](max) NULL,
	[unit] [nvarchar](max) NULL,
	[measure] [nvarchar](max) NULL,
	[size] [nvarchar](max) NULL,
	[price] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[description] [nvarchar](max) NULL,
	[minQtyInStock] [nvarchar](max) NULL,
	[productCase_code] [nvarchar](max) NULL,
	[productCase_size] [nvarchar](max) NULL,
	[productCase_price] [nvarchar](max) NULL,
	[favourite] [nvarchar](max) NULL,
	[mostOrdered] [nvarchar](max) NULL,
	[preferred] [nvarchar](max) NULL,
	[allergensValidation] [nvarchar](max) NULL,
	[ingredients] [nvarchar](max) NULL,
	[orderedIn_single] [nvarchar](max) NULL,
	[orderedIn_pack] [nvarchar](max) NULL,
	[orderedIn_both] [nvarchar](max) NULL,
	[accounting] [nvarchar](max) NULL,
	[supplierName] [nvarchar](max) NULL,
	[countOfProductsInGroup] [nvarchar](max) NULL,
	[stockOnHand] [nvarchar](max) NULL,
	[stockTakeDate] [nvarchar](max) NULL,
	[avgWeeklyConsumption] [nvarchar](max) NULL,
	[awaitingDelivery] [nvarchar](max) NULL,
	[lastOrdered] [nvarchar](max) NULL,
	[lastOrderedLocation] [nvarchar](max) NULL,
	[lastCountedQty] [nvarchar](max) NULL,
	[lastCounted] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[productCase] [nvarchar](max) NULL,
	[barcodes] [nvarchar](max) NULL,
	[allergens] [nvarchar](max) NULL,
	[mayContainAllergens] [nvarchar](max) NULL,
	[orderedIn] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_PRODUCTS',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_PRODUCTS' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_PRODUCTS', N'CREATE TABLE [int_growyze001].[DL_PRODUCTS](
	[id] [nvarchar](max) NULL,
	[groupId] [nvarchar](max) NULL,
	[mainProductId] [nvarchar](max) NULL,
	[supplierId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[barcode] [nvarchar](max) NULL,
	[autoGenBarcode] [nvarchar](max) NULL,
	[posId] [nvarchar](max) NULL,
	[code] [nvarchar](max) NULL,
	[category] [nvarchar](max) NULL,
	[subCategory] [nvarchar](max) NULL,
	[unit] [nvarchar](max) NULL,
	[measure] [nvarchar](max) NULL,
	[size] [nvarchar](max) NULL,
	[price] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[description] [nvarchar](max) NULL,
	[minQtyInStock] [nvarchar](max) NULL,
	[productCase_code] [nvarchar](max) NULL,
	[productCase_size] [nvarchar](max) NULL,
	[productCase_price] [nvarchar](max) NULL,
	[favourite] [nvarchar](max) NULL,
	[mostOrdered] [nvarchar](max) NULL,
	[preferred] [nvarchar](max) NULL,
	[allergensValidation] [nvarchar](max) NULL,
	[ingredients] [nvarchar](max) NULL,
	[orderedIn_single] [nvarchar](max) NULL,
	[orderedIn_pack] [nvarchar](max) NULL,
	[orderedIn_both] [nvarchar](max) NULL,
	[accounting] [nvarchar](max) NULL,
	[supplierName] [nvarchar](max) NULL,
	[countOfProductsInGroup] [nvarchar](max) NULL,
	[stockOnHand] [nvarchar](max) NULL,
	[stockTakeDate] [nvarchar](max) NULL,
	[avgWeeklyConsumption] [nvarchar](max) NULL,
	[awaitingDelivery] [nvarchar](max) NULL,
	[lastOrdered] [nvarchar](max) NULL,
	[lastOrderedLocation] [nvarchar](max) NULL,
	[lastCountedQty] [nvarchar](max) NULL,
	[lastCounted] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[productCase] [nvarchar](max) NULL,
	[barcodes] [nvarchar](max) NULL,
	[allergens] [nvarchar](max) NULL,
	[mayContainAllergens] [nvarchar](max) NULL,
	[orderedIn] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_PRODUCTS', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_RECIPES
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_RECIPES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_RECIPES](
	[id] [nvarchar](max) NULL,
	[mainRecipeId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[description] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[category] [nvarchar](max) NULL,
	[posId] [nvarchar](max) NULL,
	[barcode] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[totalCostPercent] [nvarchar](max) NULL,
	[totalCostPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profit] [nvarchar](max) NULL,
	[profitPercent] [nvarchar](max) NULL,
	[salePrice] [nvarchar](max) NULL,
	[targetMarginPercent] [nvarchar](max) NULL,
	[taxPercent] [nvarchar](max) NULL,
	[suggestedSalePrice] [nvarchar](max) NULL,
	[suggestedSalePriceWithTax] [nvarchar](max) NULL,
	[salePriceWithTax] [nvarchar](max) NULL,
	[calcSalePriceWithTax] [nvarchar](max) NULL,
	[profitBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profitPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[yield] [nvarchar](max) NULL,
	[otherIngredients] [nvarchar](max) NULL,
	[otherIngredientsCost] [nvarchar](max) NULL,
	[createdDate] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[featuredFile] [nvarchar](max) NULL,
	[portionCount] [nvarchar](max) NULL,
	[portion] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[folder] [nvarchar](max) NULL,
	[waste_cost] [nvarchar](max) NULL,
	[waste_percent] [nvarchar](max) NULL,
	[hasDeletedIngredients] [nvarchar](max) NULL,
	[useSalesPriceFromLatestSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[sections_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_id] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierId] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierName] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_barcode] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_unit] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_category] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_subCategory] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_size] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_price] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_isDeleted] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_ingredients] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQtyInProductMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_cost] [nvarchar](max) NULL,
	[sections_elements_recipe] [nvarchar](max) NULL,
	[sections_elements_otherIngredient] [nvarchar](max) NULL,
	[sections_elements_type] [nvarchar](max) NULL,
	[yield_size] [nvarchar](max) NULL,
	[yield_measure] [nvarchar](max) NULL,
	[portion_size] [nvarchar](max) NULL,
	[portion_measure] [nvarchar](max) NULL,
	[portion_cost] [nvarchar](max) NULL,
	[dishes_id] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_allergens] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_mayContainAllergens] [nvarchar](max) NULL,
	[sections_elements_ingredient] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_name] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_cost] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_measure] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_RECIPES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_RECIPES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_RECIPES', N'CREATE TABLE [int_growyze001].[DL_RECIPES](
	[id] [nvarchar](max) NULL,
	[mainRecipeId] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[description] [nvarchar](max) NULL,
	[notes] [nvarchar](max) NULL,
	[category] [nvarchar](max) NULL,
	[posId] [nvarchar](max) NULL,
	[barcode] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[totalCostPercent] [nvarchar](max) NULL,
	[totalCostPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profit] [nvarchar](max) NULL,
	[profitPercent] [nvarchar](max) NULL,
	[salePrice] [nvarchar](max) NULL,
	[targetMarginPercent] [nvarchar](max) NULL,
	[taxPercent] [nvarchar](max) NULL,
	[suggestedSalePrice] [nvarchar](max) NULL,
	[suggestedSalePriceWithTax] [nvarchar](max) NULL,
	[salePriceWithTax] [nvarchar](max) NULL,
	[calcSalePriceWithTax] [nvarchar](max) NULL,
	[profitBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[profitPercentBasedOnSalePriceWithTax] [nvarchar](max) NULL,
	[yield] [nvarchar](max) NULL,
	[otherIngredients] [nvarchar](max) NULL,
	[otherIngredientsCost] [nvarchar](max) NULL,
	[createdDate] [nvarchar](max) NULL,
	[files] [nvarchar](max) NULL,
	[featuredFile] [nvarchar](max) NULL,
	[portionCount] [nvarchar](max) NULL,
	[portion] [nvarchar](max) NULL,
	[status] [nvarchar](max) NULL,
	[folder] [nvarchar](max) NULL,
	[waste_cost] [nvarchar](max) NULL,
	[waste_percent] [nvarchar](max) NULL,
	[hasDeletedIngredients] [nvarchar](max) NULL,
	[useSalesPriceFromLatestSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[sections_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_id] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierId] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_supplierName] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_name] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_barcode] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_unit] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_category] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_subCategory] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_size] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_price] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_isDeleted] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_ingredients] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_measure] [nvarchar](max) NULL,
	[sections_elements_ingredient_usedQtyInProductMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_wasteMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureQty] [nvarchar](max) NULL,
	[sections_elements_ingredient_pureMeasure] [nvarchar](max) NULL,
	[sections_elements_ingredient_cost] [nvarchar](max) NULL,
	[sections_elements_recipe] [nvarchar](max) NULL,
	[sections_elements_otherIngredient] [nvarchar](max) NULL,
	[sections_elements_type] [nvarchar](max) NULL,
	[yield_size] [nvarchar](max) NULL,
	[yield_measure] [nvarchar](max) NULL,
	[portion_size] [nvarchar](max) NULL,
	[portion_measure] [nvarchar](max) NULL,
	[portion_cost] [nvarchar](max) NULL,
	[dishes_id] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_allergens] [nvarchar](max) NULL,
	[sections_elements_ingredient_product_mayContainAllergens] [nvarchar](max) NULL,
	[sections_elements_ingredient] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_name] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_cost] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_usedQty] [nvarchar](max) NULL,
	[sections_elements_otherIngredient_measure] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_RECIPES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_SALES
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_SALES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_SALES](
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[from] [nvarchar](max) NULL,
	[to] [nvarchar](max) NULL,
	[totalSales] [nvarchar](max) NULL,
	[items] [nvarchar](max) NULL,
	[nonMatchingPosIdsCount] [nvarchar](max) NULL,
	[autoGeneratedPosIdsCount] [nvarchar](max) NULL,
	[isFromSquare] [nvarchar](max) NULL,
	[isLive] [nvarchar](max) NULL,
	[salesOrigin] [nvarchar](max) NULL,
	[createdAt] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[metadata_orderId] [nvarchar](max) NULL,
	[subSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_SALES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_SALES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_SALES', N'CREATE TABLE [int_growyze001].[DL_SALES](
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[from] [nvarchar](max) NULL,
	[to] [nvarchar](max) NULL,
	[totalSales] [nvarchar](max) NULL,
	[items] [nvarchar](max) NULL,
	[nonMatchingPosIdsCount] [nvarchar](max) NULL,
	[autoGeneratedPosIdsCount] [nvarchar](max) NULL,
	[isFromSquare] [nvarchar](max) NULL,
	[isLive] [nvarchar](max) NULL,
	[salesOrigin] [nvarchar](max) NULL,
	[createdAt] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[metadata_orderId] [nvarchar](max) NULL,
	[subSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_SALES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_SALESDETAIL
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_SALESDETAIL' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_SALESDETAIL](
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[from] [nvarchar](max) NULL,
	[to] [nvarchar](max) NULL,
	[totalSales] [nvarchar](max) NULL,
	[nonMatchingPosIdsCount] [nvarchar](max) NULL,
	[autoGeneratedPosIdsCount] [nvarchar](max) NULL,
	[isFromSquare] [nvarchar](max) NULL,
	[isLive] [nvarchar](max) NULL,
	[salesOrigin] [nvarchar](max) NULL,
	[createdAt] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[metadata_orderId] [nvarchar](max) NULL,
	[subSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[items_posId] [nvarchar](max) NULL,
	[items_name] [nvarchar](max) NULL,
	[items_soldQty] [nvarchar](max) NULL,
	[items_totalValue] [nvarchar](max) NULL,
	[items_nonMatchingPosId] [nvarchar](max) NULL,
	[items_autoGeneratedPosId] [nvarchar](max) NULL,
	[items_properties] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_SALESDETAIL',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_SALESDETAIL' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_SALESDETAIL', N'CREATE TABLE [int_growyze001].[DL_SALESDETAIL](
	[id] [nvarchar](max) NULL,
	[name] [nvarchar](max) NULL,
	[from] [nvarchar](max) NULL,
	[to] [nvarchar](max) NULL,
	[totalSales] [nvarchar](max) NULL,
	[nonMatchingPosIdsCount] [nvarchar](max) NULL,
	[autoGeneratedPosIdsCount] [nvarchar](max) NULL,
	[isFromSquare] [nvarchar](max) NULL,
	[isLive] [nvarchar](max) NULL,
	[salesOrigin] [nvarchar](max) NULL,
	[createdAt] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[metadata_orderId] [nvarchar](max) NULL,
	[subSales] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[items_posId] [nvarchar](max) NULL,
	[items_name] [nvarchar](max) NULL,
	[items_soldQty] [nvarchar](max) NULL,
	[items_totalValue] [nvarchar](max) NULL,
	[items_nonMatchingPosId] [nvarchar](max) NULL,
	[items_autoGeneratedPosId] [nvarchar](max) NULL,
	[items_properties] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_SALESDETAIL', 1, SYSTEM_USER, GETDATE(), 1);
END
GO


-- Table: DL_WASTES
IF EXISTS (SELECT 1 FROM core.[int_growyze001].[GlobalParameters] WHERE ParameterKey = N'DL_WASTES' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_growyze001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_growyze001].[DL_WASTES](
	[id] [nvarchar](max) NULL,
	[date] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[products_product_id] [nvarchar](max) NULL,
	[products_product_name] [nvarchar](max) NULL,
	[products_product_barcode] [nvarchar](max) NULL,
	[products_product_category] [nvarchar](max) NULL,
	[products_product_subCategory] [nvarchar](max) NULL,
	[products_product_unit] [nvarchar](max) NULL,
	[products_product_measure] [nvarchar](max) NULL,
	[products_product_size] [nvarchar](max) NULL,
	[products_product_price] [nvarchar](max) NULL,
	[products_totalQty] [nvarchar](max) NULL,
	[products_totalCost] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[products_wastesPerDay_id] [nvarchar](max) NULL,
	[products_wastesPerDay_fullQty] [nvarchar](max) NULL,
	[products_wastesPerDay_partialQty] [nvarchar](max) NULL,
	[products_wastesPerDay_partialQtyInProductMeasure] [nvarchar](max) NULL,
	[products_wastesPerDay_totalQty] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteMeasure] [nvarchar](max) NULL,
	[products_wastesPerDay_totalCost] [nvarchar](max) NULL,
	[products_wastesPerDay_reason] [nvarchar](max) NULL,
	[products_wastesPerDay_timeOfRecord] [nvarchar](max) NULL,
	[products_wastesPerDay_reporter] [nvarchar](max) NULL,
	[products_wastesPerDay_comment] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteRecipeRecordId] [nvarchar](max) NULL,
	[products_wastesPerDay_recipeName] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteDishRecordId] [nvarchar](max) NULL,
	[products_wastesPerDay_dishName] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteOrigin] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);',
        Description = N'DL_WASTES',
        IsActive = 1,
        ModifiedBy = SYSTEM_USER,
        ModifiedDate = GETDATE()
    WHERE ParameterKey = N'DL_WASTES' AND Category = 'STAGE_DDL';
END
ELSE
BEGIN
    INSERT INTO core.[int_growyze001].[GlobalParameters]
    (ParameterKey, ParameterValue, DataType, Category, Description, IsActive, CreatedBy, CreatedDate, Version)
    VALUES (N'DL_WASTES', N'CREATE TABLE [int_growyze001].[DL_WASTES](
	[id] [nvarchar](max) NULL,
	[date] [nvarchar](max) NULL,
	[updatedAt] [nvarchar](max) NULL,
	[totalCost] [nvarchar](max) NULL,
	[organizations] [nvarchar](max) NULL,
	[products_product_id] [nvarchar](max) NULL,
	[products_product_name] [nvarchar](max) NULL,
	[products_product_barcode] [nvarchar](max) NULL,
	[products_product_category] [nvarchar](max) NULL,
	[products_product_subCategory] [nvarchar](max) NULL,
	[products_product_unit] [nvarchar](max) NULL,
	[products_product_measure] [nvarchar](max) NULL,
	[products_product_size] [nvarchar](max) NULL,
	[products_product_price] [nvarchar](max) NULL,
	[products_totalQty] [nvarchar](max) NULL,
	[products_totalCost] [nvarchar](max) NULL,
	[organizationsNames] [nvarchar](max) NULL,
	[products_wastesPerDay_id] [nvarchar](max) NULL,
	[products_wastesPerDay_fullQty] [nvarchar](max) NULL,
	[products_wastesPerDay_partialQty] [nvarchar](max) NULL,
	[products_wastesPerDay_partialQtyInProductMeasure] [nvarchar](max) NULL,
	[products_wastesPerDay_totalQty] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteMeasure] [nvarchar](max) NULL,
	[products_wastesPerDay_totalCost] [nvarchar](max) NULL,
	[products_wastesPerDay_reason] [nvarchar](max) NULL,
	[products_wastesPerDay_timeOfRecord] [nvarchar](max) NULL,
	[products_wastesPerDay_reporter] [nvarchar](max) NULL,
	[products_wastesPerDay_comment] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteRecipeRecordId] [nvarchar](max) NULL,
	[products_wastesPerDay_recipeName] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteDishRecordId] [nvarchar](max) NULL,
	[products_wastesPerDay_dishName] [nvarchar](max) NULL,
	[products_wastesPerDay_wasteOrigin] [nvarchar](max) NULL,
	[INT_FETCH_DATE] [datetime2](7) NULL,
	[LOADTS_UTC] [datetime2](7) NULL
);', 'STRING', 'STAGE_DDL', N'DL_WASTES', 1, SYSTEM_USER, GETDATE(), 1);
END
GO
