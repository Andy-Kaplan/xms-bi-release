# O10 — £580k Three Rocks sales double-count

> Detail file for ledger item **O10**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — root cause confirmed (join fan-out in cost map); fix = O7's PRODUCT_COST_MAP |
| **Area** | Sales facts / data correctness |
| **Owner / decides** | Andy |
| **Next action** | Confirm the double-count mechanism, then correct the fact build |
| **Sources** | `memory/growyze-default-dashboards.md` (noted as a separate bug) |

## Context
A **£580k Three Rocks sales double-count** surfaced during the Growyze default-dashboards deep dive (2026-06-05). Flagged there as a **separate bug** from the Growyze data blockers — a fact-layer double-count, not a presentation quirk.

## Progress log
- **2026-06-05** — Surfaced during the Growyze UAT deep dive; noted as a distinct bug.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, Three Rocks Cafe C14CF568)** — Confirmed and localised. **Not** a Growyze↔NCRAloha cross-integration overlap (Three Rocks F_LINEITEM_15MIN is NCRAloha-only). It's between two presentation facts: `F_LINEITEM_15MIN` (trustworthy, no cost join) shows net £130,203 for the week Dec 31–Jan 7; `F_PRODUCT_MARGIN_DAY` (joins sales→cost) shows **£193,096 for the same week** and **£656,642 over its 28-day window** — in the neighbourhood of the reported £580k. Ratio is a consistent **1.41–1.56× every overlapping day** (not a load-window artifact). F_PRODUCT_MARGIN_DAY has no row-level duplicate keys (43,852 keys = 43,852 rows) yet the measure is inflated — classic **join fan-out**: the product→cost map returns >1 row per product, inflating NET_VALUE before the final GROUP BY. Magnitude ~1.5×, not exactly 2×. **Fix = same as O7** (dedup cost map to one row per product before the join). Use F_LINEITEM_15MIN as the source of truth for sales meanwhile.

## Pick-up notes (resume here)
- Re-read the relevant section of `memory/growyze-default-dashboards.md` for what was observed.
- First step is to reproduce and localise which fact build stage doubles the £580k (candidate: a fan-out join or a UNION ALL across integrations).
- Related to O5's data blockers — check for a shared root cause.
- Don't mark Closed until the user confirms.
