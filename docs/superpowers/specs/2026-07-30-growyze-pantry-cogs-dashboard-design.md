# Growyze Pantry COGS dashboard — design

**Date:** 2026-07-30
**Author:** Andy Kaplan (with Claude)
**Status:** Design approved
**Ledger:** new Release item (see §11); cross-linked to **Claude Nine O25** — Scope Growyze consolidated COGS reporting opportunity
**Related:** O5 (Growyze default dashboards), O8 (Marge Brut dashboard), O6 (Growyze staging fixes), O23 (Growyze supplier `BOTTOM_LEVEL`)
**Source analysis:** `Claude Nine/docs/research/2026-07-30-growyze-raddish-cogs-workbook-analysis.md`

---

## 1. Goal

Replace the two spreadsheets Raddish (a Growyze customer) produce by hand every month per venue, with a
single XMS BI dashboard driven by the Growyze feed already landing in the warehouse.

The two documents being replaced:

| Document | What it does today |
|---|---|
| **Pantry Invoice** workbook | Growyze COGS export, hand-reformatted; `SUMIF` of delivered value by Category-Subcategory; invoice raised in TPP from those totals |
| **Consumption Report** workbook | The invoice sheet pasted into a template; 6 client-facing charts across 3 visible tabs; prior-month history pasted in as literals |

Both are maintained against a 6-page staff SOP. The June 2026 pack carried **six defects, all from one root
cause** — a column was dropped from a paste and the template only half re-pointed. Consequences included
22% of consumption (£24,199.53) silently absent from every chart, a 3-month trend showing a ~12% fall when
consumption actually rose ~14%, and every figure on the "Budget Impact" tab wrong (£49,437.83 shown against
£63,902.25 actual across 32 items, one bar reading 142.8% of category spend). Nothing in the SOP could catch
any of it: the totals check reconciles the invoice, which was unaffected, and the column check covers only
the two columns that happened to be correct.

**That is the case for this work.** The arithmetic is not hard. The value is removing the paste, holding each
measure in exactly one place, and making the failure modes loud instead of silent.

### 1.1 The measures, as Raddish define them

From the SOP, and the definitional point that drives the whole design:

- **COG Spend** = value *delivered* in the period = **what Raddish bill the client for**.
- **COG Sold** = value *consumed* in the period = **what the client actually used**.
- The two deliberately do not reconcile. Spend drives the invoice; Sold drives the insights.

June 2026, venue "Scale": Spend £106,967.73, Sold £103,195.86 (as exported), closing stock at cost
£41,399.18, across 230 items.

### 1.2 Valuation basis — verified against the June data

Growyze values **every** money column as `qty × latest cost price in the reporting period`. There is no
separate invoice-value path. Confirmed item by item:

| Item | Check | Result |
|---|---|---|
| Milk Chocolate Almonds | deliveries 165 × 9 | 1,485 = COG Spend ✔ |
| Milk Chocolate Almonds | closing 20 × 9 | 180 = cost of closing stock ✔ |
| Milk Chocolate Almonds | consumption 175 × 9 | 1,575 = COG Sold ✔ |
| Nana Joes Granola | 35 × 10.71 | 374.85 ✔ |
| Zolo Espresso Beans | 145 × 22 | 3,190 ✔ |
| Steven Smith Masala Chai | 20 × 18 | 360 ✔ |

So the fact needs **exactly one cost per item per period** — latest cost effective at or before period end —
and all value columns derive from it. This is the single most important reconciliation constraint in the
design, and it is the reason we derive the fact ourselves rather than reusing `F_INV_COUNTS_DAY` (§2.1).

---

## 2. Settled decisions

