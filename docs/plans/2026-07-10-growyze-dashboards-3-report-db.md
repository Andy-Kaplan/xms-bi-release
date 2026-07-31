# Growyze Dashboards — Plan 3: Report DB Wiring

> **REV 2 — 2026-07-31.** Rev 1 (2026-07-10) was written for **2 orgs** against a report DB that has since
> moved (O8's Marge Brut and O32's Pantry COGS both landed), and it wired **two cards that are provably
> blank**. Every "verified current state" figure below was **re-measured on 2026-07-31**, not carried over.
> See §Rev 2 changes for what changed and why. Rev 1's task shapes survive; its facts largely did not.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire Kati's 3-dashboard default pack (Overview / Sales & Profitability / Inventory Control) into the
microservice **Report DB** for **all five Growyze organisations**, so the cards built in Plans 1–2 render and are
navigable in the dashboard UI.

**Architecture:** The Report DB (`report`) is an **Azure SQL Database on `xms-sql-fog-uat`** — NOT the Managed
Instance. Dashboards resolve through: `BiConfig` (org→MI DB) → `VisualisationConfig` (org card-type grant) →
`VisualisationDataSetMap` (dataset→card) → `DashboardGrid`/`DashboardGridItem`/`DashboardGridFilter` (layout) →
`OrganisationDashboardConfig` (names the dashboard) → `DashboardGroup` + `OrganisationDashboardGroupMapping`
(navigation visibility — **load-bearing**). A dashboard renders only if its config row is joined to a visible group.

**Tech Stack:** T-SQL run **directly** against `report` via `Invoke-Sqlcmd` with the
`AZURE_MICROSERVICE_UAT_{SERVER,USER,PASSWORD}` env vars — the MI PowerShell runners do NOT reach it and the
`mcp__microservice-uat-report__query` tool is **read-only**, used for verification only. Idempotent
`IF NOT EXISTS` / `MERGE` on natural keys.

---

## Rev 2 changes (all measured, not inferred)

| # | Rev 1 said | Measured 2026-07-31 | Consequence |
|---|---|---|---|
| 1 | 2 target orgs | **5** Growyze orgs | Whole plan widened; org table below is the authority |
| 2 | — | **Ibis Heathrow (20) has NO report-DB presence at all**: no `BiConfig` row, no `VisualisationConfig` grant, no `DashboardGroup`, no dashboard | New **Task 1b** provisions it. Decision 2026-07-31: provision it |
| 3 | `OakVineInvTotalCost` on Overview + Inventory | **Renders blank on all 5 orgs** — `F_INV_DAILY_DETAIL.UOM_COST` is 100% NULL, *every row, all time* (11,549 / 113,412 / 31,144 / 4,927 / 4,850). It also `SUM`s a **per-unit cost with no quantity**, so it is not a stock value even when populated, and it snapshots `MAX(BUSINESS_DATE)` which holds only 5–262 rows | **DROPPED from the pack** (decision 2026-07-31). Overview 9→8 items, Inventory 10→9. Raised as [O37](../outstanding/O37-f-inv-daily-detail-uom-cost-null.md) |
| 4 | `InvWasteCost` on Overview + Inventory | Reads **£185.60 / £0.00 / £5.72 / £15.41 / £0.00** (Padel / Oak & Vine / Dirty Sixth / Heathrow / Gloucester). The query is **correct** — it uses `ABS(WASTE_QTY)`; Growyze simply carries almost no waste | **KEPT** (decision 2026-07-31). An honest £0 is a legitimate reading and it populates as waste data arrives |
| 5 | 22 datasets incl. `(GrowyzeProductsCompFilter, 14)` in `VisualisationDataSetMap` | **Filters need NO grant and NO dataset-map row.** Proved by observation: Gloucester renders 3 Pantry COGS filters with **no card-type-14 grant and no `VisualisationDataSetMap` rows** for them | FilterList row removed from Task 2. It would have silently no-op'd on 3 of 5 orgs (no type-14 grant to join to) |
| 6 | "both orgs already have the 4 older Growyze dashboards" | Padel **5**, Dirty Sixth **5**, Oak & Vine **11**, Gloucester **2**, Heathrow **0** | `SortOrder` 10/11/12 would have **collided** with Oak & Vine's `Weekly P&L` (10). Task 3 now computes `MAX(SortOrder)+10` per org |
| 7 | Missing card type: 6 (Heatmap) on both | Per-org gaps are all different — see the grant matrix | Task 1 grants per org, not a flat pair |
| 8 | — | **The 9 reused shared datasets carry ZERO source scoping** (0 of 16 LIVE query rows have the resolver, `int_growyze001`, `BOTTOM_SRC`, or any `SRC` reference) | Decision 2026-07-31: **accept the mix**; see §The shared-dataset audit |
| 9 | — | `GrowyzeHighestVenue` labels Oak & Vine's one Growyze location **"Ibis Gloucester Rd"** | New **Task 1c** fixes it via `MICROSERVICE_NAME` on the **MI** (decision 2026-07-31) |
| 10 | Report DB is on `xms-mssql-ne-uat` | It is **`xms-sql-fog-uat`** | Connection detail corrected |

---

## Target orgs — verified 2026-07-31

Report-DB `OrganisationId` == the GUID inside the MI database name.

| Org | Name | `OrganisationId` | MI prefix | `BiConfig` | "All Dashboards" group | Existing dashboards | Max `SortOrder` |
|---|---|---|---|---|---|---|---|
| 10 | Padel Social | `94A4B719-EB0F-421F-AD03-ABECDD888B14` | `20260310` | `20251208` ← **WRONG** ([O34](../outstanding/O34-padel-biconfig-wrong-dbprefix.md)) | `68635668-BC52-F111-8EF3-000D3AB5729E` | 5 | 4 |
| 16 | The Oak & Vine | `7ED2E768-0D22-F111-832F-000D3AB27D87` | `20260317` | `20260317` ✓ | `59635668-BC52-F111-8EF3-000D3AB5729E` | 11 | 100 |
| 18 | Dirty Sixth | `7B50D717-124C-4902-ADD2-439A9310326A` | `20260327` | `20260327` ✓ | `64635668-BC52-F111-8EF3-000D3AB5729E` | 5 | 0 |
| 20 | Ibis Heathrow | `7CE02464-9A7E-F111-B337-002248A1EC3D` | `20260722` | **ABSENT** | **ABSENT** | 0 | — |
| 21 | Ibis Gloucester Road | `67CA4E6F-9A7E-F111-B337-002248A1EC3D` | `20260722` | `20260722` ✓ | `27570C33-838B-F111-B337-002248A01454` | 2 | 0 |

> ⚠️ **Ibis Heathrow's GUID is `7CE02464-…`, not `67CA4E6F-…`.** The two Ibis orgs share the `20260722` prefix and
> their GUIDs differ only after the first block. Getting this wrong writes Heathrow's config onto Gloucester.

## Card-type grant matrix — verified 2026-07-31

The pack needs card types **2, 3, 4, 6, 8, 9, 10, 11**. FilterList (14) is **not** required (see Rev 2 change 5).

| Org | Currently granted | **Missing → grant in Task 1** |
|---|---|---|
| 10 Padel | 1,2,3,4,8,9,10,11,14 | **6** |
| 16 Oak & Vine | 1,2,3,6,7,8,9,10,11 | **4** |
| 18 Dirty Sixth | 1,2,3,4,8,9,10,11,14 | **6** |
| 20 Heathrow | *(none)* | **2,3,4,6,8,9,10,11** |
| 21 Gloucester | 1,3,4,9,10 | **2,6,8,11** |

