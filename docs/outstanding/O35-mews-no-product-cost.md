# O35 — Mews populates no product cost (profit cards blank on Mews-only orgs)

> Detail file for ledger item **O35**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — cause localised, fix not designed |
| **Area** | Data Vault / presentation — Mews integration cost path |
| **Owner / decides** | Andy |
| **Next action** | Decide whether Mews should carry a product cost at all, and if so where it comes from. Then decide what a profit card should display on an org that has no cost data (blank vs an explicit "no cost data" state) |
| **Sources** | Found 2026-07-31 while building sales source precedence for O5; `memory/growyze-default-dashboards.md` |

## Context

`presentation.F_PRODUCT_MARGIN_DAY.AVG_NET_COST` is **100% NULL on every Mews row**, on every org that carries Mews:

| Org | Mews rows (`NET_VALUE > 0`) | NULL `AVG_NET_COST` | NULL `PROFIT` |
|---|---|---|---|
| Ibis Gloucester Road (21) | 703 | 703 (100%) | 703 |
| The Oak & Vine (16) | 1,110 | 1,110 (100%) | 1,110 |

Because `PROFIT` is NULL wherever cost is NULL, any profit or margin measure over Mews sales returns NULL.

**Consequence:** the Growyze dashboard pack's `GrowyzeProfit` and `GrowyzeProfitPct` cards can never populate on a **Mews-only** org — Ibis Gloucester Road (21) and Ibis Heathrow (20). They render blank. Sales-only cards (e.g. `GrowyzeSalesByCategory`) are unaffected and work correctly there.

This surfaced only because O5's source-precedence work pointed those cards at Mews sales for the first time; previously they were hardcoded to Growyze and returned nothing on those orgs regardless.

## This is NOT O7 — do not fold them together

[O7](O7-xmse949-product-cost-matching.md) is the **NCRAloha↔MarketMan** cost-match CTE returning NULL — a *weak* match (94.7% NULL measured on Three Rocks), whose proposed fix is a dedicated Tier 1 `PRODUCT_COST_MAP`. O7's text never mentions Mews or the Ibis orgs.

The distinction that matters:

- **O7 — weak cost match.** A cost path exists but resolves poorly. Oak & Vine's *NCRAloha* rows being 32% NULL (30,787 of 95,511) **is** O7.
- **O35 — no cost path at all.** Nothing maps a cost onto a Mews product. This is an absence, not a bad match, so `PRODUCT_COST_MAP` as scoped for O7 would not fix it.

## Why it matters beyond the Growyze pack

Marge Brut on the Ibis orgs (see [O8](O8-marge-brut-dashboard.md)) does **not** hit this, because it derives cost from Growyze stock movement rather than from `F_PRODUCT_MARGIN_DAY`. That is worth knowing: it means a working cost figure for those hotels already exists in the inventory lane, and may be the natural source for a Mews product cost — the two lanes currently disagree about whether cost is knowable.

## Pick-up notes (resume here)

- Confirm the gap is upstream of presentation: check whether `datavault.SAT_LINEITEM` / the Mews staging steps carry any cost or unit-cost column at all for `int_mews001`, or whether Mews's API simply does not return one.
- The decision is partly a product one. Options, roughly: (a) map a cost from the Growyze/inventory lane onto Mews products; (b) accept Mews as sales-only and give profit cards an explicit "no cost data for this source" state rather than a blank; (c) suppress profit cards on Mews-only orgs at the dashboard-wiring level (Plan 3).
- Option (b) or (c) needs doing **before** O5's Plan 3 wires the pack to the Ibis orgs, or those two hotels ship with two permanently blank cards.
- Don't mark Closed until the user confirms.