| # | Decision | Choice |
|---|---|---|
| D1 | Scope | **Both halves, insights first.** Insights pack built first; the billing totals-by-category view is included as a card but invoices continue to be raised in TPP |
| D2 | Period grain | **Stocktake pair** — one row per item per location per stocktake-to-stocktake period. Not calendar month |
| D3 | Negative COG Sold | **Flag only — fix upstream in Growyze.** No adjustments table, no write path. The exceptions card is the mechanism that drives corrections back into the source |
| D4 | Relationship to O5 | **New pack, additive, built in parallel.** Its own Release ledger item, cross-linked to Claude Nine O25 |
| D5 | Consolidation | **Consolidated from the start** — venue is a multi-select filter and there is a by-venue comparison card |
| D6 | Consolidation shape | **Venues as locations inside one org database.** One XMS BI org per Growyze account; no cross-database / parent-org machinery |
| D7 | Dashboard shape | **One dashboard, everything on it** — 12 cards plus 3 filter widgets |
| D8 | Fact derivation | **From the Data Vault directly** (`SAT_STOCKEVENT` + `SAT_INVITEM`), not from `F_INV_COUNTS_DAY` — see §2.1 |

### 2.1 Why derive from the Data Vault (D8)

`F_INV_COUNTS_DAY` is remarkably close to the required grain. Its build
(`8_PresentationControl.sql` step 9) assigns every movement event to a `count_group` — the window *between*
two stocktakes — then `LAG`s over `COUNT` events, emitting one row per item per location per stocktake with
`PREVIOUS_COUNT`, `ACTUAL_COUNT`, `ORDER_QTY`, `TRANSFER_QTY`, `WASTE_QTY`, `UOM_COST` and
`DAYS_SINCE_LAST_COUNT`. Reusing it would have been cheaper.

Two things make it the wrong base:

1. **Cost basis.** It resolves cost through `COALESCE(InvLocCost, InvCost)` — an **average** over
   `@InvItemAvgDays`. Growyze uses *latest cost in period* (§1.2). Reconciliation to Growyze's own export is
   the acceptance test, and an average cannot satisfy it.
2. **Period boundaries are per item.** It `LAG`s partitioned by item, so each item gets its own ragged
   period. Raddish pick two stocktakes for the **whole venue** and all 230 items share `27 May – 30 Jun`.

Deriving our own step also insulates us from `F_INV_COUNTS_DAY` defects. The cost is duplicated
period-windowing logic that could drift from step 9; accepted, and noted as a risk (§10).

> **Master-file discrepancy to resolve during the build.** `8_PresentationControl.sql` still shows the
> `InvLocCost` / `SAT_INVREPORT` cost path, while `docs/presentation-and-visualisation.md` describes the
> deployed step 9 reading `SAT_INVITEM.UOM_COST` directly via an `InvItemCost` CTE. The master release file
> appears behind the deployed state. Confirm which is live before relying on either.

---

## 3. Architecture

Single integration, single database. No cross-feed MDM alignment — which is what made O8's Marge Brut hard —
because Raddish's pack contains no POS turnover at all. Category and subcategory come from Growyze natively
rather than a hand-maintained group mapping.

```
Growyze API → int_growyze001.DL_*  →  stage  →  datavault
                                                 SAT_STOCKEVENT   COUNT / ORDER(+DELIVERY) / TRANSFER / WASTE / SALE
                                                 SAT_INVITEM      UOM_COST (SCD2, post-O5 pack-size fix)
                                                 LNK_* + location and product-category tiers
                                                       │
                                   NEW  PresentationControl step (tier 110)
                                                       ▼
                                   NEW  presentation.F_COGS_PERIOD
                                        grain: INVITEM × LOCATION × stocktake period
                                                       ▼
                                   15 VisualisationQueries → one "Pantry COGS" dashboard
```

