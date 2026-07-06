# O6 — Growyze reporting + staging fixes not deployed

> Detail file for ledger item **O6**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | MONITOR — all 3 fixes observed live on UAT; confirm & close |
| **Area** | Growyze / staging + reporting |
| **Owner / decides** | Andy |
| **Next action** | Re-deploy staging scripts 02+03 after bug fixes; deploy Padel Social reporting fixes + stocktake + palette |
| **Sources** | `memory/growyze-bugs.md`, `memory/growyze-reporting.md`, `memory/growyze-delivery-trace.md`, `ClaudeDevelopment/integrations/Growyze/` (01-12) + `reporting_queries/` (12-18) |

## Context
Growyze staging runs (14 stage tables) but several fixes remain undeployed:
- **Scripts 02+03 need re-deploy** after bug fixes.
- **INTERNAL_REF bug** fixed at Step 13 (`itemId AS INTERNAL_REF`).
- **Stocktake COUNT events** — script 12, 3 new DL tables, 903 rows. Not deployed.
- **Padel Social reporting fixes** — deploy order 12→14→13→15→16→17→18.
- **Org palette** — `growyze_org_palette.sql` ("Growyze" palette, 4 colours) for Padel Social + Dirty Sixth. Not deployed.

Note: Growyze is **not inventory-only** — it feeds sales too (DL_SALES + DL_SALESDETAIL + DL_DISHES), staged into GRYZ_LINEITEM. Profit/GP% available without a separate recipe pipeline.

## Progress log
- **2026-03-05** — Staging built; bugs found; fix scripts authored.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT Padel Social + Dirty Sixth)** — All three appear DEPLOYED/RESOLVED on UAT: (1) **INTERNAL_REF** on `SAT_STOCKEVENT` is populated with Mongo-style item ids (e.g. `68d64d9b…`), 0 NULLs across SALE/COUNT/ORDER — the Step 13 fix is in. (2) **Stocktake COUNT events** present and current: Padel 7,824 rows (GRYZ_COUNT_EVENTS stage 204), Dirty Sixth 1,268 — far exceeds the claimed "~903, not deployed". (3) **16 GRYZ_\* stage tables** present and populated (claim said 14). Growyze orgs live on UAT, so this is the relevant environment. Candidate for closure pending user confirmation.

## Pick-up notes (resume here)
- Read `memory/growyze-reporting.md` for the Padel Social deploy order and `growyze-bugs.md` for the fix details.
- Distinct from O5 (default dashboards) — this is the underlying staging/reporting data correctness.
- Don't mark Closed until the user confirms.
