# XMS BI Dashboard Layout — Design Handoff

**Audience:** a designer (human or AI) reshaping the layout of XMS BI dashboards, with no prior knowledge of the platform.
**Purpose:** define precisely what is and is not possible, so that proposed layouts are buildable without SQL or frontend changes.
**Verified against:** UAT — report DB `report` on `xms-sql-fog-uat`, warehouse `core` on the UAT Managed Instance. All counts and layouts below were queried live on 2026-07-31.

---

## 1. The mental model

**A dashboard is a flow layout, not a canvas.**

An XMS BI dashboard is a single MUI (Material UI) `Grid` container. Cards are placed into it as a linear sequence. Each card declares only *how many of 12 columns it occupies*, at five screen sizes. Cards flow left to right in sort order and wrap to a new line when the next card no longer fits.

There are no rows in the data model. **A "row" is an emergent property of span arithmetic.** Three cards of 4 columns form a row because 4+4+4 = 12; the fourth card is pushed to the next line automatically.

Every one of the 82 live grids is identical in its container settings — `Columns` 12, `Spacing` 2, `Container` true. There is no variation to exploit and no way to request a different column count.

```
Grid: 12 columns
┌────────────┬────────────┬────────────┐
│  md=4      │  md=4      │  md=4      │   ← sums to 12, one line
├──────┬─────┴────────────┴────────────┤
│ md=3 │ md=9                          │   ← also sums to 12
├──────┴───────────────────────────────┤
│ md=12                                │
└──────────────────────────────────────┘
```

### The rendering chain

Understanding this explains most of the constraints in §3. Two separate databases are involved.

```
Report DB (Azure SQL)                    Warehouse (Managed Instance)
─────────────────────                    ────────────────────────────
DashboardGrid       ── container settings
  └─ DashboardGridItem                   core.core.VisualisationQueries
       ├─ SortOrder    ← LAYOUT           └─ the SQL for a dataset,
       ├─ xs/sm/md/lg/xl spans ← LAYOUT      including its title,
       ├─ VisualisationId → card type        axis labels and colours-free
       └─ DataSet ─────────────────────────►  output contract
  └─ DashboardGridFilter → filter bar
```

The report DB holds **placement**. The warehouse holds **content** — including the card's title, its axis labels and its description. Anything in the right-hand column is a SQL change, not a layout change.

---

## 2. What you can control

This is the complete set of levers. There are four.

| Lever | Column | Range | Notes |
|---|---|---|---|
| **Width** at 5 breakpoints | `ExtraSmall`, `Small`, `Medium`, `Large`, `ExtraLarge` | 1–12 | `ExtraSmall` is required; the other four are nullable and inherit upward from the nearest smaller breakpoint |
| **Order** | `SortOrder` | any int | Determines flow position. Not required to be contiguous or unique |
| **Card type** | `VisualisationId` | one of 16 | See §4 |
| **Dataset** | `DataSet` | any dataset with a matching live query | Must match on **both** name and card type — see §3 |

Plus, at grid level: which filter datasets appear and in what order (`DashboardGridFilter.DataSet`, `SortOrder`).

That is genuinely all. There is no styling, sizing, spacing, colour, title, grouping or nesting configuration.

### Breakpoints

The five spans map to MUI's breakpoint system. Standard MUI v5 defaults are `xs` ≥0px, `sm` ≥600, `md` ≥900, `lg` ≥1200, `xl` ≥1536. *Caveat: the frontend source was not available when this document was written, so a custom theme could shift these thresholds. The relative ordering is certain; the exact pixel values are the MUI defaults and should be confirmed before relying on them.*

In practice the live dashboards treat them as: `xs` = phone, `sm` = tablet, `md`/`lg`/`xl` = desktop. **In all 16 grids inventoried in §5, `md`, `lg` and `xl` are always set to the same value.** Desktop is effectively one breakpoint. Varying them is possible but unprecedented.

---

## 3. What you cannot control

This section is the reason this document exists. Every constraint below was verified against the live schema.

### Hard structural limits

**No height control of any kind.** `DashboardGridItem` has no height, aspect-ratio or row-span column. Card height is fixed by the frontend component for each card type. You cannot request a taller chart, a shorter table, or two cards of matching height. **A layout proposal that depends on specific heights cannot be built.**