## Card-type reference (`VisualisationProcedure.VisualisationId`) — verified 2026-07-31
`1 BarChartCard · 2 CombinedChartCard · 3 CustomDataGrid · 4 CustomGroupedDataGrid · 5 CustomPinnedDataGrid ·
6 HeatmapCard · 7 LineChartCard · 8 MultiLineChartCard · 9 PieChartCard · 10 SingleKPICard ·
11 StackedBarChartCard · 12 StatCard · 13 TreeViewCard · 15 RadarChartCard · 16 StaticBoxCard · 17 MarkdownCard`

> There is **no `VisualisationId = 14`** row in `VisualisationProcedure` — FilterList has no card SP, which is
> exactly why filters resolve without a grant.

## Pack dataset inventory — all 18 confirmed LIVE on the MI, 2026-07-31

| Dataset | Card type | id | Origin |
|---|---|---|---|
| `GrowyzeProfit`, `GrowyzeProfitPct` | SingleKPICard | 10 | Plan 1 |
| `GrowyzeSalesByCategory` | PieChartCard | 9 | Plan 1 |
| `GrowyzeActiveStocktakes`, `GrowyzeDeliveriesValue`, `GrowyzeAvgCostSpend`, `GrowyzeBestCategory`, `GrowyzeTopRevenueItem`, `GrowyzeHighestGPItem`, `GrowyzeMostSoldItem`, `GrowyzeLowestItem`, `GrowyzeHighestVenue`, `GrowyzeLowestVenue` | SingleKPICard | 10 | Plan 2 |
| `GrowyzeCategoryStockTrend`, `GrowyzeMenuEngineering` | CustomDataGrid | 3 | Plan 2 |
| `GrowyzeMenuProfitabilityTrend` | CombinedChartCard | 2 | Plan 2 |
| `GrowyzeSalesHeatmap` | HeatmapCard | 6 | Plan 2 |
| `GrowyzeProductsCompFilter` | FilterList | — | Plan 2 (filter — no grant, no map row) |

`ParameterMappings` is `set` on all 17 card datasets and `NULL` on the FilterList — the documented exception.

## Already-wired datasets — do NOT re-map (verified 2026-07-31)

| Org | Pack datasets already present |
|---|---|
| 10 Padel | `InvKPIGrouped`(4), `InvCOGSByCategory`(9,11), `InvStockActivity`(8,11), `InvWasteCost`(10), `ProductComparison`(3) |
| 18 Dirty Sixth | identical to Padel |
| 16 Oak & Vine | `OakVineMenuAvgItemValue`(10) only |
| 21 Gloucester | *(none)* |
| 20 Heathrow | *(none)* |

Every idempotency guard is `WHERE NOT EXISTS`, so re-mapping is harmless — this table is for expected-delta
arithmetic in the verification steps, not for hand-pruning the insert lists.

---

## The shared-dataset audit (the Plan 3 prerequisite the pick-up notes demanded)

Nine datasets are reused rather than rebuilt: `NetSales`, `OakVineMenuAvgItemValue`, `OakVineInvTotalCost`,
`InvWasteCost`, `InvStockActivity`, `InvKPIGrouped`, `InvCOGSByCategory`, `InvUseAnalisys`, `ProductComparison`
— **16 LIVE query rows** in total. Audited 2026-07-31 against the six rules in the O5 pick-up notes.

| Rule | Verdict |
|---|---|
| 1. Carry the resolver | ❌ **0 of 16.** No `Integrations` resolver, no `int_growyze001`, no `BOTTOM_SRC`, **no `SRC` reference of any kind.** Every one is source-blind |
| 2. Never filter `BOTTOM_LEVEL_NAME` | ✅ **0 offenders.** A first pass flagged `InvUseAnalisys`; reading the SQL showed it is a **select-list column** (`Column4`, labelled "Category"), not a filter. Flag withdrawn |
| 3. Category grain `TOP` | ✅ `InvCOGSByCategory` uses `COALESCE(TOP_MICROSERVICE_NAME, TOP_NAME)`. `InvKPIGrouped`/`ProductComparison` use `MIDDLE_1`, but as **grid grouping columns**, not a "best category" claim — low risk, left alone |
| 4. `CAST(<date> AS DATE)` on `CALENDAR` | ⚠️ **0 of 16 cast**, and 15 of 16 join `CALENDAR`. Inert today — `ORDER_DATE`/`COUNT_DATE`/`BUSINESS_DATE` are midnight-only on these facts — i.e. exactly the "works by luck" state rule 4 exists to pre-empt. Not fixed here (shared) |
| 5. `ParameterMappings` set | ✅ **all 16** |
| 6. Coverage-matched ratios | ✅ `InvCOGSByCategory` guards `NULLIF(AVG_NET_COST,0) IS NOT NULL` in **both** the body and the header subquery. `OakVineMenuAvgItemValue` divides `NET_VALUE`/`QUANTITY` over one row population |

**Rule 1's blast radius, measured — it only bites on Oak & Vine.**

| Org | `F_LINEITEM_15MIN` by `SRC` | `F_PRODUCT_MARGIN_DAY` by product `BOTTOM_SRC` | Inventory (`F_INV_COUNTS_DAY` rows) |
|---|---|---|---|
| 10 Padel | Growyze £211,378.22 | Growyze £183,544.64 | Growyze 8,083 |
| 16 **Oak & Vine** | **NCRAloha £2,728,513.80 + Mews £55,221.06; Growyze £0** | **NCRAloha £1,365,706.40 + Mews £55,221.06; Growyze £0** | **Growyze 465 + MarketMan 468 + 18,252 orphans** |
| 18 Dirty Sixth | Growyze £466,582.61 | Growyze £405,060.55 | Growyze 1,335 |
| 20 Heathrow | *(no rows)* | *(no rows)* | Growyze 178 |
| 21 Gloucester | Mews £33,144.54 | Mews £33,144.54 | Growyze 308 |

Padel, Dirty Sixth, Heathrow and Gloucester carry **exactly one source per fact**, so source-blindness is a
provable **no-op** on four of five orgs. Oak & Vine is the only org where it mixes: its sales are
NCRAloha+Mews with **literally zero** Growyze line items, and its inventory counts are Growyze and MarketMan at
roughly 1:1.

**Decision 2026-07-31 — accept the mix and label honestly.** `NetSales`, `InvKPIGrouped`, `InvStockActivity`,
`InvCOGSByCategory`, `InvUseAnalisys`, `ProductComparison` and `InvWasteCost` are **deliberately generic,
org-wide** cards; on a multi-source org, org-wide totals are arguably their intent. The three dashboard names —
**Overview**, **Sales & Profitability**, **Inventory Control** — are already source-neutral and make no Growyze
claim, so nothing needs renaming. The Growyze-specific cards beside them **are** resolver-scoped (Plan 2), so a
reader comparing them sees org-wide vs source-scoped, not a contradiction.

> ⚠️ This is an accepted, measured risk, **not** a clean bill of health. If a future card labelled "Growyze"
> reuses one of these nine, rule 1 applies again and this decision does not cover it.

**Two findings from executing the audit that no rule would have caught** — both are why the audit was run:

1. **`OakVineInvTotalCost` is dead** — dropped from the pack (Rev 2 change 3), raised as O37.
2. **Oak & Vine: 18,252 of 19,185 `F_INV_COUNTS_DAY` rows (95%) are real orphans** — a non-sentinel
   `INVITEM_HUB_ID` with no `D_INVITEM` row (`INVITEM_HUB_ID = CONVERT(BINARY(32), -999)` returns **0**, so this is
   not the sentinel). `InvUseAnalisys` inner-guards on `invitem.BOTTOM_INVITEM_NAME IS NOT NULL`, so on Oak & Vine
   that grid shows **~5% of its counts**. Separate root cause, raised as [O38](../outstanding/O38-oakvine-invitem-orphan-counts.md).

---

## Pack grid identity (fixed constant GUIDs — shared by all five orgs)

Grids are **not** org-scoped, and sharing is the established pattern (Padel and Dirty Sixth already share
`7C83F241-…` for Cost & Margins). One grid per dashboard, five orgs pointing at it.

- Overview `B0A1D000-0001-4A00-9E00-000000000001`
- Sales & Profitability `B0A1D000-0002-4A00-9E00-000000000002`
- Inventory Control `B0A1D000-0003-4A00-9E00-000000000003`

## Global Constraints (Report DB INSERT rules — `docs/microservice-report-database.md` §2 + report-db-notes)

- **`TransactionId` is IDENTITY** on every dbo table — never list it in an INSERT.
- **PK `{Table}Id` defaults `NEWSEQUENTIALID()`** — never specify it, EXCEPT the three grid IDs above, where a
  fixed constant buys stable idempotency across orgs and re-runs.
- **`IsDeleted` is `bit NOT NULL` with no default** — pass `0` explicitly in every INSERT.
- **`DateCreated` / `DateUpdated` default `SYSUTCDATETIME()`** — omit on insert.
- **Every script** wraps in `SET NOCOUNT ON; SET XACT_ABORT ON; BEGIN TRANSACTION … COMMIT` with a `TRY/CATCH`
  rollback (per the Marge Brut reference `integrations/MargeBrut/03_margebrut_report_config.sql`).
- **`DataSet` token = `DataSetName` on the MI** — must match `core.core.VisualisationQueries` exactly
  (case/spelling, including the `InvUseAnalisys` misspelling). This is the cross-system key.
- **`DashboardGridFilter.DataSet` must equal the per-card `FilterDefinitions` key** — see
  `memory/feedback_date_filters_via_parametermappings.md`.
- **Prerequisite:** Plans 1 **and** 2 are deployed to the MI (done 2026-07-30/31) — every `DataSet` wired here
  resolves to a LIVE MI vis query, re-confirmed above.

## Release & File Structure
Report-DB scripts are **not** part of the MI `releases/v1.1/` runner set (different server, run by hand). They live
in `ClaudeDevelopment/integrations/Growyze/report_config/` and are tracked in `QUERY_STATUS.md`.
Deploy order = Task order (1 → 1b → 1c → 2 → 3 → 4 → 5 → 6 → 7).

## Self-Contained Test Pattern
Each task ends with **read-only MCP verification** via `mcp__microservice-uat-report__query` (`database="report"`).
Writes go through `Invoke-Sqlcmd`.

---

## Task 1: Prerequisites — fix Padel `DbPrefix` + grant the missing card types

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/01_prereqs_biconfig_visconfig.sql`

**Interfaces:** Corrects `BiConfig.DbPrefix` for Padel (`20251208`→`20260310`, [O34](../outstanding/O34-padel-biconfig-wrong-dbprefix.md)) and grants each org
the card types it is missing, per the grant matrix. Data-driven from a `@Grants` table so the per-org gaps are
explicit and re-runnable.

- [ ] **Step 1 — Baseline** (record before touching anything):
```sql
SELECT OrganisationId, DbPrefix FROM dbo.BiConfig
WHERE OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7ED2E768-0D22-F111-832F-000D3AB27D87',
                         '7B50D717-124C-4902-ADD2-439A9310326A','7CE02464-9A7E-F111-B337-002248A1EC3D',
                         '67CA4E6F-9A7E-F111-B337-002248A1EC3D');
SELECT OrganisationId, VisualisationId FROM dbo.VisualisationConfig
WHERE IsDeleted = 0 AND VisualisationId IN (2,3,4,6,8,9,10,11)
  AND OrganisationId IN (/* same five */) ORDER BY OrganisationId, VisualisationId;
```
Expected before: Padel `20251208`; Heathrow **absent from both**; grants exactly as the matrix.

- [ ] **Step 2 — Write `01_prereqs_biconfig_visconfig.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    -- 1a. Fix Padel DbPrefix (O34). Guarded so a re-run is a no-op.
    UPDATE dbo.BiConfig
       SET DbPrefix = N'20260310', DateUpdated = SYSUTCDATETIME()
     WHERE OrganisationId = '94A4B719-EB0F-421F-AD03-ABECDD888B14'
       AND IsDeleted = 0 AND DbPrefix <> N'20260310';   -- old value: 20251208

    -- 1b. Grant the pack's card types where missing. Heathrow gets the full set (Task 1b
    --     creates its BiConfig row; grants are independent of it).
    DECLARE @Grants TABLE (OrganisationId UNIQUEIDENTIFIER, VisualisationId INT);
    INSERT INTO @Grants VALUES
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14', 6),                                  -- Padel
        ('7ED2E768-0D22-F111-832F-000D3AB27D87', 4),                                  -- Oak & Vine
        ('7B50D717-124C-4902-ADD2-439A9310326A', 6),                                  -- Dirty Sixth
        ('7CE02464-9A7E-F111-B337-002248A1EC3D', 2), ('7CE02464-9A7E-F111-B337-002248A1EC3D', 3),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D', 4), ('7CE02464-9A7E-F111-B337-002248A1EC3D', 6),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D', 8), ('7CE02464-9A7E-F111-B337-002248A1EC3D', 9),
        ('7CE02464-9A7E-F111-B337-002248A1EC3D',10), ('7CE02464-9A7E-F111-B337-002248A1EC3D',11),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', 2), ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', 6),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D', 8), ('67CA4E6F-9A7E-F111-B337-002248A1EC3D',11);

    INSERT INTO dbo.VisualisationConfig (OrganisationId, VisualisationId, ActiveFrom, IsDeleted)
    SELECT g.OrganisationId, g.VisualisationId, SYSUTCDATETIME(), 0
    FROM @Grants g
    WHERE NOT EXISTS (SELECT 1 FROM dbo.VisualisationConfig vc
        WHERE vc.OrganisationId = g.OrganisationId AND vc.VisualisationId = g.VisualisationId
          AND vc.IsDeleted = 0);

    COMMIT TRANSACTION;
    PRINT 'Task 1: Padel DbPrefix fixed + card types granted.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

- [ ] **Step 3 — MCP-verify:** Padel `DbPrefix = 20260310`; every org holds all of 2,3,4,6,8,9,10,11.
```sql
SELECT o.OrganisationId, v.VisualisationId
FROM (VALUES ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7ED2E768-0D22-F111-832F-000D3AB27D87'),
             ('7B50D717-124C-4902-ADD2-439A9310326A'),('7CE02464-9A7E-F111-B337-002248A1EC3D'),
             ('67CA4E6F-9A7E-F111-B337-002248A1EC3D')) o(OrganisationId)
CROSS JOIN (VALUES (2),(3),(4),(6),(8),(9),(10),(11)) v(VisualisationId)
WHERE NOT EXISTS (SELECT 1 FROM dbo.VisualisationConfig vc
    WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = v.VisualisationId AND vc.IsDeleted = 0);
```
Expected: **0 rows**.