Named `F_COGS_PERIOD`, not `F_GRYZ_*` — the grain is source-agnostic and MarketMan could feed it later. It
carries a `SOURCE` column and **every vis query scopes on it**. That is the O8 lesson: NCRAloha's `TOP_NAME`
is also `'Food'` (£916,792.80 against the Mews group's £281.62), and an unscoped query read cost of sales as
~0.5%.

---

## 4. `presentation.F_COGS_PERIOD`

Clustered on `(PERIOD_END_DATE, LOCATION_HUB_ID)`, non-clustered on `INVITEM_HUB_ID` — mirroring
`F_INV_COUNTS_DAY`.

| Group | Columns | Type |
|---|---|---|
| Keys | `INVITEM_HUB_ID`, `LOCATION_HUB_ID` | `binary(32)` NOT NULL |
| Period | `PERIOD_START_DATE`, `PERIOD_END_DATE` | `datetime2(7)` |
| | `PERIOD_DAYS`, `PERIOD_SEQ` | `int` |
| | `PERIOD_MONTH` | `date` — month of the closing stocktake |
| | `PERIOD_LABEL` | `varchar(50)` — e.g. `27 May – 30 Jun 2026` |
| Provenance | `SOURCE` | `varchar(100)` — integration schema |
| | `STANDARDISED_UOM` | `varchar(255)` |
| Category | `CATEGORY`, `SUBCATEGORY` | `varchar(255)` |
| | `REPORT_GROUP` | `varchar(255)` — materialised, see §6 |
| Quantities | `OPENING_QTY`, `DELIVERY_QTY`, `TRANSFER_QTY`, `CLOSING_QTY`, `CONSUMPTION_QTY`, `WASTE_QTY`, `SALE_QTY`, `THEO_CLOSING_QTY`, `VARIANCE_QTY` | `decimal(38,6)` |
| Cost | `UOM_COST` | `decimal(38,6)` |
| Values | `OPENING_VALUE`, `DELIVERY_VALUE`, `COG_SPEND`, `COG_SOLD`, `CLOSING_VALUE`, `WASTE_VALUE`, `VARIANCE_VALUE` | `decimal(38,6)` |
| Flags | `IS_NEGATIVE_COGS`, `HAS_ZERO_COST`, `IS_UNCOUNTED`, `IS_FIRST_PERIOD` | `bit` |

### 4.1 Derivations

```
CONSUMPTION_QTY   = OPENING_QTY + DELIVERY_QTY + TRANSFER_QTY − CLOSING_QTY
THEO_CLOSING_QTY  = OPENING_QTY + DELIVERY_QTY + TRANSFER_QTY − WASTE_QTY − SALE_QTY
VARIANCE_QTY      = CLOSING_QTY − THEO_CLOSING_QTY

UOM_COST          = SAT_INVITEM.UOM_COST / conversion_factor      -- latest at or before PERIOD_END_DATE

OPENING_VALUE     = OPENING_QTY      × UOM_COST
DELIVERY_VALUE    = DELIVERY_QTY     × UOM_COST
COG_SPEND         = (DELIVERY_QTY − TRANSFER_QTY) × UOM_COST
COG_SOLD          = CONSUMPTION_QTY  × UOM_COST
CLOSING_VALUE     = CLOSING_QTY      × UOM_COST
WASTE_VALUE       = WASTE_QTY        × UOM_COST
VARIANCE_VALUE    = VARIANCE_QTY     × UOM_COST

IS_NEGATIVE_COGS  = CONSUMPTION_QTY < 0
HAS_ZERO_COST     = UOM_COST IS NULL OR UOM_COST = 0
IS_UNCOUNTED      = item not physically counted at the closing boundary (carried forward)
IS_FIRST_PERIOD   = no prior count exists for this item at this location
```

The `UOM_COST` line preserves O5's two-step contract **exactly**: staging removes the pack
(`price / COALESCE(NULLIF(size,0),1)`), presentation removes the unit scale (`/ conversion_factor`).
Breaking it is how Ibis Gloucester Road read £762,277.46 instead of £8,157.61 across the same 151 lines.

`VARIANCE_QTY` is something the spreadsheet cannot produce. Raddish's "consumption" silently absorbs declared
waste and unexplained shrink together; because we hold `WASTE_QTY` and `SALE_QTY` as events we can separate
them. For a pantry there is no POS — the SOP explicitly says *leave the sales file blank* — so `SALE_QTY`
will be zero and variance is genuine shrink.

---

## 5. Period derivation — location-level boundaries

1. Distinct `COUNT` event timestamps per `LOCATION_HUB_ID` → the venue's stocktake calendar.
2. Consecutive pairs → periods (`PERIOD_START_DATE`, `PERIOD_END_DATE`).
3. Per item: opening = its count at or before period start; closing = its count at or before period end,
   **carried forward** where the item was not counted at that boundary (`IS_UNCOUNTED = 1`).
4. Movements summed over `(PERIOD_START_DATE, PERIOD_END_DATE]`.
5. `PERIOD_SEQ` = dense rank of period per location, most recent = 1.

Where no prior count exists at all, `OPENING_QTY = 0` and `IS_FIRST_PERIOD = 1`, so the row can be excluded
rather than silently reading as enormous consumption.

### 5.0 Unbounded read, full refresh

Step 9 bounds its read with `SE.[EVENT_TS] BETWEEN @StartDate AND @EndDate`, sourced from the ephemeral
`STOCKEVENT_START` / `STOCKEVENT_END` `GlobalParameters` (the load window — typically the DL table's date
range). Our fact must hold **every** period, because the 3-month comparison card reads history from the fact
rather than from pasted literals. So the build step reads `SAT_STOCKEVENT` **unbounded** and full-refreshes.

At pantry scale this is trivial (hundreds of items × a handful of venues × ~12 periods a year), and it means
the fact is self-consistent after any load rather than depending on how wide the last window happened to be.
It also sidesteps the O8 trap that a Fact rebuild's `DELETE` only spans the current result's MIN..MAX — with a
full-history result, the delete spans the full history.

### 5.1 Category source columns

`D_INVITEM` exposes `BOTTOM_INVITEM_NAME` / `MIDDLE_1_NAME` / `TOP_NAME` with parallel
`*_MICROSERVICE_NAME` columns, and the platform convention is `COALESCE(MICROSERVICE_NAME, native_NAME)`.

**We deliberately use the native names only:**

```
ITEM_NAME    = BOTTOM_INVITEM_NAME
SUBCATEGORY  = MIDDLE_1_NAME
CATEGORY     = TOP_NAME
```

O23 established that Growyze staging hardcodes the literal `'growyze'` into `MICROSERVICE_NAME`, and that
honouring the COALESCE collapsed three suppliers into a single bar labelled "growyze" — an empty chart traded
for a plausible wrong one. O8's group `CASE` likewise reads `TOP_NAME` directly. Verification asserts
`MICROSERVICE_NAME` is not referenced by this build step, so the trap cannot creep back in.

**Two rules to confirm against a real Growyze COGS export rather than infer:**

- **Carry-forward.** Growyze shows all 230 items with both opening and closing, so it evidently carries
  forward, but this should be verified.
- **Transfer sign convention.** Growyze's export column is `Deliveries - Transfers value`; the June data has
  transfers zero throughout, so the sign could not be verified from it.

O8 hit the sibling of the boundary bug — opening and closing resolving to the *same* month-end stocktake,
collapsing consumption to purchases. Check 6 in §8 exists to make that impossible here.

### 5.1 Delivery event type — check before authoring

`docs/stockevent-ruleset.md` records that Growyze staging emits **`EVENT_TYPE = 'DELIVERY'`** in
`GRYZ_DN_EVENTS` where the canonical value is `ORDER`, fix pending in `02_staging_tier1.sql`. Step 9 sums
`ORDER_QTY` with `CASE WHEN EVENT_TYPE = 'ORDER'`, so if that is accurate then **`ORDER_QTY` is currently
zero for Growyze orgs** and deliveries survive only inside `MOVEMENT_QTY`, which sums by behaviour rather
than type. This is very likely the same territory as O8's fixed "PURCHASES ~3× low" defect.

Our build therefore reads `EVENT_TYPE IN ('ORDER','DELIVERY')`, correct either side of that fix, and check 9
asserts deliveries are non-zero for a period with known receipts. Also read
`ClaudeDevelopment/integrations/Growyze/14_dn_events_size_multiplier_fix.sql`, which touches delivery-note
event sizing, before authoring the build step.

---

## 6. Category model

Raddish report at Category, with one bucket — `Can't Live Without It` — broken out by Subcategory. Another
Growyze customer's catch-all will be named differently, so the break-out must be configuration.

```
REPORT_GROUP = CASE WHEN CATEGORY IN (<break-out list>)
                    THEN CATEGORY + ' - ' + SUBCATEGORY
                    ELSE CATEGORY END
```

**`REPORT_GROUP` is materialised on the fact, never computed in a vis query.** Forced by an O8 finding:
`BuildDynamicWhereClause` holds every mapped column in an `NVARCHAR(100)` and assigns `JSON_VALUE` straight
into it, so a longer expression is **silently truncated**. O8's ~700-character group `CASE` was unusable as a
filter column and now lives in three places that must be kept in step. Materialising it means the grouping
rule exists exactly once — the discipline the spreadsheet lacked.

Break-out list stored in `core.GlobalParameters`, keyed per organisation, read by the build step. Adding a
customer's bucket is a config row, not a code change.

**Open verification:** whether Growyze's Category *and* Subcategory both survive into the `D_INVITEM` tiers
is untested. O5's blocker 3 was category fall-through (~5% resolving to self-name, `"Other"` holding 12.7%),
and O8 grouped off `TOP_NAME` alone. If only one level lands, the break-out rule cannot work and staging
needs fixing first. Check this before authoring the build step.

**Barcode is out of v1.** Raddish's report has one and theirs is stale (0 of 139 rows matching their own
item). Growyze holds barcodes in `DL_PRODUCTS_BARCODES`, many-per-product, so joining risks fan-out — not
worth it for a column their process could not keep correct.