**No x/y positioning.** There is no coordinate system — only order and width. Consequences:
- A persistent sidebar is impossible.
- A card cannot be pinned, floated or overlapped.
- You cannot leave a deliberate gap. A row that sums to less than 12 leaves trailing whitespace, and the next card will pull up into it if it fits.

**No tabs, accordions, sections or dividers.** A grid is one flat list. The only way to visually segment a dashboard is a full-width `StaticBoxCard` or `MarkdownCard` acting as a pseudo-header — which is exactly what the Margin Management dashboard does with its first three items.

**No nesting.** Cards cannot contain cards. There are no groups or panels.

### Content is not layout

**Card titles are not in the layout config.** A card's title, description, axis labels and legend labels all come from the *second result set* of its warehouse query. Renaming a card means editing SQL in `core.core.VisualisationQueries` and redeploying — it is not a design change. The same applies to number formatting and column headers in data grids.

**Colours cannot be controlled.** The report DB has a nine-table palette system, and palettes can be *defined* — but nothing applies them. The selection layer was never built, confirmed with the frontend team on 2026-07-30 (tracked as ledger item **O26**). All three selection tables also require a `StaffId`, so even when it is built, **brand colours cannot be set organisation-wide** without schema change. Treat chart colours as fixed and unknowable.

### Data binding

**A dataset can only be bound to a card type if a query already exists for that exact pair.** Bindings resolve on `(DataSetName, VisualizationType)`. `InvCOGSByCategory` can be rendered as both a pie and a stacked bar because both rows exist; asking for it as a heatmap requires new SQL. A card bound to a non-existent pair raises `DataSet "%s" not found` and renders as an error.

**Reusing one dataset across several card types is an established pattern**, not a hack — Dirty Sixth's "Stock Activity" renders `InvWasteAnalysis` as a bar chart, a multi-line chart and a data grid on the same dashboard.

**New metrics are not a design change.** A dataset that does not exist requires a new warehouse query, a `VisualisationDataSetMap` row, and possibly presentation-layer work. Budget for that separately.

### Filters

**Filters are grid-global.** They live in a fixed filter bar; only their presence and order are configurable. You cannot scope a filter to one card, place a filter mid-grid, or give two cards different filter sets.

**The date picker is opt-in per query.** A card responds to the date range only if its query declares `StartDate`/`EndDate` in its `ParameterMappings` JSON. A card whose query omits them silently ignores the date picker — it will not error, it will just show a different period from every other card on the dashboard.

### Sharing and blast radius

**Grids are shared across organisations.** `DashboardGrid` has no `OrganisationId`. Grid `050FCDB8-0D64-4B3A-969B-E06F529673CD` ("Margin Management") is referenced by **six different organisations**; the Growyze three-pack grids each serve five. **Re-laying-out one of these changes it for every organisation simultaneously.** Before proposing changes to a shared grid, the options are: accept the fan-out, or clone the grid first so the change lands on one organisation only.

### Conditional behaviour

**There is exactly one conditional-visibility mechanism**, and it is a happy accident of the query contract: `StaticBoxCard` and `MarkdownCard` queries return **zero rows** when their trigger condition is not met, so the card renders nothing and effectively hides itself. Margin Management uses this for a high-variance alert banner that only appears above 15% variance.

This is genuinely useful for alerts and contextual guidance. It does not extend to other card types, and it is driven by SQL logic, not configuration.

**No interactivity between cards.** No drill-down, no click-to-filter, no linked selection, no export.

### Environment caveat

`StaticBoxCard` (id 16) and `MarkdownCard` (id 17) are recent additions and were deployed to UAT ahead of Prod. Confirm availability before using them in anything Prod-bound. All other card types are established.

---

## 4. Card catalogue

Sixteen placeable card types. (`VisualisationId` 14 does not exist; `FilterList` is *not* a placeable card — filters go through `DashboardGridFilter`.)

The **data columns** are what a card can display. If a piece of information is not in that list, that card type cannot show it. The **header columns** come from a second result set and supply the chrome.

