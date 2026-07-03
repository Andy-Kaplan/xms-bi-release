# Mews001 DV Mapping Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate `core.int_mews001.StagingControl` (17 staging steps) and `core.int_mews001.EntityMappings` (25 mappings) so Mews POS data in DEV org 19 flows DL → stage → load → datavault → presentation.

**Architecture:** Config-driven, following the Growyze/NCRAloha precedent: MERGE-upsert scripts populate the two control tables; `UploadEntityMappings` generates the Load-type steps from the mappings; `sp_DataVaultLoad` executes everything. No DDL, no new DV entities — all 13 target entities are Live with tables already deployed in org 19.

**Tech Stack:** T-SQL (SQL Server Managed Instance), MCP read-only testing (`mcp__xms-bi-dev__query`), developer-executed deployment via SSMS.

**Spec:** `docs/superpowers/specs/2026-07-03-mews-dv-mapping-design.md` (amended: link mappings source Tier-1 staging tables directly per Growyze precedent, so counts are 17 steps / 25 mappings, not 21/28).

## Global Constraints

- All new `.sql` files go in `ClaudeDevelopment/integrations/Mews/` — Claude must never edit `.sql` outside `ClaudeDevelopment/`.
- Scripts use **unqualified two-part names** (`[int_mews001].[DL_ORDERS]`, `[stage].[MEWS_X]`) — never a client DB name. Three-part names are for MCP test queries ONLY.
- Every control-table write is a **MERGE upsert** on the natural key (`step_name` for StagingControl; `entity_name + source_table` for EntityMappings). Never bare INSERT. Omit the `id` column (DEFAULT NEWID()).
- `MICROSERVICE_NAME` / `MICROSERVICE_ID` = `NULL` in all staging output (MDM layer, manual entry only).
- Booleans in DL tables are `'0'`/`'1'` strings; several are NULL — filters use the tolerant form `COALESCE(col, '1') <> '0'`.
- Timestamps are ISO 8601 with `Z` (`2026-06-29T00:31:10.909Z`) — parse ONLY with `TRY_CONVERT(DATETIME2, col, 127)` (explicit style; never bare CAST/CONVERT for dates).
- Amounts are string decimals (`"10.50"`) — `CAST(col AS DECIMAL(18,2))`, no division.
- MCP: run from `database = 'core'`, prefix all org tables `[20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].`, strip ALL SQL comments before running. DEV MCP is off after 8pm.
- Commit after each task with `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.

## Testing Method (used by every task)

**Pre-deployment MCP simulation (the "failing test" analogue).** For each staging step, before the MERGE goes in the script:

1. Take the step's inner SELECT (the part inside `SELECT * INTO [stage].[X] FROM ( ... ) AS source_query`).
2. Prefix every `[int_mews001].[DL_*]` reference with the org DB: `[20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_*]`. Strip comments.
3. Run via `mcp__xms-bi-dev__query` (database `core`). Wrap in `SELECT COUNT(*) AS n FROM ( ... ) q` for count checks, or run raw for shape checks.
4. Compare to the **Expected** stated in the step. A mismatch means the query is wrong — fix before scripting. Expected counts are as-of 2026-07-03 data; if the fetcher has landed more data, re-derive with the companion DL-side count query given in the step.

**Post-deployment verification** is Task 7: developer deploys and runs the load; the agent verifies stage/DV/presentation row counts via MCP using `04_verification.sql`'s queries.

**Embedding rule:** the runnable SQL shown in each step is the *test form*. To embed it in the MERGE's `query_sql = N'...'` literal: collapse to a single line and double every single quote (`'PROD'` → `''PROD''`). The MERGE's WHEN MATCHED and WHEN NOT MATCHED branches must carry **identical** values. Reference example of the exact house style: `ClaudeDevelopment/integrations/Growyze/02_staging_tier1.sql`.

**MERGE wrapper template** (identical for all 17 staging steps — substitute the five `{...}` values from each step's spec block; this is the complete wrapper, nothing else varies):

```sql
-- Step {N}: {step_name}
MERGE INTO [core].[int_mews001].[StagingControl] AS tgt
USING (VALUES (N'{step_name}')) AS src (step_name)
ON tgt.step_name = src.step_name
WHEN MATCHED THEN
    UPDATE SET
        staging_table    = N'{staging_table}',
        query_sql        = N'{query_sql single-line, quotes doubled}',
        tier             = {tier},
        step_type        = N'Staging',
        exclude          = 0,
        description      = N'{description}',
        depends_on_steps = {depends_on_steps},
        retry_count      = 3,
        timeout_minutes  = 30,
        staging_columns  = N'{staging_columns JSON}',
        updated_at       = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (step_name, staging_table, query_sql, tier, step_type, exclude,
            description, depends_on_steps, retry_count, timeout_minutes,
            staging_columns, created_at, updated_at)
    VALUES (N'{step_name}', N'{staging_table}',
            N'{query_sql single-line, quotes doubled}',
            {tier}, N'Staging', 0,
            N'{description}',
            {depends_on_steps}, 3, 30,
            N'{staging_columns JSON}',
            GETDATE(), GETDATE());
GO
```

---

### Task 1: Scaffold + dimension staging steps (1–8)

**Files:**
- Create: `ClaudeDevelopment/integrations/Mews/01_staging_control.sql`

**Interfaces:**
- Produces: `stage.MEWS_LOCATION`, `stage.MEWS_PRODUCT`, `stage.MEWS_MOD`, `stage.MEWS_TAX`, `stage.MEWS_TENDER`, `stage.MEWS_DISCOUNT`, `stage.MEWS_CHANNEL`, `stage.MEWS_REVCENTER` staging-step definitions. Key columns later tasks rely on: `MEWS_PRODUCT.HUB_ID` values are variant ids, product ids, `{productId}-DEFAULT` synthetics, and type ids; `MEWS_TAX.HUB_ID` is the tax id.

- [ ] **Step 1.1: MCP-verify the Location query**

Run via `mcp__xms-bi-dev__query` (database `core`; this is the inner SELECT of the step, org-prefixed):

```sql
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_OUTLETS] )
SELECT id AS HUB_ID, name AS LOCATION_NAME, id AS LOCATION_ID, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1
```

Expected: **2 rows**, distinct HUB_IDs, non-null LOCATION_NAMEs.

- [ ] **Step 1.2: Write `01_staging_control.sql` header + Step 1 (Mews Location)**

File header comment: purpose, target table `[core].[int_mews001].[StagingControl]`, date, spec path. Then the MERGE (template above) with:

| Field | Value |
|---|---|
| step_name | `Mews Location` |
| staging_table | `MEWS_LOCATION` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages Mews outlets as single-level location dimension` |
| staging_columns | `["HUB_ID", "LOCATION_NAME", "LOCATION_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]` |

query_sql (test form; embed per the embedding rule):

```sql
IF OBJECT_ID('stage.MEWS_LOCATION', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_LOCATION];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_OUTLETS] )
SELECT * INTO [stage].[MEWS_LOCATION] FROM (
SELECT id AS HUB_ID, name AS LOCATION_NAME, id AS LOCATION_ID, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1 ) AS source_query;
```

- [ ] **Step 1.3: MCP-verify the Product hierarchy query**

