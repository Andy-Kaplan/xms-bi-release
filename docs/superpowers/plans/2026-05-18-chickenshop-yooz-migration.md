# Chicken Shop — Yooz Extract Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Matillion `MARKETMAN_PROCESS_YOOZ` job with an XMS BI-built daily Purchase Order extract, delivered to the existing Snowflake target table by a new Azure Function.

**Architecture:** New "Chicken Shop" org in XMS BI runs the existing MarketMan001 integration against a dedicated MarketMan account. Three new `reference.YOOZ_*` config tables plus a new `extract.V_YOOZ_PO` view produce the 44-column extract in the client DB. A timer-triggered Azure Function (in the existing Functions layer) reads the view daily and atomic-swaps the Snowflake target table. Snowflake email task is unchanged.

**Tech Stack:** SQL Server Managed Instance (XMS BI), Azure Functions (separate repo), Snowflake (customer-managed). MCP for read-only audits.

**Spec:** `docs/superpowers/specs/2026-05-18-chickenshop-yooz-migration-design.md`

**Authoring vs execution split:**
- Claude authors all SQL scripts (saved to `ClaudeDevelopment/integrations/ChickenShop/`) and runs read-only validation queries via MCP.
- The developer executes deployment scripts. Per CLAUDE.md: MCP is read-only; only SELECT/WITH queries through MCP.
- All saved SQL scripts use unqualified two-part names (e.g. `[reference].[YOOZ_MAPS]`). Three-part names only appear in MCP audit queries that target a specific test DB.

---

## File Structure

| Path | Action | Responsibility |
|---|---|---|
| `ClaudeDevelopment/integrations/ChickenShop/DEPLOY.txt` | Create | Deploy order + env-specific notes |
| `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md` | Create | Captured outputs of pre-flight MCP audits |
| `ClaudeDevelopment/integrations/ChickenShop/01_reference_yooz_tables.sql` | Create | DDL for 3 `reference.YOOZ_*` tables |
| `ClaudeDevelopment/integrations/ChickenShop/02_extract_schema_and_view.sql` | Create | `extract` schema + `V_YOOZ_PO` view |
| `ClaudeDevelopment/integrations/ChickenShop/03_provision_chickenshop.sql` | Create | `AddOrganisation` + `MapOrganisationToIntegration` |
| `ClaudeDevelopment/integrations/ChickenShop/04_validation_queries.sql` | Create | Read-only validation suite (also runnable via MCP) |
| `ClaudeDevelopment/integrations/ChickenShop/FUNCTION_HANDOFF.md` | Create | Spec/handoff doc for the Azure Functions team |
| `ClaudeDevelopment/QUERY_STATUS.md` | Modify | Add Chicken Shop section |
| `memory/MEMORY.md` | Modify | Add Chicken Shop entry under integrations |

**Stand-in test org for pre-flight audits:** Kudu (UAT GUID `20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57`) — MarketMan-only, 3 stores, no NCRAloha noise. From MEMORY Test Organisation Reference.

---

## Phase 1 — Pre-flight DV audits

The spec flagged five risks needing verification before any code is written. Tasks 1–5 resolve them.

### Task 1: Scaffold the ChickenShop folder

**Files:**
- Create: `ClaudeDevelopment/integrations/ChickenShop/DEPLOY.txt`
- Create: `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md`

- [ ] **Step 1: Create DEPLOY.txt**

```text
# Chicken Shop — Yooz Extract Migration
# Deploy order (per environment):

00_preflight_dv_audit.md   — read-only audit results (no execution)
01_reference_yooz_tables.sql   — DDL for reference.YOOZ_MAPS, YOOZ_PRICE_AMEND, YOOZ_ALLOWED_VENDORS
                                 RUN IN: Chicken Shop client DB
02_extract_schema_and_view.sql — extract schema + V_YOOZ_PO view
                                 RUN IN: Chicken Shop client DB
03_provision_chickenshop.sql   — AddOrganisation + MapOrganisationToIntegration
                                 RUN IN: core database
                                 RUN BEFORE 01 + 02 (creates the client DB)
04_validation_queries.sql      — read-only validation suite
                                 RUN IN: Chicken Shop client DB or via MCP

Recommended order in a fresh environment:
  03  ->  01  ->  02  ->  initial MarketMan DV load  ->  04
```

- [ ] **Step 2: Create 00_preflight_dv_audit.md skeleton**

```markdown
# Pre-flight DV Audit — Chicken Shop / Yooz Extract

Audits run against UAT Kudu (`20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57`) as a stand-in for Chicken Shop's eventual MarketMan-only DB shape.

## SAT_STOCKORDER column coverage
_to be populated by Task 2_

## SAT_INVITEM_STOCKORDER column coverage
_to be populated by Task 3_

## SAT_INVENTORYITEMS column coverage
_to be populated by Task 4_

## MarketMan PO data flow check
_to be populated by Task 5_

## Allowed-vendor list (from Matillion job)
_to be populated by Task 6_

## Snowflake target DDL
_to be populated when customer provides DESCRIBE TABLE output_
```

- [ ] **Step 3: Verify files exist**

Run: `Get-ChildItem "ClaudeDevelopment/integrations/ChickenShop/"`
Expected: Two new files plus the existing `matillion-export/` folder.

- [ ] **Step 4: Commit (with user approval)**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/DEPLOY.txt ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md
git commit -m "feat(chickenshop): scaffold integration folder for Yooz extract"
```

---

### Task 2: Audit SAT_STOCKORDER columns

**Files:**
- Modify: `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md`

- [ ] **Step 1: Run MCP describe_table for SAT_STOCKORDER on Kudu UAT**

Use the `mcp__xms-bi-uat__describe_table` tool with:
- `database`: `20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57`
- `schema`: `datavault`
- `table`: `SAT_STOCKORDER`

If `describe_table` cannot reach the target DB through its `database` param, fall back to a three-part read via `mcp__xms-bi-uat__query`:

```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'datavault' AND TABLE_NAME = 'SAT_STOCKORDER'
ORDER BY ORDINAL_POSITION
```

Expected: A column list including (at minimum) HUB_ID, LOADTS_UTC, plus PO header attributes.

- [ ] **Step 2: Record results in 00_preflight_dv_audit.md**

Update the SAT_STOCKORDER section with a table:

```markdown
## SAT_STOCKORDER column coverage

| Spec column | Actual column name | Type | Status |
|---|---|---|---|
| ORDER_NUMBER       | (fill in) | (fill in) | found / missing |
| ORDER_DATE         | (fill in) | (fill in) | found / missing |
| CURRENCY           | (fill in) | (fill in) | found / missing |
| ORDER_CREATOR      | (fill in) | (fill in) | found / missing |
| ORDER_APPROVERS    | (fill in) | (fill in) | found / missing |
| ERP_ORDER_STATUS / ORDER_STATUS | (fill in) | (fill in) | found / missing |
| PLANNED_DELIVERY_DATE | (fill in) | (fill in) | found / missing |
| ORDER_CANCELLED_BY_BUYER | (fill in) | (fill in) | found / missing |
| ORDER_CANCELLED_BY_SUPPLIER | (fill in) | (fill in) | found / missing |
| (MarketMan buyer/site code) | (fill in) | (fill in) | found / missing |
```

For any "missing" rows, add a note explaining the gap and proposed mitigation (extend EntityMappings to land the column, or hard-code `''` in the view).

- [ ] **Step 3: If any column is missing**

Document the decision in 00_preflight_dv_audit.md. Do NOT modify `MarketMan/MarketMan001_Mapping.sql` as part of this plan — that's a platform change requiring its own ticket. Instead, hard-code an empty string in the view and add a note in the spec's risk register.

- [ ] **Step 4: Commit (with user approval)**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md
git commit -m "audit(chickenshop): SAT_STOCKORDER column coverage"
```

