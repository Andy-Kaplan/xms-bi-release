# Pantry COGS Dashboard — Card Output Contracts

Exact result-set shapes for each card type, each copied verbatim from a live (`Status = 'LIVE'`)
example in `8_VisualisationQueries.sql`. Per the task-1 brief, examples were chosen for being
simple and representative, not the most complex available. Column lists are the literal aliases
used in the SELECT, including columns that are `NULL` placeholders (e.g. `Column8`..`Column29`) —
those placeholders are part of the contract shape, not noise, because the grid components expect
a fixed column count.

`ParameterMappings` and `FilterDefinitions` are reproduced verbatim, including when the value is
effectively empty (`'{}'` or all-blank `"column"` entries) — O8 established that
`ParameterMappings = '{}'` silently discards filters, so an empty mapping is itself load-bearing
information for Tasks 6–9, not something to skip.

---

### SingleKPICard

**Example:** `DataSetName = 'DiscountPerc'` (`8_VisualisationQueries.sql:1076`, Version 1, LIVE)

**Result set 1 columns:** `Title`, `Value` — a single row, single result set.

**Result set 2:** **none.** Unlike every other card type below, this live example has only one
SELECT in both `QueryTemplate` and `ExecutionQuery` (they are byte-identical here) — `Title` is
embedded directly alongside `Value` in the one row. Do not assume SingleKPICard always needs a
second header result set; this example proves it doesn't have to.

**Multi-series pattern:** n/a (single scalar KPI, no series).

**ParameterMappings shape (verbatim):**
```json
{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}
```

**FilterDefinitions shape (verbatim, one representative entry — full block has 16 keys, all `IN`/`VARCHAR`):**
```json
{
  "Channels": {"column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Deals": {"column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Discounts": {"column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Distributors": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Integrations": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "InvItems": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Mods": {"column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Occasions": {"column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "RevenueCentres": {"column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "ServiceCharges": {"column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Suppliers": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Tax": {"column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])", "type": "IN", "dataType": "VARCHAR"},
  "Tenders": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}
```

**OutputDefinitions (verbatim):**
```json
{"column_mappings": {}, "additional_datasets": []}
```

---

### PieChartCard

**Example:** `DataSetName = 'ForecastProductQuantity'` (`8_VisualisationQueries.sql:3239`, Version 1, LIVE)

**Result set 1 columns:** `Label`, `Value`, `Id`, `Curve`, `Stack`, `Area`, `ShowMark`, `StackOrder`, `LegendLabel`.