```sql
WITH prod AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_PRODUCTS] ),
var AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_PRODUCT_VARIANTS] ),
typ AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_PRODUCT_TYPES] )
SELECT LEVEL_NAME, COUNT(*) AS n FROM (
SELECT t.id AS HUB_ID, t.name AS PRODUCT_NAME, NULL AS PARENT_ID, 'TOP' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, t.id AS PRODUCT_ID, NULL AS ATTR_1, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM typ t WHERE t.rn = 1
UNION ALL
SELECT p.id, p.name, p.productTypeId, 'MIDDLE_1', 0, p.id, p.sku, NULL, NULL FROM prod p WHERE p.rn = 1 AND (p.status <> 'inactive' OR p.status IS NULL)
UNION ALL
SELECT CONCAT(p.id, '-DEFAULT'), p.name, p.id, 'BOTTOM', 1, CONCAT(p.id, '-DEFAULT'), p.sku, NULL, NULL FROM prod p WHERE p.rn = 1 AND (p.status <> 'inactive' OR p.status IS NULL)
UNION ALL
SELECT v.id, COALESCE(NULLIF(v.selector, ''), NULLIF(v.sku, ''), CONCAT(p.name, ' @ ', v.retailPriceInclTax)), v.productId, 'BOTTOM', 1, v.id, v.sku, NULL, NULL
FROM var v INNER JOIN prod p ON p.id = v.productId AND p.rn = 1
WHERE v.rn = 1 AND (p.status <> 'inactive' OR p.status IS NULL)
) q GROUP BY LEVEL_NAME
```

Expected: TOP = **12**, MIDDLE_1 = **98**, BOTTOM = **279** (181 variants + 98 `-DEFAULT` synthetics). All products are `status='active'` as of 2026-07-03. Variant names synthesize as `{product name} @ {price}` because selector/sku/barcode are all NULL in landed data (flag this to the fetcher team as a data-quality gap — the Mews API has variant names the flattener isn't capturing).

- [ ] **Step 1.4: Add Step 2 (Mews Product) to the script**

| Field | Value |
|---|---|
| step_name | `Mews Product` |
| staging_table | `MEWS_PRODUCT` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages 3-tier product hierarchy: types=TOP, products=MIDDLE_1, variants + synthetic {productId}-DEFAULT rows=BOTTOM. Line items key on COALESCE(variantId, productId-DEFAULT).` |
| staging_columns | `["HUB_ID", "PRODUCT_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "PRODUCT_ID", "ATTR_1", "MICROSERVICE_NAME", "MICROSERVICE_ID"]` |

query_sql = the Step 1.3 query without the `COUNT/GROUP BY` wrapper, with unqualified `[int_mews001]` names, wrapped in `IF OBJECT_ID('stage.MEWS_PRODUCT', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_PRODUCT]; ... SELECT * INTO [stage].[MEWS_PRODUCT] FROM ( <the 4-part UNION> ) AS source_query;`

- [ ] **Step 1.5: MCP-verify + add Steps 3–8 (six small dimensions)**

For each: run the inner SELECT org-prefixed via MCP, confirm the Expected, then append the MERGE. All are tier 1, depends_on_steps NULL.

**Step 3 — `Mews Modifier` → `MEWS_MOD`** — Expected: **0 rows** (source tables empty; query must still parse — MCP returns empty set, not an error).

```sql
IF OBJECT_ID('stage.MEWS_MOD', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_MOD];
WITH sets AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_MODIFIER_SETS] ),
mods AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_MODIFIERS] )
SELECT * INTO [stage].[MEWS_MOD] FROM (
SELECT s.id AS HUB_ID, s.name AS MOD_NAME, NULL AS PARENT_ID, 'TOP' AS LEVEL_NAME, 0 AS BOTTOM_LEVEL, s.id AS MOD_ID, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID FROM sets s WHERE s.rn = 1
UNION ALL
SELECT m.id, m.name, m.modifierSetId, 'BOTTOM', 1, m.id, NULL, NULL FROM mods m WHERE m.rn = 1
) AS source_query;
```
staging_columns: `["HUB_ID", "MOD_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MOD_ID", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`
description: `Stages 2-level modifier hierarchy (sets=TOP, modifiers=BOTTOM); empty until modifier data lands`

**Step 4 — `Mews Tax` → `MEWS_TAX`** — Expected: **1 row**, TAX_NAME `VAT`, TAX_MULTIPLIER `0.200000`. Note `rate` is already a multiplier (0.2) — no `/100`; DL_TAXES has NO isActive/ratePercent columns.

```sql
IF OBJECT_ID('stage.MEWS_TAX', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_TAX];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_TAXES] )
SELECT * INTO [stage].[MEWS_TAX] FROM (
SELECT id AS HUB_ID, name AS TAX_NAME, id AS TAX_ID, CAST(rate AS DECIMAL(18,6)) AS TAX_MULTIPLIER, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1 ) AS source_query;
```
staging_columns: `["HUB_ID", "TAX_NAME", "TAX_ID", "TAX_MULTIPLIER", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`
description: `Stages Mews tax profiles; rate column is already a decimal multiplier`

**Step 5 — `Mews Tender` → `MEWS_TENDER`** — Expected: **6 rows**. DL_PAYMENT_METHODS has only id/name/active and `active` is NULL on all rows — the tolerant filter keeps them.

```sql
IF OBJECT_ID('stage.MEWS_TENDER', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_TENDER];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PAYMENT_METHODS] )
SELECT * INTO [stage].[MEWS_TENDER] FROM (
SELECT id AS HUB_ID, name AS TENDER_NAME, id AS TENDER_ID, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1 AND COALESCE(active, '1') <> '0' ) AS source_query;
```
staging_columns: `["HUB_ID", "TENDER_NAME", "TENDER_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`
description: `Stages Mews payment methods as tender dimension (no tender line items yet - DL_ORDER_PAYMENTS not landed)`

**Step 6 — `Mews Discount` → `MEWS_DISCOUNT`** — Expected: **2 rows**, both active.

```sql
IF OBJECT_ID('stage.MEWS_DISCOUNT', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_PROMO_CODES] )
SELECT * INTO [stage].[MEWS_DISCOUNT] FROM (
SELECT id AS HUB_ID, COALESCE(NULLIF(description, ''), code) AS DISCOUNT_NAME, id AS DISCOUNT_ID, discountType AS VALUE_TYPE, CAST(amount AS DECIMAL(18,2)) AS [VALUE], 0 AS IS_WASTE, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1 AND COALESCE(active, '1') <> '0' ) AS source_query;
```
staging_columns: `["HUB_ID", "DISCOUNT_NAME", "DISCOUNT_ID", "VALUE_TYPE", "VALUE", "IS_WASTE", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`
description: `Stages Mews promo codes as discount dimension`

**Step 7 — `Mews Channel` → `MEWS_CHANNEL`** — Expected: **2 rows** (areas). Hub-only: no order→table→area path exists, so CHANNEL_CUSTORDER link is deferred.

```sql
IF OBJECT_ID('stage.MEWS_CHANNEL', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_CHANNEL];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_AREAS] )
SELECT * INTO [stage].[MEWS_CHANNEL] FROM (
SELECT id AS HUB_ID, name AS CHANNEL_NAME, id AS CHANNEL_ID, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1 AND COALESCE(isActive, '1') <> '0' ) AS source_query;
```
staging_columns: `["HUB_ID", "CHANNEL_NAME", "CHANNEL_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`
description: `Stages Mews dining areas as channel dimension (hub only - no order-to-area path in landed data)`

**Step 8 — `Mews Revenue Center` → `MEWS_REVCENTER`** — Expected: **0 rows** (table empty; query must parse).

```sql
IF OBJECT_ID('stage.MEWS_REVCENTER', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_REVCENTER];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REVENUE_CENTERS] )
SELECT * INTO [stage].[MEWS_REVCENTER] FROM (
SELECT id AS HUB_ID, name AS REVC_NAME, id AS REVC_ID, NULL AS PARENT_ID, 'BOTTOM' AS LEVEL_NAME, 1 AS BOTTOM_LEVEL, NULL AS MICROSERVICE_NAME, NULL AS MICROSERVICE_ID
FROM deduped WHERE rn = 1 AND COALESCE(isActive, '1') <> '0' ) AS source_query;
```
staging_columns: `["HUB_ID", "REVC_NAME", "REVC_ID", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID"]`
description: `Stages Mews revenue centers; empty until revenue center data lands`

- [ ] **Step 1.6: Commit**

```bash
git add "ClaudeDevelopment/integrations/Mews/01_staging_control.sql"
git commit -m "feat(mews): add dimension staging steps 1-8 to StagingControl script"
```

---

### Task 2: Transactional staging steps (9–12)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Mews/01_staging_control.sql` (append)

**Interfaces:**
- Consumes: nothing from Task 1 at runtime (all read DL tables).
- Produces: `MEWS_CUSTORDER` (key `HEADER_ID` = `{outletId}-{invoiceId}`, carries `LOCATION_KEY`), `MEWS_LINEITEM` (key `SRC_KEY` = `{outletId}-{invoiceId}-{itemId}-PROD`, carries `HEADER_ID`, `PRODUCT_KEY`), `MEWS_LINEITEM_TAX` (key `SRC_KEY` `...-TAX`, carries `TAX_KEY`), `MEWS_LINEITEM_DISCOUNT` (key `SRC_KEY` `...-DISCOUNT`, carries `DISCOUNT_KEY`, may be NULL). Task 3's Tier-2 step and Tasks 4–5's mappings use these exact column names.

- [ ] **Step 2.1: MCP-verify the Customer Order query**

Org-prefix the DL references and run:

```sql
WITH inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_INVOICES] ),
ord AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_ORDERS] ),
reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_REGISTERS] ),
itm AS ( SELECT invoiceId, COUNT(*) AS ITEM_COUNT FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_INVOICE_ITEMS] ) d WHERE d.rn = 1 GROUP BY invoiceId )
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN HEADER_ID IS NULL THEN 1 ELSE 0 END) AS null_header,
       SUM(CASE WHEN OPEN_TIME IS NULL THEN 1 ELSE 0 END) AS null_open,
       SUM(CASE WHEN CLOSE_TIME IS NULL THEN 1 ELSE 0 END) AS null_close,
       SUM(CASE WHEN ORDER_DATE IS NULL THEN 1 ELSE 0 END) AS null_order_date,
       SUM(GRAND_TOTAL) AS sum_grand_total
FROM (
SELECT CONCAT_WS('-', reg.outletId, inv.id) AS HEADER_ID,
       CAST(inv.total AS DECIMAL(18,2)) AS GRAND_TOTAL,
       CAST(inv.subtotal AS DECIMAL(18,2)) AS GROSS_SALES,
       CAST(inv.tax AS DECIMAL(18,2)) AS TAX_TOTAL,
       CAST(COALESCE(NULLIF(inv.discountAmount, ''), '0') AS DECIMAL(18,2)) AS DISCOUNT_GROSS,
       CAST(inv.subtotal AS DECIMAL(18,2)) - CAST(COALESCE(NULLIF(inv.discountAmount, ''), '0') AS DECIMAL(18,2)) AS NET_SALES,
       TRY_CAST(ord.covers AS INT) AS GUEST_COUNT,
       itm.ITEM_COUNT AS ITEM_COUNT,
       1 AS ORDER_COUNT,
       TRY_CONVERT(DATETIME2, ord.createdAt, 127) AS OPEN_TIME,
       TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS CLOSE_TIME,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE,
       NULL AS TABLE_NO,
       ord.notes AS ORDER_INFO,
       ord.bookingId AS EXTERNAL_REFERENCE,
       ord.state AS ORDER_STATUS,
       CASE WHEN inv.cancelled = '1' THEN 'CANCELLED' ELSE 'PAID' END AS PAYMENT_STATUS,
       reg.outletId AS LOCATION_KEY
FROM inv
LEFT JOIN ord ON ord.id = inv.orderId AND ord.rn = 1
LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1
LEFT JOIN itm ON itm.invoiceId = inv.id
WHERE inv.rn = 1 AND COALESCE(inv.cancelled, '0') <> '1'
) q
```

Expected: total_rows = **19**, all null_* columns = **0** (a non-zero null_open/null_close means the style-127 parse failed — stop and investigate), sum_grand_total > 0. Companion DL-side check: `SELECT COUNT(*) FROM <org>.[int_mews001].[DL_INVOICES] WHERE COALESCE(cancelled,'0') <> '1'` must equal total_rows.

- [ ] **Step 2.2: Add Step 9 (Mews Customer Order)**

| Field | Value |
|---|---|
| step_name | `Mews Customer Order` |
| staging_table | `MEWS_CUSTORDER` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages invoices joined to orders and registers as customer orders. Invoice is the financial source; order supplies covers/state; register resolves outlet.` |
| staging_columns | `["HEADER_ID", "GRAND_TOTAL", "GROSS_SALES", "TAX_TOTAL", "DISCOUNT_GROSS", "NET_SALES", "GUEST_COUNT", "ITEM_COUNT", "ORDER_COUNT", "OPEN_TIME", "CLOSE_TIME", "ORDER_DATE", "TRADING_DATE", "TABLE_NO", "ORDER_INFO", "EXTERNAL_REFERENCE", "ORDER_STATUS", "PAYMENT_STATUS", "LOCATION_KEY"]` |

query_sql = the Step 2.1 inner query (without the COUNT wrapper), unqualified names, wrapped in `IF OBJECT_ID('stage.MEWS_CUSTORDER', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTORDER]; ... SELECT * INTO [stage].[MEWS_CUSTORDER] FROM ( ... ) AS source_query;`

- [ ] **Step 2.3: MCP-verify the PROD line item query**

```sql
WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_INVOICE_ITEMS] ),
inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_INVOICES] ),
reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_REGISTERS] )
SELECT COUNT(*) AS total_rows,
       SUM(CAST(VOID_FLAG AS INT)) AS void_rows,
       SUM(CASE WHEN LINEITEM_TIMESTAMP IS NULL THEN 1 ELSE 0 END) AS null_timestamp,
       COUNT(DISTINCT PRODUCT_KEY) AS distinct_products
