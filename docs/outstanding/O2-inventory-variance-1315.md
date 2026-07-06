# O2 — Inventory-variance pipeline fix: scripts 13-15 not deployed

> Detail file for ledger item **O2**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Area** | Inventory / presentation pipeline |
| **Owner / decides** | Andy |
| **Next action** | Review scripts 13-15, decide whether to deploy to UAT |
| **Sources** | `memory/inventory-variance-fix.md`, `memory/inventory-variance-investigation.md`, `ClaudeDevelopment/inventory-variance-fix/` (01-15) |

## Context
Inventory variance pipeline fix, scripts 01-15. **Scripts 01-12 deployed to UAT; 13-15 not deployed.** Strategic direction: StockEvent (Path A) is primary; InvReport (Path B) supplies `UOM_COST` only.

Critical lesson from this work: `StagingControl` has **two** step types — staging AND Load — and column renames must fix both.

Related but distinct (not a code bug): recipe costs = 0 because MarketMan AVT API returns `SalesUsage = 0` for all Kudu rows (no POS integration linked in MarketMan). Staging fix (script 01) already deployed; will work once MarketMan has POS data. Path B alternative: compute theoretical usage from `F_LINEITEM_15MIN × recipe ratios` in DV (medium-term enhancement).

## Progress log
- **2026-03-12** — Scripts 01-12 deployed UAT; 13-15 authored, not deployed.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit)** — CANNOT-VERIFY by DB inspection: no deployment marker distinguishes 13-15 from the deployed 01-12, and the known root cause is a DATA gap (MarketMan AVT `SalesUsage=0` for Kudu), not code presence — so populated-vs-empty facts don't discriminate. Nothing found contradicts "13-15 not deployed." Confirm against `ClaudeDevelopment/QUERY_STATUS.md` / deploy log rather than the DB.

## Pick-up notes (resume here)
- Read `memory/inventory-variance-fix.md` for what 13-15 actually do before deciding.
- Org cursor gotcha: column is `Organisations.DatabaseStatus` (not `DatabaseState`); include `'FAILED'` status.
- Don't mark Closed until the user confirms.
