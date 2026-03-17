-- API Table DDL Export
-- Schema: int_troap001
-- Generated: 2026-01-12 14:27:52
-- Total Tables: 41

-- Table: DL_Address
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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

-- Table: DL_Menu
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_OrderItem', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_OrderPayment
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_OrderPayment', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_OrderRefundQueue
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_OrderRefundQueue', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_OrderSplitBill
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderSplitBill' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderSplitBill]
(
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderId] NVARCHAR(MAX),
    [DateCreated] NVARCHAR(MAX),
    [DtbeNumberPeople] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_OrderSplitBill', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_OrderSplitBillItem
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_OrderSplitBillItem', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_OrderSplitBillPayment
-- Check if parameter exists and update, otherwise insert
IF EXISTS (SELECT 1 FROM core.[int_troap001].[GlobalParameters] WHERE ParameterKey = N'DL_OrderSplitBillPayment' AND Category = 'STAGE_DDL')
BEGIN
    UPDATE core.[int_troap001].[GlobalParameters]
    SET ParameterValue = N'CREATE TABLE [int_troap001].[DL_OrderSplitBillPayment]
(
    [Id] NVARCHAR(MAX),
    [OrderSplitBillId] NVARCHAR(MAX),
    [OrderPaymentId] NVARCHAR(MAX),
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_OrderSplitBillPayment', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_Price
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_Price', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_Product
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_Product', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ProductBase
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_ProductBase', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ProductCategory
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_ProductCategory', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_Store
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_Store', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_StoreOpeningHours
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_StoreOpeningHours', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_StoreOpeningHoursGroup
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_StoreOpeningHoursGroup', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_StoreOrderType
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_StoreOrderType', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_StoreProductOutOfStock
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_StoreProductOutOfStock', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ZonalMenu
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_ZonalMenu', 1, SYSTEM_USER, GETDATE(), 1);
END
GO

-- Table: DL_ZonalProduct
-- Check if parameter exists and update, otherwise insert
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
    [LOADTS_UTC] DATETIME2
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
    [LOADTS_UTC] DATETIME2
);', 'STRING', 'STAGE_DDL', N'DL_ZonalProduct', 1, SYSTEM_USER, GETDATE(), 1);
END
GO