| Id | Card type | Data columns | Header columns |
|---|---|---|---|
| 1 | `BarChartCard` | `BarLabel`, `BarLabelSort`, `BarValue`, `BarValueSort` | `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `TotalValue`, `Chip` |
| 2 | `CombinedChartCard` | `XAxisLabel`, `LabelSort`, `Value`, `ValueSort`, `VisId`, `VisType`, `LegendLabel` | `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `Chip`, `Value` |
| 3 | `CustomDataGrid` | `Column1` … `Column30` | `Title`, `Description`, `Label1`–`Label29`, `Type1`–`Type29` |
| 4 | `CustomGroupedDataGrid` | `ParentId`, `Id`, `GroupedColumn`, `Column1`–`Column29` | + `GroupedLabel`, `GroupedType` |
| 5 | `CustomPinnedDataGrid` | `PinnedColumn`, `Columns`, `ColumnsSort`, `Value` | `Title`, `Description`, `PinnedLabel`, `PinnedType`, `ColumnsLabel`, `ColumnsType`, `ColumnsMinWidth`, `ValueLabel`, `ValueType` |
| 6 | `HeatmapCard` | `XAxisLabel`, `YAxisLabel`, `Value` | `Title`, `Description` |
| 7 | `LineChartCard` | `LineLabel`, `LineLabelSort`, `LineValue`, `LineValueSort` | as BarChartCard |
| 8 | `MultiLineChartCard` | `XAxisLabel`, `LabelSort`, `Value`, `ValueSort`, `VisId`, `Curve`, `Stack`, `Area`, `StackOrder`, `ShowMark`, `LegendLabel` | `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `Chip`, `Value` |
| 9 | `PieChartCard` | `Label`, `Value`, `Id`, `Curve`, `Stack`, `Area`, `StackOrder`, `ShowMark`, `LegendLabel` | `Title`, `Description`, `Trend`, `Chip`, `PiePrimaryText`, `PieSecondaryText` |
| 10 | `SingleKPICard` | `Title`, `Description`, `Trend`, `Chip`, `Value` — one row, no separate header set | — |
| 11 | `StackedBarChartCard` | `xAxisLabel`, `LabelSort`, `Value`, `ValueSort`, `VisId` (series), `Stack` | `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `Chip`, `Value` |
| 12 | `StatCard` | `XAxisLabel`, `LabelSort`, `Value`, `ValueSort` | `XAxisLabel`, `YAxisLabel`, `Title`, `Interval`, `Trend`, `Chip`, `Value` |
| 13 | `TreeViewCard` | — no live queries exist | — |
| 15 | `RadarChartCard` | `Axis`, `AxisSort`, `Label`, `Value` | `Title`, `Description`, `Value` |
| 16 | `StaticBoxCard` | `severity`, `text`, `title`, `dismissable` | — |
| 17 | `MarkdownCard` | `markdown` (single value) | — |

### Notes that affect design decisions

**`SingleKPICard`** is the workhorse — 186 of 565 placed cards, a third of everything on screen. Its `Title`/`Value` render reliably and `Description` renders as a subtitle. **`Trend` and `Chip` exist in the contract but no production query populates them, and their rendering has never been confirmed.** Do not design a KPI row that depends on a trend indicator or a status chip without testing first. To show a comparison ("vs Feb 2026"), put it in `Description`, which is verified.

**`CombinedChartCard`** is the only way to mix marks. `VisType` is set *per row* to `'bar'` or `'line'`, so one query can render bars and an overlaid line. This is how conversion-rate-over-volume charts are built.

**`MultiLineChartCard`** stacks by default. Rows sharing a `Stack` value are **summed cumulatively**. To draw independent lines, give each series its own `Stack` value — setting different `VisId` values does *not* unstack them. `Curve` accepts `'linear'` or `'natural'` (smoothed); `ShowMark` toggles point markers.

**The three data grids** all render up to 29–30 columns with per-column type tokens: `TEXT`, `INT`, `DECIMAL`, `PERCENT`, `CURRENCY`. `CustomGroupedDataGrid` adds parent/child grouping; `CustomPinnedDataGrid` pivots into a matrix with a pinned first column. `CustomPinnedDataGrid` (3 live queries) and `StatCard` (3) are placed on **zero** live dashboards — they are effectively untested in production.

**`StaticBoxCard`** is a dismissable alert banner with a severity level, not a chart. **`MarkdownCard`** renders rich text assembled by SQL. Both self-hide when their query returns no rows. Together they are the only tools available for narrative, guidance or section headers.

### Availability vs. usage

Query availability differs sharply from what is actually deployed — useful when judging how safe a card type is.

