# O21 — Report DB: 12 procedures hand-deployed, absent from RoundhousE

> Detail file for ledger item **O21**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — verified on UAT, not yet remediated |
| **Area** | Microservice report DB / release process |
| **Owner / decides** | Andy |
| **Next action** | Commit the 12 procedures as numbered RoundhousE migration scripts, then confirm they deploy to a clean environment |
| **Raised** | 2026-07-29 (four-agent report-DB audit) |
| **Sources** | `docs/microservice-report-database.md` §7.1, §7.2.1, §9.1 |

## The problem

Twelve stored procedures exist on the UAT `report` database but were **applied by hand on 2026-07-06 and never captured as RoundhousE migration scripts.** Any environment built from the migration history — including **Prod** — will not have them.

This matters because these twelve are the *only* safe paths for operations the platform actually needs. The auto-generated `{Table}_DeleteEntity` procedures are **hard `DELETE`s**, not soft deletes (a separate finding from the same audit). The hand-deployed `{Table}_Delete` family is the soft-delete path. So on Prod today:

- there is **no soft-delete path** for any report-DB table, and
- the only available delete route physically destroys rows, leaving just the `D` audit row.

Since Prod dashboard/report-DB configuration is still outstanding (see O15), this must be fixed *before* that work begins rather than after.

## The twelve procedures

Soft-delete family (`UPDATE … SET IsDeleted = 1 WHERE …Id = @… AND IsDeleted = 0`):

| Procedure | Created (UTC) |
|---|---|
| `BiConfig_Delete` | 2026-07-06 13:24:20 |
| `DashboardConfig_Delete` | 2026-07-06 13:24:20 |
| `DashboardGrid_Delete` | 2026-07-06 13:24:21 |
| `DashboardGridFilter_Delete` | 2026-07-06 13:24:21 |
| `DashboardGridItem_Delete` | 2026-07-06 13:24:21 |
| `DashboardGroup_Delete` | 2026-07-06 13:24:21 |
| `DashboardGroupMapping_Delete` | 2026-07-06 13:40:46 |
| `DashboardPalette_Delete` | 2026-07-06 14:18:05 |
| `DashboardPaletteColour_Delete` | 2026-07-06 14:34:45 |
| `OrganisationDashboardConfig_Delete` | 2026-07-06 15:00:47 |

Creation helpers:

| Procedure | Created (UTC) | Why it matters |
|---|---|---|
| `DashboardGroup_Create` | 2026-07-06 13:24:21 | The **only working** group-creation path — `DashboardGroup_AddEntity` omits `NOT NULL` `SortOrder` and always throws |
| `DashboardGroupMapping_Create` | 2026-07-06 13:40:46 | True upsert (un-deletes on composite-key hit) |

## Evidence

```sql
SELECT name, create_date, modify_date FROM sys.procedures
WHERE CAST(create_date AS DATE) = '2026-07-06' ORDER BY create_date;

SELECT id, version_id, script_name, entry_date FROM RoundhousE.ScriptsRun
WHERE entry_date >= '2026-06-20' ORDER BY id;
```

- All 12 have `create_date` = `modify_date` = 2026-07-06, 13:24–15:00 UTC.
- `RoundhousE.ScriptsRun` jumps from **id 95 (2026-06-23)** straight to **id 96 (2026-07-10)**. No script ran on 2026-07-06, and no `RoundhousE.Version` row exists for that date (v40 = 07-03, v41 = 07-10).
- The two later runs (2026-07-10, 2026-07-15) were both GUID-named "everytime" scripts and **left every one of the twelve `modify_date` values untouched** — proving they are absent from the migration set entirely, not merely deployed out of sequence.

## Also incomplete even on UAT

The `_Delete` family covers only 10 of 25 dbo tables. There is **no** soft-delete procedure for:

`OrganisationDashboardGroupMapping`, `StaffDashboardConfig`, `StaffDashboardGroupMapping`, `VisualisationConfig`, `VisualisationDataSetMap`, `VisualisationProcedure`, and every org/staff palette table.

Deletes against those go through hard-delete `_DeleteEntity` unless written by hand as `UPDATE … SET IsDeleted = 1`. Worth deciding whether to complete the family while capturing it.

## Pick-up notes

- Extract the live definitions from `sys.sql_modules` on UAT — they are the reference implementation and are known-good.
- Number them into the report-DB migration sequence after `073` (the last real script, 2026-06-23). Note `074`+ may already be taken by later work; check `RoundhousE.ScriptsRun` before numbering.
- These are `CREATE PROCEDURE` scripts, so they must be idempotent for RoundhousE (`CREATE OR ALTER`, or drop-then-create).
- None of the `_Delete` procedures cascades: soft-deleting a grid leaves its items and filters live; soft-deleting a group leaves its mappings. Decide whether that is intended before promoting them as the sanctioned path.
- Related trap worth fixing in the same pass: `DashboardGroup_AddEntity` is unusable (see `docs/microservice-report-database.md` §7.1), so any runbook still calling it needs updating to `DashboardGroup_Create`.
- Report-DB writes are human-run — MCP `execute` is not enabled on any `microservice-*` server, so Claude cannot apply these.