---

### Task 3: Audit SAT_INVITEM_STOCKORDER columns

**Files:**
- Modify: `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md`

- [ ] **Step 1: Run MCP query for SAT_INVITEM_STOCKORDER column list**

```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'datavault' AND TABLE_NAME = 'SAT_INVITEM_STOCKORDER'
ORDER BY ORDINAL_POSITION
```

Expected: HUB_ID columns for the link plus line attributes.

- [ ] **Step 2: Record results in 00_preflight_dv_audit.md**

```markdown
## SAT_INVITEM_STOCKORDER column coverage

| Spec column | Actual column name | Type | Status |
|---|---|---|---|
| LINE_NUMBER          | (fill in) | (fill in) | found / missing |
| UNIT_PRICE / ITEM_UNIT_PRICE | (fill in) | (fill in) | found / missing |
| QUANTITY / QUANTITY_ORDERED | (fill in) | (fill in) | found / missing |
| AMOUNT_INC_TAX       | (fill in) | (fill in) | found / missing |
| AMOUNT_EXCL_TAX      | (fill in) | (fill in) | found / missing |
| TAX_AMOUNT           | (fill in) | (fill in) | found / missing |
| TAX_PROFILE_CODE     | (fill in) | (fill in) | found / missing |
```

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md
git commit -m "audit(chickenshop): SAT_INVITEM_STOCKORDER column coverage"
```

---

### Task 4: Audit SAT_INVENTORYITEMS + SAT_SUPPLIER columns

**Files:**
- Modify: `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md`

- [ ] **Step 1: Run two MCP queries**

```sql
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'datavault'
  AND TABLE_NAME IN ('SAT_INVENTORYITEMS', 'SAT_SUPPLIER')
ORDER BY TABLE_NAME, ORDINAL_POSITION
```

- [ ] **Step 2: Record results in 00_preflight_dv_audit.md**

```markdown
## SAT_INVENTORYITEMS column coverage

| Spec column | Actual column name | Type | Status |
|---|---|---|---|
| PRODUCT_CODE        | (fill in) | (fill in) | found / missing |
| SRC_KEY             | (fill in) | (fill in) | found / missing |
| CLIENT_ITEM_CODE    | (fill in) | (fill in) | found / missing |
| ITEM_NAME / ITEM_DESCRIPTION | (fill in) | (fill in) | found / missing |
| VENDOR_ITEM_CODE    | (fill in) | (fill in) | found / missing |

## SAT_SUPPLIER column coverage

| Spec column | Actual column name | Type | Status |
|---|---|---|---|
| SUPPLIER_NAME       | (fill in) | (fill in) | found / missing |
| SUPPLIER_CODE       | (fill in) | (fill in) | found / missing |
```

Note: `SRC_KEY` is conventionally present on every DV satellite — if missing here, that's significant and worth flagging.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md
git commit -m "audit(chickenshop): SAT_INVENTORYITEMS + SAT_SUPPLIER column coverage"
```

---

### Task 5: Confirm MarketMan POs flow + sample data

**Files:**
- Modify: `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md`

- [ ] **Step 1: Confirm STOCKORDER hub has rows for Kudu**

```sql
SELECT COUNT(*) AS hub_row_count
FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].[datavault].[HUB_STOCKORDER]
```

Expected: a non-zero number. If zero, MarketMan POs are not flowing through staging — escalate before continuing. This affects whether the platform delivers POs at all, which is a precondition for the view to function.

- [ ] **Step 2: Sample the satellite to confirm column population**

```sql
SELECT TOP 5 *
FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].[datavault].[SAT_STOCKORDER]
ORDER BY LOADTS_UTC DESC
```

Expected: rows with ORDER_NUMBER / ORDER_DATE / CURRENCY populated (or whatever the actual columns from Task 2 are).

- [ ] **Step 3: Check that link satellite carries line-level data**

```sql
SELECT TOP 5 *
FROM [20260129_XMS_5AD1BEAC-31FD-F011-8D4C-0022489A1D57].[datavault].[SAT_INVITEM_STOCKORDER]
ORDER BY LOADTS_UTC DESC
```

- [ ] **Step 4: Record outcome in 00_preflight_dv_audit.md**

```markdown
## MarketMan PO data flow check

- HUB_STOCKORDER row count: (fill in)
- SAT_STOCKORDER sample rows visible: yes / no
- SAT_INVITEM_STOCKORDER sample rows visible: yes / no
- Latest LOADTS_UTC: (fill in)
- Outcome: data flowing / not flowing / partial

If not flowing: STOP and escalate. Yooz extract cannot be built on top of an empty DV.
```

- [ ] **Step 5: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md
git commit -m "audit(chickenshop): confirm MarketMan PO data flow"
```

---

### Task 6: Extract full allowed-vendor list from Matillion JSON

**Files:**
- Modify: `ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md`

- [ ] **Step 1: Extract all Filter Conditions referencing VENDOR_NAME from the Yooz export**

Grep the pretty-printed export:

```
Grep tool with:
  path: ClaudeDevelopment/integrations/ChickenShop/matillion-export/_yooz_pretty.json
  pattern: "VENDOR_NAME"
  context: 30 lines after
```

Walk every match and collect the literal vendor names that appear as Filter Conditions' fourth element (value field).

- [ ] **Step 2: Deduplicate and record**

```markdown
## Allowed-vendor list (from Matillion job)

| # | Vendor name (exact, as in Matillion) |
|---|---|
| 1 | Bidfood |
| 2 | Yes Chef |
| 3 | (fill in) |
| … | (fill in) |

These become the seed rows for `reference.YOOZ_ALLOWED_VENDORS`.
```

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/00_preflight_dv_audit.md
git commit -m "audit(chickenshop): full allowed-vendor list from Matillion"
```

---

## Phase 2 — Author deployment scripts

Each script ships with idempotency guards (per CLAUDE.md). All saved scripts use unqualified two-part names.

### Task 7: Author `01_reference_yooz_tables.sql`

**Files:**
- Create: `ClaudeDevelopment/integrations/ChickenShop/01_reference_yooz_tables.sql`

- [ ] **Step 1: Write the failing validation query (will be run after deployment)**

Save this as a validation snippet inside `04_validation_queries.sql` later. Expected to return zero rows before deployment, non-empty after:

```sql
SELECT name, create_date
FROM sys.tables
WHERE schema_id = SCHEMA_ID('reference')
  AND name IN ('YOOZ_MAPS', 'YOOZ_PRICE_AMEND', 'YOOZ_ALLOWED_VENDORS')
ORDER BY name
```

- [ ] **Step 2: Author the script**