| Card type | Live queries | Cards placed |
|---|---|---|
| `BarChartCard` | 140 | 144 |
| `SingleKPICard` | 102 | 186 |
| `FilterList` | 38 | n/a (filters) |
| `CustomDataGrid` | 37 | 59 |
| `StackedBarChartCard` | 31 | 33 |
| `MultiLineChartCard` | 30 | 41 |
| `PieChartCard` | 26 | 25 |
| `CombinedChartCard` | 22 | 45 |
| `HeatmapCard` | 12 | 14 |
| `RadarChartCard` | 10 | 6 |
| `CustomGroupedDataGrid` | 5 | 6 |
| `LineChartCard` | 4 | 3 |
| `CustomPinnedDataGrid` | 3 | 0 |
| `StatCard` | 3 | 0 |
| `StaticBoxCard` | 2 | 2 |
| `MarkdownCard` | 1 | 1 |
| `TreeViewCard` | 0 | 0 |

**466 live queries and 565 placed cards in total.** (Note: `CLAUDE.md` and `docs/presentation-and-visualisation.md` both state 109 queries across 89 datasets. Those figures are from January 2026 and are stale by a factor of four. The live warehouse is authoritative.)

---

## 5. Layout inventory

Sixteen grids, one per distinct layout family. 82 live grids exist but they collapse to these patterns; where a grid is shared, the organisations are named.

Notation: `SortOrder · CardType · dataset · xs/sm/md`. Desktop rows are derived from `md` spans. `lg` and `xl` equal `md` in every case below.

---

### 5.1 The Growyze three-pack

Three grids shared by **five organisations** — The Oak & Vine, Ibis Heathrow, Ibis Gloucester Road, Dirty Sixth, Padel Social. The highest-blast-radius layouts in the platform.

#### Overview — `B0A1D000-0001-4A00-9E00-000000000001`
Filters: `Locations`, `InvItems`

| Row | Cards |
|---|---|
| 1 | `NetSales` 12/6/4 · `GrowyzeProfit` 12/6/4 · `GrowyzeProfitPct` 12/6/4 |
| 2 | `GrowyzeActiveStocktakes` 12/6/4 · `GrowyzeDeliveriesValue` 12/6/4 · `InvWasteCost` 12/6/4 |
| 3 | MultiLineChart `InvStockActivity` 12 |
| 4 | CustomDataGrid `GrowyzeCategoryStockTrend` 12 |

Rows 1–2 are all `SingleKPICard`. Clean, symmetric — 6 KPIs as 2×3, then two full-width cards.

#### Sales & Profitability — `B0A1D000-0002-4A00-9E00-000000000002`
Filters: `Locations`, `Products`, `GrowyzeProductsCompFilter`

| Row | Cards |
|---|---|
| 1 | **Six** KPIs at md=2: `NetSales`, `GrowyzeProfit`, `GrowyzeProfitPct`, `OakVineMenuAvgItemValue`, `GrowyzeAvgCostSpend`, `GrowyzeBestCategory` |
| 2 | Four KPIs at md=3: `GrowyzeTopRevenueItem`, `GrowyzeHighestGPItem`, `GrowyzeMostSoldItem`, `GrowyzeLowestItem` |
| 3 | PieChart `GrowyzeSalesByCategory` md=5 · CustomDataGrid `ProductComparison` md=7 |
| 4 | CombinedChart `GrowyzeMenuProfitabilityTrend` 12 |
| 5 | CustomDataGrid `GrowyzeMenuEngineering` 12 |
| 6 | Heatmap `GrowyzeSalesHeatmap` 12 |

The densest layout in the platform: 10 KPIs before any chart. Row 1 proves **six-across at md=2 is viable**; row 3 proves asymmetric 5/7 splits work.

#### Inventory Control — `B0A1D000-0003-4A00-9E00-000000000003`
Filters: `Locations`, `InvItems`

| Row | Cards |
|---|---|
| 1 | `GrowyzeActiveStocktakes` · `GrowyzeDeliveriesValue` · `InvWasteCost` — all md=4 |
| 2 | StackedBar `InvStockActivity` 12 |
| 3 | `GrowyzeHighestVenue` md=6 · `GrowyzeLowestVenue` md=6 |
| 4 | CustomGroupedDataGrid `InvKPIGrouped` 12 |
| 5 | PieChart `InvCOGSByCategory` md=6 · CustomDataGrid `InvUseAnalisys` md=6 |