FROM (
SELECT CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'PROD') AS SRC_KEY,
       CONCAT_WS('-', reg.outletId, ii.invoiceId) AS HEADER_ID,
       'PROD' AS LINEITEM_TYPE,
       CAST(ii.total AS DECIMAL(18,2)) AS GROSS_VALUE,
       CAST(ii.tax AS DECIMAL(18,2)) AS TAX_VALUE,
       CAST(ii.subtotal AS DECIMAL(18,2)) AS NET_VALUE,
       CAST(ii.quantity AS DECIMAL(18,4)) AS QUANTITY,
       CASE WHEN ii.isVoid = '1' OR ii.isComp = '1' THEN 1 ELSE 0 END AS VOID_FLAG,
       TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP,
       CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE,
       ii.id AS LINE_ID,
       ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER,
       COALESCE(ii.productVariantId, CONCAT(ii.productId, '-DEFAULT')) AS PRODUCT_KEY
FROM ii
INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1
LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1
WHERE ii.rn = 1 AND COALESCE(inv.cancelled, '0') <> '1'
) q
```

Expected: total_rows = **22**; **null_timestamp = 0 (HARD GATE — NULL LINEITEM_TIMESTAMP silently voids F_LINEITEM_15MIN)**; void_rows = count of comp/void items (2 as of 2026-07-03 — cross-check: `SELECT COUNT(*) FROM <org>.[int_mews001].[DL_INVOICE_ITEMS] WHERE isComp = '1' OR isVoid = '1'`).

- [ ] **Step 2.4: Add Step 10 (Mews Line Item)**

| Field | Value |
|---|---|
| step_name | `Mews Line Item` |
| staging_table | `MEWS_LINEITEM` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages invoice items as PROD line items. PRODUCT_KEY = COALESCE(variantId, productId-DEFAULT) resolving 100% of lines to a BOTTOM product member. LINEITEM_TIMESTAMP from item createdAt (must never be NULL).` |
| staging_columns | `["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "PRODUCT_KEY"]` |