---

## 7. Dashboard

One dashboard, "Pantry COGS". 12 cards, 3 filter widgets, 15 `VisualisationQueries` records, all
`PantryCOGS*` datasets reading `F_COGS_PERIOD` scoped on `SOURCE`.

| Dataset | Card type | Content |
|---|---|---|
| `PantryCOGSSpendKPI` | SingleKPICard | Σ `COG_SPEND` |
| `PantryCOGSSoldKPI` | SingleKPICard | Σ `COG_SOLD` |
| `PantryCOGSClosingStockKPI` | SingleKPICard | Σ `CLOSING_VALUE` |
| `PantryCOGSVarianceKPI` | SingleKPICard | Σ `VARIANCE_VALUE` — unexplained shrink |
| `PantryCOGSConsumptionMix` | PieChartCard | `COG_SOLD` by `REPORT_GROUP` |
| `PantryCOGSPeriodComparison` | BarChartCard, 3 series | `COG_SOLD` by `REPORT_GROUP` for selected month and the two before, plus % change |
| `PantryCOGSTopItemsByCategory` | BarChartCard, 2 series | Top items: % of category units, % of category spend |
| `PantryCOGSSlowMovers` | BarChartCard | Bottom 10 by `CONSUMPTION_QTY > 0` per category |
| `PantryCOGSByVenue` | BarChartCard | `COG_SOLD` by venue — the consolidation view |
| `PantryCOGSBillingTotals` | CustomDataGrid | `COG_SPEND` by `CATEGORY - SUBCATEGORY` + grand total |
| `PantryCOGSItemTable` | CustomGroupedDataGrid | Full item table, grouped by `REPORT_GROUP` |
| `PantryCOGSExceptions` | CustomDataGrid | Negative COGS · zero cost price · uncounted · first period · blank/new subcategory |
| `PantryCOGSVenues` | FilterList | `D_LOCATION`, scoped by `SOURCE`, multi-select |
| `PantryCOGSPeriods` | FilterList | Fact `PERIOD_LABEL` ordered by `PERIOD_END_DATE` desc, default latest |
| `PantryCOGSCategories` | FilterList | Fact `REPORT_GROUP`, multi-select |