Note the two half-width KPIs in row 3 — an unusual choice; KPIs elsewhere are 2, 3 or 4 columns. *(`InvUseAnalisys` is a live misspelling of "Analysis" in both the layout and the warehouse. It must be matched exactly.)*

---

### 5.2 Pantry COGS — `3931A79E-61B1-4157-B006-B8E7DAA0B708` (Padel Social)

Filters: `PantryCOGSVenues`, `PantryCOGSPeriods`, `PantryCOGSCategories`. Same layout deployed as three separate grids for Padel Social, Ibis Gloucester Road and Dirty Sixth.

| Row | Cards |
|---|---|
| 1 | Four KPIs md=3: `PantryCOGSSpendKPI`, `SoldKPI`, `ClosingStockKPI`, `VarianceKPI` |
| 2 | PieChart `ConsumptionMix` md=6 · BarChart `PeriodComparison` md=6 |
| 3 | BarChart `TopItemsByCategory` md=6 · BarChart `SlowMovers` md=6 |
| 4 | BarChart `ByVenue` 12 |
| 5 | CustomDataGrid `BillingTotals` 12 |
| 6 | CustomGroupedDataGrid `ItemTable` 12 |
| 7 | CustomDataGrid `Exceptions` 12 |

A textbook shape: KPI row → paired charts → full-width detail. Rows 5–7 are three consecutive full-width tables, which is a lot of uninterrupted scroll.

---

### 5.3 Marge Brut — `FA17D12F-1CFB-4D15-87D6-21B22DFA5EE3` (The Oak & Vine)

Filter: `MargeBrutGroups`

| Row | Cards |
|---|---|
| 1 | Four KPIs md=3 — but **xs=12, sm=12**, so they stack one-per-line on both phone *and* tablet |
| 2 | CustomDataGrid `MargeBrutGrid` 12 |
| 3 | BarChart `CostRatioByGroup` md=6 · BarChart `PurchasesBySupplier` md=6 |
| 4 | PieChart `MargeBrutConsumptionMix` md=6 — **orphan: fills only half the row** |

Two defects worth fixing: the `sm=12` KPI stack wastes tablet width (every other dashboard uses `sm=3` or `sm=6`), and the final pie chart leaves 6 empty columns.

---

### 5.4 Margin Management — `050FCDB8-0D64-4B3A-969B-E06F529673CD`

**Shared by six organisations** — Three Rocks Cafe, Dover Street Counter, Kudu, Martinos, Myrtos, The Dover Restaurant. Filter: `Locations`.

| Row | Cards | SortOrder |
|---|---|---|
| 1 | StaticBoxCard `InvMMHeader` 12 | 1 |
| 2 | StaticBoxCard `InvMMHeader2` 12 | 2 |
| 3 | MarkdownCard `InvMMHeader` 12 | 3 |
| 4 | Four KPIs: `NetSales`, `InvPosVar`, `InvWasteCost`, `InvNegVar` — **xs=3** | 12–15 |
| 5 | PieChart `InvTheoMargin` md=3 · StackedBar `InvTop20Variance` md=9 | 25, 28 |
| 6 | CombinedChart `InvCountVariance` 12 | 37 |

The only dashboard using the narrative cards, and the only one with a **3/9 asymmetric split**. Rows 1–3 are conditional — they appear only when their SQL trigger fires.

Two things to note. First, `SortOrder` is deliberately gapped (1,2,3,12,13,14,15,25,28,37) to leave room for insertion — a convention worth preserving. Second, **`xs=3` puts four KPIs across a phone screen**, which is almost certainly too cramped; every other dashboard uses `xs=6` or `xs=12`.

---

### 5.5 The Oak & Vine bespoke set

Ten dashboards unique to one organisation, so safe to restyle. Four representative layouts:

#### Weekly P&L — `055D05C2-8E33-F111-9A49-000D3AB27214` · filter `Locations`

| Row | Cards |
|---|---|
| 1 | Four KPIs 6/3/3: `OakVineNetRevenue`, `FoodRevenue`, `DrinkRevenue`, `GrossProfit` |
| 2 | BarChart `RevenueByWeek` md=8 · PieChart `FoodDrinkSplit` md=4 |
| 3 | BarChart `COSByWeek` md=6 · LineChart `COSPercentByWeek` md=6 |
| 4 | MultiLineChart `FoodDrinkCOSPercent` 12 |
| 5 | BarChart `LabourCostByWeek` md=6 · LineChart `LabourPercentByWeek` md=6 |
| 6 | BarChart `GPByWeek` md=6 · LineChart `GPPercentByWeek` md=6 |
| 7 | BarChart `ExpensesByWeek` 12 |

