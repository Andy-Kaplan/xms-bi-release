/*  DEPLOY NOTE
    Deploy THIS TABLE ONLY for the target org. Do NOT run DeployPresentationTables -
    it DROPs every registered presentation table (O8).

    37 columns. OPENING_COUNT_DATE / CLOSING_COUNT_DATE were added by the final-review
    fix wave (finding I6): they record WHICH stocktake each period boundary actually
    resolved to per item. Without them, the O8-sibling defect (opening and closing
    resolving to the same stocktake, collapsing consumption to purchases) is undetectable
    after the build, because it happens per item inside 02's two OUTER APPLYs while
    PERIOD_START_DATE / PERIOD_END_DATE are always distinct at period level.
    Verify check 6 reads them. Four things must stay in agreement, in this order:
    this DDL, @cols below, 02's column_mappings, and 02's final SELECT aliases.
*/

DECLARE @ddl NVARCHAR(MAX) = N'CREATE TABLE [presentation].[F_COGS_PERIOD](
    [INVITEM_HUB_ID] [binary](32) NOT NULL,
    [LOCATION_HUB_ID] [binary](32) NOT NULL,
    [PERIOD_START_DATE] [datetime2](7) NULL,
    [PERIOD_END_DATE] [datetime2](7) NULL,
    [PERIOD_DAYS] [int] NULL,
    [PERIOD_SEQ] [int] NULL,
    [PERIOD_MONTH] [date] NULL,
    [PERIOD_LABEL] [varchar](50) NULL,
    [OPENING_COUNT_DATE] [date] NULL,
    [CLOSING_COUNT_DATE] [date] NULL,
    [SOURCE] [varchar](100) NULL,
    [STANDARDISED_UOM] [varchar](255) NULL,
    [ITEM_NAME] [nvarchar](255) NULL,
    [CATEGORY] [nvarchar](255) NULL,
    [SUBCATEGORY] [nvarchar](255) NULL,
    [REPORT_GROUP] [nvarchar](255) NULL,
    [OPENING_QTY] [decimal](38, 6) NULL,
    [DELIVERY_QTY] [decimal](38, 6) NULL,
    [TRANSFER_QTY] [decimal](38, 6) NULL,
    [CLOSING_QTY] [decimal](38, 6) NULL,
    [CONSUMPTION_QTY] [decimal](38, 6) NULL,
    [WASTE_QTY] [decimal](38, 6) NULL,
    [SALE_QTY] [decimal](38, 6) NULL,
    [THEO_CLOSING_QTY] [decimal](38, 6) NULL,
    [VARIANCE_QTY] [decimal](38, 6) NULL,
    [UOM_COST] [decimal](38, 6) NULL,
    [OPENING_VALUE] [decimal](38, 6) NULL,
    [DELIVERY_VALUE] [decimal](38, 6) NULL,
    [COG_SPEND] [decimal](38, 6) NULL,
    [COG_SOLD] [decimal](38, 6) NULL,
    [CLOSING_VALUE] [decimal](38, 6) NULL,
    [WASTE_VALUE] [decimal](38, 6) NULL,
    [VARIANCE_VALUE] [decimal](38, 6) NULL,
    [IS_NEGATIVE_COGS] [bit] NULL,
    [HAS_ZERO_COST] [bit] NULL,
    [IS_UNCOUNTED] [bit] NULL,
    [IS_FIRST_PERIOD] [bit] NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_COGS_PERIOD-CLUSTERED] ON [presentation].[F_COGS_PERIOD]
(
    [PERIOD_END_DATE] ASC,
    [LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_COGS_PERIOD-INVITEM] ON [presentation].[F_COGS_PERIOD]
(
    [INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;';

DECLARE @cols NVARCHAR(MAX) = N'[{"name": "INVITEM_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "LOCATION_HUB_ID", "data_type": "[binary](32)", "nullable": false}, {"name": "PERIOD_START_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "PERIOD_END_DATE", "data_type": "[datetime2](7)", "nullable": true}, {"name": "PERIOD_DAYS", "data_type": "[int]", "nullable": true}, {"name": "PERIOD_SEQ", "data_type": "[int]", "nullable": true}, {"name": "PERIOD_MONTH", "data_type": "[date]", "nullable": true}, {"name": "PERIOD_LABEL", "data_type": "[varchar](50)", "nullable": true}, {"name": "OPENING_COUNT_DATE", "data_type": "[date]", "nullable": true}, {"name": "CLOSING_COUNT_DATE", "data_type": "[date]", "nullable": true}, {"name": "SOURCE", "data_type": "[varchar](100)", "nullable": true}, {"name": "STANDARDISED_UOM", "data_type": "[varchar](255)", "nullable": true}, {"name": "ITEM_NAME", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "CATEGORY", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "SUBCATEGORY", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "REPORT_GROUP", "data_type": "[nvarchar](255)", "nullable": true}, {"name": "OPENING_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "DELIVERY_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "TRANSFER_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "CLOSING_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "CONSUMPTION_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "WASTE_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "SALE_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "THEO_CLOSING_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "VARIANCE_QTY", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "UOM_COST", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "OPENING_VALUE", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "DELIVERY_VALUE", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "COG_SPEND", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "COG_SOLD", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "CLOSING_VALUE", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "WASTE_VALUE", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "VARIANCE_VALUE", "data_type": "[decimal](38, 6)", "nullable": true}, {"name": "IS_NEGATIVE_COGS", "data_type": "[bit]", "nullable": true}, {"name": "HAS_ZERO_COST", "data_type": "[bit]", "nullable": true}, {"name": "IS_UNCOUNTED", "data_type": "[bit]", "nullable": true}, {"name": "IS_FIRST_PERIOD", "data_type": "[bit]", "nullable": true}]';

MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'F_COGS_PERIOD')) AS src (table_name)
    ON tgt.[table_name] = src.[table_name]
WHEN MATCHED THEN UPDATE SET
     [table_type]           = N'Fact'
    ,[schema_name]          = N'presentation'
    ,[ddl_script]           = @ddl
    ,[column_definitions]   = @cols
    ,[description]          = N'Item x location x stocktake-period COGS fact for Growyze pantry reporting. COG Spend = delivered value (billing); COG Sold = consumption value (insights). All money columns valued at latest cost price in period.'
    ,[version]              = 1
    ,[status]               = N'live'
    ,[is_system_generated]  = 0
    ,[updated_at]           = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script, column_definitions,
     description, business_owner, data_source, version, status,
     is_system_generated, created_by, created_at, updated_at)
VALUES
    (N'F_COGS_PERIOD', N'Fact', N'presentation', @ddl, @cols,
     N'Item x location x stocktake-period COGS fact for Growyze pantry reporting.',
     NULL, N'Growyze', 1, N'live', 0, NULL, GETDATE(), GETDATE());
