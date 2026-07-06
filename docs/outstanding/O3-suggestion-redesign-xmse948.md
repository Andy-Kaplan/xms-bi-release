# O3 — Suggestion system redesign (XMSE-948): scripts 01-07 not deployed

> Detail file for ledger item **O3**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Area** | Suggestion / AI engine |
| **Owner / decides** | Andy |
| **Next action** | Deploy scripts 01-07 in order to a test org and validate |
| **Sources** | `memory/suggestion-system-redesign.md`, `memory/suggestion-generator-review.md`, `ClaudeDevelopment/suggestions/` (01-07), [XMSE-948](https://threerocks.atlassian.net/browse/XMSE-948) |

## Context
Redesign of the suggestion/description rules engine. Related Jira XMSE-948 (hide empty cards). Scripts 01-07 authored and MCP-tested. **Not deployed.**

## Progress log
- **2026-03-11** — Scripts 01-07 created and MCP-tested; not deployed.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, UAT + DEV)** — Confirms NOT-DEPLOYED. UAT: `ActionInferenceRules`/`DescriptionRules`/`DescriptionTemplates`/`MetricDefinitions` all 0 rows. DEV: ActionInferenceRules 0; the other three hold only 4 baseline-seed rows each (from `7_Dynamic Suggestion Tables.sql`). The table the redesign centres on (ActionInferenceRules) is empty everywhere. Item stands as OPEN.

## Pick-up notes (resume here)
- Deploy order: **01 → 02 → 03 → sp_DeployObjects → 04 → 05 → 06 → 07**.
- Read `memory/suggestion-system-redesign.md` for the design and `suggestion-generator-review.md` for the review findings.
- Don't mark Closed until the user confirms.