query_sql = Step 2.3 inner query, unqualified, wrapped with `IF OBJECT_ID('stage.MEWS_LINEITEM', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_LINEITEM]; ... SELECT * INTO [stage].[MEWS_LINEITEM] FROM ( ... ) AS source_query;`

- [ ] **Step 2.5: MCP-verify + add Step 11 (Mews Line Item Tax)**

Same CTE chain as Step 2.3 plus `tx AS ( SELECT TOP 1 id FROM ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_TAXES] ) t WHERE t.rn = 1 ORDER BY id )`. Inner query:

```sql
SELECT CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'TAX') AS SRC_KEY,
       CONCAT_WS('-', reg.outletId, ii.invoiceId) AS HEADER_ID,
       'TAX' AS LINEITEM_TYPE,
       CAST(ii.tax AS DECIMAL(18,2)) AS GROSS_VALUE,
       CAST(ii.tax AS DECIMAL(18,2)) AS TAX_VALUE,
       CAST(0 AS DECIMAL(18,2)) AS NET_VALUE,
       CAST(1 AS DECIMAL(18,4)) AS QUANTITY,
       CASE WHEN ii.isVoid = '1' OR ii.isComp = '1' THEN 1 ELSE 0 END AS VOID_FLAG,
       TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP,
       CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE,
       ii.id AS LINE_ID,
       ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER,
       tx.id AS TAX_KEY
FROM ii
INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1
LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1
CROSS JOIN tx
WHERE ii.rn = 1 AND COALESCE(inv.cancelled, '0') <> '1'
  AND CAST(ii.tax AS DECIMAL(18,2)) <> 0
```

MCP-verify Expected: row count = DL-side `SELECT COUNT(*) FROM <org>.[int_mews001].[DL_INVOICE_ITEMS] WHERE CAST(tax AS DECIMAL(18,2)) <> 0` (19 as of 2026-07-03); every TAX_KEY non-null and identical (single-tax assumption — documented in the description).

| Field | Value |
|---|---|
| step_name | `Mews Line Item Tax` |
| staging_table | `MEWS_LINEITEM_TAX` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages TAX-type line items from invoice item tax amounts. SINGLE-TAX ASSUMPTION: items carry no tax id; all TAX lines link to the sole tax profile via CROSS JOIN. Verification guards against >1 active tax.` |
| staging_columns | `["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "TAX_KEY"]` |

- [ ] **Step 2.6: MCP-verify + add Step 12 (Mews Line Item Discount)**

Same CTE chain (ii, inv, reg — no tx). Inner query:

```sql
SELECT CONCAT_WS('-', reg.outletId, ii.invoiceId, ii.id, 'DISCOUNT') AS SRC_KEY,
       CONCAT_WS('-', reg.outletId, ii.invoiceId) AS HEADER_ID,
       'DISCOUNT' AS LINEITEM_TYPE,
       -1 * COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '') AS DECIMAL(18,2)), 0) AS GROSS_VALUE,
       CAST(0 AS DECIMAL(18,2)) AS TAX_VALUE,
       -1 * COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '') AS DECIMAL(18,2)), 0) AS NET_VALUE,
       CAST(1 AS DECIMAL(18,4)) AS QUANTITY,
       CASE WHEN ii.isVoid = '1' OR ii.isComp = '1' THEN 1 ELSE 0 END AS VOID_FLAG,
       TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS LINEITEM_TIMESTAMP,
       CAST(TRY_CONVERT(DATETIME2, ii.createdAt, 127) AS DATE) AS ITEM_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS ORDER_DATE,
       CAST(TRY_CONVERT(DATETIME2, inv.createdAt, 127) AS DATE) AS TRADING_DATE,
       ii.id AS LINE_ID,
       ROW_NUMBER() OVER (PARTITION BY ii.invoiceId ORDER BY ii.id) AS LINE_ORDER,
       inv.promoCodeId AS DISCOUNT_KEY
FROM ii
INNER JOIN inv ON inv.id = ii.invoiceId AND inv.rn = 1
LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1
WHERE ii.rn = 1 AND COALESCE(inv.cancelled, '0') <> '1'
  AND COALESCE(TRY_CAST(NULLIF(ii.discountAmount, '') AS DECIMAL(18,2)), TRY_CAST(NULLIF(ii.discount, '') AS DECIMAL(18,2)), 0) <> 0
```

MCP-verify Expected: **0 rows** as of 2026-07-03 (no discounts in landed data; query must parse cleanly).

| Field | Value |
|---|---|
| step_name | `Mews Line Item Discount` |
| staging_table | `MEWS_LINEITEM_DISCOUNT` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages DISCOUNT-type line items (negative values) from invoice item discounts. DISCOUNT_KEY = invoice promoCodeId, may be NULL for ad-hoc discounts; the DISCOUNT_LINEITEM link stages separately with NULL keys filtered.` |
| staging_columns | `["SRC_KEY", "HEADER_ID", "LINEITEM_TYPE", "GROSS_VALUE", "TAX_VALUE", "NET_VALUE", "QUANTITY", "VOID_FLAG", "LINEITEM_TIMESTAMP", "ITEM_DATE", "ORDER_DATE", "TRADING_DATE", "LINE_ID", "LINE_ORDER", "DISCOUNT_KEY"]` |

- [ ] **Step 2.7: Commit**

```bash
git add "ClaudeDevelopment/integrations/Mews/01_staging_control.sql"
git commit -m "feat(mews): add transactional staging steps 9-12 (custorder + 3 line types)"
```

---

### Task 3: CRM staging steps (13–15) + Tier-2 link staging (16–17)

**Files:**
- Modify: `ClaudeDevelopment/integrations/Mews/01_staging_control.sql` (append)

**Interfaces:**
- Consumes: `stage.MEWS_LINEITEM_DISCOUNT` (Step 17 reads it at runtime — tier 2 guarantees it runs after tier 1).
- Produces: `MEWS_CUSTOMER` (key `HUB_ID` = customer id), `MEWS_ADDRESS` (key `HUB_ID` = `{customerId}-HOME`, carries `CUSTOMER_KEY`), `MEWS_CONTACT` (key `HUB_ID` = `{customerId}-EMAIL|PHONE`, carries `CUSTOMER_KEY`), `MEWS_CUSTORDER_REVCENTER_LNK` (`HEADER_ID`, `REVC_KEY`), `MEWS_DISCOUNT_LINEITEM_LNK` (`SRC_KEY`, `DISCOUNT_KEY`).

- [ ] **Step 3.1: MCP-verify + add Step 13 (Mews Customer)**

```sql
IF OBJECT_ID('stage.MEWS_CUSTOMER', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTOMER];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_CUSTOMERS] )
SELECT * INTO [stage].[MEWS_CUSTOMER] FROM (
SELECT id AS HUB_ID, fullName AS FORENAME, NULL AS SURNAME, NULL AS MIDDLE_NAMES, NULL AS TITLE, NULL AS GENDER, dateOfBirth AS DOB
FROM deduped WHERE rn = 1 ) AS source_query;
```

MCP-verify (org-prefixed inner SELECT wrapped in COUNT): Expected **364 rows**.

| Field | Value |
|---|---|
| step_name | `Mews Customer` |
| staging_table | `MEWS_CUSTOMER` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages Mews guest profiles as individuals. Mews has a single fullName field mapped to FORENAME.` |
| staging_columns | `["HUB_ID", "FORENAME", "SURNAME", "MIDDLE_NAMES", "TITLE", "GENDER", "DOB"]` |

