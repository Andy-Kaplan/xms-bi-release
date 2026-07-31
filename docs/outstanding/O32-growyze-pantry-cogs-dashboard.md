# O32 — Growyze Pantry COGS dashboard (replaces Raddish's manual spreadsheets)

> Detail file for ledger item **O32**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — **DEPLOYED and VERIFIED on UAT org 21** (steps 1–10). All 12 cards + 3 filters exercised through the real card SPs. Only the **front-end UI check (step 11)** remains |
| **Priority** | 2 |
| **Area** | Growyze / presentation + Report DB |
| **Owner / decides** | Andy |
| **Next action** | **Step 11 — open the "Pantry COGS" dashboard as Ibis Gloucester Road on UAT and look at it.** The data layer is fully verified, so anything wrong from here is rendering, not data. Then decide the **three decisions** (§Decisions) |
| **Spec** | [`docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md`](../superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md) |
| **Plan** | [`docs/superpowers/plans/2026-07-30-growyze-pantry-cogs-dashboard.md`](../superpowers/plans/2026-07-30-growyze-pantry-cogs-dashboard.md) |
| **Cross-linked** | **Claude Nine ledger O25** — "Scope Growyze consolidated COGS reporting opportunity" (the commercial thread with Kati) |
| **Scripts** | `ClaudeDevelopment/integrations/Growyze/cogs/` (13 files) |

## Context

Kati (Growyze) raised consolidated COGS reporting as potential paid work. Raddish, a Growyze customer, produce
**two spreadsheets by hand per venue per month** against a 6-page staff SOP: an invoice workbook (delivered value
→ `SUMIF` by category → invoice raised in TPP) and a client-facing consumption/insights pack (6 charts).

Their June 2026 pack carried **six defects, all from one root cause** — a column was dropped from a paste and the
template only half re-pointed. Effects: **£24,199.53 (22%) of consumption absent from every chart**; a 3-month
trend showing a ~12% fall when consumption actually rose ~14%; every figure on the "Budget Impact" tab wrong
(£49,437.83 shown vs £63,902.25 actual across 32 items, one bar reading 142.8% of category spend). Nothing in
their SOP could catch any of it. Full forensic analysis:
`Claude Nine/docs/research/2026-07-30-growyze-raddish-cogs-workbook-analysis.md`.

**The value here is not the arithmetic — it is removing the paste, holding each measure in one place, and making
failures loud instead of silent.**

### Key design decisions (full rationale in the spec)

| # | Decision |
|---|---|
| D1 | Both halves, insights first; invoices still raised in TPP |
| D2 | **Stocktake-pair period grain**, not calendar month |
| D3 | Negative COG Sold is **flagged only** — fixed upstream in Growyze; no adjustments table, no write path |
| D4 | New pack, additive to O5's default Growyze dashboards |
| D5/D6 | Consolidated from the start; **venues as locations in one org DB** — no cross-database rollup |
| D7 | **One dashboard**, 12 cards + 3 filter widgets |
| D8 | Fact derived from the **Data Vault**, not from `F_INV_COUNTS_DAY` — because Growyze values everything at *latest cost price in the period* and that fact uses an average |

## Prerequisites before the numbers can be trusted

