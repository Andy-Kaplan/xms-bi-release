# O4 — Parent-org reporting: scripts 10-11 not deployed

> Detail file for ledger item **O4**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | MONITOR — UAT appears to hold 10-11 already; confirm the exact boundary, then close |
| **Area** | Parent-org / cross-database reporting |
| **Owner / decides** | Andy |
| **Next action** | Review scripts 10-11, decide whether to deploy to UAT |
| **Sources** | `memory/parent-org-reporting.md`, `ClaudeDevelopment/parent-org/` (01-11 + DEPLOY.txt) |

## Context
Parent-organisation reporting: quorum gate, parent dims/facts (tiers 100-102), 13 vis queries, cross-database `UNION ALL`. Dashboard "Group Overview" for Nabil Enterprises — 11 cards + 2 filters. **Scripts 01-09 deployed to UAT; 10-11 authored, not deployed.**

## Progress log
- **2026-03-12 → 2026-03-16** — 01-09 deployed UAT; 10-11 authored, not deployed.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT)** — UAT holds MORE than the original 13/09 scope: PresentationControl tiers ≥100 = **8 steps** (tier 100 dims PD_LOCATION/PD_ORGANISATION; tier 101 facts PF_BOOKING_METRICS_HOUR, PF_FOODCOST_DAY, PF_INVENTORY_EFFICIENCY_DAY, PF_PROFIT_DAY, PF_REVENUE_DAY; tier 102 PF_GROWTH_PERIOD). VisualisationQueries `Parent%` = **21 LIVE** (vs 13 expected) — the extra ~8 are a `ParentBkgBrand*` family on PF_BOOKING_METRICS_HOUR, which look like the 10-11 (or later) additions. Report DB: "Group Overview" config exists for Nabil Enterprises (OrgID 8) AND a second for The Big Table Group; all 21 datasets wired in VisualisationDataSetMap. **DEV is far behind** (1 tier-≥100 step, 7 Parent queries). Can't pin exact 09-vs-11 boundary from DB state, but 10-11 appear effectively deployed to UAT. **Caveat: visibility may be blocked by O13** (empty DashboardGroupMapping).

## Pick-up notes (resume here)
- Read `memory/parent-org-reporting.md` + `ClaudeDevelopment/parent-org/DEPLOY.txt` for what 10-11 add.
- Don't mark Closed until the user confirms.
