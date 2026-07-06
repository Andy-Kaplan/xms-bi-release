# O11 — Square integration: SQL scripts not built

> Detail file for ledger item **O11**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — design + plan done, scripts not built |
| **Area** | Integrations / Square POS |
| **Owner / decides** | Andy |
| **Next action** | Build the integration SQL scripts from the approved design + plan |
| **Sources** | `ClaudeDevelopment/integrations/Square/` (design + implementation plan) |

## Context
Square POS integration. Design spec + implementation plan authored (see recent commits: "Square001 integration implementation plan", "Square integration design spec"). **Scripts not yet built.**

Note: the warehouse-side (this Release repo) scripts are tracked here. The ingestion/fetcher side (Azure Functions) may be tracked separately in the **XMS BI Integrations** ledger.

## Progress log
- **~2026-06** — Design spec + implementation plan committed. Scripts not built.
- **2026-07-02** — Logged to ledger from memory + git history.

## Pick-up notes (resume here)
- Read the design + plan under `ClaudeDevelopment/integrations/Square/` first.
- Follow the standard integration pattern: `_INIT` → `_DDL` → `_Staging` → `_Mapping` → `_Final`.
- Don't mark Closed until the user confirms.