1. **A Growyze COGS export** for a venue whose data we hold, loaded into
   `[reference].[GROWYZE_COGS_EXPORT_STAGING]` (column shape documented in `99_verify_cogs_period.sql`'s header).
   Until it exists, **check 2 reports SKIPPED** — internal consistency is provable, faithful replacement of the
   spreadsheet is **not**. Ask Kati alongside the six-defect conversation. ⚠️ **Still outstanding** — but see the
   2026-07-31 log entry: closing stock now reconciles *exactly* against the platform's own `F_INV_COUNTS_DAY`,
   which is independent corroboration of the valuation path even though it is not the Growyze export itself.
2. ~~**The org GUID** for the target org in the `report` database.~~ **RESOLVED 2026-07-31.** For Ibis Gloucester
   Road it is **`67CA4E6F-9A7E-F111-B337-002248A1EC3D`** — i.e. the GUID embedded in the Managed-Instance database
   name `20260722_XMS_67CA4E6F-…`, confirmed present in `report.dbo.OrganisationDashboardConfig` (1 existing row).
   The MI integer org id ("21") is still **not** usable there.

## Deliverables (13 files, `ClaudeDevelopment/integrations/Growyze/cogs/`)

| File | Purpose |
|---|---|
| `PREFLIGHT.md` | The 3 gating questions, answered with `file:line` citations |
| `00_CARD_CONTRACTS.md` | Real per-card-type output contracts extracted from live examples |
| `99_verify_cogs_period.sql` | **11 checks — written first; this is the test.** Checks 5 and 6b are INFO by design, not PASS |
| `01_cogs_period_table.sql` | `presentation.F_COGS_PERIOD` DDL, **37 columns**, `PresentationTables` MERGE |
| `02_cogs_period_build.sql` | Tier-110 `PresentationControl` build, 12 CTEs |
| `03_report_group_config.sql` | `GlobalParameters` break-out bucket config |
| `04_vis_kpis.sql` | 4 `SingleKPICard` |
| `05_vis_charts.sql` | 5 chart datasets |
| `06_vis_grids.sql` | 3 grid datasets |
| `07_vis_filters.sql` | 3 `FilterList` widgets |
| `08_report_db_config.sql` | Report-DB wiring — **run by hand against `report`**, different server |
| `90_deploy_cogs.ps1` | Runner: `-WhatIf`, typed confirmation, halt-on-error, `-StartAt` resume, logging |
| `DEPLOY.txt` / `README.md` | Ordered sequence and honest current state |

## Progress log

- **2026-07-30** — Spec and plan written; all 13 artefacts authored via 11 subagent tasks with per-task review,
  then a central cross-file verification pass. **Nothing executed — no DB access in the authoring session.**
  All cross-file contract checks PASS: 35 DDL columns with no orphan `F.[...]` reference across 6 consumers; the
  3 filter names present in all 5 relevant files; no hardcoded client DB name; no bare `INSERT` into a control
  table; no `MICROSERVICE_NAME`, no `AVG(`, no `STOCKEVENT_START/END` in the build; longest mapped filter
  expression 44 chars (limit 100); venue expression byte-identical across emitter and all 3 consumers; all 12
  cards sharing one `ParameterMappings` shape.

  **Defects found and fixed during the build — most were in the plan, not the implementations:**
  - **The plan told the build to copy the inline UOM-conversion CTE verbatim.** That literal list is exactly what
    `ClaudeDevelopment/12_uom_conversion_fix.sql` *removed* from the three existing inventory build steps,
    because Growyze's native unit strings (`'each'`, `'g'`, `'kg'`) are different words from the MarketMan-shaped
    literals (`'EA'`, `'gr'`) — its header records **61.7% of Growyze rows with NULL `STANDARDISED_UOM`** and
    **ORDER quantities understated ~75%**. Following the plan would have rebuilt a fixed, high-impact silent-loss
    bug into the newest code. The implementer overrode it with evidence and was right.
  - **Venue filter compared `binary(32)` against a hex string** (controller error, propagated to 4 dispatches).
    `LOCATION_HUB_ID` is binary; the filter list emits `CONVERT(VARCHAR(64), …, 2)`. The implicit conversion
    takes character bytes, so it does not error — it matches nothing and every card silently empties. Now one
    frozen expression on both sides.
  - **Deploy order let check 8 pass vacuously.** The final verify ran before the vis queries deployed, so the
    filter-length check queried zero rows and reported PASS having tested nothing. Now **three** verify runs
    (steps 1, 7, 9) with step 7 annotated as non-coverage for check 8.
  - **`@OrgId` was specified `INT`; the report DB uses `uniqueidentifier`** — would have failed immediately.
  - **`PERIOD_LABEL` NULL-safety** — plain date concatenation yields NULL for every venue's first period, which
    would have shown a blank row in the period picker the whole dashboard depends on.
  - Coverage guard extended: Growyze gives items with a NULL subcategory an `'All INVITEMs'` sentinel on **both**
    category tiers, so a NULL-only test would have passed exactly the rows it exists to catch — including the
    composite form `"<Category> - All INVITEMs"`.
  - New risk found and guarded: `UOM_CONVERSION`'s PK is `(FROM_UOM, TO_UOM)`, so one unit can carry several
    rows and the build's join would fan out. **Deliberately not changed** — the build matches the pattern three
    live facts use, and diverging would silently differ from them. Guarded by new **check 10** instead.

- **DOC-DEBT fixed in the same pass:** `docs/stockevent-ruleset.md` claimed the Growyze `DELIVERY`→`ORDER` fix
  was still pending. It landed — `02_staging_tier1.sql:290` emits `''ORDER''`. Corrected.

- **2026-07-30 (evening) — full review chain run; 0 open findings.**
  Independent whole-pack review → one fix wave → scoped re-review → one targeted round. Full reasoning in
  `.superpowers/sdd/2026-07-30-growyze-pantry-cogs-dashboard/` (`final-review.md`, `task-12-fixwave-report.md`,
  `re-review.md`, `progress.md`). **That workspace is deliberately NOT deleted** — nothing is committed, so it
  is the only record of the review chain. Safe to remove once the 13 files are committed.

  **Verified clean and still intact after all changes:** quote balance at both nesting levels across all 9
  `.sql` files; every JSON payload parsing; the column contract agreeing **five** ways (DDL, `column_definitions`,
  `column_mappings` × 2, final SELECT aliases) with 0 type mismatches; every spec §4.1 derivation exact; the
  `UOM_COST` latest-cost-at-period-end shape; per-location period boundaries; `@FilterClause` counts and alias
  scope at all 18 injection points; one distinct expression per filter key across all 12 cards + emitter.

  **Three Critical defects found, all controller errors, none visible from inside the file containing it:**
  - **C1** — the runner deployed the break-out config to `core` while the build reads it from the **client**
    database. `STRING_SPLIT(NULL,'|')` returns zero rows rather than erroring, so `REPORT_GROUP = CATEGORY`
    everywhere: the whole category model silently did nothing while every card rendered and every check passed.
    Fixed, and **new check 11** proves it happened rather than assuming.
  - **C2** — the filter widgets used a `Value`/`Label` output contract. Of 21 live `FilterList` records, **18 use
    `Label`/`ID`/`ParentID`/`BottomLevel` and none use `Value`**. Re-shaped to follow the live `Locations`
    record. **Still needs UI confirmation** — see §Decisions.
  - **C3** — the trend card carried the period filter, so one selected stocktake period admitted one month and
    the three-month comparison collapsed to a single series *in its default state*. Key removed from that one
    card, with an in-file comment so a consistency sweep cannot undo it.

  **Eight Important, all fixed**, including: `WASTE_QTY`/`SALE_QTY` ignoring `EVENT_BEHAVIOUR` (a `'+'` reversal
  was inflating variance); check 3 being tautological; check 6 unable to detect its own bug; checks 8a/8b
  potentially `OPENJSON`-ing every record in the table; check 2 unable to ever pass (join lacked period and
  location); a missing cost on stationary stock vanishing from closing-stock value unreported; the pie's total
  counting slices it does not draw; and every item getting a row for every period, flooding the exceptions card.

  **One new blocker introduced by the fix wave and caught by the re-review (N1):** the rewritten check 6 fired on
  designed carry-forward and would have halted the runner at step 7 on the first-deploy org. Split into **6a**
  (period-level drift guard, FAIL) and **6b** (carry-forward visibility, INFO, never FAIL).

- **2026-07-31 — first execution against a real database. Files committed. One new Critical (C4) found and fixed.**

  Every prior session authored this pack with **no DB access**, so four review passes could only check the files
  against each other. This session ran them against UAT org 21. Three of PREFLIGHT's source-only inferences were
  confirmed live (both category levels distinct — 5 categories / 18 subcategories; all `MICROSERVICE_NAME` NULL,
  so the no-`COALESCE` rule holds; `UOM_CONVERSION` has no multi-row `FROM_UOM`, so **check 10 passes** and the
  fan-out that would multiply this fact's grain is absent). The three-part `[core].[reference].[UOM_CONVERSION]`
  vs two-part `[core].[GlobalParameters]` asymmetry was checked and is **correct** — the deployed
  `12_uom_conversion_fix.sql:78` uses the identical three-part form and the client DB has no local UOM table.

  **C4 — the entire fact came out unpriced, and all eleven checks passed anyway.** Executing the build SELECT
  read-only returned 732 rows in which **every** money column — `COG_SPEND`, `COG_SOLD`, `CLOSING_VALUE`,
  `WASTE_VALUE`, `VARIANCE_VALUE` — was NULL, and 732 of 732 rows carried `HAS_ZERO_COST = 1`. Cause: `ItemCost`
  filtered `SAT_INVITEM.EFFECTIVEFROM <= PERIOD_END_DATE` to express spec §1.2's "latest cost *in* the period",
  but on a freshly-loaded org every satellite row carries `EFFECTIVEFROM` = the **load date** — here 2026-07-28,
  against periods ending 31 May and 30 Jun 2026. Zero rows matched. The three deployed sibling inventory facts
  never hit this because their `InvItemCost` resolves on `CURRENT_FLAG = 1` with no temporal predicate at all
  (`cost-path-redesign/04:177-187`).

  **Why nothing caught it, which is the reusable part.** Check 5 (unpriced stock) is INFO *by design* — a few
  unpriced items is a source condition, not a build defect — so 100% unpriced read as a loud version of an
  expected shrug. Check 7 is a deliberate, faithful **mirror** of the build's cost rule, so when the build
  resolved NULL the check resolved NULL too and its `ISNULL(x,0) - ISNULL(y,0)` comparison came out zero: it
  **passed on a fact with no money in it**. A mirror check cannot falsify a premise it shares — the same failure
  shape as the already-recorded "check 6 unable to detect its own bug". With `BarChartCard` rendering NULL as
  `0.00` (O8's finding), the runner would have reported success and shipped a dashboard reading £0.00 everywhere
  while looking deliberate.

  **Fixed** by replacing the hard predicate with a three-key `ORDER BY` that keeps the point-in-time intent as
  first preference and falls back to the earliest version that exists, so it degrades instead of vanishing and
  starts honouring real cost history automatically once the satellite has any. Check 7 was updated **in lockstep**
  (a mirror left un-updated would have produced a false FAIL on every priced row and halted the runner), and new
  **check 12** is an *independent witness*: it reads the fact directly, re-derives nothing, and FAILs only when
  the satellite demonstrably holds priced items yet not one fact row carries a usable cost — the one state that
  has no source-data explanation. Verify is now **12 checks / 13 result rows**.

  **After the fix the build reconciles exactly.** Closing stock at 31 May = **£10,151.06** against
  `F_INV_COUNTS_DAY`'s **£10,175.54**. The £24.48 gap is *not* an error in the new fact: `F_INV_COUNTS_DAY` holds
  **158 rows for 157 distinct items** on that date, double-counting one item worth £24.48 twice.
  `10,175.54 − 24.48 = 10,151.06` exactly, and `F_COGS_PERIOD`'s grain is unique (732 rows / 732 distinct keys)
  so it counts it once. **The new fact is the more correct of the two, and it surfaced a live pre-existing
  double-count in `F_INV_COUNTS_DAY` worth raising separately.** The 30 Jun difference (£8,496.68 vs £8,127.01)
  is the designed carry-forward: 220 items were not counted at that stocktake.

  **Two source-data caveats recorded in `DEPLOY.txt`, both real and neither a defect:**
  - Growyze sends **only `COUNT` and `ORDER` events** on this org — no waste, sale, transfer or production. So
    `WASTE_VALUE` is £0.00 everywhere and `VARIANCE_VALUE` comes out as exactly `−COG_SOLD` (June: −£3,387.77).
    Arithmetically correct, but it means the **"unexplained shrink" KPI reports the whole consumption as
    unexplained** — do not present it as a shrink figure on this org. It also makes the build's documented
    unhandled-`EVENT_TYPE` exposure nil here.
  - The first period sweeps **4,649 delivery events back to 2023-03-28** against zero opening stock
    (£87,968.13 of `COG_SPEND` vs £1,733.38 in the only real period). This is correctly quarantined —
    **every measure card excludes `IS_FIRST_PERIOD`** and the exceptions grid deliberately surfaces it — but it
    leaves org 21 with exactly **one** usable period, so the trend and 3-month comparison cards will each show a
    single series. Expected; shape-testing only, as `DEPLOY.txt` already said.

  Runner connectivity confirmed: the MI public endpoint needs **port 3342**, which `90_deploy_cogs.ps1:98` already
  appends (matching the reference runner). Both edited `.sql` files re-verified for quote balance at both nesting
  levels and `SET PARSEONLY` clean — one apostrophe (`today's`) inside the `@sql` literal was caught and doubled.

- **2026-07-31 (later) — DEPLOYED steps 1–10 on UAT org 21, then verified every card by execution.**

  **Steps 1–9** via `90_deploy_cogs.ps1`: step 9 (the real gate) returned **PASS=10 FAIL=0 WARN=1 SKIPPED=1
  INFO=2** — check 12 PASS, check 11 WARN, check 2 SKIPPED, checks 5/6b INFO, exactly as predicted. Step 1 failed
  as designed (table absent). Both runner safety rules fired correctly: `DeployPresentationTables` never called,
  step 10 refused. Deployed fact matches the pre-deploy simulation to the penny.

  **Step 10** run by hand against `report` on `xms-sql-fog-uat` via `Invoke-Sqlcmd` (MCP is read-only there). Its
  own transactional verify-or-rollback returned **PASS — 12 cards, 3 filters, group-mapped and visible**.
  `BiConfig` already existed with `DbPrefix = 20260722`, independently confirming the prefix. The dashboard is
  additive alongside O8's "Marge Brut" on the same org, in the existing "All Dashboards" group. ⚠️ The committed
  `08_report_db_config.sql` still holds its `<TARGET-ORG-GUID>` / `<TARGET-DB-PREFIX>` placeholders **by design** —
  the run used a substituted scratch copy so the committed script stays org-agnostic. Do not commit a pinned copy.

  **Cross-database contract check (the seam nothing had tested).** All **15** dataset names in the report DB's
  `DashboardGridItem`/`DashboardGridFilter` match the 15 `PantryCOGS%` rows in `core.core.VisualisationQueries`
  exactly, and every card type agrees (4×SingleKPICard→10, PieChart→9, 4×BarChart→1, 2×CustomDataGrid→3,
  CustomGroupedDataGrid→4; the 3 FilterLists carry no `VisualisationId`, which is correct). This is the
  `DashboardGridFilter.DataSet` == `FilterDefinitions` key contract, and it holds.

  **Every card type executed against the live org — all 5 return correct data:**

  | Card / filter | Result |
  |---|---|
  | `SingleKPICard` COG Spend | **£1,733.38** ✓ matches fact |
  | `SingleKPICard` COG Sold | **£3,387.77** ✓ |
  | `SingleKPICard` Closing stock | **£8,496.68** ✓ |
  | `SingleKPICard` Unexplained variance | **−£3,387.77** — exactly `−COG_SOLD`, the documented no-waste/sale caveat, now confirmed live |
  | `PieChartCard` Consumption mix | Beverages £391.81 + Food £2,995.96 = **£3,387.77** ✓, zero slices correctly omitted |
  | `BarChartCard` By venue | Ibis Gloucester Rd **£3,387.77** ✓ |
  | `CustomDataGrid` Billing totals | **GRAND TOTAL £1,733.378404 == the COG Spend KPI exactly** — check 3's three-way agreement proven through the real SPs |
  | `CustomGroupedDataGrid` Item table | correct parent/child nesting (`ParentId` NULL on group rows, group id on children) |
  | 3 × `FilterList` | all return the `Label`/`ID`/`ParentID`/`BottomLevel` contract |

  **C2 IS NOW SETTLED BY OBSERVATION, NOT INFERENCE** — the open question was whether the renderer reads `ID`.
  The filters were round-tripped: filtering COG Sold to `Food` returned **£2,995.96**, the exact Food subtotal
  (not the £3,387.77 total), and a **deliberately bogus venue hash returned NULL** — proving the filter is
  genuinely applied rather than silently ignored, which is the failure mode the binary(32)-vs-hex-string defect
  would have produced. The venue filter's real hex ID returns the full value. Period filter round-trips too, and
  `PERIOD_LABEL` renders `"Opening - 31 May 2026"` rather than NULL, confirming that fix.

  **What step 11 can still find:** only front-end rendering. Every data-layer contract is now verified by
  execution, so if a card looks wrong in the browser, look at the renderer before suspecting the data.

- **2026-07-31 (third session) — rolled out to Padel Social (10) and Dirty Sixth (18). One more Critical (C5)
  found, fixed and verified. Dirty Sixth fully live; Padel held at the report-DB step.**

  **C5 — closing stock is a snapshot and was being SUMmed across periods.** Every measure card treated its
  measure as a flow. That is right for COG Spend, COG Sold, waste and variance, and **wrong** for opening/closing
  balances. It was invisible on org 21 for the same structural reason C4 was invisible to eleven checks: that org
  has exactly **one** non-first period, so a sum over periods and a snapshot are the same number. On Padel, with
  33 period-ends across 2 locations, `PantryCOGSClosingStockKPI` read **£709,650.42** against a true latest
  closing stock of **£31,395.51** — **22.6× overstated, presented as a headline figure**. Dirty Sixth was ~5×.

  Four columns across two cards were affected — the KPI, plus the item table's `OPENING_QTY`, `CLOSING_QTY` and
  `CLOSING_VALUE` (the initial count of "3 spots" was low; the grep that found it matched only `*_VALUE`).
  Fixed with the standard opening/closing-balance treatment: opening from the **earliest** period in scope,
  closing from the **latest**, resolved **per location** (and per item in the grid) because venues keep
  independent stocktake calendars under D5/D6 — a single global MAX would silently drop every venue that did not
  count on the most recent date. Flows remain plain SUMs. Verified three ways: org 21 **unchanged at £8,496.68**
  (no regression), Padel now **£31,395.51**, Dirty Sixth **£16,860.51** — each matching an independently computed
  figure — and the item table's Beverages root row returns **£9,402.39** (the snapshot) rather than £59,677.98
  (the old raw sum) while its flow columns still sum across all periods.

  ⚠️ **This is now the second defect of exactly this shape** (after C4): code that is correct on the first deploy
  org *because that org's data is degenerate*, and wrong everywhere else. Org 21 has one period, one location and
  no waste/sale events — it cannot exercise period arithmetic, cross-location resolution, or the flow/snapshot
  distinction. **A single-period org is not a sufficient acceptance environment for this pack.** Anything added
  here should be shape-tested against Padel (2 locations, 33 period-ends) before it is believed.

  **Both orgs FAIL check 4, and it is a source-data gap, not a build defect.** Padel: 34 rows / **9** items;
  Dirty Sixth: 34 rows / **12** items — Growyze inventory items carrying no category, so they land on the
  `'All INVITEMs'` sentinel (the exact case PREFLIGHT Q2's caveat predicted for a NULL `subCategory`). Impact is
  small — Padel £97.04 sold of £21,873.82 (**0.4%**), Dirty Sixth −£321.44 of £102,240.78 (**0.3%**) — and the
  items surface under an oddly-named bucket rather than vanishing, so card totals stay correct. The runner
  **halted on it at step 7 on both orgs**, which is the gate behaving as designed. Deployment was continued past
  it deliberately, with the impact measured first. **The fix belongs with Growyze: categorise ~9–12 items per
  org.** Everything else passes on both orgs, including check 12.

  **Padel Social is deliberately NOT wired in the report DB — see new [O34](O34-padel-biconfig-wrong-dbprefix.md).**
  Its `BiConfig.DbPrefix` is `20251208`, resolving to a database that does not exist (the real one is
  `20260310_…`); it is the only mismatch of 19 orgs, and `Audit.BiConfig` shows it was **wrong on the original
  insert**, not drifted. `08_report_db_config.sql`'s `BiConfig` step is an `IF NOT EXISTS` guard, so running it
  would have skipped the bad row and wired a dashboard that cannot resolve data. Padel's MI side **is** complete
  (fact built, 17,556 rows, verified) — only the report-DB wiring waits on O34.

  **Dirty Sixth is fully live**: steps 1–10 complete, report DB returned *PASS — 12 cards, 3 filters,
  group-mapped and visible*, and the Closing Stock KPI verified by execution at £16,860.51.

- **2026-07-31 (fourth session) — Padel wired; O34's blocker disproved; C6 found and fixed.**

  **O34 was wrong and Andy disproved it from the UI.** The claim that Padel's dashboards had never rendered
  (because `BiConfig.DbPrefix` names a non-existent database) was inference from docs + schema + audit trail, all
  three of which agreed with each other and were all wrong about the running system. Padel's *Cost & Margins*
  renders fully; `InvCOGSByCategory` against the real DB matches it to the penny (£56,189). `DbPrefix` is **not**
  the resolver. O34 downgraded to priority 4 (hygiene + a doc fix), the hold lifted, and Padel wired — report DB
  returned *PASS — 12 cards, 3 filters, group-mapped*, now sitting alongside its 4 existing dashboards.

  **C6 — the fact was APPENDING on every rebuild, not replacing. The worst defect in this pack.**
  Immediately after wiring, Padel's Closing Stock KPI read **£62,791.01 — exactly 2× the £31,395.51 verified
  minutes earlier.** The fact held **35,112 rows for 17,556 distinct grain keys**; Dirty Sixth **14,264 for
  7,132**. Both exact doubles. Neither had been built twice by me — **a single scheduled presentation refresh did
  it**, because registering the tier-110 step globally means every org's scheduled rebuild now runs it.

  Cause, in `sp_ExecuteQuery`:
  ```sql
  ELSE IF @TableType = 'Fact' AND @TimeSeriesTargetColumn IS NOT NULL
  BEGIN ... DELETE FROM target WHERE [col] BETWEEN @MinDate AND @MaxDate END
  -- then, UNCONDITIONALLY:
  INSERT INTO target (...) SELECT ... FROM ##TempResults
  ```
  `02_cogs_period_build.sql` registered `time_series_entity` and `time_series_target_column` as **NULL**, so the
  DELETE was skipped and the INSERT still ran. **All 19 other Fact steps set that column** — this step was the
  sole exception (bar `PF_GROWTH_PERIOD`, see below). It never errors, never warns, and **compounds every refresh
  cycle**: unbounded table growth with every measure inflating in lockstep.

  Fixed by setting `time_series_entity = 'STOCKEVENT'`, `time_series_target_column = 'PERIOD_END_DATE'` in
  **both** MERGE branches — the UPDATE branch matters, because omitting it there is exactly what would stop a
  re-run from repairing an already-broken control row. `sp_ExecuteQuery` resolves the source column from
  `column_mappings` and RAISERRORs if absent, so a typo is loud. The build reads unbounded history, so MIN..MAX
  spans every period and the DELETE is a true full replace. All three orgs rebuilt clean —
  Padel 35,112→**17,556**, Dirty Sixth 14,264→**7,132**, org 21 **732** unchanged — KPIs back to £31,395.51 /
  £16,860.51 / £8,496.68, and **idempotency proven by rebuilding Padel twice in a row with no growth.**

  ⚠️ **Check 1 (grain/fan-out) is the right guard and it did not fire, because the duplicate arrives *after*
  deployment.** Every verify run happened before the first scheduled refresh. A deploy-time gate cannot catch a
  defect whose trigger is the *next* scheduled rebuild — **re-run `99_verify` a day after any deploy**, which is
  now written into `DEPLOY.txt` step 6.

  ⚠️ **`PF_GROWTH_PERIOD` (tier 102, parent-org / [O4](O4-parent-org-1011.md)) carries the same NULL
  `time_series_target_column`** and is the only other Fact that does. It is very likely accumulating the same way
  on every parent-org rebuild. **Not investigated here — worth checking as part of O4.**

## Decisions — three things waiting on Andy (none is a defect)

1. **The comparison card can no longer be pointed at chosen months.** `BuildDynamicWhereClause` builds **one**
   filter clause and substitutes it at *every* `@FilterClause` token, so the period selection cannot reach the
   card's anchor while being excluded from its data query — it is all or nothing. The card therefore always
   shows the latest three months within the selected venues and categories. That is honest and matches its
   title, and far better than collapsing to one month while claiming a trend. But "show me March to May" is not
   expressible on that card. If wanted, it needs a different mechanism: drive the anchor from the
   `StartDate`/`EndDate` **`ParameterMappings`** slots (a separate channel from `@Filters`), or give the card its
   own picker. Recorded in-file as a design change, not as a key to add back.
2. **Check 11 contradicts `03`'s own documentation.** `03_report_group_config.sql` describes "no catch-all
   bucket" as a legitimate configuration for a future customer; check 11 FAILs that state, because for *this*
   pack a missing value means the C1 mis-deploy. Correct here, wrong for the next customer. One of the two must
   give — either stop calling it legitimate in `03`, or let check 11 accept an explicit empty-by-design marker.
3. **`PantryCOGSSlowMovers` deviates from spec §7 in three ways** — global rather than per-category bottom-10;
   quantities ranked across mixed UOMs (kg, L, each in one list); grouped on `ITEM_NAME` rather than
   `INVITEM_HUB_ID`, so two items sharing a name merge. All three are documented in the card's header with the
   trade-off for each. None can produce a wrong *total* — they change which bars appear and in what order.

## Pick-up notes (resume here)

- `cogs/PREFLIGHT.md`'s Q2 gate is **confirmed live on org 21** (2026-07-31): both category levels are distinct —
  5 categories, 18 subcategories. No stop. Q3 is likewise confirmed clean (all `MICROSERVICE_NAME` NULL).
- **Check 12 must PASS.** It is the cost-resolution gate added after C4. A FAIL means the `ItemCost` OUTER APPLY
  in `02` has lost its `EFFECTIVEFROM` fallback and every money column is NULL — do not deploy the dashboard on
  that result. Expect **WARN on check 11**: org 21's categories are Food / Beverages / Other, so it carries none
  of the configured break-out buckets and the break-out is *unproven* there, not broken.
- Then `cogs/DEPLOY.txt`, steps 1–9 via `90_deploy_cogs.ps1` on UAT org 21. Step 1 is *expected* to FAIL.
- **Do not reconcile values against Padel Social or Dirty Sixth** — both have implausible stock values
  (~£587k–£1.2M) from a separate unresolved cause (O5 sub-item). Reconciling there would validate the dashboard
  against numbers already known to be wrong.
- `08_report_db_config.sql` is run **by hand** against `report`; the runner refuses it deliberately.
- Never run `DeployPresentationTables` — it DROPs every registered presentation table. Deploy `F_COGS_PERIOD`
  individually; the runner already does.
- **Expect INFO, not PASS, on checks 5 and 6b, and PASS-or-WARN on 11.** Only a FAIL halts. Checks 5 (unpriced
  stock) and 6b (closing counts carried forward) surface *source-data* conditions that are not build defects;
  check 11 WARNs when the org has none of the configured break-out categories, which means "unproven here", not
  "broken". `DEPLOY.txt` step 7 states the expected verdict per check.
- **Read check 10 before trusting any figure.** A `UOM_CONVERSION` fan-out multiplies *this* fact's grain (via
  `ItemCost` → `Calc`'s `LEFT JOIN`), where in the three sibling inventory facts it only inflates a movement
  `SUM`. Its PASS is load-bearing here in a way it is not for them.
- **C2 is settled only at the UI step.** The filter widgets now match all 18 live precedent records, but that
  the renderer reads `ID` is inferred, not observed. Deploy step 11 (exercise all three filters) is the gate —
  treat it as one. If the filters do nothing, look there before suspecting the data.
- Additive to [O5](O5-growyze-default-dashboards.md); distinct object names, all MERGE upserts, so the two can
  deploy in either order.
- The review-chain workspace at `.superpowers/sdd/2026-07-30-growyze-pantry-cogs-dashboard/` is the only record
  of *why* several non-obvious choices were made (git has nothing yet). Keep until the 13 files are committed.
- Don't mark Closed until Andy confirms.