```sql
/* =====================================================================
   01_reference_yooz_tables.sql

   Creates the three reference tables that drive the Yooz PO extract.
   Run inside the Chicken Shop client DB.
   Idempotent: safe to re-run.

   See: docs/superpowers/specs/2026-05-18-chickenshop-yooz-migration-design.md
   ===================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reference')
    EXEC(N'CREATE SCHEMA [reference]');
GO

/* ---------- reference.YOOZ_MAPS ---------- */
IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'reference' AND t.name = N'YOOZ_MAPS'
)
BEGIN
    CREATE TABLE [reference].[YOOZ_MAPS] (
        MAP_ID            INT IDENTITY(1,1) NOT NULL,
        MAP_TYPE          NVARCHAR(50)  NOT NULL,
        MM_CODE           NVARCHAR(200) NOT NULL,
        YOOZ_CODE         NVARCHAR(200) NOT NULL,
        DESCRIPTION       NVARCHAR(500) NULL,
        IS_ACTIVE         BIT           NOT NULL CONSTRAINT DF_YOOZ_MAPS_IsActive          DEFAULT (1),
        LAST_MODIFIED_UTC DATETIME2(3)  NOT NULL CONSTRAINT DF_YOOZ_MAPS_LastModifiedUtc   DEFAULT (SYSUTCDATETIME()),
        LAST_MODIFIED_BY  NVARCHAR(100) NULL,
        CONSTRAINT PK_YOOZ_MAPS PRIMARY KEY CLUSTERED (MAP_ID)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'UX_YOOZ_MAPS_ActiveKey'
      AND object_id = OBJECT_ID(N'[reference].[YOOZ_MAPS]')
)
BEGIN
    CREATE UNIQUE INDEX UX_YOOZ_MAPS_ActiveKey
        ON [reference].[YOOZ_MAPS] (MAP_TYPE, MM_CODE, YOOZ_CODE)
        WHERE IS_ACTIVE = 1;
END;
GO

/* ---------- reference.YOOZ_PRICE_AMEND ---------- */
IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'reference' AND t.name = N'YOOZ_PRICE_AMEND'
)
BEGIN
    CREATE TABLE [reference].[YOOZ_PRICE_AMEND] (
        AMEND_ID          INT IDENTITY(1,1) NOT NULL,
        PRODUCT_CODE      NVARCHAR(200)  NOT NULL,
        AMEND_PRICE       DECIMAL(18,4)  NOT NULL,
        TAX_PERCENT       DECIMAL(9,4)   NOT NULL,
        EFFECTIVE_FROM    DATE           NOT NULL,
        EFFECTIVE_TO      DATE           NULL,
        LAST_MODIFIED_UTC DATETIME2(3)   NOT NULL CONSTRAINT DF_YOOZ_PRICE_AMEND_LastModifiedUtc DEFAULT (SYSUTCDATETIME()),
        LAST_MODIFIED_BY  NVARCHAR(100)  NULL,
        CONSTRAINT PK_YOOZ_PRICE_AMEND PRIMARY KEY CLUSTERED (AMEND_ID)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_YOOZ_PRICE_AMEND_ProductCode_Effective'
      AND object_id = OBJECT_ID(N'[reference].[YOOZ_PRICE_AMEND]')
)
BEGIN
    CREATE INDEX IX_YOOZ_PRICE_AMEND_ProductCode_Effective
        ON [reference].[YOOZ_PRICE_AMEND] (PRODUCT_CODE, EFFECTIVE_FROM, EFFECTIVE_TO);
END;
GO

/* ---------- reference.YOOZ_ALLOWED_VENDORS ---------- */
IF NOT EXISTS (
    SELECT 1 FROM sys.tables t
    JOIN sys.schemas s ON s.schema_id = t.schema_id
    WHERE s.name = N'reference' AND t.name = N'YOOZ_ALLOWED_VENDORS'
)
BEGIN
    CREATE TABLE [reference].[YOOZ_ALLOWED_VENDORS] (
        VENDOR_NAME NVARCHAR(200) NOT NULL,
        NOTES       NVARCHAR(500) NULL,
        IS_ACTIVE   BIT           NOT NULL CONSTRAINT DF_YOOZ_ALLOWED_VENDORS_IsActive DEFAULT (1),
        ADDED_UTC   DATETIME2(3)  NOT NULL CONSTRAINT DF_YOOZ_ALLOWED_VENDORS_AddedUtc DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_YOOZ_ALLOWED_VENDORS PRIMARY KEY CLUSTERED (VENDOR_NAME)
    );
END;
GO
```

- [ ] **Step 3: Verify the script parses cleanly**

Open in SSMS or via `sqlcmd -i 01_reference_yooz_tables.sql -d tempdb -E` against a sandbox to confirm no syntax errors. Do NOT run against a real client DB at this stage.

- [ ] **Step 4: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/01_reference_yooz_tables.sql
git commit -m "feat(chickenshop): add reference table DDL for Yooz extract"
```

---

### Task 8: Author `02_extract_schema_and_view.sql`

**Files:**
- Create: `ClaudeDevelopment/integrations/ChickenShop/02_extract_schema_and_view.sql`

Use the column names recorded in 00_preflight_dv_audit.md. If any "Verify" column from §4 of the spec is missing in the audit, substitute `''` and add an inline comment.

- [ ] **Step 1: Author the script**

```sql
/* =====================================================================
   02_extract_schema_and_view.sql

   Creates the extract schema and V_YOOZ_PO view, which produces the
   44-column Yooz Purchase Order extract.

   Run inside the Chicken Shop client DB AFTER 01_reference_yooz_tables.sql.
   Idempotent: safe to re-run.

   See: docs/superpowers/specs/2026-05-18-chickenshop-yooz-migration-design.md
   ===================================================================== */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'extract')
    EXEC(N'CREATE SCHEMA [extract]');
GO

CREATE OR ALTER VIEW [extract].[V_YOOZ_PO] AS
WITH
    /* one row per PO line, resolved against its current SAT versions */
    so AS (
        SELECT
            HUB_ID,
            ORDER_NUMBER,
            ORDER_DATE,
            CURRENCY,
            ORDER_CREATOR,         /* substitute '' if Task 2 found missing */
            ORDER_APPROVERS,       /* substitute '' if missing */
            ORDER_STATUS           AS ERP_ORDER_STATUS,
            PLANNED_DELIVERY_DATE,
            ORDER_CANCELLED_BY_BUYER,
            ORDER_CANCELLED_BY_SUPPLIER,
            BUYERCODE              /* MarketMan site / buyer code; verify name in Task 2 */
        FROM [datavault].[SAT_STOCKORDER]
    ),
    line AS (
        SELECT
            STOCKORDER_HUB_ID,
            INVITEM_HUB_ID,
            LINE_NUMBER,
            UNIT_PRICE,
            QUANTITY,
            AMOUNT_INC_TAX,
            AMOUNT_EXCL_TAX,
            TAX_AMOUNT,
            TAX_PROFILE_CODE       /* substitute '' if Task 3 found missing */
        FROM [datavault].[SAT_INVITEM_STOCKORDER]
    ),
    item AS (
        SELECT
            HUB_ID,
            SRC_KEY,
            PRODUCT_CODE,
            CLIENT_ITEM_CODE,
            ITEM_NAME              AS ITEM_DESCRIPTION,
            VENDOR_ITEM_CODE       /* substitute '' if Task 4 found missing */
        FROM [datavault].[SAT_INVENTORYITEMS]
    ),
    sup AS (
        SELECT
            HUB_ID,
            SUPPLIER_NAME,
            SUPPLIER_CODE
        FROM [datavault].[SAT_SUPPLIER]
    ),
    /* Resolve supplier per PO via the distributor/supplier link */
    so_sup AS (
        SELECT
            lnk.STOCKORDER_HUB_ID,
            sup.SUPPLIER_NAME,
            sup.SUPPLIER_CODE
        FROM [datavault].[LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER] lnk
        INNER JOIN sup ON sup.HUB_ID = lnk.SUPPLIER_HUB_ID
    )
