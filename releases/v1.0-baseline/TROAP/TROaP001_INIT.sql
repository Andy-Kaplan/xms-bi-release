-- ============================================
-- TROaP001 INIT - regenerated from UAT 2026-06-02 10:45:23
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'TROaP001',
		@IntegrationDisplayName = N'TROaP'

SELECT	'Return Value' = @return_value

GO

UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
  "integration_info": {
    "source": "troap"
  },
  "tables": {
    "[dbo].[Address]": {},
    "[dbo].[Allergen]": {},
    "[dbo].[AllowedStores]": {},
    "[dbo].[AvailabilityRule]": {},
    "[dbo].[AvailabilityRuleValidDays]": {},
    "[dbo].[Basket]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[BasketItem]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[BrainTreePaymentIntent]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[BrainTreePaymentLog]": {
      "delta_columns": [
        "DateCreated"
      ]
    },
    "[dbo].[CouponDiscount]": {},
    "[dbo].[Customer]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[CustomerOpenCheck]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[CustomerOpenCheckBasket]": {
      "delta_columns": [
        "DateCreated"
      ]
    },
    "[dbo].[CustomerOpenCheckCharge]": {
      "parent_table": "[dbo].[CustomerOpenCheck]",
      "parent_table_key_column": "Id",
      "parent_table_delta_columns": [
        "DateUpdated",
        "DateCreated"
      ],
      "fk_column": "CustomerOpenCheckId"
    },
    "[dbo].[CustomerOpenCheckCouponDiscount]": {
      "parent_table": "[dbo].[CustomerOpenCheck]",
      "parent_table_key_column": "Id",
      "parent_table_delta_columns": [
        "DateUpdated",
        "DateCreated"
      ],
      "fk_column": "CustomerOpenCheckId"
    },
    "[dbo].[CustomerOpenCheckDiscount]": {
      "parent_table": "[dbo].[CustomerOpenCheck]",
      "parent_table_key_column": "Id",
      "parent_table_delta_columns": [
        "DateUpdated",
        "DateCreated"
      ],
      "fk_column": "CustomerOpenCheckId"
    },
    "[dbo].[CustomerOpenCheckPromotion]": {
      "parent_table": "[dbo].[CustomerOpenCheck]",
      "parent_table_key_column": "Id",
      "parent_table_delta_columns": [
        "DateUpdated",
        "DateCreated"
      ],
      "fk_column": "CustomerOpenCheckId"
    },
    "[dbo].[Device]": {},
    "[dbo].[lstChargeType]": {},
    "[dbo].[lstOpenCheckStatus]": {},
    "[dbo].[lstOrderStatus]": {},
    "[dbo].[lstPaymentStatus]": {},
    "[dbo].[lstRefundReason]": {},
    "[dbo].[lstPaymentType]": {},
    "[dbo].[lstShipmentType]": {},
    "[dbo].[Menu]": {},
    "[dbo].[MenuCategory]": {},
    "[dbo].[MenuCategoryGroup]": {},
    "[dbo].[MenuPriceBand]": {},
    "[dbo].[MenuProduct]": {},
    "[dbo].[Order]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[OrderItem]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[OrderPayment]": {
      "delta_columns": [
        "DateUpdated",
        "DateCreated"
      ]
    },
    "[dbo].[OrderRefundQueue]": {
      "delta_columns": [
        "DateCreated",
        "DateProcessed"
      ]
    },
    "[dbo].[OrderSplitBill]": {
      "delta_columns": [
        "DateCreated"
      ]
    },
    "[dbo].[OrderSplitBillItem]": {
      "delta_columns": [
        "DateUpdated"
      ]
    },
    "[dbo].[OrderSplitBillPayment]": {
      "parent_table": "[dbo].[OrderSplitBill]",
      "parent_table_key_column": "OrderSplitBillId",
      "parent_table_delta_columns": [
        "DateCreated"
      ],
      "fk_column": "OrderSplitBillId"
    },
    "[dbo].[Price]": {},
    "[dbo].[Product]": {},
    "[dbo].[ProductBase]": {},
    "[dbo].[ProductCategory]": {},
    "[dbo].[Store]": {},
    "[dbo].[StoreOpeningHours]": {},
    "[dbo].[StoreOpeningHoursGroup]": {},
    "[dbo].[StoreOrderType]": {},
    "[dbo].[StoreProductOutOfStock]": {},
    "[dbo].[ZonalMenu]": {},
    "[dbo].[ZonalProduct]": {}
  }
}'
WHERE [IntegrationName] = N'TROaP001';
GO