The strongest layout convention in the platform: **absolute value as a bar, the same metric as a percentage as a line, side by side.** Repeated three times for cost of sales, labour and gross profit. Highly readable and worth propagating.

#### Product Mix — `159CCC16-E733-F111-9A49-000D3AB27214`
Filters: `Locations`, `ProductCategories`, `Products`, `Occasions`

| Row | Cards |
|---|---|
| 1 | Four KPIs 6/3/3 |
| 2 | BarChart `Top10Products` md=8 · PieChart `FoodDrinksSplit` md=4 |
| 3 | StackedBar `RevenueByCategory` md=6 · BarChart `RevenueByOccasion` md=6 |
| 4 | Heatmap `SalesByHour` 12 |
| 5 | MultiLine `WeeklyTrend` md=6 · BarChart `Bottom10Products` md=6 |

Note the 8/4 pairing in row 2 — a wide ranked bar chart beside a narrow pie. Used on both this and Weekly P&L.

#### Market Basket — `5AAE6529-F933-F111-9A49-000D3AB27214`
Filters: `Locations`, `ProductCategories`, `Products`, `Occasions`

| Row | Cards |
|---|---|
| 1 | Four KPIs 6/3/3 |
| 2 | Heatmap `CategoryAffinity` md=6 · BarChart `OrderSize` md=6 |
| 3 | CustomDataGrid `TopPairs` 12 |

The tightest dashboard in the platform at 7 cards. A good template for a focused, single-question view.

#### Revenue & Trading — `EA052030-F933-F111-9A49-000D3AB27214` · filters `Locations`, `Occasions`

| Row | Cards |
|---|---|
| 1 | Four KPIs 6/3/3 |
| 2 | BarChart `DailyTrend` 12 |
| 3 | BarChart `ByDayOfWeek` md=6 · BarChart `ATVByHour` md=6 |
| 4 | Heatmap `HourlyByLocation` 12 |
| 5 | BarChart `ATVByLocation` md=6 — **orphan half-row** |
| 6 | CustomDataGrid `DailyDetail` 12 |

Row 5 is a wrapping artefact: a 6-column card followed by a 12-column card cannot share a line, so the bar chart sits alone with 6 empty columns beside it. A common and easily fixed defect.

---

### 5.6 The brand set — `EBF2D548-7F67-4710-9748-1BC9722B0770` (Las Iguanas "Sales Overview")

Six near-identical dashboard sets across Las Iguanas, Frankie & Bennys, Bella Italia, Amalfi, Chiquito and The Big Table Group. Each brand has its own grid, so changes are per-brand — but the *pattern* is replicated six times and should be changed consistently.

Filters: `Locations`, `RevenueCentres`, `DayOfWeek`

| Row | Cards |
|---|---|
| 1 | Four KPIs 12/6/3: `NetSales`, `TotalOrders`, `GrossATV`, `DiscountPerc` |
| 2 | CombinedChart `NetSalesByHour` 12 |
| 3 | CustomDataGrid `SalesKPIGrouped` 12 |

The minimal viable dashboard — 6 cards, 3 rows. The `12/6/3` KPI progression (1-up phone, 2-up tablet, 4-up desktop) is the most common responsive pattern in the platform and the safest default.

#### Bookings — Brand Deep Dive — `9EB93034-B657-486D-9DA7-E13FFE172A96` · filter `BkgBrands`

| Row | Cards |
|---|---|
| 1 | Four KPIs 12/6/3 |
| 2 | StackedBar `MonthlyBookingsCovers` md=6 · MultiLine `SessionsUsers` md=6 |
| 3 | CustomDataGrid `MonthlyTable` 12 |

#### Group Overview — `745A1F13-7150-4A21-AE1E-05A9BFB380E1` (The Big Table Group)
Filters: `ParentLocations`, `ParentOrganisations`

| Row | Cards |
|---|---|
| 1 | Three KPIs 12/6/4: `ParentNetSales`, `ParentOrderCount`, `ParentAvgOrderValue` |
| 2 | PieChart `ParentRevenueShare` md=6 · StackedBar `ParentOrgRevenue` md=6 |
| 3 | MultiLine `ParentOrgRevenueTrend` 12 |
| 4 | CustomDataGrid `ParentOrgSummaryTable` 12 |