---

## Task 1b: Provision Ibis Heathrow in the report DB

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/01b_provision_heathrow.sql`

**Interfaces:** Heathrow (`7CE02464-…`) has **no** `BiConfig` row and **no** `DashboardGroup`. Creates both so
Tasks 3–6 have something to attach to. Card-type grants are already handled in Task 1. This is the only task in
the plan that creates **org-level** config rather than adding to existing config — treat it as the highest-risk
step and verify before continuing.

> ⚠️ **Use `7CE02464-9A7E-F111-B337-002248A1EC3D`.** Gloucester is `67CA4E6F-…`; both use prefix `20260722`.
> Verify against `core.core.Organisations` before running: Heathrow's MI DB is
> `20260722_XMS_7CE02464-9A7E-F111-B337-002248A1EC3D`.

- [ ] **Step 1 — Baseline:** confirm the absence you are about to fix, and that no soft-deleted row exists to revive
      instead:
```sql
SELECT * FROM dbo.BiConfig       WHERE OrganisationId = '7CE02464-9A7E-F111-B337-002248A1EC3D';
SELECT * FROM dbo.DashboardGroup WHERE OrganisationId = '7CE02464-9A7E-F111-B337-002248A1EC3D';
```
Expected: **0 rows each**. If a soft-deleted row appears, revive it (`IsDeleted = 0`) rather than inserting.

- [ ] **Step 2 — Write `01b_provision_heathrow.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @Org UNIQUEIDENTIFIER = '7CE02464-9A7E-F111-B337-002248A1EC3D';

    -- 1b-i. BiConfig. Prefix 20260722 -> 20260722_XMS_7CE02464-... (confirmed to exist on the MI).
    IF NOT EXISTS (SELECT 1 FROM dbo.BiConfig WHERE OrganisationId = @Org AND IsDeleted = 0)
        INSERT INTO dbo.BiConfig (OrganisationId, DbPrefix, IsDeleted)
        VALUES (@Org, N'20260722', 0);

    -- 1b-ii. Root "All Dashboards" group, matching the shape the other four orgs use
    --        (ParentDashboardGroupId NULL, StaffId NULL = org-wide, discoverable).
    --        PK omitted deliberately: NEWSEQUENTIALID() default, never a hardcoded GUID.
    IF NOT EXISTS (SELECT 1 FROM dbo.DashboardGroup
                   WHERE OrganisationId = @Org AND Name = N'All Dashboards'
                     AND ParentDashboardGroupId IS NULL AND StaffId IS NULL AND IsDeleted = 0)
        INSERT INTO dbo.DashboardGroup (OrganisationId, Name, ParentDashboardGroupId, StaffId, IsDeleted)
        VALUES (@Org, N'All Dashboards', NULL, NULL, 0);

    COMMIT TRANSACTION;
    PRINT 'Task 1b: Heathrow BiConfig + All Dashboards group provisioned.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

> **`DashboardGroup` hazard, inherited from the report-DB notes:** a group with `OrganisationId IS NULL` leaks
> dashboards cross-org. `@Org` is NOT NULL here by construction — but if the insert is ever edited, keep it that way.
> Also do **not** reach for `DashboardGroup_AddEntity`; it always throws. `DashboardGroup_Create` is the working SP
> if you prefer an SP path.

- [ ] **Step 3 — MCP-verify:** exactly one `BiConfig` row (`DbPrefix = 20260722`) and exactly one root
      `All Dashboards` group for `7CE02464-…`; **and Gloucester (`67CA4E6F-…`) is unchanged** — one `BiConfig`
      row still reading `20260722` and still exactly one group. This second half is the check that catches a
      GUID mix-up.

---

## Task 1c: Fix the misleading Growyze venue label on Oak & Vine (MI, not report DB)

**Files:** Create `ClaudeDevelopment/integrations/Growyze/22_oakvine_growyze_location_name.sql`

**Interfaces:** Orgs 16/20/21 share one Growyze tenant, and Oak & Vine's single Growyze location is named
**"Ibis Gloucester Rd"** — so `GrowyzeHighestVenue` renders *"Ibis Gloucester Rd · £8,911"* on Oak & Vine. The
money is right; the label is not. Fix by setting `MICROSERVICE_NAME` on that location's satellite row —
`MICROSERVICE_NAME` is the display-name resolver and is **manual-entry MDM by design**, so setting it by hand is
the sanctioned mechanism. Related to [O24](../outstanding/O24-oak-vine-growyze-mews-mapping.md).

> ⚠️ **This runs against the MI, not `report`** — it is here because it gates the venue cards that Tasks 5–6 wire.
> ⚠️ **Never set `MICROSERVICE_NAME` from a staging pipeline.** O23's lesson: Growyze staging hardcoding the
> literal `'growyze'` collapsed three supplier bars into one. This is a one-row, by-hand correction.
> ⚠️ `D_LOCATION` is a **Dimension** step, so `core.sp_ProcessPresentation` rebuilds it truncate-and-rebuild
> **unconditionally** — no load window needed. The label changes on the next presentation rebuild.

- [ ] **Step 1 — Identify the row and agree the name.** Confirm exactly one Growyze location on Oak & Vine and
      capture its current name and hub id before writing anything. Decide the replacement label with Andy (the
      venue is a real place; do not invent a name).
- [ ] **Step 2 — Write the script** as a keyed, idempotent `UPDATE` on the single `SAT_LOCATION` current row,
      recording the old value in a comment for rollback.
- [ ] **Step 3 — Rebuild `D_LOCATION`** and verify the card renders the corrected label.
- [ ] **Step 4 — Verify no collateral:** Padel/Dirty/Heathrow/Gloucester venue names unchanged, and Oak & Vine's
      Mews/NCRAloha locations untouched (this org has 9 locations — only the one Growyze row may change).

---

## Task 2: Dataset wiring (`VisualisationDataSetMap`) — all five orgs

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/02_dataset_map.sql`

**Interfaces:** Adds the pack's **26 (dataset, card-type) pairs** for all five orgs, joined to the matching
`VisualisationConfig` row by card type. Depends on Task 1 (a missing grant means the join finds nothing and the
dataset is **silently skipped** — which is why Step 3's check is a NOT EXISTS over the full cross product, not a
row count). `OakVineInvTotalCost` is **absent by decision**; `GrowyzeProductsCompFilter` is **absent because
filters need no map row**.

- [ ] **Step 1 — Baseline:**
```sql
SELECT vc.OrganisationId, m.DataSet, vc.VisualisationId
FROM dbo.VisualisationDataSetMap m
JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
WHERE m.IsDeleted = 0 AND vc.IsDeleted = 0 AND m.DataSet LIKE 'Growyze%'
  AND vc.OrganisationId IN (/* the five */);
