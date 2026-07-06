# O9 — Demo organisation data generator: org not provisioned

> Detail file for ledger item **O9**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — generator implemented, demo org not provisioned |
| **Area** | Demo data / org provisioning |
| **Owner / decides** | Andy |
| **Next action** | Provision a demo org via stored procedure, then load the generated data |
| **Sources** | `memory/demo-org-generator.md`, `ClaudeDevelopment/demo-data/` (Python + SQL) |

## Context
Demo org data generator (Python + SQL) — 52 CSVs, 3.4M rows. **Implemented, but the demo org has not been provisioned** and the data not loaded.

## Progress log
- **2026-03-16** — Generator implemented (52 CSVs, 3.4M rows). Demo org not provisioned.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT + DEV)** — Confirms NOT-PROVISIONED. UAT: 18 orgs, all real. DEV: 21 orgs; the only demo-plausible names ("Boulder Bistro" OrgID 20, "Three Rocks Hotel" OrgID 19) have 0 rows in `F_LINEITEM_15MIN` — empty shells, not the 3.4M-row demo load. The generated dataset (52 CSVs) is loaded nowhere.

## Pick-up notes (resume here)
- Read `memory/demo-org-generator.md` for the generator layout and loader (`load_bcp.ps1`).
- Organisations MUST be added via stored procedure, never direct INSERT.
- Don't mark Closed until the user confirms.
