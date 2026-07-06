# Front-end test cards on TEST — XMSE-1030, XMSE-1014, XMSE-948

Sample data and live cards on the **Kitchen Sink** dashboard for **Three Rocks Cafe** in TEST so Craig can build and verify three front-end pieces of work.

## What this folder contains

| File | Target | Purpose |
|---|---|---|
| `01_register_vis_queries_TEST.sql` | BI MI TEST → `core.core.VisualisationQueries` | Upserts six dataset queries (one per test card) |
| `02_wire_kitchen_sink_TEST.sql` | microservice TEST → `report.dbo.*` | Adds `VisualisationDataSetMap` rows + six `DashboardGridItem` rows on the Kitchen Sink dashboard |
| `03_map_kitchen_sink_to_group_TEST.sql` | microservice TEST → `report.dbo.OrganisationDashboardGroupMapping` | Maps Kitchen Sink to "Test Group" so it appears in the nav |
| `04_fix_markdown_card_sp_TEST.sql` | BI MI TEST → `core.core.DeploymentObjects` + Three Rocks Cafe DB | Fixes a TEST-environment-only bug in `core.MarkdownCard` SP (was filtering by `VisualizationType='BarChartCard'`). |
| `05_fix_multiline_null_value_test.sql` | BI MI TEST → `core.core.VisualisationQueries` | Replaces `NULL AS Stack` with `'total' AS Stack` in `MultiLineNullValueTest`. Front end can't handle NULL Stack. |

Both scripts are idempotent (MERGE on natural keys) — safe to re-run.

## Deploy order

1. Run `01_register_vis_queries_TEST.sql` against the BI MI TEST core database.
2. Run `02_wire_kitchen_sink_TEST.sql` against `report` on the microservice TEST server (`xms-mssql-ne-test`).
3. Refresh the Kitchen Sink dashboard for Three Rocks Cafe in the front end. The six new cards appear at the bottom (sort orders 100-105).

## The six test datasets

### XMSE-1030 — Horizontal stacked bar component

| Property | Value |
|---|---|
| `DataSetName` | `HorizontalStackedBarTest` |
| `VisualizationType` | `StackedBarChartCard` (reuse existing card type until the new component is wired up) |
| Shape | 5 stores stacked by 4 categories (Food / Drink / Snacks / Other), 20 rows total |
| Self-contained | Yes — uses a `(VALUES ...)` constructor, no DV dependency |

**Result-set 1 (data) row shape:** `XAxisLabel`, `LabelSort`, `Value`, `ValueSort`, `VisId`, `Stack`
**Result-set 2 (header) row shape:** `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `Chip`, `Value`

When Craig builds the new `HorizontalStackedBarChartCard` component (or `BarChartCard` with a horizontal flag), the row shape is identical to the existing `StackedBarChartCard` — only the rendering orientation changes. To switch the dashboard tile to the new component once it exists, either (a) flip the `VisualisationId` on the `DashboardGridItem` row to whichever new procedure is registered, or (b) add a `HorizontalStackedBarChartCard` row to `dbo.VisualisationProcedure`, register a new `VisualisationConfig` entry for Three Rocks Cafe, and re-point the existing dataset map.

### XMSE-1014 — MultiLineChartCard NULL Value bug

| Property | Value |
|---|---|
| `DataSetName` | `MultiLineNullValueTest` |
| `VisualizationType` | `MultiLineChartCard` |
| Shape | 2 series (`Series A`, `Series B`) × 5 days |
| Header `Value` | **`NULL`** — this is the bug repro |

**Expected behaviour after fix:** the inline KPI figure above the chart is hidden (matches `StackedBarChartCard`).
**Current behaviour:** "0.00" is rendered above the chart.

The `HorizontalStackedBarTest` card on the same dashboard is a useful reference — its header also returns a non-NULL `Value` so Craig can see the working case alongside the broken one.

### XMSE-948 — MarkdownCard / StaticBoxCard hide-on-empty

Four datasets, two pairs:

| `DataSetName` | `VisualizationType` | Rows returned | Expected behaviour |
|---|---|---|---|
| `MarkdownTestEmpty` | `MarkdownCard` | 0 | Card is **hidden** — no empty container, no layout gap |
| `MarkdownTestVisible` | `MarkdownCard` | 1 | Card renders the markdown body |
| `StaticBoxTestEmpty` | `StaticBoxCard` | 0 | Banner is **hidden** |
| `StaticBoxTestVisible` | `StaticBoxCard` | 1 | Banner renders with `severity = INFO` |

The "Empty" and "Visible" pair are deliberately placed adjacent on Kitchen Sink so that — once the fix is in — the row reflows: only the visible card remains, sitting where the empty one used to be.

**MarkdownCard data-row shape:** single column `markdown` (NVARCHAR(MAX)) — markdown body
**StaticBoxCard data-row shape:** `severity`, `text`, `title`, `dismissable`

## TEST environment reference

| Item | Value |
|---|---|
| TEST organisation | Three Rocks Cafe |
| `OrganisationId` | `C14CF568-588D-F011-B3CD-000D3AD9E9D4` |
| `DbPrefix` | `20250917` |
| Client BI MI database | `20250917_XMS_C14CF568-588D-F011-B3CD-000D3AD9E9D4` |
| Kitchen Sink `DashboardGridId` | `87D8B576-BE97-F011-B3CD-000D3AD9E35E` |

## Tile sizing on Kitchen Sink

Each test tile is half-width on desktop (Medium / Large / ExtraLarge = 6 of 12) and full-width on mobile (ExtraSmall / Small = 12 of 12). Sort orders 100-105 push them below all existing cards.

## Reverting

To remove the test cards from Kitchen Sink without dropping the registered queries, soft-delete the six `DashboardGridItem` rows:

```sql
USE [report];
UPDATE dbo.DashboardGridItem
SET IsDeleted = 1, DateUpdated = SYSUTCDATETIME()
WHERE DashboardGridId = '87D8B576-BE97-F011-B3CD-000D3AD9E35E'
  AND DataSet IN (
      N'HorizontalStackedBarTest', N'MultiLineNullValueTest',
      N'MarkdownTestEmpty',         N'MarkdownTestVisible',
      N'StaticBoxTestEmpty',        N'StaticBoxTestVisible');
```

The `VisualisationDataSetMap` rows and `core.core.VisualisationQueries` records can stay in place — they are inert without a `DashboardGridItem` referencing them.