The parent-organisation rollup pattern. `Parent*` datasets aggregate across child organisations.

---

### 5.7 Dirty Sixth

#### Stock Activity — `7ED51BEF-1DEE-496F-8B83-09BF7E357F1B` · filters `Locations`, `InvItems`

Fourteen cards, ten rows — the longest scroll in the platform.

| Row | Cards |
|---|---|
| 1 | BarChart `InvConsumption` 12 |
| 2 | CustomDataGrid `InvConsumption` 12 |
| 3 | BarChart `InvWasteAnalysis` md=6 · MultiLine `InvWasteAnalysis` md=6 |
| 4 | CustomDataGrid `InvWasteAnalysis` 12 |
| 5 | StackedBar `InvStockActivity` md=6 · MultiLine `InvStockActivity` md=6 |
| 6 | Three KPIs md=4: `InvWasteCost`, `InvOrdersCost`, `InvNegVar` |
| 7 | StackedBar `InvTop20Variance` 12 |
| 8 | CustomDataGrid `InvCountData` 12 |
| 9 | MultiLine `InvVarianceTrend` 12 |
| 10 | CustomDataGrid `InvAvgUsage` 12 |

**The clearest restructuring candidate.** The KPI row is buried at row 6, below five rows of charts — every other dashboard leads with KPIs. Six of ten rows are full-width, and `InvConsumption`, `InvWasteAnalysis` and `InvStockActivity` each appear two or three times in different card types.

#### Cost & Margins — `7C83F241-9CD7-4326-B659-109CF4408793` (shared with Padel Social)
Filters: `Locations`, `InvItems`, `Products`

| Row | Cards |
|---|---|
| 1 | PieChart `InvCOGSByCategory` md=6 · StackedBar `InvCOGSByCategory` md=6 |
| 2 | MultiLine `InvMarginTrend` 12 |
| 3 | CustomGroupedDataGrid `InvMargeBrut` 12 |
| 4 | PieChart `InvUsageByCategory` md=6 · StackedBar `InvUsageBySubCategory` md=6 |

Row 1 shows the same dataset as both a pie and a stacked bar — a composition-plus-trend pairing. **No KPI cards at all**, the only dashboard of which that is true. `SortOrder` runs 1,2,3,4,6,7 — position 5 was deleted, illustrating that gaps are normal.

---

### 5.8 Survey — `C79D83A8-DC32-F111-9A49-000D3AB27214` ("Survey - Lifestyle - Standard")

Filter: `SurveyDistCommunityFilter`. Neighbours - Eastleigh has 12 survey dashboards on this pattern.

| Rows 1–5 | Ten `BarChartCard`s, all md=6, in pairs |
|---|---|
| | `SurveyDistLifestyleArts`, `Children`, `Education`, `Family`, `Health`, `Over70`, `Singles`, `Sport`, `YoungAdults`, `Youth` |

Ten identical bar charts in five identical rows, no KPIs, no variation. **The strongest case for redesign in the inventory** — a `RadarChartCard` comparing all ten lifestyle dimensions on one axis set, or a heatmap, would replace five rows of scroll with a single card. Radar queries already exist for other survey themes, so the pattern is proven.

---

## 6. Conventions and anti-patterns

Distilled from the 16 layouts above. These are observed, not documented — but they are consistent enough to treat as house style.

### Conventions worth preserving

**KPIs lead.** Fourteen of sixteen dashboards open with a KPI row. The two that don't (Stock Activity, Cost & Margins) are the two that read worst.

**`12/6/3` is the default responsive KPI progression** — 1-up on phone, 2-up on tablet, 4-up on desktop. Use it unless there's a reason not to.

**Detail sinks.** Full-width data grids belong at the bottom. Every dashboard follows this.

**Bar + line pairing.** Absolute value as a bar beside the same metric as a percentage as a line, both md=6. Oak & Vine's Weekly P&L uses it three times.

**Composition + trend pairing.** A pie beside a stacked bar for the same dataset — composition now, composition over time.

**8/4 for ranked-plus-share.** A wide ranked bar chart beside a narrow pie.