### 7.1 Filters — deliberately discrete pickers, not a date range

O8 established that dashboard date ranges come through **`ParameterMappings`**, not `FilterDefinitions`; that
`ParameterMappings = '{}'` **silently discards** picked dates; and that a naive bare-column date mapping
drops the opening month of any mid-month range while passing on whole months — i.e. it ships broken. Our
periods are discrete stocktake pairs, so a picker is both simpler and correct.

### 7.2 Platform contracts this design must honour

All established in O8 by verification rather than assumption:

1. `DashboardGridFilter.DataSet` **must equal** the per-card `FilterDefinitions` key, or the filter is never
   emitted. A key with no widget is silently dead.
2. Mapped filter and parameter column expressions must be **≤100 characters** (§6).
3. **Never return NULL as `TotalValue`** on a BarChartCard — it renders as `0.00`, asserting a wrong number
   rather than omitting one.
4. FilterClause alias contract: header-subquery aliases must match the data query.
5. `DashboardGridItem.IsDeleted` *is* honoured by `DashboardGrid_Load`, so soft-deleting a card genuinely
   hides it (unlike `OrganisationDashboardGroupMapping`).

### 7.3 The 3-period comparison

Raddish paste the previous two months in as literals; lose the file and the history is gone. Ours comes from
the fact.

