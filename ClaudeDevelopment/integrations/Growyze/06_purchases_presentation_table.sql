-- F_PURCHASES_DAY Presentation Table DDL
-- Inserts the table definition into core.PresentationTables
-- Prerequisite: 05_invitem_stockorder_entity_fix.sql deployed
-- Uses MERGE upsert pattern per CLAUDE.md rules

MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (
    N'F_PURCHASES_DAY',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_PURCHASES_DAY](
    [INVITEM_HUB_ID]      [binary](32)      NOT NULL,
    [SUPPLIER_HUB_ID]     [binary](32)      NOT NULL,
    [LOCATION_HUB_ID]     [binary](32)      NOT NULL,
    [STOCKORDER_HUB_ID]   [binary](32)      NOT NULL,
    [ORDER_DATE]           [datetime2](7)    NULL,
    [DELIVERY_DATE]        [datetime2](7)    NULL,
    [ORDER_STATUS]         [nvarchar](255)   NULL,
    [UNIT_PRICE]           [decimal](38, 6)  NULL,
    [UNIT_COST]            [decimal](38, 6)  NULL,
    [ORDER_QTY]            [decimal](38, 6)  NULL,
    [LINE_TOTAL]           [decimal](38, 6)  NULL,
    [PACK_SIZE]            [decimal](38, 6)  NULL,
    [PACK_PRICE]           [decimal](38, 6)  NULL,
    [ORDER_REFERENCE]      [nvarchar](255)   NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_PURCHASES_DAY-CLUSTERED] ON [presentation].[F_PURCHASES_DAY]
(
    [ORDER_DATE] ASC,
    [LOCATION_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-INVITEM] ON [presentation].[F_PURCHASES_DAY]
(
    [INVITEM_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-SUPPLIER] ON [presentation].[F_PURCHASES_DAY]
(
    [SUPPLIER_HUB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
;',
    N'[
        {"name": "INVITEM_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Inventory item hub key"},
        {"name": "SUPPLIER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Supplier hub key"},
        {"name": "LOCATION_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Location hub key (resolved via delivery event)"},
        {"name": "STOCKORDER_HUB_ID", "type": "binary(32)", "nullable": false, "description": "Stock order hub key"},
        {"name": "ORDER_DATE", "type": "datetime2(7)", "nullable": true, "description": "Order placement date"},
        {"name": "DELIVERY_DATE", "type": "datetime2(7)", "nullable": true, "description": "Expected delivery date"},
        {"name": "ORDER_STATUS", "type": "nvarchar(255)", "nullable": true, "description": "Order status"},
        {"name": "UNIT_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Unit price per item"},
        {"name": "UNIT_COST", "type": "decimal(38,6)", "nullable": true, "description": "Estimated unit cost"},
        {"name": "ORDER_QTY", "type": "decimal(38,6)", "nullable": true, "description": "Quantity ordered"},
        {"name": "LINE_TOTAL", "type": "decimal(38,6)", "nullable": true, "description": "Line total (qty * price)"},
        {"name": "PACK_SIZE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack size"},
        {"name": "PACK_PRICE", "type": "decimal(38,6)", "nullable": true, "description": "Case/pack price"},
        {"name": "ORDER_REFERENCE", "type": "nvarchar(255)", "nullable": true, "description": "PO number / order reference"}
    ]',
    N'Purchase order line items by day. One row per inventory item per stock order. Provides per-item purchase pricing, supplier spend analysis, and delivery tracking.',
    NULL,
    NULL,
    1,
    N'live',
    0,
    NULL,
    GETDATE(),
    GETDATE()
)) AS src (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
ON tgt.table_name = src.table_name AND tgt.schema_name = src.schema_name
WHEN MATCHED THEN
    UPDATE SET
        ddl_script = src.ddl_script,
        column_definitions = src.column_definitions,
        description = src.description,
        version = src.version,
        status = src.status,
        updated_at = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (table_name, table_type, schema_name, ddl_script, column_definitions, description, business_owner, data_source, version, status, is_system_generated, created_by, created_at, updated_at)
    VALUES (src.table_name, src.table_type, src.schema_name, src.ddl_script, src.column_definitions, src.description, src.business_owner, src.data_source, src.version, src.status, src.is_system_generated, src.created_by, src.created_at, src.updated_at);