```
Expected before: **0 rows** (no `Growyze*` dataset is mapped on any org).

- [ ] **Step 2 — Write `02_dataset_map.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER);
    INSERT INTO @Orgs VALUES
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),   -- 10 Padel Social
        ('7ED2E768-0D22-F111-832F-000D3AB27D87'),   -- 16 The Oak & Vine
        ('7B50D717-124C-4902-ADD2-439A9310326A'),   -- 18 Dirty Sixth
        ('7CE02464-9A7E-F111-B337-002248A1EC3D'),   -- 20 Ibis Heathrow
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D');   -- 21 Ibis Gloucester Road

    DECLARE @DataSets TABLE (DataSet NVARCHAR(1024), VisualisationId INT);
    INSERT INTO @DataSets VALUES
        -- SingleKPICard (10) - 15
        (N'NetSales', 10), (N'OakVineMenuAvgItemValue', 10), (N'InvWasteCost', 10),
        (N'GrowyzeProfit', 10), (N'GrowyzeProfitPct', 10), (N'GrowyzeActiveStocktakes', 10),
        (N'GrowyzeDeliveriesValue', 10), (N'GrowyzeAvgCostSpend', 10), (N'GrowyzeBestCategory', 10),
        (N'GrowyzeTopRevenueItem', 10), (N'GrowyzeHighestGPItem', 10), (N'GrowyzeMostSoldItem', 10),
        (N'GrowyzeLowestItem', 10), (N'GrowyzeHighestVenue', 10), (N'GrowyzeLowestVenue', 10),
        -- PieChartCard (9) - 2
        (N'GrowyzeSalesByCategory', 9), (N'InvCOGSByCategory', 9),
        -- CombinedChartCard (2) - 1
        (N'GrowyzeMenuProfitabilityTrend', 2),
        -- CustomDataGrid (3) - 4
        (N'GrowyzeCategoryStockTrend', 3), (N'GrowyzeMenuEngineering', 3),
        (N'InvUseAnalisys', 3), (N'ProductComparison', 3),
        -- CustomGroupedDataGrid (4) - 1
        (N'InvKPIGrouped', 4),
        -- HeatmapCard (6) - 1
        (N'GrowyzeSalesHeatmap', 6),
        -- MultiLineChartCard (8) + StackedBarChartCard (11): same dataset, two placements - 2
        (N'InvStockActivity', 8), (N'InvStockActivity', 11);

    INSERT INTO dbo.VisualisationDataSetMap (VisualisationConfigId, DataSet, IsDeleted)
    SELECT vc.VisualisationConfigId, ds.DataSet, 0
    FROM @Orgs o
    CROSS JOIN @DataSets ds
    JOIN dbo.VisualisationConfig vc
        ON vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = ds.VisualisationId
       AND vc.IsDeleted = 0
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.VisualisationDataSetMap m
        WHERE m.VisualisationConfigId = vc.VisualisationConfigId AND m.DataSet = ds.DataSet
          AND m.IsDeleted = 0);

    COMMIT TRANSACTION;
    PRINT 'Task 2: pack datasets wired for all five orgs.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```
> **Notes.** `InvUseAnalisys` keeps the existing misspelling — it must match the MI `DataSetName` exactly.
> `InvStockActivity` is wired under **both** 8 and 11: two distinct LIVE MI query rows for one `DataSetName`,
> placed on Overview (MultiLine) and Inventory (StackedBar) respectively.

- [ ] **Step 3 — MCP-verify (NOT EXISTS over the full 26 × 5 cross product — the only form that catches a
      silently-skipped dataset):**
```sql
SELECT o.OrganisationId, ds.DataSet, ds.VisualisationId
FROM (VALUES ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7ED2E768-0D22-F111-832F-000D3AB27D87'),
             ('7B50D717-124C-4902-ADD2-439A9310326A'),('7CE02464-9A7E-F111-B337-002248A1EC3D'),
             ('67CA4E6F-9A7E-F111-B337-002248A1EC3D')) o(OrganisationId)
CROSS JOIN (VALUES (N'NetSales',10),(N'OakVineMenuAvgItemValue',10),(N'InvWasteCost',10),
    (N'GrowyzeProfit',10),(N'GrowyzeProfitPct',10),(N'GrowyzeActiveStocktakes',10),
    (N'GrowyzeDeliveriesValue',10),(N'GrowyzeAvgCostSpend',10),(N'GrowyzeBestCategory',10),
    (N'GrowyzeTopRevenueItem',10),(N'GrowyzeHighestGPItem',10),(N'GrowyzeMostSoldItem',10),
    (N'GrowyzeLowestItem',10),(N'GrowyzeHighestVenue',10),(N'GrowyzeLowestVenue',10),
    (N'GrowyzeSalesByCategory',9),(N'InvCOGSByCategory',9),(N'GrowyzeMenuProfitabilityTrend',2),
    (N'GrowyzeCategoryStockTrend',3),(N'GrowyzeMenuEngineering',3),(N'InvUseAnalisys',3),
    (N'ProductComparison',3),(N'InvKPIGrouped',4),(N'GrowyzeSalesHeatmap',6),
    (N'InvStockActivity',8),(N'InvStockActivity',11)) ds(DataSet, VisualisationId)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap m
    JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
    WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = ds.VisualisationId
      AND m.DataSet = ds.DataSet AND m.IsDeleted = 0 AND vc.IsDeleted = 0);
```
Expected: **0 rows** (130 pairs all present).

---

## Task 3: Grids, dashboard configs, and group mappings (structure)

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/03_grids_configs_groups.sql`

**Interfaces:** Creates the 3 shared pack grids (fixed GUIDs), **15** `OrganisationDashboardConfig` rows
(3 dashboards × 5 orgs) pointing at them, and maps all 15 into each org's `All Dashboards` group. `SortOrder` is
computed as **that org's current `MAX(SortOrder)` + 10/20/30** so the pack lands after existing dashboards on
every org — a fixed 10/11/12 would have collided with Oak & Vine's `Weekly P&L` (10). No `DashboardGroup`
creation here: four orgs already have one and Task 1b made Heathrow's.

- [ ] **Step 1 — Write `03_grids_configs_groups.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @G_Overview  UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';
    DECLARE @G_Sales     UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
    DECLARE @G_Inventory UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';

    -- 3a. Grids (shared across all five orgs; fixed GUIDs for stable idempotency)
    DECLARE @Grids TABLE (DashboardGridId UNIQUEIDENTIFIER);
    INSERT INTO @Grids VALUES (@G_Overview),(@G_Sales),(@G_Inventory);
    INSERT INTO dbo.DashboardGrid (DashboardGridId, Container, Spacing, Columns, IsDeleted)
    SELECT g.DashboardGridId, 1, 2, 12, 0 FROM @Grids g
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGrid d WHERE d.DashboardGridId = g.DashboardGridId);

    -- 3b. One config row per (org, dashboard). SortOrder = org's current max + 10/20/30.
    --     Names are deliberately SOURCE-NEUTRAL - see the shared-dataset audit decision.
    DECLARE @Orgs TABLE (OrganisationId UNIQUEIDENTIFIER);
    INSERT INTO @Orgs VALUES
        ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7ED2E768-0D22-F111-832F-000D3AB27D87'),
        ('7B50D717-124C-4902-ADD2-439A9310326A'),('7CE02464-9A7E-F111-B337-002248A1EC3D'),
        ('67CA4E6F-9A7E-F111-B337-002248A1EC3D');

    DECLARE @Dash TABLE (DashboardGridId UNIQUEIDENTIFIER, Name NVARCHAR(256),
                         IconName NVARCHAR(254), Offset INT);
    INSERT INTO @Dash VALUES
        (@G_Overview,  N'Overview',              N'Dashboard',  10),
        (@G_Sales,     N'Sales & Profitability', N'TrendingUp', 20),
        (@G_Inventory, N'Inventory Control',     N'Inventory',  30);

    INSERT INTO dbo.OrganisationDashboardConfig
        (DashboardGridId, OrganisationId, Name, IconName, SortOrder, IsDeleted)
    SELECT d.DashboardGridId, o.OrganisationId, d.Name, d.IconName,
           ISNULL((SELECT MAX(x.SortOrder) FROM dbo.OrganisationDashboardConfig x
                   WHERE x.OrganisationId = o.OrganisationId AND x.IsDeleted = 0), 0) + d.Offset,
           0
    FROM @Orgs o CROSS JOIN @Dash d
    WHERE NOT EXISTS (SELECT 1 FROM dbo.OrganisationDashboardConfig e
        WHERE e.OrganisationId = o.OrganisationId AND e.Name = d.Name AND e.IsDeleted = 0);

    -- 3c. Map each new config into that org's root "All Dashboards" group.
    MERGE INTO dbo.OrganisationDashboardGroupMapping AS tgt
    USING (
        SELECT g.DashboardGroupId, odc.OrganisationDashboardConfigId
        FROM dbo.OrganisationDashboardConfig odc
        JOIN dbo.DashboardGroup g
            ON g.OrganisationId = odc.OrganisationId AND g.Name = N'All Dashboards'
           AND g.ParentDashboardGroupId IS NULL AND g.StaffId IS NULL AND g.IsDeleted = 0
        WHERE odc.OrganisationId IN (
                '94A4B719-EB0F-421F-AD03-ABECDD888B14','7ED2E768-0D22-F111-832F-000D3AB27D87',
                '7B50D717-124C-4902-ADD2-439A9310326A','7CE02464-9A7E-F111-B337-002248A1EC3D',
                '67CA4E6F-9A7E-F111-B337-002248A1EC3D')
          AND odc.Name IN (N'Overview', N'Sales & Profitability', N'Inventory Control')
          AND odc.IsDeleted = 0
    ) AS src
        ON tgt.DashboardGroupId = src.DashboardGroupId
       AND tgt.OrganisationDashboardConfigId = src.OrganisationDashboardConfigId
    WHEN MATCHED AND tgt.IsDeleted = 1 THEN UPDATE SET IsDeleted = 0, DateUpdated = SYSUTCDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (DashboardGroupId, OrganisationDashboardConfigId, IsDeleted)
        VALUES (src.DashboardGroupId, src.OrganisationDashboardConfigId, 0);

    COMMIT TRANSACTION;
    PRINT 'Task 3: grids + 15 configs + group mappings created.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

