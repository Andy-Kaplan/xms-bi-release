# O13 — UAT DashboardGroupMapping empty → dashboards silently invisible

> Detail file for ledger item **O13**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — fix script exists, not confirmed run |
| **Area** | Microservice report DB / dashboard visibility |
| **Owner / decides** | Andy |
| **Next action** | Run `01_populate_uat_dashboard_groups.sql` on the UAT report DB; verify dashboards are navigable |
| **Sources** | `docs/microservice-report-database.md` §5.3 + §11, `ClaudeDevelopment/microservice-report/01_populate_uat_dashboard_groups.sql` |

## Context
Surfaced by the 2026-07-02 deployment audit: `dbo.DashboardGroupMapping` on the **UAT report DB is completely empty (0 rows)**. Per the platform's load-bearing visibility rule, an `OrganisationDashboardConfig` row without a matching `DashboardGroupMapping` row is **silently invisible** to the front end (navigation goes through `DashboardGroup_Load`).

This is platform-wide on UAT, not specific to any one dashboard — but it means dashboards that audit correctly as "configured" (notably **O8 Marge Brut** and **O4 Group Overview**) may not actually be reachable by users until the group mappings are populated.

## Progress log
- **2026-07-02 (DB audit, UAT report DB)** — `DashboardGroupMapping` = 0 rows across the whole UAT report DB. Discovered while confirming O4/O8 deployment.

## Pick-up notes (resume here)
- A reference idempotent population script already exists: `ClaudeDevelopment/microservice-report/01_populate_uat_dashboard_groups.sql`. Review it, then have the developer run it (Claude must not execute writes via MCP).
- After running, re-check that Group Overview (O4) and Marge Brut (O8) appear in the front-end nav before closing those items.
- See `docs/microservice-report-database.md` §5.3 + §11 for the exact visibility rule.
- Don't mark Closed until the user confirms.