Cross-venue alignment is the wrinkle — venues stocktake on different dates, so "the previous period" is not a
shared concept once several are selected. One rule rather than two behaviours: **the comparison card always
groups by `PERIOD_MONTH`** (the month the closing stocktake falls in), taking the selected month and the two
before it. The fact stays at stocktake-pair grain, which is the truth; only the comparison labels by month,
which is what the client recognises.

---

## 8. Verification

No SQL unit-test harness exists here; the house equivalent is a PASS/FAIL `99_verify` script. **It is
authored first, run against the target org, and expected to fail before the build step exists.**

| # | Check | Passes when |
|---|---|---|
| 1 | Grain / fan-out | fact rows = distinct `(INVITEM_HUB_ID, LOCATION_HUB_ID, PERIOD_END_DATE)`; `Σ CLOSING_VALUE` equals an independent recompute from the Data Vault |
| 2 | **Reconcile to Growyze** | item-level `COG_SOLD`, `COG_SPEND`, `CLOSING_VALUE` match a real Growyze COGS export for the same stocktake pair |
| 3 | Internal consistency | category subtotals = grand total = KPI, all three agreeing |
| 4 | **Coverage guard** | **0** items with movement and NULL `CATEGORY` / `REPORT_GROUP` |
| 5 | Zero-cost guard | items with movement and zero/NULL cost are *reported*, never hidden |
| 6 | Period integrity | no period where opening and closing resolve to the same stocktake; no non-positive `PERIOD_DAYS` |
| 7 | Cost basis | `UOM_COST` equals `SAT_INVITEM`'s latest value at or before `PERIOD_END_DATE`, not an average |
| 8 | Filter-column length | every mapped filter/parameter expression ≤100 characters |
| 9 | Delivery events present | `Σ DELIVERY_QTY > 0` for a period with known receipts (§5.1) |

**Check 4 is the defect that lost 22% of Raddish's consumption.** Ours must fail loudly rather than silently
drop rows. **Check 5 is their SOP check 8**, automated.

**Check 2 is the acceptance test that matters, and it has a dependency:** a Growyze COGS export for a venue
whose data we hold — either generated from a UAT Growyze org, or supplied by Kati. Without it we can prove
internal consistency but not faithful replacement. Worth requesting alongside the defect conversation.

Follow the `data-quality-tester` discipline after the first build: row counts, fan-out, null leakage,
`UOM_COST` sanity.

---

## 9. Deployment

Scripts in a new `ClaudeDevelopment/integrations/Growyze/cogs/` folder. All control-table records use
**MERGE upserts on natural keys** so every script re-runs cleanly (never bare `INSERT`).

Order — note `99_verify` runs **three** times, and why:

