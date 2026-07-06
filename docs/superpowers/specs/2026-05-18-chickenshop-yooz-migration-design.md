# Chicken Shop — Yooz Extract Migration (Matillion → XMS BI)

**Status:** Design — ready for implementation planning
**Date:** 2026-05-18
**Owner:** Andrew Kaplan
**Source artefacts:** `ClaudeDevelopment/integrations/ChickenShop/matillion-export/MARKETMAN_MASTER.json`, `MARKETMAN_PROCESS_YOOZ.json`

## 1. Context and goals

Chicken Shop currently runs a Matillion ETL pipeline against MarketMan that produces a daily Purchase Order extract table in Snowflake (`SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ`). A Snowflake task emails this table downstream for consumption by Yooz (the customer's invoice/PO processing system).

This design replaces the Matillion job `MARKETMAN_PROCESS_YOOZ` with an XMS BI-based equivalent. XMS BI becomes the source of MarketMan data; an Azure Function in the existing Functions layer ports the daily extract into the same Snowflake target table. The Snowflake email task is unchanged.

### Goals

- Eliminate Chicken Shop's dependency on the `MARKETMAN_PROCESS_YOOZ` Matillion job.
- Use XMS BI's MarketMan integration as the single source of MarketMan data for this customer.
- Produce an identical `MARKETMAN_PO_YOOZ` Snowflake table — same columns, same shape, same daily refresh — so the downstream email task and Yooz consumer require no change.
- Provision a dedicated "Chicken Shop" XMS BI org with its own MarketMan API account, isolated from Three Rocks Cafe (where Chicken Shop's data has been co-resident in UAT during evaluation).

### Non-goals

- Replacing the Snowflake email task or migrating delivery into the Azure Function.
- Migrating other Matillion jobs for this customer (NCR / Tevalis / Deliveroo / Yext / the Yooz mapping refresh).
- Building the data-entry UI for the Yooz mapping tables — separate workstream.
- Generalising the `extract` schema pattern to other XMS BI orgs.

## 2. Architecture

```
┌────────────────────────────────────────────────┐
│  Chicken Shop client DB (XMS BI MI)            │
│                                                │
│   datavault.SAT_STOCKORDER          ─┐         │
│   datavault.SAT_INVITEM_STOCKORDER  ─┤         │
│   datavault.SAT_SUPPLIER            ─┤ joined  │
│   datavault.SAT_INVENTORYITEMS      ─┘         │
│                                                │
│   reference.YOOZ_MAPS                          │
│   reference.YOOZ_PRICE_AMEND                   │
│   reference.YOOZ_ALLOWED_VENDORS               │
│                                                │
│   extract.V_YOOZ_PO  ◄── view over above       │
└────────────────────────────────────────────────┘
                  │
                  │ SELECT * FROM extract.V_YOOZ_PO
                  ▼
┌────────────────────────────────────────────────┐
│  Azure Function — ChickenShopYoozExtract       │
│  (timer-triggered, fixed daily time)           │
│   1. SELECT extract from XMS BI                │
│   2. Stage in Snowflake (MARKETMAN_PO_YOOZ_STAGING)│
│   3. Atomic TRUNCATE + INSERT into target      │
└────────────────────────────────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────────────┐
│  Snowflake — UNCHANGED                         │
│   SIXSEVENS_DATALAKE.CHIKN.MARKETMAN_PO_YOOZ   │
│        ▼                                       │
│   Existing Snowflake email task                │
└────────────────────────────────────────────────┘
```

### Components and ownership

| Component | Where it lives | Owned by |
|---|---|---|
| Chicken Shop org + client DB | XMS BI MI | This work |
| MarketMan integration provisioning (existing `MarketMan001`) | XMS BI MI | This work — uses existing platform code |
| Reference tables (3) | Chicken Shop client DB, `reference` schema | This work — DDL only; data entry is separate |
| Extract view | Chicken Shop client DB, new `extract` schema | This work |
| Azure Function | Existing Functions layer, outside this repo | This work — scope/spec only; code in Functions repo |
| Snowflake target table + email task | Customer's Snowflake account | Untouched |
| Mapping data entry mechanism | TBD | Separate workstream |

### Architectural choices

- **`extract` is a new schema, distinct from `presentation`.** `presentation` is for dashboard cards driven through `PresentationControl`. Outbound feeds for external systems belong somewhere else; introducing `extract` keeps the analytics layer clean and makes the convention available to future Yooz-like integrations without needing it on day one.
- **The view is unmaterialised.** The extract is a single-day, narrow query over a few satellites and a handful of small reference tables. Materialising as a presentation table would force the build into every org's `sp_DataVaultLoad` run, requiring new conditional logic in `PresentationControl`. A view is cheaper to operate and has zero blast radius on existing orgs.
- **The Azure Function is a pipe, not a transformer.** All filters, joins, and amendment overrides live in the SQL view. The Function reads one result set and writes it. Keeps the transformation in one place, in SQL, where it can be inspected and tested with a single query.
- **No platform changes.** Numbered release scripts, `core` stored procedures, and `presentation` build steps are untouched. All new objects ship as Chicken Shop integration scripts under `ClaudeDevelopment/integrations/ChickenShop/`.

## 3. Reference tables

Three new tables in the `reference` schema of the Chicken Shop client DB. The separate data-entry mechanism writes; the extract view reads.

### `reference.YOOZ_MAPS`

Generic MarketMan→Yooz mapping table, discriminated by `MAP_TYPE`. Consolidates what Matillion split across `marketman_yooz_maps` and the derived `marketman_yooz_orditem_account`.

| Column | Type | Notes |
|---|---|---|
| `MAP_ID` | INT IDENTITY PK | Surrogate for edit convenience |
| `MAP_TYPE` | NVARCHAR(50) NOT NULL | `PRODUCT-ACCOUNT_CODE`, `TAX`, `ORGUNIT`, future types |
| `MM_CODE` | NVARCHAR(200) NOT NULL | MarketMan-side value |
| `YOOZ_CODE` | NVARCHAR(200) NOT NULL | Yooz-side value |
| `DESCRIPTION` | NVARCHAR(500) NULL | Free text for audit |
| `IS_ACTIVE` | BIT NOT NULL DEFAULT 1 | Soft delete |
| `LAST_MODIFIED_UTC` | DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME() | |
| `LAST_MODIFIED_BY` | NVARCHAR(100) NULL | Populated by data-entry mechanism |

Filtered unique index on (`MAP_TYPE`, `MM_CODE`, `YOOZ_CODE`) WHERE `IS_ACTIVE = 1` prevents duplicate active mappings.

### `reference.YOOZ_PRICE_AMEND`

Manual price / qty overrides. Adds effective-dating, which Matillion's `mm_yooz_product_price_ammend` lacked.

| Column | Type | Notes |
|---|---|---|
| `AMEND_ID` | INT IDENTITY PK | |
| `PRODUCT_CODE` | NVARCHAR(200) NOT NULL | Matches MM product code |
| `AMEND_PRICE` | DECIMAL(18,4) NOT NULL | Override unit price |
| `TAX_PERCENT` | DECIMAL(9,4) NOT NULL | Override tax % |
| `EFFECTIVE_FROM` | DATE NOT NULL | Start of validity |
| `EFFECTIVE_TO` | DATE NULL | Open-ended if NULL |
| `LAST_MODIFIED_UTC` | DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME() | |
| `LAST_MODIFIED_BY` | NVARCHAR(100) NULL | |

### `reference.YOOZ_ALLOWED_VENDORS`

Vendor whitelist. Matillion hard-coded vendor names inline as filter conditions; lifting to a table makes onboarding a new vendor a data change.

| Column | Type | Notes |
|---|---|---|
| `VENDOR_NAME` | NVARCHAR(200) NOT NULL PK | Matches `SAT_SUPPLIER.SUPPLIER_NAME` |
| `NOTES` | NVARCHAR(500) NULL | E.g. "Bidfood — onboarded 2025-09" |
| `IS_ACTIVE` | BIT NOT NULL DEFAULT 1 | |
| `ADDED_UTC` | DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME() | |

## 4. Extract view: `extract.V_YOOZ_PO`

44 columns out, one row per PO line. Definition mirrors the Matillion SQL that builds the existing `MARKETMAN_PO_YOOZ` table — same column names, order, NVL-to-empty-string handling, date format (`yyyyMMdd`), and GL-account fallback to `-1`.

### Column mapping

| # | Output column | Source | Notes |
|---|---|---|---|
| 1 | `COMMAND` | `'CREATE'` literal | |
| 2 | `VENDOR_NAME` | `SAT_SUPPLIER.SUPPLIER_NAME`, ISNULL → `''` | Via `LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER` |
| 3 | `VENDOR_CODE` | `SAT_SUPPLIER.SUPPLIER_CODE` | |
| 4 | `ORDER_NUMBER` | `SAT_STOCKORDER.ORDER_NUMBER` | |
| 5 | `ORDER_DATE` | `FORMAT(SAT_STOCKORDER.ORDER_DATE,'yyyyMMdd')`, NULL → `''` | |
| 6 | `AMOUNT_INC_TAX` | `SAT_INVITEM_STOCKORDER.AMOUNT_INC_TAX`, overridden if amendment matched | |
| 7 | `AMOUNT_EXCL_TAX` | `SAT_INVITEM_STOCKORDER.AMOUNT_EXCL_TAX`, overridden | |
| 8 | `CURRENCY` | `SAT_STOCKORDER.CURRENCY` | |
| 9 | `ORDER_CREATOR` | `SAT_STOCKORDER.ORDER_CREATOR` | Verify column exists — see §7 |
| 10 | `ORDER_APPROVERS` | `SAT_STOCKORDER.ORDER_APPROVERS` | Verify |
| 11 | `ERP_ORDER_STATUS` | `SAT_STOCKORDER.ORDER_STATUS` | Verify naming |
| 12 | `LINE_NUMBER` | `SAT_INVITEM_STOCKORDER.LINE_NUMBER` | |
| 13 | `CLIENT_ITEM_CODE` | `SAT_INVENTORYITEMS.CLIENT_ITEM_CODE` | |
| 14 | `ITEM_DESCRIPTION` | `SAT_INVENTORYITEMS.ITEM_NAME` (or `ITEM_DESCRIPTION` if distinct) | |
| 15 | `ITEM_UNIT_PRICE` | `SAT_INVITEM_STOCKORDER.UNIT_PRICE`, overridden | |
| 16 | `QUANTITY_ORDERED` | `SAT_INVITEM_STOCKORDER.QUANTITY` | |
| 17–20 | `QUANTITY_RECEIVED`, `QUANTITY_INVOICED`, `AMOUNT_INVOICED`, `DISCOUNTED_AMOUNT` | `''` literal | |
| 21 | `TAX_PROFILE_CODE` | `SAT_INVITEM_STOCKORDER.TAX_PROFILE_CODE` | Verify column exists |
| 22 | `TAX_AMOUNT` | `SAT_INVITEM_STOCKORDER.TAX_AMOUNT`, overridden | |
| 23 | `GL_ACCOUNT_CHARGED` | `YOOZ_MAPS.YOOZ_CODE` where `MAP_TYPE='PRODUCT-ACCOUNT_CODE'`, ISNULL → `-1` | See join below |
| 24–27 | `COST_CENTERS_CHARTS_CODES`, `COST_CENTERS_CODES`, `SUBSIDIARY` | `''` | |
| 28 | `VENDOR_ITEM_CODE` | `SAT_INVENTORYITEMS.VENDOR_ITEM_CODE` | Verify |
| 29–32 | Header/line custom data, reception comment/date | `''` | |
| 33 | `PLANNED_DELIVERY_DATE` | `FORMAT(SAT_STOCKORDER.PLANNED_DELIVERY_DATE,'yyyyMMdd')`, NULL → `''` | |
| 34–43 | `TO_BE_RECEIVED` through `BUDGET_CODE` | `''` | |
| 44 | `ORGUNIT_CODE` | `YOOZ_MAPS.YOOZ_CODE` where `MAP_TYPE='ORGUNIT'`, MM_CODE = MarketMan buyer/site code on PO | |

### GL account mapping join (preserves Matillion fallback)

```sql
LEFT JOIN reference.YOOZ_MAPS gl
    ON gl.MAP_TYPE = 'PRODUCT-ACCOUNT_CODE'
   AND gl.IS_ACTIVE = 1
   AND gl.MM_CODE IN (
        'PC_' + ISNULL(NULLIF(LTRIM(RTRIM(item.PRODUCT_CODE)),''), LTRIM(RTRIM(item.SRC_KEY))),
        'PC_' + ISNULL(NULLIF(LTRIM(RTRIM(item.PRODUCT_CODE)),''), LTRIM(RTRIM(item.SRC_KEY)))
              + '_' + LTRIM(RTRIM(item.SRC_KEY))
   )
```

This preserves Matillion's exact key-construction logic so the customer's existing `YOOZ_MAPS` rows continue to match without re-keying.

### Price amendment override

```sql
CROSS APPLY (
    SELECT TOP 1 *
    FROM reference.YOOZ_PRICE_AMEND a
    WHERE a.PRODUCT_CODE = item.PRODUCT_CODE
      AND CAST(GETUTCDATE() AS DATE) BETWEEN a.EFFECTIVE_FROM
                                         AND ISNULL(a.EFFECTIVE_TO, '9999-12-31')
) amend
```

Applied to derived columns:

```sql
ISNULL(amend.AMEND_PRICE, line.UNIT_PRICE) AS ITEM_UNIT_PRICE,
ISNULL(amend.AMEND_PRICE * line.QUANTITY, line.AMOUNT_EXCL_TAX) AS AMOUNT_EXCL_TAX,
ISNULL((amend.AMEND_PRICE * line.QUANTITY) * (100 + amend.TAX_PERCENT) / 100,
       line.AMOUNT_INC_TAX) AS AMOUNT_INC_TAX,
ISNULL((amend.AMEND_PRICE * line.QUANTITY) * (100 + amend.TAX_PERCENT) / 100
        - (amend.AMEND_PRICE * line.QUANTITY),
       line.TAX_AMOUNT) AS TAX_AMOUNT
```

### Filters

```sql
WHERE so.PLANNED_DELIVERY_DATE = CAST(DATEADD(DAY, -1, GETUTCDATE()) AS DATE)
  AND so.ORDER_CANCELLED_BY_BUYER    IS NULL
  AND so.ORDER_CANCELLED_BY_SUPPLIER IS NULL
  AND EXISTS (SELECT 1 FROM reference.YOOZ_ALLOWED_VENDORS v
              WHERE v.IS_ACTIVE = 1 AND v.VENDOR_NAME = sup.SUPPLIER_NAME)
```

`yoozHistDays` is hard-coded to 1. If a parameterised history window is ever needed (e.g. for backfill), the view becomes an inline table-valued function. Out of scope for v1.

## 5. Azure Function

### Scope

One Function: `ChickenShopYoozExtract`. Timer-triggered at a fixed daily UTC time (e.g. `0 0 6 * * *` for 06:00 UTC), chosen to land after the XMS BI MarketMan DV load completes for the Chicken Shop org. Function source code lives in the existing Functions layer repo, not in XMS BI.

### Run sequence

1. Resolve the Chicken Shop client DB name from `core.core.Organisations` by org code. Avoids hard-coding the dated GUID DB name.
2. `SET TRANSACTION ISOLATION LEVEL SNAPSHOT`, then `SELECT … FROM [{ClientDB}].extract.V_YOOZ_PO`. Snapshot isolation prevents a concurrent DV load from shifting the result mid-read.
3. Stage to Snowflake `MARKETMAN_PO_YOOZ_STAGING` via the Functions layer's existing Snowflake write path (COPY INTO / Snowpipe / bulk-insert — whichever pattern is established).
4. In a Snowflake transaction: `TRUNCATE MARKETMAN_PO_YOOZ` then `INSERT INTO MARKETMAN_PO_YOOZ SELECT * FROM MARKETMAN_PO_YOOZ_STAGING`. Atomic swap so the downstream email task never sees an empty target.
5. Log run outcome to the Functions layer's observability stack: rows read from MI, rows written to Snowflake, duration, success/failure.

### Failure handling

- **MI read fails** → log, alert, do nothing in Snowflake. Yesterday's table stays in place; email goes out on yesterday's data.
- **Snowflake write fails after staging** → staging table left for diagnosis; target untouched (transaction rollback).
- **Zero-row extract** → legitimate result. Log as warning, write empty result to Snowflake. The email recipients getting an empty email is the existing customer-visible behaviour.

### Configuration (App settings, not code)

- MI connection string (Key Vault reference).
- Snowflake connection string (Key Vault reference).
- Org code (`ChickenShop`).
- Snowflake target table fully-qualified name.
- Schedule expression.

## 6. Org provisioning and deployment

### Provisioning sequence — per environment (UAT first, then Prod)

1. `core.AddOrganisation @OrganisationName='Chicken Shop', @OrganisationCode=<new uniqueidentifier>`. Returns OrgID; client DB provisioned automatically via the existing infrastructure (state PENDING → CREATING → ACTIVE).
2. Lookup MarketMan integration: `SELECT IntegrationID FROM core.core.Integrations WHERE IntegrationName = 'MarketMan001'`.
3. `core.MapOrganisationToIntegration @OrganisationID, @IntegrationID`. Provisions `int_marketman001` schema in the Chicken Shop client DB and seeds `StagingControl` / `EntityMappings`.
4. Configure MarketMan API credentials for Chicken Shop's separate account (location of run-time credentials to be confirmed during planning).
5. Deploy Yooz-specific objects (scripts below).
6. Run initial MarketMan DV load.
7. Populate reference tables via the separate data-entry mechanism. Until populated, extract returns zero rows — safe failure mode.
8. Schedule the Azure Function in the Functions layer.

### Deployment scripts — `ClaudeDevelopment/integrations/ChickenShop/`

| Script | Purpose | Idempotent |
|---|---|---|
| `01_reference_yooz_tables.sql` | DDL for the three `reference.YOOZ_*` tables | `IF NOT EXISTS` guards |
| `02_extract_schema_and_view.sql` | `CREATE SCHEMA extract`, `CREATE OR ALTER VIEW extract.V_YOOZ_PO` | `CREATE OR ALTER`; schema guarded |
| `03_provision_chickenshop.sql` | Provisioning sequence (steps 1–3) parameterised by env | Existence-checked before each SP call |
| `04_validation_queries.sql` | Read-only checks: row counts per join, sample extract output, schema audit of verification-flagged columns | Always safe |
| `DEPLOY.txt` | Deploy order and env-specific notes | — |

All scripts use unqualified two-part names (e.g. `reference.YOOZ_MAPS`, `extract.V_YOOZ_PO`) per project rules. They run inside the Chicken Shop client DB.

### Environment progression

- **DEV** — provision org, deploy scripts, sample MarketMan data (with a test API key if Chicken Shop's prod key shouldn't touch DEV), verify view produces sensible output.
- **UAT** — full provision with real MarketMan credentials. Azure Function runs in a UAT slot writing to a UAT Snowflake target (e.g. `MARKETMAN_PO_YOOZ_UAT`). Side-by-side comparison with Matillion output for ≥ 1 week before cutover.
- **Prod** — provision org, deploy scripts, point Function at production Snowflake target. Cutover day: disable Matillion job, enable Function, monitor for ≥ 3 days before declaring done.

### Cutover and rollback

- **Side-by-side run** during UAT to confirm zero functional diff against Matillion.
- **Rollback** = re-enable Matillion job, disable Function. Snowflake target is full-refreshed on each Matillion run, so a single run restores prior behaviour. No data to unwind.
- **Org deletion** as a worst-case is supported by the existing platform; the Chicken Shop org is isolated from TRC, so removing it has no other impact.

## 7. Risks and verification work

To fold into the implementation plan as upfront tasks before code is written.

| # | Item | Verification method | Mitigation if it fails |
|---|---|---|---|
| 1 | DV columns flagged "Verify" in §4 actually exist in `SAT_STOCKORDER` / `SAT_INVITEM_STOCKORDER` / `SAT_INVENTORYITEMS` | MCP `describe_table` against a Chicken-Shop-shaped MarketMan DB (Three Rocks Cafe in UAT is the closest stand-in until Chicken Shop is provisioned) | Extend MarketMan001 `EntityMappings` to land the missing columns, or hard-code `''` and document the gap |
| 2 | `MARKETMAN_PO_YOOZ` Snowflake DDL — column types, precision, nullability | `SHOW COLUMNS` / `DESCRIBE TABLE` from the customer or via the Functions layer's existing Snowflake connection | Function adjusts casts on the write side; view stays unchanged |
| 3 | MarketMan POs actually flow for Chicken Shop's MarketMan account | One DV load against the new org's API key; sample `SAT_STOCKORDER` | Escalate to MarketMan integration debugging — out of scope for this work |
| 4 | The full allowed-vendor list (only Bidfood + Yes Chef visible in the export sample) | Re-read further into the Matillion job's filter conditions, or ask the customer | Populates `YOOZ_ALLOWED_VENDORS` seed data |
| 5 | MarketMan→Yooz `ORGUNIT` mapping rows for Chicken Shop's sites | Read existing `marketman_yooz_maps` rows in Snowflake | Customer provides before first valid extract; until then sites map to NULL `ORGUNIT_CODE` |

### Known v1 limitations

- `yoozHistDays` is hard-coded to 1. Backfills require a different mechanism.
- The GL mapping key fallback (`PC_` + product_code + optional `_src_key`) preserves Matillion's brittleness exactly. Worth a future cleanup once we know whether the ambiguous-product-code case actually fires.
- No row-count anomaly alerting (e.g. "200 rows yesterday, 0 today"). Out of scope for v1; can be added Function-side later.

## 8. Out of scope

- The data-entry mechanism for `reference.YOOZ_*` tables.
- Replacing the Snowflake email task.
- Migrating any other Matillion job (NCR / Tevalis / Deliveroo / Yext, the Yooz mapping rebuild job).
- Generalising the `extract` schema pattern to other XMS BI orgs. The convention is introduced cleanly so future customers can reuse it, but multi-org rollout is deferred — premature.
- The `AGG_Switch_Processing` step from Matillion's master job. It's a Snowflake-DV maintenance step with no XMS BI equivalent (XMS BI's DV does not use Matillion's aggregation-switch pattern).