- [ ] **Step 2 — MCP-verify:** 3 grids exist; **15** new config rows (3 per org); **0 ungrouped** (Task 7 Step 1);
      and each org's pack `SortOrder` values all exceed that org's pre-existing max (Padel > 4, Oak & Vine > 100,
      Dirty Sixth > 0, Gloucester > 0, Heathrow from 0).

---

## Task 4: Overview dashboard — items + filters

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/04_items_overview.sql`

**Interfaces:** Populates grid `B0A1D000-0001-…` (shared by all five orgs). Layout: **6 KPIs** (md=4 — two rows of
three, since dropping `OakVineInvTotalCost` left 6 not 7) → stock-activity MultiLine (md=12) →
category-stock-trend grid (md=12). Filters: `Locations`, `InvItems`.

- [ ] **Step 1 — Write `04_items_overview.sql`**
```sql
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0001-4A00-9E00-000000000001';

    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
                          ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items VALUES
        (10, N'NetSales',                  1, 12, 6, 4, 4, 4),
        (10, N'GrowyzeProfit',             2, 12, 6, 4, 4, 4),
        (10, N'GrowyzeProfitPct',          3, 12, 6, 4, 4, 4),
        (10, N'GrowyzeActiveStocktakes',   4, 12, 6, 4, 4, 4),
        (10, N'GrowyzeDeliveriesValue',    5, 12, 6, 4, 4, 4),
        (10, N'InvWasteCost',              6, 12, 6, 4, 4, 4),
        ( 8, N'InvStockActivity',          7, 12,12,12,12,12),
        ( 3, N'GrowyzeCategoryStockTrend', 8, 12,12,12,12,12);

    INSERT INTO dbo.DashboardGridItem (DashboardGridId, VisualisationId, DataSet, SortOrder,
                                       ExtraSmall, Small, Medium, Large, ExtraLarge, IsDeleted)
    SELECT @Grid, i.VisualisationId, i.DataSet, i.SortOrder,
           i.ExtraSmall, i.Small, i.Medium, i.Large, i.ExtraLarge, 0
    FROM @Items i
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGridItem d
        WHERE d.DashboardGridId = @Grid AND d.DataSet = i.DataSet
          AND d.VisualisationId = i.VisualisationId AND d.IsDeleted = 0);

    DECLARE @Filters TABLE (DataSet NVARCHAR(1024), SortOrder INT);
    INSERT INTO @Filters VALUES (N'Locations', 1), (N'InvItems', 2);
    INSERT INTO dbo.DashboardGridFilter (DashboardGridId, DataSet, SortOrder, IsDeleted)
    SELECT @Grid, f.DataSet, f.SortOrder, 0 FROM @Filters f
    WHERE NOT EXISTS (SELECT 1 FROM dbo.DashboardGridFilter d
        WHERE d.DashboardGridId = @Grid AND d.DataSet = f.DataSet AND d.IsDeleted = 0);

    COMMIT TRANSACTION;
    PRINT 'Task 4: Overview - 8 items + 2 filters placed.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE(); THROW;
END CATCH
```

- [ ] **Step 2 — MCP-verify:** **8** items + 2 filters on the Overview grid.

---

## Task 5: Sales & Profitability dashboard — items + filters

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/05_items_sales.sql`

**Interfaces:** Populates grid `B0A1D000-0002-…`. Layout: 6 KPIs (md=2) → 4 Menu-Item-Highlight KPIs (md=3) →
SalesByCategory pie (md=5) + ProductComparison grid (md=7) → MenuProfitabilityTrend combined (md=12) →
MenuEngineering grid (md=12) → SalesHeatmap (md=12). Filters: `Locations`, `Products`,
`GrowyzeProductsCompFilter`. Same transaction/guard shape as Task 4.