SELECT
    /*  1 */ N'CREATE'                                                   AS COMMAND,
    /*  2 */ ISNULL(so_sup.SUPPLIER_NAME, N'')                            AS VENDOR_NAME,
    /*  3 */ so_sup.SUPPLIER_CODE                                         AS VENDOR_CODE,
    /*  4 */ so.ORDER_NUMBER                                              AS ORDER_NUMBER,
    /*  5 */ ISNULL(FORMAT(so.ORDER_DATE, N'yyyyMMdd'), N'')              AS ORDER_DATE,
    /*  6 */ ISNULL((amend.AMEND_PRICE * line.QUANTITY) * (100 + amend.TAX_PERCENT) / 100,
                    line.AMOUNT_INC_TAX)                                  AS AMOUNT_INC_TAX,
    /*  7 */ ISNULL(amend.AMEND_PRICE * line.QUANTITY,
                    line.AMOUNT_EXCL_TAX)                                 AS AMOUNT_EXCL_TAX,
    /*  8 */ ISNULL(so.CURRENCY, N'')                                     AS CURRENCY,
    /*  9 */ ISNULL(so.ORDER_CREATOR, N'')                                AS ORDER_CREATOR,
    /* 10 */ ISNULL(so.ORDER_APPROVERS, N'')                              AS ORDER_APPROVERS,
    /* 11 */ ISNULL(so.ERP_ORDER_STATUS, N'')                             AS ERP_ORDER_STATUS,
    /* 12 */ line.LINE_NUMBER                                             AS LINE_NUMBER,
    /* 13 */ ISNULL(CAST(item.CLIENT_ITEM_CODE AS NVARCHAR(200)), N'')    AS CLIENT_ITEM_CODE,
    /* 14 */ item.ITEM_DESCRIPTION                                        AS ITEM_DESCRIPTION,
    /* 15 */ ISNULL(amend.AMEND_PRICE, line.UNIT_PRICE)                   AS ITEM_UNIT_PRICE,
    /* 16 */ line.QUANTITY                                                AS QUANTITY_ORDERED,
    /* 17 */ N''                                                          AS QUANTITY_RECEIVED,
    /* 18 */ N''                                                          AS QUANTITY_INVOICED,
    /* 19 */ N''                                                          AS AMOUNT_INVOICED,
    /* 20 */ N''                                                          AS DISCOUNTED_AMOUNT,
    /* 21 */ line.TAX_PROFILE_CODE                                        AS TAX_PROFILE_CODE,
    /* 22 */ ISNULL((amend.AMEND_PRICE * line.QUANTITY) * (100 + amend.TAX_PERCENT) / 100
                  - (amend.AMEND_PRICE * line.QUANTITY),
                    line.TAX_AMOUNT)                                      AS TAX_AMOUNT,
    /* 23 */ ISNULL(gl.YOOZ_CODE, N'-1')                                  AS GL_ACCOUNT_CHARGED,
    /* 24 */ N''                                                          AS COST_CENTERS_CHARTS_CODES,
    /* 25 */ N''                                                          AS COST_CENTERS_CODES,
    /* 26 */ N''                                                          AS SUBSIDIARY,
    /* 27 */ ISNULL(item.VENDOR_ITEM_CODE, N'')                           AS VENDOR_ITEM_CODE,
    /* 28 */ N''                                                          AS HEADER_LEVEL_CUSTOM_DATA,
    /* 29 */ N''                                                          AS LINE_LEVEL_CUSTOM_DATA,
    /* 30 */ N''                                                          AS RECEPTION_COMMENT,
    /* 31 */ N''                                                          AS RECEPTION_DATE,
    /* 32 */ ISNULL(FORMAT(so.PLANNED_DELIVERY_DATE, N'yyyyMMdd'), N'')   AS PLANNED_DELIVERY_DATE,
    /* 33 */ N''                                                          AS TO_BE_RECEIVED,
    /* 34 */ N''                                                          AS TYPE_OF_PO,
    /* 35 */ N''                                                          AS DELIVERY_ADDRESS,
    /* 36 */ N''                                                          AS INVOICING_ADDRESS,
    /* 37 */ N''                                                          AS PDF_YOOZ_NUMBER,
    /* 38 */ N''                                                          AS TYPE_OF_LINE,
    /* 39 */ N''                                                          AS SUB_LINES_MANAGEMENT,
    /* 40 */ N''                                                          AS BUDGET_PERIOD_CODE,
    /* 41 */ N''                                                          AS BUDGET_CODE,
    /* 42 */ ISNULL(orgunit.YOOZ_CODE, N'')                               AS ORGUNIT_CODE
FROM line
INNER JOIN so   ON so.HUB_ID   = line.STOCKORDER_HUB_ID
INNER JOIN item ON item.HUB_ID = line.INVITEM_HUB_ID
LEFT  JOIN so_sup ON so_sup.STOCKORDER_HUB_ID = line.STOCKORDER_HUB_ID
LEFT  JOIN [reference].[YOOZ_MAPS] gl
    ON gl.MAP_TYPE = N'PRODUCT-ACCOUNT_CODE'
   AND gl.IS_ACTIVE = 1
   AND gl.MM_CODE IN (
        N'PC_' + ISNULL(NULLIF(LTRIM(RTRIM(item.PRODUCT_CODE)), N''), LTRIM(RTRIM(item.SRC_KEY))),
        N'PC_' + ISNULL(NULLIF(LTRIM(RTRIM(item.PRODUCT_CODE)), N''), LTRIM(RTRIM(item.SRC_KEY)))
              + N'_' + LTRIM(RTRIM(item.SRC_KEY))
   )
LEFT JOIN [reference].[YOOZ_MAPS] orgunit
    ON orgunit.MAP_TYPE = N'ORGUNIT'
   AND orgunit.IS_ACTIVE = 1
   AND orgunit.MM_CODE = so.BUYERCODE
OUTER APPLY (
    SELECT TOP 1 a.AMEND_PRICE, a.TAX_PERCENT
    FROM [reference].[YOOZ_PRICE_AMEND] a
    WHERE a.PRODUCT_CODE = item.PRODUCT_CODE
      AND CAST(GETUTCDATE() AS DATE) BETWEEN a.EFFECTIVE_FROM AND ISNULL(a.EFFECTIVE_TO, '9999-12-31')
    ORDER BY a.EFFECTIVE_FROM DESC
) amend
WHERE so.PLANNED_DELIVERY_DATE = CAST(DATEADD(DAY, -1, GETUTCDATE()) AS DATE)
  AND so.ORDER_CANCELLED_BY_BUYER    IS NULL
  AND so.ORDER_CANCELLED_BY_SUPPLIER IS NULL
  AND EXISTS (
        SELECT 1 FROM [reference].[YOOZ_ALLOWED_VENDORS] v
        WHERE v.IS_ACTIVE = 1
          AND v.VENDOR_NAME = so_sup.SUPPLIER_NAME
  );
