# O7 — XMSE-949: Product cost matching refactor (ProductMargins pie empty)

> Detail file for ledger item **O7**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — fix proposed, not built |
| **Area** | Presentation / product margin |
| **Owner / decides** | Andy |
| **Next action** | Build the proposed dedicated Tier 1 `PRODUCT_COST_MAP` table |
| **Sources** | `memory/product-cost-matching.md`, [XMSE-949](https://threerocks.atlassian.net/browse/XMSE-949) |

## Context
ProductMargins PieChart renders empty because the NCRAloha↔MarketMan cost-match CTE inside `PresentationControl` returns NULL. Proposed fix: a dedicated Tier 1 `PRODUCT_COST_MAP` table instead of the inline CTE match.

## Progress log
- **2026-03-11** — Diagnosed; refactor proposed (dedicated cost-map table).
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, DEV Three Rocks Cafe)** — Reframed. The pie would **not** be empty: `F_PRODUCT_MARGIN_DAY` has 516 distinct products, **303 (59%) with a non-zero matched cost** → ~303 slices. But the cost-match is weak at daily-row grain: 33,390 rows, AVG_NET_COST NULL in 31,633 (94.7%). Kudu: 0 rows entirely (upstream empty, not a cost-match issue). **Critical link to O10:** the same product→cost mapping that returns NULL for most rows ALSO fans out (>1 cost row per product), inflating F_PRODUCT_MARGIN_DAY measures ~1.5×. A single dedicated `PRODUCT_COST_MAP` (one row per product) fixes BOTH the NULL weakness (O7) and the fan-out over-count (O10).

## Pick-up notes (resume here)
- Read `memory/product-cost-matching.md` for the CTE detail and the proposed table shape.
- Depends on MarketMan DV being fresh — see O1 (XMSE-944); may be blocked by it.
- Don't mark Closed until the user confirms.