- [ ] **Step 3.2: MCP-verify + add Step 14 (Mews Address)**

```sql
IF OBJECT_ID('stage.MEWS_ADDRESS', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_ADDRESS];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_CUSTOMERS] )
SELECT * INTO [stage].[MEWS_ADDRESS] FROM (
SELECT CONCAT(id, '-HOME') AS HUB_ID,
       CONCAT_WS(', ', NULLIF(address1, ''), NULLIF(address2, '')) AS ADDRESS,
       postalCode AS POSTCODE, state AS REGION, country AS COUNTRY, city AS TOWN,
       id AS CUSTOMER_KEY
FROM deduped
WHERE rn = 1 AND COALESCE(NULLIF(address1, ''), NULLIF(address2, ''), NULLIF(city, ''), NULLIF(postalCode, '')) IS NOT NULL
) AS source_query;
```

MCP-verify: row count must equal DL-side `SELECT COUNT(*) FROM <org>.[int_mews001].[DL_CUSTOMERS] WHERE COALESCE(NULLIF(address1,''), NULLIF(address2,''), NULLIF(city,''), NULLIF(postalCode,'')) IS NOT NULL` (record the number — unknown until run).

| Field | Value |
|---|---|
| step_name | `Mews Address` |
| staging_table | `MEWS_ADDRESS` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages customer home addresses (key {customerId}-HOME); customers with no address component are excluded` |
| staging_columns | `["HUB_ID", "ADDRESS", "POSTCODE", "REGION", "COUNTRY", "TOWN", "CUSTOMER_KEY"]` |

- [ ] **Step 3.3: MCP-verify + add Step 15 (Mews Contact)**

```sql
IF OBJECT_ID('stage.MEWS_CONTACT', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_CONTACT];
WITH deduped AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_CUSTOMERS] )
SELECT * INTO [stage].[MEWS_CONTACT] FROM (
SELECT CONCAT(id, '-EMAIL') AS HUB_ID, email AS CONTACT, 'EMAIL' AS CONTACT_TYPE, id AS CUSTOMER_KEY
FROM deduped WHERE rn = 1 AND NULLIF(email, '') IS NOT NULL
UNION ALL
SELECT CONCAT(id, '-PHONE'), COALESCE(NULLIF(phone, ''), NULLIF(mobile, '')), 'PHONE', id
FROM deduped WHERE rn = 1 AND COALESCE(NULLIF(phone, ''), NULLIF(mobile, '')) IS NOT NULL
) AS source_query;
```

MCP-verify: count by CONTACT_TYPE; EMAIL rows = customers with non-empty email, PHONE rows = customers with phone or mobile. No NULL CONTACT values.

| Field | Value |
|---|---|
| step_name | `Mews Contact` |
| staging_table | `MEWS_CONTACT` |
| tier | 1 |
| depends_on_steps | NULL |
| description | `Stages customer email and phone contacts, one row per contact (keys {customerId}-EMAIL / {customerId}-PHONE)` |
| staging_columns | `["HUB_ID", "CONTACT", "CONTACT_TYPE", "CUSTOMER_KEY"]` |

- [ ] **Step 3.4: Add Step 16 (Mews Order Revenue Center Link) — tier 2**

```sql
IF OBJECT_ID('stage.MEWS_CUSTORDER_REVCENTER_LNK', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_CUSTORDER_REVCENTER_LNK];
WITH inv AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_INVOICES] ),
reg AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [int_mews001].[DL_REGISTERS] )
SELECT * INTO [stage].[MEWS_CUSTORDER_REVCENTER_LNK] FROM (
SELECT CONCAT_WS('-', reg.outletId, inv.id) AS HEADER_ID, inv.revenueCenterId AS REVC_KEY
FROM inv LEFT JOIN reg ON reg.id = inv.registerId AND reg.rn = 1
WHERE inv.rn = 1 AND COALESCE(inv.cancelled, '0') <> '1' AND inv.revenueCenterId IS NOT NULL
) AS source_query;
```

MCP-verify Expected: **0 rows** (revenueCenterId NULL on all invoices as of 2026-07-03; the platform convention is that staging guarantees non-null link keys — `exclude_conditions` is unused platform-wide).

| Field | Value |
|---|---|
| step_name | `Mews Order Revenue Center Link` |
| staging_table | `MEWS_CUSTORDER_REVCENTER_LNK` |
| tier | 2 |
| depends_on_steps | NULL |
| description | `Link staging: order-to-revenue-center pairs, NULL revenue center keys filtered out. Empty until Mews populates revenueCenterId.` |
| staging_columns | `["HEADER_ID", "REVC_KEY"]` |

- [ ] **Step 3.5: Add Step 17 (Mews Discount Line Link) — tier 2**

```sql
IF OBJECT_ID('stage.MEWS_DISCOUNT_LINEITEM_LNK', 'U') IS NOT NULL DROP TABLE [stage].[MEWS_DISCOUNT_LINEITEM_LNK];
SELECT * INTO [stage].[MEWS_DISCOUNT_LINEITEM_LNK] FROM (
SELECT li.SRC_KEY, li.DISCOUNT_KEY
FROM [stage].[MEWS_LINEITEM_DISCOUNT] li
WHERE li.DISCOUNT_KEY IS NOT NULL
) AS source_query;
```

Cannot MCP-verify until `MEWS_LINEITEM_DISCOUNT` exists (post-deploy check in Task 7). Expected then: **0 rows**.

| Field | Value |
|---|---|
| step_name | `Mews Discount Line Link` |
| staging_table | `MEWS_DISCOUNT_LINEITEM_LNK` |
| tier | 2 |
| depends_on_steps | `N'Mews Line Item Discount'` |
| description | `Link staging: discount-to-line pairs from MEWS_LINEITEM_DISCOUNT with NULL promo keys filtered out` |
| staging_columns | `["SRC_KEY", "DISCOUNT_KEY"]` |

- [ ] **Step 3.6: Whole-script syntax sanity + commit**

Confirm the file has exactly **17 MERGE statements**, each `GO`-terminated, each with identical values in both branches (spot-check steps 2, 9, 10). Then:

```bash
git add "ClaudeDevelopment/integrations/Mews/01_staging_control.sql"
git commit -m "feat(mews): add CRM + tier-2 link staging steps 13-17, completing 17-step StagingControl script"
```

---

### Task 4: Entity mappings — 15 hub rows

**Files:**
- Create: `ClaudeDevelopment/integrations/Mews/02_entity_mappings.sql`

**Interfaces:**
- Consumes: staging column names from Tasks 1–3 (exact, positional).
- Produces: 15 hub rows in `core.int_mews001.EntityMappings`. `source_columns` JSON and `entity_columns` JSON are **positional pairs**; `"hash": 1` marks the business-key column(s); the first entity column is always `HUB_ID`. Task 5 relies on the same key columns for hash-consistency.

**House style** (see `ClaudeDevelopment/integrations/Growyze/04_entity_mappings.sql`) — full MERGE for row 1; rows 2–15 use the identical wrapper with their own values:

```sql
-- #1: LOCATION from MEWS_LOCATION
MERGE INTO [core].[int_mews001].[EntityMappings] AS tgt
USING (VALUES (N'LOCATION', N'MEWS_LOCATION')) AS src (entity_name, source_table)
ON tgt.entity_name = src.entity_name AND tgt.source_table = src.source_table
WHEN MATCHED THEN
    UPDATE SET
        source_columns      = N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
        entity_columns      = N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_ID"]',
        type2_columns       = NULL,
        cdc_exclude_columns = NULL,
        date_filter_column  = NULL,
        track_deletions     = 0,
        updated_at          = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (entity_name, source_table, source_columns, entity_columns,
            type2_columns, cdc_exclude_columns, date_filter_column, track_deletions,
            created_at, updated_at, is_active)
    VALUES (N'LOCATION', N'MEWS_LOCATION',
            N'[{"name": "HUB_ID", "hash": 1}, {"name": "LOCATION_NAME", "hash": 0}, {"name": "PARENT_ID", "hash": 0}, {"name": "LEVEL_NAME", "hash": 0}, {"name": "BOTTOM_LEVEL", "hash": 0}, {"name": "MICROSERVICE_NAME", "hash": 0}, {"name": "MICROSERVICE_ID", "hash": 0}, {"name": "LOCATION_ID", "hash": 0}]',
            N'["HUB_ID", "LOCATION_NAME", "PARENT_ID", "LEVEL_NAME", "BOTTOM_LEVEL", "MICROSERVICE_NAME", "MICROSERVICE_ID", "LOCATION_ID"]',
            NULL, NULL, NULL, 0,
            GETDATE(), GETDATE(), 1);