**Result set 2 columns:** `Title`, `Description`, `Trend`, `Chip`, `PiePrimaryText` (a scalar sub-SELECT re-running the same aggregate as result set 1's total), `PieSecondaryText`.

**Multi-series pattern:** one row per slice in result set 1 (`GROUP BY R.product_category`); no separate series column — each row's `Label`/`Id` is the slice key and `Value` is its magnitude. `Curve`/`Stack`/`Area`/`ShowMark`/`StackOrder` are per-row rendering hints repeated as constants on every row, not per-series values.

**ParameterMappings shape (verbatim):**
```json
{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "forecast_date",
  "EndDate": ""
}
```
Note `EndDate` is an empty string here, not omitted — this dataset is a point-in-time forecast, not a date-ranged fact.

**FilterDefinitions shape:** same 16-key `Channels`..`Tenders` block as SingleKPICard above, but every `"column"` value is `""` in this example (no filter is wired to any column) — a fully inert filter block, still declared.

**OutputDefinitions (verbatim):**
```json
{"column_mappings": {}, "additional_datasets": []}
```

**Note:** `ExecutionQuery` is `NULL` for this record (line 3445) — `QueryTemplate` is the field actually used to render; `ExecutionQuery` is frequently `NULL` on LIVE rows in this table and should not be assumed populated.

---

### BarChartCard

**Example:** `DataSetName = 'Discounts'` (`8_VisualisationQueries.sql:1599`, Version 1, LIVE)

**Result set 1 columns:** `BarLabel`, `BarLabelSort`, `BarValue`, `BarValueSort`. (The underlying subquery computes several more columns — `ITEMS_SOLD`, `SALES_TOTAL`, `SALES_NET_TOTAL`, `TAX_TOTAL`, `TAX_PERC`, `ORDER_TYPE_SALES`, `SERIES_LABEL` — but the outer SELECT only surfaces the 4 contract columns; the rest are commented out with `--` in the live query, evidence of a card that was pared back rather than a series-capable one.)

**Result set 2 columns:** `XAxisLabel`, `YAxisLabel`, `Title`, `Description`, `Trend`, `TotalValue`, `Chip`.

**Multi-series pattern:** none in this example — single series (one bar per `BarLabel`). A multi-series BarChartCard would need an additional grouping/series column in result set 1; this example does not demonstrate one, so Tasks 6–9 should not assume a series column exists without adding it explicitly.

**ParameterMappings shape (verbatim):**
```json
{"LocationList": "SITE_HUB_ID", "StartDate": "POSTX_DATE", "EndDate": "POSTX_DATE"}
```

**FilterDefinitions shape (verbatim — only 3 keys in this example, all inert):**
```json
{
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}
```

**OutputDefinitions (verbatim): `N'{}'`** — a literal empty JSON object, not `{"column_mappings": {}, "additional_datasets": []}`. This is the exact O8 case: this card's filters are declared in `FilterDefinitions` but every `"column"` is blank AND `OutputDefinitions` itself is `{}` — confirms a live card whose filter wiring is a no-op today. Do not copy this pattern for the COGS dashboard; wire real columns.

**Also note:** `ExecutionQuery` is `NULL` on this record (line 1682).

---

### CustomDataGrid

**Example:** `DataSetName = 'InvCountData'` (`8_VisualisationQueries.sql:4916`, Version 1, LIVE) — chosen because it is already an inventory-item/location grid, directly analogous to what the Pantry COGS grid cards will need.

**Result set 1 columns:** `Column1` .. `Column29` (fixed 29-column shape). In this example only `Column1`-`Column4` carry real values: `Column1` = `LOCATION_NAME`, `Column2` = `INVITEM`, `Column3` = `COUNT_FREQUENCY`, `Column4` = `COUNT_RECENCY`; `Column5`-`Column29` are `NULL` literals padding out the fixed shape.

**Result set 2 columns:** `Title`, `Description`, then 29 `Label`N/`Type`N pairs (`Label1`/`Type1` .. `Label29`/`Type29`). Only the first 4 pairs are populated in this example: `Label1`='Location'/`Type1`='TEXT', `Label2`='Inventory Item'/`Type2`='TEXT', `Label3`='Count Frequency'/`Type3`='DECIMAL', `Label4`='Count Recency'/`Type4`='DECIMAL'; the rest are `NULL`.

**Multi-series pattern:** n/a — this is a flat grid, one row per (location, inventory item); no grouping/series column (contrast with CustomGroupedDataGrid below).

**ParameterMappings shape (verbatim):**
```json
{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}
```

**FilterDefinitions shape:** 19-key block; only two are wired — `InvItems` → `COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])` and `Locations` → `COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])`; the rest (`Channels`, `DayOfWeek`, `Deals`, `DealToggle`, `Discounts`, `Distributors`, `Integrations`, `Mods`, `Occasions`, `ProductCategories`, `Products`, `ProductsComp`, `RevenueCentres`, `ServiceCharges`, `Suppliers`, `SurveyFilter`, `SurveyFilterAge`, `Tax`, `Tenders`) all have `"column": ""`.

**OutputDefinitions (verbatim):**
```json
{"column_mappings": {}, "additional_datasets": []}
```

**Data-quality note directly relevant to Pantry COGS:** the query filters `WHERE ... AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL` (line 4949) — an explicit guard against orphan/unresolved inventory-item joins. Tasks 4/5 should carry the same guard for Growyze data given the orphan-key issues documented in `15_orphan_product_fix.sql` (a different entity, but the same class of problem — a resolvable pattern worth reusing).

---

### CustomGroupedDataGrid

**Example:** `DataSetName = 'InvKPIGrouped'` (`8_VisualisationQueries.sql:5476`, Version 1, LIVE) — chosen because it is the live query that already reads `D_INVITEM.TOP_NAME`/`MIDDLE_1_NAME`/`BOTTOM_INVITEM_NAME` with the exact `COALESCE(*_MICROSERVICE_NAME, native)` pattern flagged as risky in Q3 above.

**Ambiguity note (per the brief's Step 4 guidance):** this was the only clean live `CustomGroupedDataGrid` example found with three worktree copies of the same file existing at `.claude/worktrees/*` — only the repo-root `8_VisualisationQueries.sql` copy was used, per the read-only/root-only scope for this task.

**Result set 1 columns:** `ParentId`, `Id`, `GroupedColumn`, `Column1` .. `Column29` (fixed 29-column shape, same convention as CustomDataGrid). Only `Column1`-`Column7` carry real values (`NET_SALES`, `RECIPE_COST`, `WASTE_COST`, `VARIANCE_COST`, `VARIANCE_COST_PERC`, `VARIANCE_COST_PERC_OF_TOTAL`, `VARIANCE_COST_PERC_OF_TOTAL_SALES`); `Column8`-`Column29` are `NULL`.

**This single result set is itself the hierarchy**, built from 4 `UNION ALL` branches over a common `Base` CTE, one branch per tree level:
1. Leaf item level: `ParentId = {Location}-{TOP}` wait — actually `ParentId = CONCAT(LOCATION_NAME, '-', INVENTORY_ITEM_MIDDLE)`, `Id = CONCAT(LOCATION_NAME, '-', INVENTORY_ITEM)`, `GroupedColumn = INVENTORY_ITEM` (no aggregation — one row per item).
2. Middle level: `ParentId = CONCAT(LOCATION_NAME, '-', INVENTORY_ITEM_TOP)`, `Id = CONCAT(LOCATION_NAME, '-', INVENTORY_ITEM_MIDDLE)`, `GroupedColumn = INVENTORY_ITEM_MIDDLE`, values `SUM()`'d across items within that middle group.
3. Top level: `ParentId = LOCATION_NAME`, `Id = CONCAT(LOCATION_NAME, '-', INVENTORY_ITEM_TOP)`, `GroupedColumn = INVENTORY_ITEM_TOP`, values `SUM()`'d across the whole top category.
4. Location level: `ParentId = NULL`, `Id = LOCATION_NAME`, `GroupedColumn = LOCATION_NAME`, values `SUM()`'d across the whole location.

This is the concrete `ParentId`/`Id` tree-linking pattern any COGS grouped grid (by Category/Sub Category/Item) must follow: each level's `Id` must equal the level-below's `ParentId`, all the way to a root row with `ParentId = NULL`.

**Result set 2: none in `QueryTemplate`/`ExecutionQuery`.** Unlike BarChartCard/PieChartCard/CustomDataGrid/FilterList, this live example has **no second SELECT** for header metadata. Instead, the header is fully **declarative**, carried in `OutputDefinitions.additional_datasets[0]`:
```json
{
  "name": "Header1",
  "type": "Header",
  "columns": ["Title", "Description", "GroupedLabel", "GroupedType", "Label1", "Type1", "...", "Label29", "Type29"],
  "values": {
    "GroupedType": "TEXT",
    "Label1": "Net Sales", "Type1": "DECIMAL",
    "Label2": "Recipe Cost", "Type2": "DECIMAL",
    "Label3": "Waste Cost", "Type3": "DECIMAL",
    "Label4": "Variance Cost", "Type4": "DECIMAL",
    "Label5": "Variance %", "Type5": "PERCENT",
    "Label6": "Variance % of Total", "Type6": "PERCENT",
    "Label7": "Variance % of Total Sales", "Type7": "PERCENT"
  }
}
```
(`Title`, `Description`, `GroupedLabel` literal string values were not visible in the read window and are omitted here rather than guessed — re-read `8_VisualisationQueries.sql` around line 5888-5960 if a later task needs those exact literals.)

**Confirmed uncertainty flagged per the brief's ambiguity note:** this means CustomGroupedDataGrid, at least in this live example, genuinely does not follow the "query result set 2" header pattern the other 4 card types use — it uses a static JSON header instead. Task authors should treat this as card-type-specific, not assume a header SELECT is always required.

**ParameterMappings shape (verbatim):**
```json
{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}
```

**FilterDefinitions shape:** same 19-key block as CustomDataGrid, same two live wirings (`InvItems`, `Locations`), rest blank.

**OutputDefinitions.column_mappings (verbatim):**
```json
{
  "ParentId": "ParentId", "Id": "Id", "GroupedColumn": "GroupedColumn",
  "Column1": "Column1", "Column2": "Column2", "Column3": "Column3", "Column4": "Column4",
  "Column5": "Column5", "Column6": "Column6", "Column7": "Column7",
  "Column8": "", "Column9": "", "...": "(Column8-Column29 all empty strings)"
}
```

---

### FilterList

**Example:** `DataSetName = 'Channels'` (`8_VisualisationQueries.sql:526`, Version 1, LIVE)

**Result set 1 columns (raw `QueryTemplate`):** `CHANNEL_NAME`, `CHANNEL_ID`, `PARENT_ID`, `BOTTOM_LEVEL` (physical/native column names from `SAT_CHANNEL`).

**Result set 1 columns (as actually rendered, per `ExecutionQuery` re-aliasing):** `Label`, `ID`, `ParentID`, `BottomLevel` — the `ExecutionQuery` wraps the raw query and re-aliases each column to match `OutputDefinitions.column_mappings`. **This is the key pattern for FilterList:** `QueryTemplate` uses native names; `ExecutionQuery` is what the frontend actually consumes, and its column names must equal the `column_mappings` values, not the raw source names.

**Result set 2 columns:** `Title` only — `SELECT 'Channels' AS [Title]`.

**Multi-series pattern:** n/a (this is a hierarchy/tree filter list, not a chart) — but note the tree-shape convention: `ID` = `COALESCE(MICROSERVICE_NAME, CHANNEL_NAME)` when `BOTTOM_LEVEL = 1` (leaf), else the raw `CHANNEL_ID` (parent node); `Label` = `COALESCE(MICROSERVICE_NAME, CHANNEL_NAME)` always. This is the same `COALESCE(*_MICROSERVICE_NAME, native)` pattern flagged as unsafe for Growyze INVITEM in Q3 — a Growyze-sourced FilterList over `D_INVITEM`/`SAT_INVITEM` must not blindly copy this pattern without the live-clean check noted in `PREFLIGHT.md`.

**Ambiguity note (per the brief's Step 4 guidance):** `Channels` was chosen as the simplest available FilterList (flat `SELECT DISTINCT` over one satellite, no joins) — a Growyze/inventory-specific FilterList example was not required to exist for this task and none was found scoped to Growyze; downstream tasks building an inventory-item or category FilterList should follow this shape but source from `D_INVITEM`, not `SAT_CHANNEL`.

**ParameterMappings shape (verbatim):**
```json
{"LocationList": "", "StartDate": "", "EndDate": ""}
```
All three are empty strings — this FilterList is not date- or location-scoped (it lists all channels regardless of the dashboard's date/location filters).

**FilterDefinitions shape (verbatim — only 5 keys, all inert):**
```json
{
  "Discounts": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "ProductCategories": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "Products": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilter": {"column": "", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "", "type": "IN", "dataType": "VARCHAR"}
}
```

**OutputDefinitions (verbatim):**
```json
{
  "column_mappings": {"Label": "CHANNEL_NAME", "ID": "CHANNEL_ID", "ParentID": "PARENT_ID", "BottomLevel": "BOTTOM_LEVEL"},
  "additional_datasets": [
    {"name": "Header1", "type": "Header", "columns": ["Title"], "values": {"Title": "Channels"}}
  ]
}
```

---

## Contracts every query in 04–07 must honour

1. Two result sets: data, then header metadata. **Exception found in the live examples above:** `SingleKPICard` (no second result set — `Title` is inline with `Value`) and `CustomGroupedDataGrid` (header is declared statically in `OutputDefinitions.additional_datasets`, not queried). `PieChartCard`, `BarChartCard`, `CustomDataGrid`, and `FilterList` all do follow the two-result-set pattern in their live examples.
2. Header-subquery aliases MUST match the data query's aliases (FilterClause alias contract) —
   `@FilterClause` is injected at every site, so a mismatched alias throws at render time.
3. `WHERE 1=1 @FilterClause` is the injection pattern. (Note: the live `Discounts` BarChartCard example spells the placeholder `@FilterClause` — consistent across all 6 examples read for this task; watch for the header-record typo `@FilterCLause` seen once in the `DiscountPerc` SingleKPICard example, line 1119/1255 — capital `L` — evidently harmless there because SQL is case-insensitive for identifiers, but do not copy that casing into new queries.)
4. Never `NULL AS TotalValue` on a BarChartCard — renders as 0.00.
5. Every mapped filter/parameter column expression ≤100 characters.
6. Scope every query: `AND F.[SOURCE] LIKE 'int_growyze%'`.
