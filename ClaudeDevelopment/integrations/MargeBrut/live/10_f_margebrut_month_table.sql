-- ============================================
-- 10_f_margebrut_month_table.sql
-- Registers presentation.F_MARGEBRUT_MONTH into core.PresentationTables
-- so sp_DeployObjects / DeployPresentationTables can create it.
--
-- Part of the Marge Brut mock -> live build (Task 1).
-- Natural key verified via MCP against core.PresentationTables:
--   UQ_PresentationTables_TableName_Version UNIQUE (table_name, version)
-- Column list verified via INFORMATION_SCHEMA.COLUMNS (core.PresentationTables):
--   id (PK, default NEWID()), table_name, table_type, schema_name, ddl_script,
--   column_definitions, description, business_owner, data_source, version,
--   status, is_system_generated, parent_tables, child_tables, created_by,
--   created_at, updated_by, updated_at
-- ============================================

MERGE INTO [core].[PresentationTables] AS tgt
USING (VALUES (N'F_MARGEBRUT_MONTH', 1)) AS src (table_name, version)
ON tgt.table_name = src.table_name AND tgt.version = src.version
WHEN MATCHED THEN UPDATE SET
    table_type = N'Fact',
    schema_name = N'presentation',
    ddl_script = N'CREATE TABLE [presentation].[F_MARGEBRUT_MONTH](
        [GROUP_NAME] [nvarchar](50) NOT NULL,
        [PERIOD_MONTH] [date] NOT NULL,
        [TURNOVER_INCL] [decimal](18,2) NULL,
        [TURNOVER_EXCL] [decimal](18,2) NULL,
        [OPENING] [decimal](18,2) NULL,
        [PURCHASES] [decimal](18,2) NULL,
        [REV_PROV] [decimal](18,2) NULL,
        [NEW_PROV] [decimal](18,2) NULL,
        [ALL_STOCK] [decimal](18,2) NULL,
        [CLOSING] [decimal](18,2) NULL,
        [STAFF_MEAL] [decimal](18,2) NULL,
        [COMP] [decimal](18,2) NULL,
        [CONSUMPTION] [decimal](18,2) NULL,
        [COST_PCT] [decimal](9,4) NULL,
        [GP_PCT] [decimal](9,4) NULL,
        CONSTRAINT [PK_F_MARGEBRUT_MONTH] PRIMARY KEY ([GROUP_NAME],[PERIOD_MONTH])
    )',
    column_definitions = N'[{"name": "GROUP_NAME", "data_type": "NVARCHAR(50)", "nullable": false}, {"name": "PERIOD_MONTH", "data_type": "DATE", "nullable": false}, {"name": "TURNOVER_INCL", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "TURNOVER_EXCL", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "OPENING", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "PURCHASES", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "REV_PROV", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "NEW_PROV", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "ALL_STOCK", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "CLOSING", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "STAFF_MEAL", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "COMP", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "CONSUMPTION", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "COST_PCT", "data_type": "DECIMAL(9,4)", "nullable": true}, {"name": "GP_PCT", "data_type": "DECIMAL(9,4)", "nullable": true}]',
    description = N'Marge Brut monthly F&B cost-of-sales fact - one row per reporting group per month (turnover, opening/closing stock, purchases, provisions, staff meals/comps, consumption, cost % and GP %).',
    business_owner = NULL,
    data_source = N'MargeBrut',
    status = N'live',
    is_system_generated = 0,
    updated_by = N'Claude (ClaudeDevelopment)',
    updated_at = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (table_name, table_type, schema_name, ddl_script,
     column_definitions, description, business_owner, data_source,
     version, status, is_system_generated, created_by,
     created_at, updated_at)
VALUES (
    N'F_MARGEBRUT_MONTH',
    N'Fact',
    N'presentation',
    N'CREATE TABLE [presentation].[F_MARGEBRUT_MONTH](
        [GROUP_NAME] [nvarchar](50) NOT NULL,
        [PERIOD_MONTH] [date] NOT NULL,
        [TURNOVER_INCL] [decimal](18,2) NULL,
        [TURNOVER_EXCL] [decimal](18,2) NULL,
        [OPENING] [decimal](18,2) NULL,
        [PURCHASES] [decimal](18,2) NULL,
        [REV_PROV] [decimal](18,2) NULL,
        [NEW_PROV] [decimal](18,2) NULL,
        [ALL_STOCK] [decimal](18,2) NULL,
        [CLOSING] [decimal](18,2) NULL,
        [STAFF_MEAL] [decimal](18,2) NULL,
        [COMP] [decimal](18,2) NULL,
        [CONSUMPTION] [decimal](18,2) NULL,
        [COST_PCT] [decimal](9,4) NULL,
        [GP_PCT] [decimal](9,4) NULL,
        CONSTRAINT [PK_F_MARGEBRUT_MONTH] PRIMARY KEY ([GROUP_NAME],[PERIOD_MONTH])
    )',
    N'[{"name": "GROUP_NAME", "data_type": "NVARCHAR(50)", "nullable": false}, {"name": "PERIOD_MONTH", "data_type": "DATE", "nullable": false}, {"name": "TURNOVER_INCL", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "TURNOVER_EXCL", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "OPENING", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "PURCHASES", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "REV_PROV", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "NEW_PROV", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "ALL_STOCK", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "CLOSING", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "STAFF_MEAL", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "COMP", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "CONSUMPTION", "data_type": "DECIMAL(18,2)", "nullable": true}, {"name": "COST_PCT", "data_type": "DECIMAL(9,4)", "nullable": true}, {"name": "GP_PCT", "data_type": "DECIMAL(9,4)", "nullable": true}]',
    N'Marge Brut monthly F&B cost-of-sales fact - one row per reporting group per month (turnover, opening/closing stock, purchases, provisions, staff meals/comps, consumption, cost % and GP %).',
    NULL,
    N'MargeBrut',
    1,
    N'live',
    0,
    N'Claude (ClaudeDevelopment)',
    GETDATE(),
    GETDATE()
);