> Per the O35 decision (2026-07-31): `GrowyzeAvgCostSpend`, `GrowyzeBestCategory`, `GrowyzeHighestGPItem`,
> `GrowyzeMenuProfitabilityTrend` and `GrowyzeMenuEngineering` **are** wired to both Ibis orgs, where they render
> the explicit `No cost data` state rather than a blank. That is deliberate and verified.
> Per the intra-day finding: `GrowyzeSalesHeatmap` is a **recent-window** view on Growyze-sourced orgs (only ~14%
> of Padel's PROD lines carry a timestamp, because `DL_SALES` is a rolling window and history never backfills).
> Its `Description` already says so. POS-sourced orgs are unaffected.

- [ ] **Step 1 — Write `05_items_sales.sql`**
```sql
    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0002-4A00-9E00-000000000002';
    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
                          ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items VALUES
        (10, N'NetSales',                       1, 12, 6, 2, 2, 2),
        (10, N'GrowyzeProfit',                  2, 12, 6, 2, 2, 2),
        (10, N'GrowyzeProfitPct',               3, 12, 6, 2, 2, 2),
        (10, N'OakVineMenuAvgItemValue',        4, 12, 6, 2, 2, 2),
        (10, N'GrowyzeAvgCostSpend',            5, 12, 6, 2, 2, 2),
        (10, N'GrowyzeBestCategory',            6, 12, 6, 2, 2, 2),
        (10, N'GrowyzeTopRevenueItem',          7, 12, 6, 3, 3, 3),
        (10, N'GrowyzeHighestGPItem',           8, 12, 6, 3, 3, 3),
        (10, N'GrowyzeMostSoldItem',            9, 12, 6, 3, 3, 3),
        (10, N'GrowyzeLowestItem',             10, 12, 6, 3, 3, 3),
        ( 9, N'GrowyzeSalesByCategory',        11, 12,12, 5, 5, 5),
        ( 3, N'ProductComparison',             12, 12,12, 7, 7, 7),
        ( 2, N'GrowyzeMenuProfitabilityTrend', 13, 12,12,12,12,12),
        ( 3, N'GrowyzeMenuEngineering',        14, 12,12,12,12,12),
        ( 6, N'GrowyzeSalesHeatmap',           15, 12,12,12,12,12);
    -- INSERT ... DashboardGridItem with the same NOT EXISTS guard as Task 4
    -- Filters: (N'Locations',1),(N'Products',2),(N'GrowyzeProductsCompFilter',3)
    --          -> DashboardGridFilter, same guard
```
Wrap in the same `SET NOCOUNT/XACT_ABORT` + `TRY/CATCH` transaction as Task 4, with both the `DashboardGridItem`
insert and the `DashboardGridFilter` insert.

- [ ] **Step 2 — MCP-verify:** 15 items + 3 filters on the Sales grid.

---

## Task 6: Inventory Control dashboard — items + filters

**Files:** Create `ClaudeDevelopment/integrations/Growyze/report_config/06_items_inventory.sql`

**Interfaces:** Populates grid `B0A1D000-0003-…`. Layout: **3 KPIs** (md=4 — `OakVineInvTotalCost` dropped) →
StockActivity stacked-bar (md=12) → Highest/Lowest venue KPIs (md=6 each) → InvKPIGrouped grid (md=12) →
InvCOGSByCategory pie (md=6) + InvUseAnalisys grid (md=6). Filters: `Locations`, `InvItems`.

- [ ] **Step 1 — Write `06_items_inventory.sql`**
```sql
    DECLARE @Grid UNIQUEIDENTIFIER = 'B0A1D000-0003-4A00-9E00-000000000003';
    DECLARE @Items TABLE (VisualisationId INT, DataSet NVARCHAR(1024), SortOrder INT,
                          ExtraSmall INT, Small INT, Medium INT, Large INT, ExtraLarge INT);
    INSERT INTO @Items VALUES
        (10, N'GrowyzeActiveStocktakes', 1, 12, 6, 4, 4, 4),
        (10, N'GrowyzeDeliveriesValue',  2, 12, 6, 4, 4, 4),
        (10, N'InvWasteCost',            3, 12, 6, 4, 4, 4),
        (11, N'InvStockActivity',        4, 12,12,12,12,12),
        (10, N'GrowyzeHighestVenue',     5, 12, 6, 6, 6, 6),
        (10, N'GrowyzeLowestVenue',      6, 12, 6, 6, 6, 6),
        ( 4, N'InvKPIGrouped',           7, 12,12,12,12,12),
        ( 9, N'InvCOGSByCategory',       8, 12,12, 6, 6, 6),
        ( 3, N'InvUseAnalisys',          9, 12,12, 6, 6, 6);
    -- INSERT ... DashboardGridItem with the NOT EXISTS guard
    -- Filters: (N'Locations',1),(N'InvItems',2) -> DashboardGridFilter, same guard
```
Wrap identically to Tasks 4–5.

> **`InvStockActivity` appears on both Overview (MultiLine = 8) and Inventory (StackedBar = 11).** These are two
> distinct LIVE MI query rows for one `DataSetName`; the `DashboardGridItem` guard is per
> (grid, dataset, **VisualisationId**), so both placements coexist, and Task 2 maps the dataset under both ids.
>
> **Known reading caveats on this dashboard, all measured — none is a wiring fault:**
> - `InvWasteCost` reads ~£0 on every org (Growyze carries almost no waste).
> - `InvUseAnalisys` shows only ~5% of Oak & Vine's counts ([O38](../outstanding/O38-oakvine-invitem-orphan-counts.md)) and is exposed to
>   [O33](../outstanding/O33-inv-counts-day-movement-fanout.md)'s count fan-out via its `RN = 1` pick.
> - `InvKPIGrouped`/`InvCOGSByCategory`/`InvStockActivity` are org-wide, not Growyze-scoped — on Oak & Vine they
>   include MarketMan inventory and NCRAloha/Mews sales. Accepted by decision; see the shared-dataset audit.

- [ ] **Step 2 — MCP-verify:** **9** items + 2 filters on the Inventory grid.

---

## Task 7: End-to-end render verification

**Files:** verification only (no new script). Every query runs read-only via
`mcp__microservice-uat-report__query` (`database="report"`).

- [ ] **Step 1 — No ungrouped configs** (the O13 failure mode) — expected **0 rows**:
```sql
SELECT odc.OrganisationId, odc.Name
FROM dbo.OrganisationDashboardConfig odc
WHERE odc.OrganisationId IN ('94A4B719-EB0F-421F-AD03-ABECDD888B14','7ED2E768-0D22-F111-832F-000D3AB27D87',
                             '7B50D717-124C-4902-ADD2-439A9310326A','7CE02464-9A7E-F111-B337-002248A1EC3D',
                             '67CA4E6F-9A7E-F111-B337-002248A1EC3D')
  AND odc.IsDeleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.OrganisationDashboardGroupMapping m
    JOIN dbo.DashboardGroup g ON g.DashboardGroupId = m.DashboardGroupId AND g.IsDeleted = 0
    WHERE m.OrganisationDashboardConfigId = odc.OrganisationDashboardConfigId AND m.IsDeleted = 0);
```

- [ ] **Step 2 — Every placed card is granted to every org** — expected **0 rows**:
```sql
SELECT DISTINCT o.OrganisationId, dgi.DataSet, dgi.VisualisationId
FROM dbo.DashboardGridItem dgi
CROSS JOIN (VALUES ('94A4B719-EB0F-421F-AD03-ABECDD888B14'),('7ED2E768-0D22-F111-832F-000D3AB27D87'),
                   ('7B50D717-124C-4902-ADD2-439A9310326A'),('7CE02464-9A7E-F111-B337-002248A1EC3D'),
                   ('67CA4E6F-9A7E-F111-B337-002248A1EC3D')) o(OrganisationId)
WHERE dgi.DashboardGridId IN ('B0A1D000-0001-4A00-9E00-000000000001',
                              'B0A1D000-0002-4A00-9E00-000000000002',
                              'B0A1D000-0003-4A00-9E00-000000000003')
  AND dgi.IsDeleted = 0
  AND NOT EXISTS (
    SELECT 1 FROM dbo.VisualisationDataSetMap m
    JOIN dbo.VisualisationConfig vc ON vc.VisualisationConfigId = m.VisualisationConfigId
    WHERE vc.OrganisationId = o.OrganisationId AND vc.VisualisationId = dgi.VisualisationId
      AND m.DataSet = dgi.DataSet AND m.IsDeleted = 0 AND vc.IsDeleted = 0);
```

- [ ] **Step 3 — Every wired `DataSet` resolves to a LIVE MI vis query.** Cross-system check, so it needs a read
      on **both** servers: pull the distinct `(DataSet, VisualisationId)` pairs from `DashboardGridItem` plus the
      distinct `DataSet` values from `DashboardGridFilter` for the three pack grids, then confirm each has a
      `Status = 'LIVE'` row in `core.core.VisualisationQueries` with the matching `VisualizationType`
      (`FilterList` for the filters). **This is the check that catches a `DataSet` spelling drift**, which Step 2
      cannot see — Step 2 only proves the report DB agrees with itself.

- [ ] **Step 4 — `BiConfig` resolves to a database that exists** (the O34 class of error, for all five orgs):
      each org's `DbPrefix + '_XMS_' + OrganisationId` must name a real MI database. Expected: 5 of 5 resolve.

- [ ] **Step 5 — Nothing pre-existing regressed.** Re-run the "existing dashboards" and
      "already-wired datasets" baselines from the org table above and confirm they are **unchanged**: Padel 5,
      Oak & Vine 11, Dirty Sixth 5, Gloucester 2 pre-existing dashboards, all still group-mapped. The pack is
      additive; anything that moved is a defect.

- [ ] **Step 6 — Front-end smoke test** (developer, in the UI as each org): Overview / Sales & Profitability /
      Inventory Control appear in the nav and every card loads. **Expected readings, so a wrong number is
      recognisable rather than merely plausible** — these are the deployed-template figures verified 2026-07-31:

  | Card | Padel | Oak & Vine | Dirty Sixth | Heathrow | Gloucester |
  |---|---|---|---|---|---|
  | Active Stocktakes | `2 / 3` | `1 / 1` | `1 / 1` | `1 / 1` | `1 / 1` |
  | Deliveries | £47,395 | £22,577 | £68,248 | £61,826 | £22,577 |
  | Avg Cost Spend | £1.25 | £1.31 | £1.83 | `—` | `No cost data` |
  | Best Category | Beverages · 82.0% | Food · 81.8% | Food · 79.1% | `—` | `No cost data` |
  | Highest GP% Item | Off Peak Court Time | Sparkling Water | Pulled Pork Nuggets | `—` | `No cost data` |
  | Waste Cost | ~£186 | £0 | ~£6 | ~£15 | £0 |

  Also expect `GrowyzeProfit`/`GrowyzeProfitPct`: Padel £148,897.95 / 80.8%, Oak & Vine £905,503.87 / 82.9%,
  Dirty Sixth £317,414.99 / 78.4%, Heathrow blank, Gloucester `No cost data`. Record any card that departs from
  this table and trace it: a **blank** card → a missing grant or a `DataSet` mismatch (Steps 2–3);
  a **wrong number** → an MI-side data change, which Step 5's witness should already have flagged.

---

## Verification Checklist (Plan 3 done when all true)
- [ ] Padel `BiConfig.DbPrefix = 20260310`; all five orgs hold card types 2,3,4,6,8,9,10,11 (Task 1 Step 3 → 0 rows).
- [ ] Heathrow has a `BiConfig` row and an `All Dashboards` group; **Gloucester unchanged** (Task 1b Step 3).
- [ ] Oak & Vine's Growyze venue label reads correctly, other orgs' labels unchanged (Task 1c).
- [ ] All 26 pack `(dataset, card-type)` pairs wired for all 5 orgs (Task 2 Step 3 → 0 rows).
- [ ] 3 grids + 15 configs created; 0 ungrouped (Task 7 Step 1 → 0 rows).
- [ ] Overview 8 items / 2 filters; Sales 15 / 3; Inventory 9 / 2.
- [ ] Every wired `DataSet` resolves to a LIVE MI vis query of the matching type (Task 7 Step 3).
- [ ] Pre-existing dashboards and datasets unchanged (Task 7 Step 5).
- [ ] Front-end shows all 3 dashboards for all 5 orgs, readings matching the Step 6 table.
- [ ] `QUERY_STATUS.md` updated; O5 detail file and ledger row updated; O37/O38 raised.

## Rollback
Soft-delete the additions: `UPDATE … SET IsDeleted = 1` on the new `OrganisationDashboardGroupMapping`,
`OrganisationDashboardConfig`, `DashboardGridItem`, `DashboardGridFilter` and `DashboardGrid` rows (keyed by the
three fixed grid GUIDs and the three dashboard names) and the new `VisualisationDataSetMap` rows. Leave the
`VisualisationConfig` grants — they are additive and harmless. Revert Padel's `DbPrefix` only if it regresses (it
was already wrong). **Heathrow's `BiConfig` row and group (Task 1b) are the only org-level creations** — soft-delete
both to undo. Task 1c is a one-row MI `UPDATE` with the old value recorded in the script.