GO
```

Note: `id` is omitted throughout (DEFAULT NEWID(); avoids the hex-only GUID trap). `type2_columns`/`cdc_exclude_columns`/`date_filter_column` = NULL and `track_deletions` = 0 on every row (platform convention — all existing integrations ship NULL there).

- [ ] **Step 4.1: Write hub rows #1–#8 (dimensions)**

Positional source→entity pairs (source col = staging col; entity col = SAT column; first pair is always key→HUB_ID with hash:1, hash:0 on the rest):

| # | entity_name | source_table | source_columns (in order) | entity_columns (in order) |
|---|---|---|---|---|
| 1 | LOCATION | MEWS_LOCATION | HUB_ID¹, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID, LOCATION_ID | HUB_ID, LOCATION_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID, LOCATION_ID |
| 2 | PRODUCT | MEWS_PRODUCT | HUB_ID¹, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, PRODUCT_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, PRODUCT_ID, ATTR_1, MICROSERVICE_NAME, MICROSERVICE_ID |
| 3 | MOD | MEWS_MOD | HUB_ID¹, MOD_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MOD_ID, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, MOD_NAME, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MOD_ID, MICROSERVICE_NAME, MICROSERVICE_ID |
| 4 | TAX | MEWS_TAX | HUB_ID¹, TAX_NAME, TAX_ID, TAX_MULTIPLIER, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, TAX_NAME, TAX_ID, TAX_MULTIPLIER, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 5 | TENDER | MEWS_TENDER | HUB_ID¹, TENDER_NAME, TENDER_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, TENDER_NAME, TENDER_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 6 | DISCOUNT | MEWS_DISCOUNT | HUB_ID¹, DISCOUNT_NAME, DISCOUNT_ID, VALUE_TYPE, VALUE, IS_WASTE, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, DISCOUNT_NAME, DISCOUNT_ID, VALUE_TYPE, VALUE, IS_WASTE, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 7 | CHANNEL | MEWS_CHANNEL | HUB_ID¹, CHANNEL_NAME, CHANNEL_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, CHANNEL_NAME, CHANNEL_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |
| 8 | REVCENTER | MEWS_REVCENTER | HUB_ID¹, REVC_NAME, REVC_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID | HUB_ID, REVC_NAME, REVC_ID, PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, MICROSERVICE_NAME, MICROSERVICE_ID |

(¹ = `"hash": 1`.)

- [ ] **Step 4.2: Write hub rows #9–#15 (transactional + CRM)**

| # | entity_name | source_table | source_columns (in order) | entity_columns (in order) |
|---|---|---|---|---|
| 9 | CUSTORDER | MEWS_CUSTORDER | HEADER_ID¹, GRAND_TOTAL, DISCOUNT_GROSS, GROSS_SALES, TAX_TOTAL, NET_SALES, GUEST_COUNT, ITEM_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, TRADING_DATE | HUB_ID, GRAND_TOTAL, DISCOUNT_GROSS, GROSS_SALES, TAX_TOTAL, NET_SALES, GUEST_COUNT, ITEM_COUNT, ORDER_COUNT, OPEN_TIME, CLOSE_TIME, ORDER_DATE, TABLE_NO, ORDER_INFO, EXTERNAL_REFERENCE, ORDER_STATUS, PAYMENT_STATUS, TRADING_DATE |
| 10 | LINEITEM | MEWS_LINEITEM | SRC_KEY¹, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, SRC_KEY⁰ | HUB_ID, HEADER_ID, LINEITEM_TYPE, GROSS_VALUE, TAX_VALUE, NET_VALUE, QUANTITY, LINEITEM_TIMESTAMP, ITEM_DATE, ORDER_DATE, VOID_FLAG, LINE_ID, LINE_ORDER, TRADING_DATE, SRC_KEY |
| 11 | LINEITEM | MEWS_LINEITEM_TAX | (identical to #10) | (identical to #10) |
| 12 | LINEITEM | MEWS_LINEITEM_DISCOUNT | (identical to #10) | (identical to #10) |
| 13 | INDIVIDUAL | MEWS_CUSTOMER | HUB_ID¹, FORENAME, SURNAME, MIDDLE_NAMES, TITLE, GENDER, DOB | HUB_ID, FORENAME, SURNAME, MIDDLE_NAMES, TITLE, GENDER, DOB |
| 14 | ADDRESS | MEWS_ADDRESS | HUB_ID¹, ADDRESS, POSTCODE, REGION, COUNTRY, TOWN | HUB_ID, ADDRESS, POSTCODE, REGION, COUNTRY, TOWN |
| 15 | CONTACT | MEWS_CONTACT | HUB_ID¹, CONTACT, CONTACT_TYPE | HUB_ID, CONTACT, CONTACT_TYPE |

Notes: rows #10–#12 have literally the same JSON — write it out in full three times (only `source_table` differs); `SRC_KEY` appears twice in #10–#12: once with hash:1 (→ HUB_ID) and once with hash:0 (→ the SRC_KEY SAT attribute) — this is the platform's OCCASION double-map pattern.

- [ ] **Step 4.3: Static validation via MCP**

Validate every JSON literal parses (run per row-pair, using the actual JSON strings):

```sql
SELECT [key], value FROM OPENJSON(N'<source_columns JSON>')
```

Expected: one array element per column, no error. Also verify positional pair counts match: count of objects in `source_columns` = count of strings in `entity_columns` for every row.

- [ ] **Step 4.4: Commit**

```bash
git add "ClaudeDevelopment/integrations/Mews/02_entity_mappings.sql"
git commit -m "feat(mews): add 15 hub entity mappings"
```

---

### Task 5: Entity mappings — 10 link rows + Load-step generation script

**Files:**
- Modify: `ClaudeDevelopment/integrations/Mews/02_entity_mappings.sql` (append)
- Create: `ClaudeDevelopment/integrations/Mews/03_upload_load_steps.sql`

**Interfaces:**
- Consumes: staging key columns from Tasks 1–3; hub keys from Task 4.
- Produces: 10 link rows; `03` script that generates `step_type='Load'` StagingControl rows.

**Hash-consistency rule (the thing that breaks silently if wrong):** the generated Load steps hash keys as `HASHBYTES('SHA2_256', CONCAT_WS('|', <col>, 'int_mews001'))`. A link's hub-side key column must therefore contain the **same literal values** as the hub mapping's hash:1 column, or the link rows point at hubs that don't exist (the Dirty Sixth orphan-link bug). The pairs used here: `LOCATION_KEY`=outletId=LOCATION HUB_ID; `PRODUCT_KEY`∈{variantId, productId-DEFAULT}=PRODUCT HUB_ID; `HEADER_ID`=CUSTORDER key; `SRC_KEY`=LINEITEM key; `TAX_KEY`=tax id=TAX HUB_ID; `DISCOUNT_KEY`=promoCodeId=DISCOUNT HUB_ID; `CUSTOMER_KEY`=customer id=INDIVIDUAL HUB_ID; MEWS_ADDRESS/MEWS_CONTACT `HUB_ID`=ADDRESS/CONTACT keys.

- [ ] **Step 5.1: Write link rows #16–#25**

Link rows: both source columns `"hash": 1`; entity_columns are the two `{ENTITY}_HUB_ID` names in the same order; `type2_columns`/`cdc_exclude_columns`/`date_filter_column` NULL, `track_deletions` 0. Full MERGE per row (same wrapper as Task 4, entity/source values below):

| # | entity_name | source_table | source_columns | entity_columns |
|---|---|---|---|---|
| 16 | CUSTORDER_LOCATION | MEWS_CUSTORDER | `[{"name": "HEADER_ID", "hash": 1}, {"name": "LOCATION_KEY", "hash": 1}]` | `["CUSTORDER_HUB_ID", "LOCATION_HUB_ID"]` |
| 17 | CUSTORDER_LINEITEM | MEWS_LINEITEM | `[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]` | `["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]` |
| 18 | CUSTORDER_LINEITEM | MEWS_LINEITEM_TAX | `[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]` | `["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]` |
| 19 | CUSTORDER_LINEITEM | MEWS_LINEITEM_DISCOUNT | `[{"name": "SRC_KEY", "hash": 1}, {"name": "HEADER_ID", "hash": 1}]` | `["LINEITEM_HUB_ID", "CUSTORDER_HUB_ID"]` |
| 20 | LINEITEM_PRODUCT | MEWS_LINEITEM | `[{"name": "SRC_KEY", "hash": 1}, {"name": "PRODUCT_KEY", "hash": 1}]` | `["LINEITEM_HUB_ID", "PRODUCT_HUB_ID"]` |
| 21 | LINEITEM_TAX | MEWS_LINEITEM_TAX | `[{"name": "SRC_KEY", "hash": 1}, {"name": "TAX_KEY", "hash": 1}]` | `["LINEITEM_HUB_ID", "TAX_HUB_ID"]` |
| 22 | DISCOUNT_LINEITEM | MEWS_DISCOUNT_LINEITEM_LNK | `[{"name": "DISCOUNT_KEY", "hash": 1}, {"name": "SRC_KEY", "hash": 1}]` | `["DISCOUNT_HUB_ID", "LINEITEM_HUB_ID"]` |
| 23 | CUSTORDER_REVCENTER | MEWS_CUSTORDER_REVCENTER_LNK | `[{"name": "HEADER_ID", "hash": 1}, {"name": "REVC_KEY", "hash": 1}]` | `["CUSTORDER_HUB_ID", "REVCENTER_HUB_ID"]` |
| 24 | ADDRESS_INDIVIDUAL | MEWS_ADDRESS | `[{"name": "HUB_ID", "hash": 1}, {"name": "CUSTOMER_KEY", "hash": 1}]` | `["ADDRESS_HUB_ID", "INDIVIDUAL_HUB_ID"]` |
| 25 | CONTACT_INDIVIDUAL | MEWS_CONTACT | `[{"name": "HUB_ID", "hash": 1}, {"name": "CUSTOMER_KEY", "hash": 1}]` | `["CONTACT_HUB_ID", "INDIVIDUAL_HUB_ID"]` |

- [ ] **Step 5.2: Write `03_upload_load_steps.sql`**

Complete file (header comment + one statement — this is what Growyze's dev scripts were missing, and why its data never reached the DV):

```sql
/* ============================================================================
   Mews Integration - Generate Load Steps
   Translates core.int_mews001.EntityMappings rows into StagingControl rows
   with step_type = 'Load'. Idempotent (regenerates on re-run).
   Run AFTER 01 + 02. Developer-executed (EXEC not allowed via MCP).
   ============================================================================ */
EXEC [core].[UploadEntityMappings] @intSchema = N'int_mews001';
GO
```

- [ ] **Step 5.3: Cross-check hash-key consistency (desk check + MCP)**

For each of the 10 link rows, confirm against the Task 1–3 staging queries that the hub-side key column's values equal the corresponding hub mapping's hash:1 column values (the table in this task's header lists the expected pairs). Then spot-verify the PRODUCT pair with data:

```sql
WITH ii AS ( SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY LOADTS_UTC DESC) AS rn FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_INVOICE_ITEMS] )
SELECT COUNT(*) AS unresolved FROM ii
WHERE ii.rn = 1 AND COALESCE(ii.productVariantId, CONCAT(ii.productId, '-DEFAULT')) NOT IN (
  SELECT id FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_PRODUCT_VARIANTS]
  UNION ALL
  SELECT CONCAT(id, '-DEFAULT') FROM [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43].[int_mews001].[DL_PRODUCTS]
)
```

Expected: **unresolved = 0** (every sale line's PRODUCT_KEY resolves to a staged BOTTOM member).

- [ ] **Step 5.4: Commit**

```bash
git add "ClaudeDevelopment/integrations/Mews/02_entity_mappings.sql" "ClaudeDevelopment/integrations/Mews/03_upload_load_steps.sql"
git commit -m "feat(mews): add 10 link mappings + UploadEntityMappings load-step generation"
```

---

### Task 6: Verification script + status log

**Files:**
- Create: `ClaudeDevelopment/integrations/Mews/04_verification.sql`
- Modify: `ClaudeDevelopment/QUERY_STATUS.md` (add a Mews section)

**Interfaces:**
- Consumes: everything from Tasks 1–5.
- Produces: a read-only script whose every query emits a `check_name`, `expected`, `actual`, `status` row — runnable section-by-section via MCP (org-prefixed) or whole via SSMS.

- [ ] **Step 6.1: Write `04_verification.sql`**

Read-only (`SELECT`/`WITH` only). Unqualified two-part names. Five sections; each query follows this shape (Section A query shown complete; B–E queries listed with their exact checks):

```sql
/* Section A: control-plane counts (run against core) */
SELECT 'staging_steps' AS check_name, '17' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 17 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Staging' AND exclude = 0;

SELECT 'load_steps_generated' AS check_name, '25' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 25 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[int_mews001].[StagingControl] WHERE step_type = 'Load' AND exclude = 0;

SELECT 'entity_mappings' AS check_name, '25' AS expected,
       CAST(COUNT(*) AS VARCHAR(10)) AS actual,
       CASE WHEN COUNT(*) = 25 THEN 'PASS' ELSE 'FAIL' END AS status
FROM [core].[int_mews001].[EntityMappings] WHERE is_active = 1;
```

**Section B — stage tables (run in org DB after `sp_Staging`):** one query per table asserting: MEWS_LOCATION = 2; MEWS_PRODUCT = 389 with per-level breakdown (TOP 12 / MIDDLE_1 98 / BOTTOM 279); MEWS_TAX = 1; MEWS_TENDER = 6; MEWS_DISCOUNT = 2; MEWS_CHANNEL = 2; MEWS_MOD = 0; MEWS_REVCENTER = 0; MEWS_CUSTORDER = 19; MEWS_LINEITEM = 22; MEWS_LINEITEM_TAX = DL-derived count; MEWS_LINEITEM_DISCOUNT = 0; MEWS_CUSTOMER = 364; MEWS_ADDRESS / MEWS_CONTACT = the counts recorded in Task 3; both `_LNK` tables = 0. (Counts are 2026-07-03 baselines; where the fetcher may have landed more, the query compares to the DL-side equivalent instead of a literal.)

**Section C — data-quality gates (org DB):**
- `null_lineitem_timestamp`: `SELECT COUNT(*) FROM [stage].[MEWS_LINEITEM] WHERE LINEITEM_TIMESTAMP IS NULL` — expected 0 (**hard gate**).
- `single_tax_guard`: `SELECT COUNT(DISTINCT id) FROM [int_mews001].[DL_TAXES]` — expected 1; >1 breaks the LINEITEM_TAX assumption, escalate.
- `unresolved_product_keys`: stage-side version of Step 5.3 — `SELECT COUNT(*) FROM [stage].[MEWS_LINEITEM] li WHERE NOT EXISTS (SELECT 1 FROM [stage].[MEWS_PRODUCT] p WHERE p.HUB_ID = li.PRODUCT_KEY AND p.BOTTOM_LEVEL = 1)` — expected 0.
- `custorder_lineitem_coverage`: every `MEWS_LINEITEM.HEADER_ID` exists in `MEWS_CUSTORDER.HEADER_ID` — expected 0 missing.
- `financial_reconciliation`: `ABS(SUM(MEWS_LINEITEM.GROSS_VALUE where VOID_FLAG=0) − SUM(MEWS_CUSTORDER.GRAND_TOTAL))` per HEADER_ID, count of headers where the difference exceeds 0.05 — report (comps zero out item totals but invoice totals may retain them; investigate non-zero, don't hard-fail).

**Section D — post-load DV counts (org DB after `sp_DataVaultLoad`):** HUB_LOCATION = 2; HUB_PRODUCT = 389; HUB_CUSTORDER = 19; HUB_LINEITEM = stage line total (22 + TAX-line count + 0); HUB_INDIVIDUAL = 364; SAT_* current-flag counts equal their hubs; LNK_CUSTORDER_LINEITEM = HUB_LINEITEM count; LNK_LINEITEM_PRODUCT = 22; LNK_CUSTORDER_LOCATION = 19; **orphan-link check** (the Dirty Sixth bug pattern): `SELECT COUNT(*) FROM [datavault].[LNK_LINEITEM_PRODUCT] l WHERE NOT EXISTS (SELECT 1 FROM [datavault].[HUB_PRODUCT] h WHERE h.HUB_ID = l.PRODUCT_HUB_ID)` — expected 0, repeated for each of the 10 links' two sides.

**Section E — presentation (org DB after presentation rebuild):** `F_LINEITEM_15MIN` > 0 rows; `D_PRODUCT` BOTTOM members ≈ 279 + sentinel; `D_LOCATION` = 2 + sentinel; `SELECT ParameterValue FROM [core].[GlobalParameters] WHERE ParameterKey IN ('LINEITEM_START', 'LINEITEM_END')` — NULL is the expected resting state after a completed load.

- [ ] **Step 6.2: MCP-run Section A**

Org-independent (targets `core.int_mews001.*`): run the three Section A queries via MCP now — before deployment, expected actuals are 17/0/25 once 01+02 have been deployed by the developer, or 0/0/0 beforehand. Record which state you observed. (Section B–E queries run in Task 7 post-deploy.)

- [ ] **Step 6.3: Update `ClaudeDevelopment/QUERY_STATUS.md`**

Add a `## Mews (int_mews001)` section listing the four scripts with purpose, status `created — not deployed`, spec/plan links, and the 2026-07-03 expected-count baselines.

- [ ] **Step 6.4: Commit**

```bash
git add "ClaudeDevelopment/integrations/Mews/04_verification.sql" "ClaudeDevelopment/QUERY_STATUS.md"
git commit -m "feat(mews): add verification script and QUERY_STATUS entries"
```

---

### Task 7: Deployment + post-load verification

**Files:**
- Modify: `ClaudeDevelopment/QUERY_STATUS.md` (status updates)
- Create: `ClaudeDevelopment/integrations/Mews/DEPLOY.txt`

**Interfaces:**
- Consumes: all four scripts. The MCP connection is read-only — deployment is **developer-executed**; the agent's role is pre-flight, instructions, and post-flight verification.

- [ ] **Step 7.1: Write `DEPLOY.txt`**

```text
Mews001 DV Mapping - Deploy Order (DEV)
Target: core database (01-03), then org DB load (04 checks)

1. 01_staging_control.sql      -- SSMS vs core. Expect: 17 rows in core.int_mews001.StagingControl (step_type='Staging')
2. 02_entity_mappings.sql      -- SSMS vs core. Expect: 25 rows in core.int_mews001.EntityMappings
3. 03_upload_load_steps.sql    -- SSMS vs core. Expect: 25 Load rows added to StagingControl
4. Run the load for org 19 (Three Rocks Hotel):
     USE [20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43];
     EXEC [core].[sp_DataVaultLoad] @SchemaList = N'int_mews001';
5. 04_verification.sql sections B-E -- SSMS vs org DB (or hand to Claude for MCP verification)
Rollback: UPDATE core.int_mews001.StagingControl SET exclude = 1;
          UPDATE core.int_mews001.EntityMappings SET is_active = 0;
          (config-only change - no DDL to reverse; stage tables are DROP/SELECT INTO)
All scripts are idempotent MERGE upserts - safe to re-run.
```

- [ ] **Step 7.2: Hand off to developer, wait for deployment**

Stop and notify: scripts ready, deploy order in DEPLOY.txt. Do not proceed until the developer confirms steps 1–4 ran.

- [ ] **Step 7.3: Post-deploy MCP verification**

Run `04_verification.sql` sections A–E via MCP (org-prefix Section B–E table references; strip comments; run each SELECT separately). Record every check's actual vs expected. Failure playbook:
- `load_steps_generated` ≠ 25 → inspect `SELECT step_name, staging_table FROM core.int_mews001.StagingControl WHERE step_type = 'Load'` for which mapping didn't translate; likely a JSON typo in 02.
- Stage-table count mismatch → re-run that step's Task 1–3 MCP test query; if the test passes but the stage table differs, check `core.LOG_STG` in the org DB for the step's error.
- Orphan links ≠ 0 → the hash-consistency table in Task 5 identifies which key pair to inspect.
- `F_LINEITEM_15MIN` = 0 with DV populated → check LINEITEM_TIMESTAMP nulls (Section C) and the `LINEITEM_START`/`END` GlobalParameters window.

- [ ] **Step 7.4: Update QUERY_STATUS.md and commit**

Set the Mews section rows to `deployed to DEV — verified {date}` with actual counts observed, note any deviations. 

```bash
git add "ClaudeDevelopment/QUERY_STATUS.md" "ClaudeDevelopment/integrations/Mews/DEPLOY.txt"
git commit -m "docs(mews): record DEV deployment + verification results"
```

---

## Plan Self-Review Record

- **Spec coverage:** §2 decisions → Tasks 1–5; §3 product hierarchy → Steps 1.3–1.4, 5.3; §4 staging → Tasks 1–3 (17 steps; spec's separate Tier-2 layer replaced by direct link mappings + 2 filter steps, per Growyze precedent — spec amended); §5 mappings → Tasks 4–5 (25 rows; spec amended from 28); §6 deliverables → all four scripts + DEPLOY.txt; §7 testing → Testing Method + per-step MCP checks + Task 6/7; §8 gaps → carried in descriptions and QUERY_STATUS.
- **Additions the spec lacked:** `03_upload_load_steps.sql` (Load-step generation — the missing piece that left Growyze data outside the DV), MEWS_ADDRESS/MEWS_CONTACT as their own staging steps (a mapping key can't fan one row into two contact rows), hash-consistency check, financial reconciliation check.
- **Type consistency:** staging column names in Tasks 1–3 match mapping JSON in Tasks 4–5 (LOCATION_KEY, PRODUCT_KEY, TAX_KEY, DISCOUNT_KEY, CUSTOMER_KEY, HEADER_ID, SRC_KEY, HUB_ID verified per pair).
