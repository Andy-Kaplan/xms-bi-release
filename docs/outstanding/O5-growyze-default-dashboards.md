# O5 — Growyze default dashboards rebuild

> Detail file for ledger item **O5**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — blockers identified, build not done |
| **Area** | Growyze / presentation + Report DB |
| **Owner / decides** | Andy |
| **Next action** | Resolve the three data blockers, then build the default dashboards per the re-plan |
| **Sources** | `memory/growyze-default-dashboards.md`, mockup `ClaudeDevelopment/integrations/Growyze/dashboard_mockups/kati_default_dashboards.html` |

## Context
Default dashboards for Growyze orgs. **The 2026-05-20 plan is STALE** (P1 filter void; Growyze sales already in facts; cost is `F_PRODUCT_MARGIN_DAY.AVG_NET_COST`, not `D_PRODUCT`). Re-planned 2026-06-05 via a 6-agent UAT deep dive into 3 split plans (data-quality+enablement / cards+InvMargeBrut / Report DB wiring).

Real blockers before dashboards can be trusted:
1. **NULL `LINEITEM_TIMESTAMP`** on Growyze line items.
2. **Inventory `UOM_COST` pack-vs-unit inflation** (16-113×).
3. **`D_PRODUCT` category fall-through.**

## Progress log
- **2026-05-20** — Initial plan (now stale).
- **2026-06-05** — Re-planned via 6-agent UAT deep dive; blockers identified.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT Padel Social + Dirty Sixth)** — 2 of 3 blockers cleared:
  1. **NULL LINEITEM_TIMESTAMP — STILL-OPEN but has workaround.** `F_LINEITEM_15MIN` is 100% NULL on LINEITEM_TIMESTAMP (Padel 9,394/9,394, Dirty Sixth 15,722/15,722), BUT sibling `ORDER_DATE` is fully populated (Padel 2026-01-29→05-13, net £184,480). Only intra-day / time-of-day cards are blocked; date-grain cards work off ORDER_DATE.
  2. **UOM_COST pack-vs-unit inflation — RESOLVED / not present.** `F_INV_USAGE_DAY` (Padel 9,990 rows): min 0, avg 1.77, max 134.30, only 16 rows >100, none >1000. Top values are genuinely expensive retail items (padel rackets), not unit-vs-pack inflation.
  3. **D_PRODUCT category fall-through — PARTIALLY-RESOLVED (minor).** `D_PRODUCT` 2,169 rows, 0 NULL categories; 4 real categories cover 95%; ~109 (5%) fall through to self-name, "Other" holds 276 (12.7%). Small residual, not systemic.
  Net: dashboards can be built now on the date grain; timestamp blocker only limits intra-day cards.

## Pick-up notes (resume here)
- Read `memory/growyze-default-dashboards.md` for the full re-plan and the 3 split plans.
- These blockers overlap with O10 (£580k double-count) — check whether they share a root cause before fixing.
- Don't mark Closed until the user confirms.