> ⚠️ **Soft-deleting an `OrganisationDashboardGroupMapping` does nothing** — the mapping's `IsDeleted` is never
> filtered by the reader. To actually hide a pack dashboard, soft-delete its `OrganisationDashboardConfig` row.

---

## Self-Review
- **Spec coverage:** every mockup card maps to a placed item (reused, Plan-1/2-built, or here-wired) or a
  documented deferral (Ingredient Based Sales, Fastest-Growing, transfers, discounts) or a **measured, decided
  drop** (`OakVineInvTotalCost`). All 3 dashboards + navigation covered for all 5 orgs. ✓
- **Every fact re-measured.** The org table, grant matrix, already-wired list, card types and expected front-end
  readings were all read from UAT on 2026-07-31, not carried from rev 1. Rev 1's stale facts would have caused a
  `SortOrder` collision, 4 silently-skipped datasets on Gloucester, a no-op FilterList map row, and two blank cards.
- **Placeholder scan:** Tasks 5–6 give the full item/filter tables and back-reference Task 4's exact
  INSERT+guard shape rather than repeating it — a precise reference, not a TODO. ✓
- **The verification catches what the last three verifiers missed.** Task 2 Step 3 and Task 7 Step 2 are
  `NOT EXISTS` over the **full cross product**, so they cannot report a confident PASS over zero datasets — the
  `99_verify_plan2.sql` trap. Task 7 Step 3 reads the **other** server, so it is an independent witness rather
  than the report DB agreeing with itself. Task 7 Step 5 is a regression witness. Task 7 Step 6 states expected
  values, so a wrong number is falsifiable and not merely plausible. ✓
- **Risk:** additive on four orgs. The two genuine risks are **Task 1b** (first org-level creation — hence its
  own baseline and its "Gloucester unchanged" counter-check, because the two Ibis GUIDs differ only in the first
  block) and **Task 1c** (an MI write requiring a presentation rebuild). Everything else is new grids + new
  per-org configs mapped into existing groups. ✓
- **Known-and-accepted, not hidden:** the org-wide reading of 7 shared cards on Oak & Vine; `No cost data` on the
  Ibis profit cards (O35); ~£0 waste everywhere; a recent-window heatmap on Growyze orgs; `InvUseAnalisys`
  exposure to O33/O38. Each is measured, decided and stated on the dashboard it affects. ✓

## Execution Handoff
**Rev 2 complete.** Prerequisites: Plans 1 & 2 deployed to the MI (done 2026-07-30/31; all 18 datasets
re-confirmed LIVE 2026-07-31). Report-DB scripts run **directly against `report` on `xms-sql-fog-uat`** via
`Invoke-Sqlcmd` (MI runners do not reach it; MCP there is read-only verification). Task 1c runs against the **MI**.
Deploy order: 1 → 1b → 1c → 2 → 3 → 4 → 5 → 6 → 7.