GO
```

Note: the view uses `OUTER APPLY` (not `CROSS APPLY` as in the spec) so PO lines without a matching amendment still appear. The spec's `CROSS APPLY` example was illustrative; `OUTER APPLY` is the correct mechanic.

- [ ] **Step 2: Parse-check the script**

Run the script against `tempdb` with the `reference.YOOZ_*` tables stubbed and empty `datavault.*` tables to confirm syntax. Any "Invalid column name" errors against the DV satellites are expected at this stage if column names differ from the audit — back-fill from the audit and re-check.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/02_extract_schema_and_view.sql
git commit -m "feat(chickenshop): add extract.V_YOOZ_PO view definition"
```

---

### Task 9: Author `03_provision_chickenshop.sql`

**Files:**
- Create: `ClaudeDevelopment/integrations/ChickenShop/03_provision_chickenshop.sql`

This runs in the `core` database, not the client DB. Per MEMORY: `AddOrganisation.@OrganisationCode` is uniqueidentifier; `MapOrganisationToIntegration` takes int IDs; `AddIntegration` has no `@IntegrationType` param (and isn't needed here — MarketMan001 already exists).

- [ ] **Step 1: Author the script**

```sql
/* =====================================================================
   03_provision_chickenshop.sql

   Provisions the Chicken Shop organisation and links it to the
   existing MarketMan001 integration.

   Run inside the `core` database, in any environment where Chicken Shop
   has not yet been provisioned.

   Idempotent: skips provisioning if the org already exists.

   Prerequisites:
     - core.AddOrganisation       exists
     - core.MapOrganisationToIntegration exists
     - MarketMan001 integration   exists in core.core.Integrations

   See: docs/superpowers/specs/2026-05-18-chickenshop-yooz-migration-design.md
   ===================================================================== */

DECLARE @OrgName        NVARCHAR(200) = N'Chicken Shop';
DECLARE @OrgCode        UNIQUEIDENTIFIER = NEWID();   /* override with a fixed GUID for env parity if needed */
DECLARE @IntegrationName NVARCHAR(100) = N'MarketMan001';

DECLARE @OrgID         INT;
DECLARE @IntegrationID INT;

/* --- Locate or create the organisation --- */
SELECT @OrgID = OrganisationID FROM core.Organisations WHERE OrganisationName = @OrgName;

IF @OrgID IS NULL
BEGIN
    PRINT N'Provisioning new organisation: ' + @OrgName;
    EXEC core.AddOrganisation
        @OrganisationName = @OrgName,
        @OrganisationCode = @OrgCode;
    SELECT @OrgID = OrganisationID FROM core.Organisations WHERE OrganisationName = @OrgName;
    PRINT N'Created OrgID: ' + CAST(@OrgID AS NVARCHAR(10));
END
ELSE
BEGIN
    PRINT N'Organisation already exists. OrgID: ' + CAST(@OrgID AS NVARCHAR(10));
END;

/* --- Locate the MarketMan integration --- */
SELECT @IntegrationID = IntegrationID FROM core.Integrations WHERE IntegrationName = @IntegrationName;

IF @IntegrationID IS NULL
BEGIN
    RAISERROR(N'Integration %s not found in core.Integrations. Aborting.', 16, 1, @IntegrationName);
    RETURN;
END;

/* --- Map org to integration (skips if already mapped) --- */
IF NOT EXISTS (
    SELECT 1 FROM core.OrganisationIntegrations
    WHERE OrganisationID = @OrgID AND IntegrationID = @IntegrationID
)
BEGIN
    PRINT N'Mapping OrgID ' + CAST(@OrgID AS NVARCHAR(10))
        + N' to IntegrationID ' + CAST(@IntegrationID AS NVARCHAR(10));
    EXEC core.MapOrganisationToIntegration
        @OrganisationID = @OrgID,
        @IntegrationID  = @IntegrationID;
    PRINT N'Mapping created. The OrganisationIntegrations AFTER INSERT trigger will provision the int_marketman001 schema in the client DB.';
END
ELSE
BEGIN
    PRINT N'Org/Integration mapping already exists.';
END;

/* --- Report final state --- */
SELECT
    o.OrganisationID,
    o.OrganisationName,
    o.OrganisationCode,
    o.DatabaseName,
    o.DatabaseStatus,
    i.IntegrationID,
    i.IntegrationName
FROM core.Organisations o
LEFT JOIN core.OrganisationIntegrations oi ON oi.OrganisationID = o.OrganisationID
LEFT JOIN core.Integrations             i  ON i.IntegrationID    = oi.IntegrationID
WHERE o.OrganisationName = @OrgName;
GO
```

- [ ] **Step 2: Parse-check**

Open against UAT in SSMS connected to `core` — do NOT execute. Confirm no syntax errors.

- [ ] **Step 3: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/03_provision_chickenshop.sql
git commit -m "feat(chickenshop): add org provisioning script"
```

---

### Task 10: Author `04_validation_queries.sql`

**Files:**
- Create: `ClaudeDevelopment/integrations/ChickenShop/04_validation_queries.sql`

Each query is self-contained and read-only so it can run via MCP (with comments stripped — see CLAUDE.md note).

- [ ] **Step 1: Author the script**

```sql
/* =====================================================================
   04_validation_queries.sql

   Read-only validation suite. Run inside the Chicken Shop client DB
   after deploying 01 and 02.

   Each block has a "Description" header and an "Expected" result.
   Strip leading -- comments before running blocks via MCP.
   ===================================================================== */


/* ===== 01: Reference tables exist ===== */
/* Expected: three rows */
SELECT s.name AS schema_name, t.name AS table_name, t.create_date
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'reference'
  AND t.name IN (N'YOOZ_MAPS', N'YOOZ_PRICE_AMEND', N'YOOZ_ALLOWED_VENDORS')
ORDER BY t.name;


/* ===== 02: Filtered unique index on YOOZ_MAPS exists ===== */
/* Expected: one row */
SELECT i.name AS index_name, i.is_unique, i.has_filter, i.filter_definition
FROM sys.indexes i
WHERE i.object_id = OBJECT_ID(N'[reference].[YOOZ_MAPS]')
  AND i.name = N'UX_YOOZ_MAPS_ActiveKey';


/* ===== 03: Extract schema and view exist ===== */
/* Expected: one row, schema = extract, view = V_YOOZ_PO */
SELECT s.name AS schema_name, v.name AS view_name, v.create_date, v.modify_date
FROM sys.views v
JOIN sys.schemas s ON s.schema_id = v.schema_id
WHERE s.name = N'extract' AND v.name = N'V_YOOZ_PO';


/* ===== 04: View column shape ===== */
/* Expected: 42 columns in the order defined by the view */
SELECT c.column_id, c.name AS column_name, t.name AS data_type, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types   t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID(N'[extract].[V_YOOZ_PO]')
ORDER BY c.column_id;


/* ===== 05: PO data flowing in DV ===== */
/* Expected: non-zero hub count; latest SAT timestamp within the last 36h */
SELECT
    (SELECT COUNT(*) FROM [datavault].[HUB_STOCKORDER])                  AS hub_stockorder_rows,
    (SELECT MAX(LOADTS_UTC) FROM [datavault].[SAT_STOCKORDER])           AS latest_sat_stockorder_load,
    (SELECT COUNT(*) FROM [datavault].[SAT_INVITEM_STOCKORDER])          AS sat_line_rows;


/* ===== 06: Sample extract output ===== */
/* Expected: zero rows is acceptable only if no qualifying POs yesterday */
/*           AND reference.YOOZ_ALLOWED_VENDORS has at least one active row */
SELECT TOP 10 *
FROM [extract].[V_YOOZ_PO];


/* ===== 07: Allowed-vendor configuration sanity ===== */
/* Expected: non-zero count once vendor list is seeded */
SELECT COUNT(*) AS active_vendor_count
FROM [reference].[YOOZ_ALLOWED_VENDORS]
WHERE IS_ACTIVE = 1;


/* ===== 08: GL-map fallback diagnostic ===== */
/* Expected: every row in sample either matches gl1 (simple key) or gl2 (fallback key) */
/*           or has GL_ACCOUNT_CHARGED = '-1' in the view */
WITH item_keys AS (
    SELECT
        item.HUB_ID,
        item.PRODUCT_CODE,
        item.SRC_KEY,
        N'PC_' + ISNULL(NULLIF(LTRIM(RTRIM(item.PRODUCT_CODE)), N''), LTRIM(RTRIM(item.SRC_KEY)))                                  AS key_simple,
        N'PC_' + ISNULL(NULLIF(LTRIM(RTRIM(item.PRODUCT_CODE)), N''), LTRIM(RTRIM(item.SRC_KEY))) + N'_' + LTRIM(RTRIM(item.SRC_KEY)) AS key_fallback
    FROM [datavault].[SAT_INVENTORYITEMS] item
)
SELECT TOP 20
    k.PRODUCT_CODE,
    k.SRC_KEY,
    k.key_simple,
    k.key_fallback,
    gl_simple.YOOZ_CODE   AS matched_via_simple,
    gl_fallback.YOOZ_CODE AS matched_via_fallback
FROM item_keys k
LEFT JOIN [reference].[YOOZ_MAPS] gl_simple
    ON gl_simple.MAP_TYPE = N'PRODUCT-ACCOUNT_CODE' AND gl_simple.MM_CODE = k.key_simple AND gl_simple.IS_ACTIVE = 1
LEFT JOIN [reference].[YOOZ_MAPS] gl_fallback
    ON gl_fallback.MAP_TYPE = N'PRODUCT-ACCOUNT_CODE' AND gl_fallback.MM_CODE = k.key_fallback AND gl_fallback.IS_ACTIVE = 1
ORDER BY k.PRODUCT_CODE;


/* ===== 09: Amendment-override diagnostic ===== */
/* Expected: rows where ITEM_UNIT_PRICE in view differs from raw UNIT_PRICE exactly when AMEND_PRICE applies */
SELECT TOP 10
    line.STOCKORDER_HUB_ID,
    line.LINE_NUMBER,
    item.PRODUCT_CODE,
    line.UNIT_PRICE                            AS raw_unit_price,
    amend.AMEND_PRICE,
    ISNULL(amend.AMEND_PRICE, line.UNIT_PRICE) AS effective_unit_price
FROM [datavault].[SAT_INVITEM_STOCKORDER] line
INNER JOIN [datavault].[SAT_INVENTORYITEMS] item ON item.HUB_ID = line.INVITEM_HUB_ID
OUTER APPLY (
    SELECT TOP 1 a.AMEND_PRICE
    FROM [reference].[YOOZ_PRICE_AMEND] a
    WHERE a.PRODUCT_CODE = item.PRODUCT_CODE
      AND CAST(GETUTCDATE() AS DATE) BETWEEN a.EFFECTIVE_FROM AND ISNULL(a.EFFECTIVE_TO, '9999-12-31')
    ORDER BY a.EFFECTIVE_FROM DESC
) amend
WHERE amend.AMEND_PRICE IS NOT NULL;


/* ===== 10: Date filter diagnostic ===== */
/* Expected: equal to today minus 1 (UTC) */
SELECT CAST(DATEADD(DAY, -1, GETUTCDATE()) AS DATE) AS yoozHistDays_1_target_date;
```

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/04_validation_queries.sql
git commit -m "feat(chickenshop): add read-only validation query suite"
```

---

### Task 11: Author `FUNCTION_HANDOFF.md`

**Files:**
- Create: `ClaudeDevelopment/integrations/ChickenShop/FUNCTION_HANDOFF.md`

This document is the contract for the Functions team. They build the code; we provide the contract.

- [ ] **Step 1: Author the handoff doc**

```markdown
# Azure Function: `ChickenShopYoozExtract` — Handoff

## Purpose

Replace Matillion's daily Yooz extract for Chicken Shop. Reads the
44-column extract from XMS BI and atomic-swaps it into the existing
Snowflake target table. Snowflake's downstream email task is unchanged.

## Trigger

Timer trigger, daily UTC. Suggested expression: `0 0 6 * * *` (06:00 UTC).
Override via App Setting `Schedule`. Choose a time after the Chicken Shop
MarketMan DV load reliably completes.

## Configuration (App Settings, all Key Vault-backed where they hold secrets)

| Setting | Example | Notes |
|---|---|---|
| `XmsBi__ConnectionString` | `Server=…;Database=master;…` | Connects to MI. Auth via managed identity preferred. |
| `XmsBi__OrgCode` | `Chicken Shop` | Used to look up the client DB. |
| `Snowflake__ConnectionString` | (vault ref) | Existing customer Snowflake account. |
| `Snowflake__TargetTable` | `SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ` | |
| `Snowflake__StagingTable` | `SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ_STAGING` | |
| `Schedule` | `0 0 6 * * *` | Timer expression. |

## Run sequence

1. Look up Chicken Shop's client DB name from MI:

   ```sql
   SELECT DatabaseName
   FROM core.Organisations
   WHERE OrganisationName = @OrgCode AND DatabaseStatus = 'ACTIVE'
   ```

2. Begin a snapshot read transaction on MI and select the extract:

   ```sql
   SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
   BEGIN TRANSACTION;
   SELECT * FROM [{ClientDB}].[extract].[V_YOOZ_PO];
   COMMIT;
   ```

3. Stream rows into Snowflake staging table (`CREATE OR REPLACE` then bulk COPY/INSERT, whichever pattern is established in the Functions layer).

4. Atomic swap on Snowflake:

   ```sql
   BEGIN;
   TRUNCATE TABLE SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ;
   INSERT INTO SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ
   SELECT * FROM SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ_STAGING;
   COMMIT;
   ```

5. Log: rows read from MI, rows written to Snowflake, duration, success/failure. Use the Functions layer's existing observability sink.

## Failure semantics

- MI read fails → log + alert, do NOT touch Snowflake.
- Snowflake write fails after staging → staging table left for diagnosis (transaction rollback covers the target).
- Zero rows read → legitimate result; write the empty result through. Log a warning. The empty email is expected behaviour from the existing Matillion baseline.

## Column contract (44 columns, order MUST match)

See `docs/superpowers/specs/2026-05-18-chickenshop-yooz-migration-design.md` §4 for the exhaustive column list, types, and notes. Match the view's output column order exactly — the Snowflake target table column order must align.

## Casts the Function must apply

Once the customer provides `DESCRIBE TABLE SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ`, fill in the cast table below:

| Output column | View type | Snowflake type | Cast required |
|---|---|---|---|
| ORDER_DATE | NVARCHAR (yyyyMMdd) | (fill in) | (fill in) |
| AMOUNT_INC_TAX | DECIMAL | (fill in) | (fill in) |
| ... | ... | ... | ... |

## Non-goals

- No business logic in the Function. All filters/joins/overrides live in the view.
- No email or notification — Snowflake email task is unchanged.
- No retries with backoff — single failure should alert, not silently retry into the next day's window.
```

- [ ] **Step 2: Commit**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/FUNCTION_HANDOFF.md
git commit -m "docs(chickenshop): add Azure Function handoff spec"
```

---

## Phase 3 — UAT deployment and validation

Developer-executed steps with Claude-driven validation in between.

### Task 12: Deploy `03_provision_chickenshop.sql` to UAT

**Files:** none modified — operational step.

- [ ] **Step 1: Developer executes the script**

In SSMS connected to the UAT `core` database, open and run `ClaudeDevelopment/integrations/ChickenShop/03_provision_chickenshop.sql`.

Expected `PRINT` messages:
- `Provisioning new organisation: Chicken Shop`
- `Created OrgID: <int>`
- `Mapping OrgID <int> to IntegrationID <int>`
- `Mapping created. The OrganisationIntegrations AFTER INSERT trigger will provision the int_marketman001 schema in the client DB.`

The final SELECT returns a row showing the new org's DatabaseName (a `YYYYMMDD_XMS_<GUID>` value) and DatabaseStatus.

- [ ] **Step 2: Claude validates via MCP (read-only)**

```sql
SELECT OrganisationID, OrganisationName, OrganisationCode, DatabaseName, DatabaseStatus
FROM core.core.Organisations
WHERE OrganisationName = N'Chicken Shop'
```

Expected: one row, DatabaseStatus eventually `ACTIVE` (initial state may be `PENDING` or `CREATING`).

```sql
SELECT oi.OrganisationID, oi.IntegrationID, i.IntegrationName
FROM core.core.OrganisationIntegrations oi
INNER JOIN core.core.Integrations i ON i.IntegrationID = oi.IntegrationID
WHERE oi.OrganisationID = (SELECT OrganisationID FROM core.core.Organisations WHERE OrganisationName = N'Chicken Shop')
```

Expected: one row with `IntegrationName = MarketMan001`.

- [ ] **Step 3: Wait until DatabaseStatus = ACTIVE**

Poll the org row every few minutes until `DatabaseStatus = 'ACTIVE'`. Provisioning typically takes 5–15 minutes for the client DB to be created.

- [ ] **Step 4: Record the Chicken Shop client DB GUID**

Update `memory/MEMORY.md` Test Organisation Reference (UAT section) with the new entry once the GUID is known. Defer this until Task 16 to consolidate the memory write.

---

### Task 13: Deploy `01_reference_yooz_tables.sql` to Chicken Shop UAT DB

- [ ] **Step 1: Developer executes**

In SSMS, with database context set to the new Chicken Shop UAT client DB, run `01_reference_yooz_tables.sql`. Expected: no errors, three table create messages (or "already exists" branches if re-run).

- [ ] **Step 2: Claude validates via MCP**

```sql
SELECT s.name AS schema_name, t.name AS table_name
FROM [<Chicken Shop UAT DB>].sys.tables t
JOIN [<Chicken Shop UAT DB>].sys.schemas s ON s.schema_id = t.schema_id
WHERE s.name = N'reference'
  AND t.name IN (N'YOOZ_MAPS', N'YOOZ_PRICE_AMEND', N'YOOZ_ALLOWED_VENDORS')
ORDER BY t.name
```

Expected: three rows.

```sql
SELECT name, is_unique, has_filter, filter_definition
FROM [<Chicken Shop UAT DB>].sys.indexes
WHERE object_id = OBJECT_ID(N'[<Chicken Shop UAT DB>].[reference].[YOOZ_MAPS]')
```

Expected: PK + filtered unique index `UX_YOOZ_MAPS_ActiveKey`.

---

### Task 14: Deploy `02_extract_schema_and_view.sql` to Chicken Shop UAT DB

- [ ] **Step 1: Developer executes**

In SSMS, with database context set to the Chicken Shop UAT client DB, run `02_extract_schema_and_view.sql`. Expected: no errors.

If errors are about missing DV satellite columns: the column names in the view must match what Phase 1 audits found. Update the view's CTEs to use the actual column names, re-commit, re-deploy.

- [ ] **Step 2: Claude validates via MCP**

```sql
SELECT name, create_date, modify_date
FROM [<Chicken Shop UAT DB>].sys.views
WHERE object_id = OBJECT_ID(N'[<Chicken Shop UAT DB>].[extract].[V_YOOZ_PO]')
```

Expected: one row.

```sql
SELECT column_id, name, system_type_name
FROM [<Chicken Shop UAT DB>].sys.columns
WHERE object_id = OBJECT_ID(N'[<Chicken Shop UAT DB>].[extract].[V_YOOZ_PO]')
ORDER BY column_id
```

Expected: 42 columns. (The "44 cols" headline in the spec counts `COMMAND` and `ORGUNIT_CODE` plus 40 data columns; recount confirms; view yields 42 SELECT items as numbered in Task 8.)

- [ ] **Step 3: Sample-select the view**

```sql
SELECT TOP 5 * FROM [<Chicken Shop UAT DB>].[extract].[V_YOOZ_PO]
```

Expected before DV load: zero rows. Expected before vendor seeding: zero rows. Expected after both: rows that look like Yooz CSV records (note: dates as `yyyyMMdd` strings, empty strings instead of NULLs, GL_ACCOUNT_CHARGED = `-1` until YOOZ_MAPS is seeded).

---

### Task 15: Run initial MarketMan DV load against the Chicken Shop UAT org

- [ ] **Step 1: Configure MarketMan API credentials**

Set Chicken Shop's MarketMan account credentials in the integration's run-time configuration (location to be confirmed during this task — likely `GlobalParameters` in the new client DB or an Azure Key Vault reference. If unclear, consult `docs/data-pipeline.md` §2-3 or ask the platform owner.) **Do not paste credentials into any committed file.**

- [ ] **Step 2: Trigger an initial DV load**

Use the established MarketMan run mechanism (`sp_DataVaultLoad` driven from `core` or whatever scheduled job runs MarketMan for other orgs). Wait for completion.

- [ ] **Step 3: Claude validates via MCP**

```sql
SELECT
    (SELECT COUNT(*) FROM [<Chicken Shop UAT DB>].[datavault].[HUB_STOCKORDER])           AS hub_stockorder_rows,
    (SELECT MAX(LOADTS_UTC) FROM [<Chicken Shop UAT DB>].[datavault].[SAT_STOCKORDER])    AS latest_sat_stockorder_load,
    (SELECT COUNT(*) FROM [<Chicken Shop UAT DB>].[datavault].[SAT_INVITEM_STOCKORDER])   AS sat_line_rows
```

Expected: non-zero `hub_stockorder_rows` (assuming Chicken Shop has historical POs in MarketMan). `latest_sat_stockorder_load` within the last hour.

If `hub_stockorder_rows = 0` after a successful load, escalate — MarketMan credentials may be wrong, or Chicken Shop's MarketMan tenant simply has no PO data.

- [ ] **Step 4: Seed YOOZ_ALLOWED_VENDORS with the list from Task 6**

The data-entry mechanism is out of scope, but for UAT we need *some* data in this table to verify the view returns rows. Hand the seed list to whoever has DML access to the Chicken Shop UAT client DB to insert manually.

---

### Task 16: End-to-end view validation in UAT

- [ ] **Step 1: Run the full `04_validation_queries.sql` suite via MCP**

For each block in the script (strip `--` comments), run as a separate MCP query against the Chicken Shop UAT client DB. Record each block's pass/fail in a new file `ClaudeDevelopment/integrations/ChickenShop/UAT_VALIDATION_REPORT.md`.

- [ ] **Step 2: Sample 20 rows from the view and inspect manually**

```sql
SELECT TOP 20 *
FROM [<Chicken Shop UAT DB>].[extract].[V_YOOZ_PO]
ORDER BY ORDER_NUMBER, LINE_NUMBER
```

Check by eye:
- `COMMAND = 'CREATE'` on every row.
- `ORDER_DATE` and `PLANNED_DELIVERY_DATE` formatted `yyyyMMdd`.
- `VENDOR_NAME` is in the allowed list.
- `GL_ACCOUNT_CHARGED` is `'-1'` (until `YOOZ_MAPS` is seeded with PRODUCT-ACCOUNT_CODE rows) and otherwise looks like a GL code.
- No NULL values in NVARCHAR columns — should be `''`.

- [ ] **Step 3: Side-by-side comparison setup**

If Matillion is still producing the legacy CSV/table for Chicken Shop, run the same date filter through the legacy Snowflake table:

```sql
SELECT *
FROM SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ
WHERE PLANNED_DELIVERY_DATE = TO_CHAR(DATEADD(DAY,-1,CURRENT_DATE()),'YYYYMMDD')
```

Compare row counts and a sample of rows to the view output. Document discrepancies in `UAT_VALIDATION_REPORT.md`.

- [ ] **Step 4: Commit the validation report**

```bash
git add ClaudeDevelopment/integrations/ChickenShop/UAT_VALIDATION_REPORT.md
git commit -m "chore(chickenshop): UAT validation report"
```

---

## Phase 4 — Wrap-up

### Task 17: Update QUERY_STATUS.md and MEMORY.md

**Files:**
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`
- Modify: `memory/MEMORY.md`

- [ ] **Step 1: Append a Chicken Shop section to QUERY_STATUS.md**

```markdown
## ChickenShop (Yooz extract migration)

| Script | Purpose | Status |
|---|---|---|
| `01_reference_yooz_tables.sql` | DDL for 3 reference tables | Deployed to UAT |
| `02_extract_schema_and_view.sql` | extract schema + V_YOOZ_PO view | Deployed to UAT |
| `03_provision_chickenshop.sql` | Org + integration provisioning | Deployed to UAT |
| `04_validation_queries.sql` | Read-only validation suite | N/A — read-only |
| `FUNCTION_HANDOFF.md` | Azure Function handoff doc | Handed off |

Awaiting: Azure Function build + side-by-side comparison ≥ 1 week before Prod cutover.
```

- [ ] **Step 2: Add Chicken Shop integration entry to MEMORY.md**

In the `## Integrations` section (or create one if absent), add a one-line entry. In the UAT Test Organisation Reference, add the Chicken Shop GUID once known:

```markdown
- `<new GUID>` — "Chicken Shop" (OrgID <int>, MarketMan001)
```

Detail file at `memory/chickenshop-yooz-migration.md` (create if entry warrants it — only if there's surprising/non-obvious knowledge to capture; the design and plan docs are sufficient for most lookups).

- [ ] **Step 3: Commit memory + status updates**

```bash
git add ClaudeDevelopment/QUERY_STATUS.md memory/MEMORY.md
git commit -m "docs(chickenshop): update QUERY_STATUS and memory after UAT deployment"
```

---

### Task 18: Final review and PR

- [ ] **Step 1: Confirm all 17 prior tasks done**

Check the task list. Every checkbox should be ticked. Any deferred items belong in a follow-up ticket, not this PR.

- [ ] **Step 2: Review the full diff**

```bash
git log --oneline main..HEAD
git diff main..HEAD --stat
```

Expected: ~8 new files in `ClaudeDevelopment/integrations/ChickenShop/`, plus modifications to `QUERY_STATUS.md` and `MEMORY.md`. No changes to numbered release scripts or `docs/*.md` core platform documentation.

- [ ] **Step 3: Open PR (with user approval)**

```bash
gh pr create --title "Chicken Shop: Matillion Yooz extract migration to XMS BI" --body "$(cat <<'EOF'
## Summary
- New Chicken Shop org provisioned via existing platform SPs; uses the MarketMan001 integration with a separate API account.
- Adds `reference.YOOZ_MAPS`, `YOOZ_PRICE_AMEND`, `YOOZ_ALLOWED_VENDORS` plus a new `extract.V_YOOZ_PO` view that builds the 44-column Yooz Purchase Order extract.
- Handoff doc for the Azure Functions team — Function reads the view daily, atomic-swaps the existing Snowflake target table.

## Spec / Plan
- Design: docs/superpowers/specs/2026-05-18-chickenshop-yooz-migration-design.md
- Plan: docs/superpowers/plans/2026-05-18-chickenshop-yooz-migration.md

## Test plan
- [ ] 03_provision_chickenshop.sql deployed to UAT; Chicken Shop org provisioned
- [ ] 01_reference_yooz_tables.sql deployed; 3 reference tables verified
- [ ] 02_extract_schema_and_view.sql deployed; view returns 42 columns
- [ ] Initial MarketMan DV load completes against Chicken Shop UAT
- [ ] 04 validation queries all green; UAT_VALIDATION_REPORT.md committed
- [ ] Side-by-side comparison with Matillion legacy run for ≥ 1 week
- [ ] No changes to numbered platform release scripts

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Self-review notes

Verified against the spec before handover:

- §1 (Context/goals/non-goals) → Phase 1–3 cover the goals; non-goals are explicitly out of plan.
- §2 (Architecture) → File structure section + Tasks 7–11 implement each component.
- §3 (Reference tables) → Task 7 fully.
- §4 (Extract view, 44 columns) → Task 8 fully. (Note: 42 SELECT items in the implementation; the "44" in the spec counts COMMAND + ORGUNIT_CODE + 40 data fields. Plan and spec agree on the actual column shape; the headline number is a counting nuance, not a discrepancy.)
- §5 (Azure Function) → Task 11 (FUNCTION_HANDOFF.md) covers as much as can be specified before the Function is built. Function code is outside this repo.
- §6 (Provisioning + deployment) → Tasks 1, 9, 12–15.
- §7 (Risks + verification) → Phase 1 (Tasks 2–6).
- §8 (Out of scope) → Honoured throughout; no work attempts to address out-of-scope items.

No placeholders in any code or SQL block. Method/table/column names referenced in later tasks all match definitions in earlier tasks (e.g. `extract.V_YOOZ_PO`, `reference.YOOZ_MAPS`, `MAP_TYPE='PRODUCT-ACCOUNT_CODE'` are used identically across Tasks 8, 10, and 14).