**Gapped `SortOrder`.** Either 10/20/30 or gapped integers, leaving room to insert without renumbering. Contiguous 1,2,3 numbering makes later insertion awkward.

### Anti-patterns present in live dashboards

| Anti-pattern | Where | Fix |
|---|---|---|
| **Orphan half-rows** — a md=6 card followed by a md=12 card, leaving 6 dead columns | Marge Brut row 4; Revenue & Trading row 5 | Pair it, or promote to md=12 |
| **KPIs buried below charts** | Stock Activity (row 6 of 10) | Move to row 1 |
| **`sm=12` on KPIs** — wastes tablet width | Marge Brut | Use `sm=6` |
| **`xs=3` on KPIs** — four KPIs across a phone | Margin Management | Use `xs=6` or `xs=12` |
| **Full-width monotony** — 3+ consecutive md=12 cards | Pantry COGS rows 5–7; Stock Activity | Pair what can be paired |
| **Repetition without variation** — 10 identical cards | Survey - Lifestyle - Standard | Consolidate into one multi-series card |

### Realistic scale

Live dashboards run **2 to 15 cards**, median 8. Filters run 0 to 4. Anything beyond ~15 cards has no precedent.

---

## 7. Output format

Emit one JSON object per dashboard.

```json
{
  "dashboard": "Pantry COGS",
  "gridId": "3931A79E-61B1-4157-B006-B8E7DAA0B708",
  "organisations": ["Padel Social"],
  "grid": { "columns": 12, "spacing": 2, "container": true },
  "filters": [
    { "sortOrder": 1, "dataSet": "PantryCOGSVenues" },
    { "sortOrder": 2, "dataSet": "PantryCOGSPeriods" }
  ],
  "items": [
    {
      "sortOrder": 10,
      "cardType": "SingleKPICard",
      "visualisationId": 10,
      "dataSet": "PantryCOGSSpendKPI",
      "spans": { "xs": 12, "sm": 6, "md": 3, "lg": 3, "xl": 3 },
      "note": "optional — rationale for a non-obvious choice"
    }
  ]
}
```

### Rules

1. **`grid` is fixed.** Always `{ "columns": 12, "spacing": 2, "container": true }`. Reproduce it for completeness; never vary it.
2. **`md` spans must sum to exactly 12 within each intended visual row.** This is the one invariant that determines whether a layout renders as designed. State the row breakdown in your reasoning so it can be checked.
3. **`cardType` and `visualisationId` must agree** and come from the §4 table.
4. **`dataSet` must be an existing dataset with a live query for that card type.** To introduce a new one, list it separately under `"requiresNewQuery"` with a description of the metric — do not put it in `items` as though it were available.
5. **`sortOrder`** — use gapped values (10, 20, 30…).
6. **Omit `lg`/`xl`** only if equal to `md`; including them explicitly is preferred, matching current practice.
7. **Never specify height, colour, title or position.** If a design depends on any of these, say so explicitly as a caveat rather than encoding it.

### Also report

- **`"blastRadius"`** — for a shared grid, every affected organisation, and whether you recommend cloning the grid first.
- **`"requiresSql"`** — anything needing a warehouse change: new datasets, retitled cards, reformatted grid columns.
- **`"unverified"`** — any reliance on `Trend`, `Chip`, `StatCard`, `CustomPinnedDataGrid`, `TreeViewCard`, or `md`/`lg`/`xl` divergence. These are contract-legal but production-untested.

---

## 8. Quick reference

**The whole layout surface:** 5 span numbers, 1 sort order, 1 card type, 1 dataset — per card. Plus grid-level filter datasets and their order.

**The one invariant:** `md` spans sum to 12 per row.

**The five hardest limits:** no heights · no coordinates · no colours · no titles in config · no tabs or sections.

**Source of truth:** report DB `report` (`DashboardGrid`, `DashboardGridItem`, `DashboardGridFilter`, `VisualisationProcedure`) for layout; `core.core.VisualisationQueries` on the Managed Instance for content. Always filter `IsDeleted = 0` — soft-deleted debris distorts report DB counts by 10–25%.

**Companion:** `docs/dashboard-layout-gallery.html` renders every layout in this document as a visual wireframe.

**Deeper detail:** `docs/microservice-report-database.md` (full report DB reference, §4 layout tables, §12 known defects) and `docs/presentation-and-visualisation.md` (card procedures, query patterns — note its query counts are stale).
