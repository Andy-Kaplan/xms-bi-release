# O8 — Marge Brut dashboard not deployed

> Detail file for ledger item **O8**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — mock is live on Oak & Vine; **mock→live conversion** built (8 scripts, branch `worktree-margebrut-live`), gated on fetcher feed + O5 + new UAT org |
| **Area** | Dashboard / vis queries + Report DB |
| **Owner / decides** | Andy |
| **Next action** | Merge branch `worktree-margebrut-live`; then execute `ClaudeDevelopment/integrations/MargeBrut/live/DEPLOY.txt` when the Growyze feed + new UAT org are ready |
| **Sources** | `docs/superpowers/specs/2026-07-10-marge-brut-live-design.md`, `docs/superpowers/plans/2026-07-10-marge-brut-live.md`, `ClaudeDevelopment/integrations/MargeBrut/live/`, `memory/marge-brut-dashboard.md` |

## Context
Real XMS BI dashboard reproducing an Accor hotel "Marge Brut" spreadsheet, hosted on the **existing** UAT org **The Oak & Vine** (OrgID 16, GUID `7ED2E768-0D22-F111-832F-000D3AB27D87`), fed by mocked Oct-2025 data via literal-`VALUES` vis queries. No org-creation needed. Dataset tokens `MargeBrut*`. VisualisationId map: 1=Bar, 3=Grid, 9=Pie, 10=KPI.

## Progress log
- **2026-06-08** — Scripts written, query shapes MCP-verified; not deployed.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT)** — DEPLOYED to UAT. Org confirmed OrgID 16 = `20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87`. VisualisationQueries `MargeBrut%` = **9 LIVE** (Comps, Consumption KPI+Mix, CostRatioByGroup+KPI, Grid, PurchasesBySupplier+KPI, TurnoverKPI). Report DB: all 9 datasets mapped under the Oak & Vine GUID; "Marge Brut" OrganisationDashboardConfig present, not deleted. DEV: 0. **Caveat: visibility likely blocked by O13** (empty DashboardGroupMapping) — verify it's actually navigable in the front end before closing.
- **2026-07-10 (mock→live build)** — Scoped + designed + built the **live** conversion (Mews turnover + Growyze consumption). Now that Mews works, decided (user): full cost-of-sales model, real Growyze feed, **new dedicated UAT "Three Rocks Hotel" org** (Mews+Growyze only, so the ratio reconciles), grouping via per-product `MICROSERVICE_NAME` MDM feeding a **new `presentation.F_MARGEBRUT_MONTH`** fact. Spec + plan written; 8 scripts authored + MCP-shape-tested + peer-reviewed (subagent-driven) on branch `worktree-margebrut-live`: `live/01_provision_uat_org`, `10_f_margebrut_month_table`, `11_reference_margebrut_manual`, `12_group_mapping`, `13_f_margebrut_month_control`, `14_margebrut_vis_queries`, `15_report_config`, `99_verify` + `DEPLOY.txt`. Final whole-branch review: **READY TO MERGE** (0 Critical/Important). **Nothing deployed/live** — gated on: (a) fetcher lands a real Growyze feed for the hotel; (b) O5 `UOM_COST` inflation fix (consumption correctness gate); (c) new UAT org creation. Discovered: **Mews001 does not exist on UAT** (DEV-only) — `01_provision` creates it + seeds its 22-row STAGE_DDL before mapping.

## Go-live checklist (from final review — do at deploy, not merge)
- Execute `live/DEPLOY.txt` in order; the fetcher gate (step 3) blocks everything needing real data.
- **Re-run `12_group_mapping` before every fact rebuild** if new products/items have loaded (the `ELSE 'Food'` catch-all means Check 2 coverage only catches items loaded *after* the last grouping run).
- Non-F&B Growyze stock silently inflates the `Food` group via the catch-all — add to the go-live data-quality checklist alongside the O5 `UOM_COST` gate; numbers are provisional until confirmed against the real catalogue.
- **NEVER re-run the mock `../02_margebrut_vis_queries.sql` after go-live** — it shares the VisualisationQueries MERGE key with live `14` and would silently revert the dashboard to mock data.
- Validate `MargeBrutPurchasesBySupplier` (F_PURCHASES_DAY.LINE_TOTAL) reconciles with `MargeBrutPurchasesKPI` (fact PURCHASES) — different measures; rename to "Supplier Spend" if they can't reconcile. Requires Growyze `06`/`07` (F_PURCHASES_DAY) deployed first.

## Pick-up notes (resume here)
- Read `memory/marge-brut-dashboard.md` for tokens/VisualisationId map; the spec/plan under `docs/superpowers/` for the live design.
- Don't mark Closed until the user confirms.
