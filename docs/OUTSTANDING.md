# XMS BI Release — Outstanding Work Ledger

**The live status board for all open work on this project.** Kept current as work is done — when an item is started, advanced, or closed, update its row here in the same session.

**Status tags:** `OPEN` = needs work, no fix yet · `DIAGNOSED` = root cause known, fix not actioned · `MONITOR` = fix applied, watching it · `BLOCKED` = waiting on someone else · `DOC-DEBT` = documentation gap.

**Last updated:** 2026-07-29 (O5 UOM_COST blocker fixed + deployed to UAT; O8 gate (b) cleared)

---

## At a glance

> **Each ID links to a detail file** under [`outstanding/`](outstanding/) holding that task's full context, **progress log**, and pick-up notes. Read the one file for the task you're picking up — detail files are deliberately *not* loaded at session start, so this board stays cheap to keep in context. This table is the only thing surfaced at session start.

| ID | Item | Area | Status | Owner / decides | Next action |
|---|---|---|---|---|---|
| [O1](outstanding/O1-xmse944-marketman-load-failure.md) | XMSE-944: MarketMan dup-INVITEM_ID PK bug | MarketMan / DV load | MONITOR | Andy | Audit: 0 dupes — bug gone. Confirm & close; DEV pipeline dormant since ~Mar 10 |
| [O2](outstanding/O2-inventory-variance-1315.md) | Inventory-variance fix: scripts 13-15 not deployed | Inventory / presentation | OPEN | Andy | Not DB-verifiable — confirm vs QUERY_STATUS/deploy log |
| [O3](outstanding/O3-suggestion-redesign-xmse948.md) | Suggestion system redesign (XMSE-948): 01-07 not deployed | Suggestion / AI engine | OPEN | Andy | Audit confirms NOT deployed (both envs). Deploy 01-07 |
| [O4](outstanding/O4-parent-org-1011.md) | Parent-org reporting: scripts 10-11 | Parent-org / reporting | MONITOR | Andy | Audit: UAT holds 21 Parent queries + tiers 100-102 — likely already deployed. Confirm 10-11 & close |
| [O5](outstanding/O5-growyze-default-dashboards.md) | Growyze default dashboards rebuild | Growyze / presentation | DIAGNOSED | Andy | UOM_COST blocker fixed + deployed to UAT 2026-07-29 (£762,277.46→£8,157.61). NULL LINEITEM_TIMESTAMP + D_PRODUCT fall-through remain |
| [O6](outstanding/O6-growyze-reporting-staging-fixes.md) | Growyze reporting + staging fixes | Growyze / staging | MONITOR | Andy | Audit: all 3 fixes observed live on UAT. Confirm & close |
| [O7](outstanding/O7-xmse949-product-cost-matching.md) | XMSE-949: Product cost matching refactor | Presentation / margin | DIAGNOSED | Andy | Audit: cost-map is weak (95% NULL) AND fans out ~1.5× (= O10). Build PRODUCT_COST_MAP |
| [O8](outstanding/O8-marge-brut-dashboard.md) | Marge Brut dashboard (mock live; mock→live built) | Dashboard / vis + Report DB | OPEN | Andy | Merge branch `worktree-margebrut-live` (8 scripts, review-clean); then run `live/DEPLOY.txt` when Growyze feed + new UAT org ready. O5 UOM_COST gate cleared 2026-07-29; gated on fetcher + org |
| [O9](outstanding/O9-demo-org-not-provisioned.md) | Demo org data generator: org not provisioned | Demo data / provisioning | OPEN | Andy | Audit confirms not provisioned (both envs). Provision via SP, load data |
| [O10](outstanding/O10-threerocks-sales-double-count.md) | £580k Three Rocks sales over-count | Sales facts / correctness | DIAGNOSED | Andy | Audit: confirmed ~1.5× join fan-out in F_PRODUCT_MARGIN_DAY cost map (= O7). Dedup cost map |
| [O11](outstanding/O11-square-integration-scripts.md) | Square integration: SQL scripts not built | Integrations / Square POS | OPEN | Andy | Build scripts from approved design + plan (not DB-audited) |
| [O12](outstanding/O12-doc-debt.md) | Doc debt: DV diagram stat + audit findings §8-10 | Documentation | DOC-DEBT | Andy | Fix Live Links stat 39→40; address §8-10 |
| [O13](outstanding/O13-uat-dashboard-groupmapping-empty.md) | UAT DashboardGroupMapping empty → dashboards invisible | Report DB / visibility | DIAGNOSED | Andy | Run 01_populate_uat_dashboard_groups.sql; verify Group Overview + Marge Brut navigable |
| [O14](outstanding/O14-mews-dv-mapping-deploy.md) | Mews001 DV mapping: scripts built + reviewed, not deployed | Integrations / Mews POS | OPEN | Andy | Deploy per integrations/Mews/DEPLOY.txt (01→02→03 + sp_DataVaultLoad org 19), then Claude MCP-verifies 04 B–E |

---

## Closed

*(none yet — when an item is confirmed done, move its row here with a date and one-line outcome, and keep its detail file for history)*

---

## Maintenance

- **One detail file per item** under `outstanding/O<n>-<slug>.md`. When you advance a task, append a dated entry to that file's **Progress log** and update its status mini-table — then sync the `Status` / `Next action` cells in the table above.
- **Adding an item:** add a table row with the next `O<n>` ID and create its detail file from the `task-detail.md` template (status mini-table → context → Progress log → Pick-up notes).
- **Never mark an item done / Closed without explicit user confirmation** — even when the work looks finished and verified. Report it and ask first; only then move its row to the **Closed** section above.
- Per-script status (test results, target stack) belongs in `ClaudeDevelopment/QUERY_STATUS.md`, not here; this board tracks *work*.
- The session-start hook injects this whole file (table only). Keep it table-only — task detail belongs in the per-item files, not here.
