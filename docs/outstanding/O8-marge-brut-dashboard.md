# O8 — Marge Brut dashboard not deployed

> Detail file for ledger item **O8**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | MONITOR — deployed to UAT (9 queries + config); may be hidden by O13. Confirm & close |
| **Area** | Dashboard / vis queries + Report DB |
| **Owner / decides** | Andy |
| **Next action** | Deploy scripts 02 (global vis queries) + 03 (report config) to UAT org The Oak & Vine |
| **Sources** | `memory/marge-brut-dashboard.md`, `ClaudeDevelopment/integrations/MargeBrut/` (02, 03) |

## Context
Real XMS BI dashboard reproducing an Accor hotel "Marge Brut" spreadsheet, hosted on the **existing** UAT org **The Oak & Vine** (OrgID 16, GUID `7ED2E768-0D22-F111-832F-000D3AB27D87`), fed by mocked Oct-2025 data via literal-`VALUES` vis queries. No org-creation needed. Dataset tokens `MargeBrut*`. VisualisationId map: 1=Bar, 3=Grid, 9=Pie, 10=KPI.

## Progress log
- **2026-06-08** — Scripts written, query shapes MCP-verified; not deployed.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT)** — DEPLOYED to UAT. Org confirmed OrgID 16 = `20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87`. VisualisationQueries `MargeBrut%` = **9 LIVE** (Comps, Consumption KPI+Mix, CostRatioByGroup+KPI, Grid, PurchasesBySupplier+KPI, TurnoverKPI). Report DB: all 9 datasets mapped under the Oak & Vine GUID; "Marge Brut" OrganisationDashboardConfig present, not deleted. DEV: 0. **Caveat: visibility likely blocked by O13** (empty DashboardGroupMapping) — verify it's actually navigable in the front end before closing.

## Pick-up notes (resume here)
- Read `memory/marge-brut-dashboard.md` for the dataset tokens and VisualisationId mapping.
- Don't mark Closed until the user confirms.