1. `99_verify_cogs_period.sql` → expect **FAIL** (table absent). Test-first; this is the only test harness here.
2. `PresentationTables` DDL record for `F_COGS_PERIOD` (MERGE)
3. `PresentationControl` build step, **tier 110** (MERGE) — clear of the 22 core steps and of the parent-org tiers 100–102
4. `GlobalParameters` break-out-bucket config (MERGE)
5. Deploy **that table only** for the target org
6. Presentation rebuild — `sp_ProcessPresentation @TierFilter = 110`, scoping blast radius to this change
7. `99_verify` → expect PASS on checks 1, 3, 4, 5, 6, 7, 9, 10. Check 2 is **SKIPPED** (no Growyze export).
   **Check 8 is vacuous at this point** — no `PantryCOGS%` vis rows exist yet, so it passes having tested
   nothing. Do not read its PASS as coverage.
8. 15 `VisualisationQueries` upserts (`04`–`07`)
9. `99_verify` → expect PASS **including check 8**, which is only meaningful once the vis records exist
10. Report-DB wiring — run **directly against `report`**, by hand, not via MCP or the MI runners
11. UI check in the front end, exercising all three filters

The three-run structure exists because check 8 (filter-column ≤100 chars) reads `VisualisationQueries`. A single
post-build verify would find zero `PantryCOGS%` rows and report PASS without testing the truncation trap it was
written for — a check that cannot fail is worse than no check.

Claude authors; Andy deploys via the PowerShell runner (`docs/release-guide.md` §6). MCP `execute` is
permitted on DEV/TEST/UAT only; Prod is human-run.

**Two traps to respect:** `DeployPresentationTables` **DROPs every registered table**, so ours is deployed
individually and never through the bulk procedure; and a Fact rebuild's `DELETE` only spans the current
result's MIN..MAX.

**Shape-test target: Ibis Gloucester Road (UAT org 21).** Exactly two count dates — 31 May and 30 Jun — which
is one complete stocktake period, and the org where the `UOM_COST` fix was verified (£10,175.54 and
£8,127.01). Padel Social and Dirty Sixth have more counts but stock values remain implausible
(~£587k–£1.2M, open O5 sub-item), so they cannot be used for value reconciliation.

---

## 10. Risks

| # | Risk | Mitigation |
|---|---|---|
| 1 | Growyze will not reconcile first pass — cost basis, carry-forward, transfer signs | Do check 2 as an item-level diff **before** building any card |
| 2 | Two-level category integrity unproven (O5 blocker 3) | Verify before authoring the build step; staging fix may be a prerequisite |
| 3 | `DELIVERY` vs `ORDER` event type (§5.1) | Read both values; check 9 asserts deliveries are non-zero |
| 4 | Period-windowing logic duplicated from step 9 and could drift | Documented in both places; consider consolidating once both are proven |
| 5 | Sparse stocktake cadence makes enormous periods | `PERIOD_DAYS` on the fact and surfaced in the item table so it is visible, not hidden |
| 6 | Padel / Dirty Sixth implausible stock values | Excluded from reconciliation; separate O5 sub-item |
| 7 | Concurrent Growyze presentation changes with O5 Plans 1–3 | Additive by construction; distinct object names; MERGE upserts |
| 8 | Flag-only adjustments (D3) shift work onto the Pantry Manager | Accepted decision; exceptions card is what makes it workable |
| 9 | Raddish/Scale is not an XMS BI org | Built for Growyze orgs generically, proven on UAT; onboarding Raddish is separate work and a commercial conversation |

---

## 11. Out of scope

- Raising invoices — billing totals are shown for reconciliation; invoices continue in TPP.
- An adjustments write path or UI (D3).
- Cross-database / parent-org rollup (D6).
- Barcode (§6).
- Onboarding Raddish or any specific Growyze customer as an XMS BI organisation.
- The free-text "Recommendations & Interventions" narrative — stays human; a MarkdownCard could host it later.

---

## 12. Doc sync on completion

Per CLAUDE.md sync rules:

- `docs/presentation-and-visualisation.md` — new `F_COGS_PERIOD` table, new build step, 15 new vis queries
- `docs/index.html` — presentation-table and vis-query counts
- `docs/OUTSTANDING.md` + the new item's detail file — progress log
- `ClaudeDevelopment/QUERY_STATUS.md` — every new script in `cogs/`
- `docs/stockevent-ruleset.md` — if the `DELIVERY`/`ORDER` question resolves
