# F_PURCHASES_DAY Presentation Fact Table — Design

**Date:** 2026-03-06
**Status:** Approved
**Prerequisite:** `05_invitem_stockorder_entity_fix.sql` deployed (adds SAT_LNK_INVITEM_STOCKORDER attributes)

## 1. Purpose

Expose purchase order line-item data in the presentation layer. Currently no presentation table surfaces STOCKORDER data — purchase orders flow into `F_INV_USAGE_DAY` only as aggregated `ORDER_QTY`, losing supplier, unit price, PO reference, delivery date, and order status.

### Business Value

1. **Purchase spend analysis** — spend by supplier, by item, by location, over time
2. **Per-item purchase price history** — track price changes, identify cost increases
3. **Delivery tracking** — PO reference, order date vs delivery date, order status
4. **Supplier performance** — lead times, order frequency, spend concentration
5. **UOM_COST derivation path** — latest purchase price per item can fill the INVREPORT gap for Growyze (and any future integration without INVREPORT)

### Reports Enabled (from Growyze Wishlist)

| Report | Current Status | With F_PURCHASES_DAY |
|---|---|---|
| Invoice summary (C1) | BLOCKED (Phase 2) | PARTIAL — purchase orders serve as invoice proxy |
| Filter orders by date (C4) | No vis query | FEASIBLE — ORDER_DATE filtering |
| Usage & Consumption cost (C2, C5) | PARTIAL (volume only) | Upgradeable — UOM_COST from latest purchase price |
| Weekly sales & costs (C8) | PARTIAL (recipe cost only) | Enhanced — actual purchase cost available |

## 2. Table Design

### Grain

One row per **INVITEM x STOCKORDER line item**. This is the finest grain of purchasing data — each row represents one product on one purchase order.

### DDL

```sql
CREATE TABLE [presentation].[F_PURCHASES_DAY](
    [INVITEM_HUB_ID]      [binary](32)      NOT NULL,
    [SUPPLIER_HUB_ID]     [binary](32)      NOT NULL,
    [LOCATION_HUB_ID]     [binary](32)      NOT NULL,
    [STOCKORDER_HUB_ID]   [binary](32)      NOT NULL,
    [ORDER_DATE]           [datetime2](7)    NULL,
    [DELIVERY_DATE]        [datetime2](7)    NULL,
    [ORDER_STATUS]         [nvarchar](255)   NULL,
    [UNIT_PRICE]           [decimal](38, 6)  NULL,
    [UNIT_COST]            [decimal](38, 6)  NULL,
    [ORDER_QTY]            [decimal](38, 6)  NULL,
    [LINE_TOTAL]           [decimal](38, 6)  NULL,
    [PACK_SIZE]            [decimal](38, 6)  NULL,
    [PACK_PRICE]           [decimal](38, 6)  NULL,
    [ORDER_REFERENCE]      [nvarchar](255)   NULL
) ON [PRIMARY]
;

CREATE CLUSTERED INDEX [F_PURCHASES_DAY-CLUSTERED] ON [presentation].[F_PURCHASES_DAY]
(
    [ORDER_DATE] ASC,
    [LOCATION_HUB_ID] ASC
) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-INVITEM] ON [presentation].[F_PURCHASES_DAY]
(
    [INVITEM_HUB_ID] ASC
) ON [PRIMARY]
;

CREATE NONCLUSTERED INDEX [F_PURCHASES_DAY-SUPPLIER] ON [presentation].[F_PURCHASES_DAY]
(
    [SUPPLIER_HUB_ID] ASC
) ON [PRIMARY]
;
```

### Column Mapping

| Column | Source | DV Entity |
|---|---|---|
| INVITEM_HUB_ID | LNK_INVITEM_STOCKORDER.INVITEM_HUB_ID | LNK_INVITEM_STOCKORDER |
| SUPPLIER_HUB_ID | LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER.SUPPLIER_HUB_ID | LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER |
| LOCATION_HUB_ID | LNK_LOCATION_STOCKEVENT.LOCATION_HUB_ID (via delivery event chain) | LNK_STOCKEVENT_STOCKORDER + LNK_LOCATION_STOCKEVENT |
| STOCKORDER_HUB_ID | LNK_INVITEM_STOCKORDER.STOCKORDER_HUB_ID | LNK_INVITEM_STOCKORDER |
| ORDER_DATE | SAT_STOCKORDER.ORDER_DATE | SAT_STOCKORDER |
| DELIVERY_DATE | SAT_STOCKORDER.DELIVERY_DATE | SAT_STOCKORDER |
| ORDER_STATUS | SAT_STOCKORDER.ORDER_STATUS | SAT_STOCKORDER |
| UNIT_PRICE | SAT_LNK_INVITEM_STOCKORDER.PRICE | SAT_LNK_INVITEM_STOCKORDER |
| UNIT_COST | SAT_LNK_INVITEM_STOCKORDER.ESTIMATED_COST | SAT_LNK_INVITEM_STOCKORDER |
| ORDER_QTY | SAT_LNK_INVITEM_STOCKORDER.QUANTITY | SAT_LNK_INVITEM_STOCKORDER |
| LINE_TOTAL | QUANTITY * PRICE (computed) | Derived |
| PACK_SIZE | SAT_LNK_INVITEM_STOCKORDER.CASE_SIZE | SAT_LNK_INVITEM_STOCKORDER |
| PACK_PRICE | SAT_LNK_INVITEM_STOCKORDER.CASE_PRICE | SAT_LNK_INVITEM_STOCKORDER |
| ORDER_REFERENCE | SAT_STOCKORDER.ORDER_INFO | SAT_STOCKORDER |

### Location Resolution

No direct LNK_LOCATION_STOCKORDER exists in the DV model. Location is resolved via the delivery event chain:

```
STOCKORDER → LNK_STOCKEVENT_STOCKORDER → STOCKEVENT → LNK_LOCATION_STOCKEVENT → LOCATION
```

Orders without a corresponding delivery event get sentinel `CONVERT(BINARY(32), -999)`.

## 3. PresentationControl Step

| Property | Value |
|---|---|
| step_name | Purchases by Day |
| table_name | F_PURCHASES_DAY |
| tier | 1 |
| table_type | Fact |
| time_series_entity | STOCKEVENT |
| time_series_target_column | ORDER_DATE |
| GlobalParameters | STOCKEVENT_START, STOCKEVENT_END |

### Query Design

```sql
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = 'STOCKEVENT_START';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = 'STOCKEVENT_END';

WITH OrderLines AS (
    SELECT
        LIS.INVITEM_HUB_ID,
        LIS.STOCKORDER_HUB_ID,
        SL.QUANTITY,
        SL.PRICE,
        SL.ESTIMATED_COST,
        SL.CASE_SIZE,
        SL.CASE_PRICE,
        ROW_NUMBER() OVER(PARTITION BY LIS.LNK_ID ORDER BY SL.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_INVITEM_STOCKORDER] LIS
    INNER JOIN [datavault].[SAT_LNK_INVITEM_STOCKORDER] SL
        ON LIS.LNK_ID = SL.LNK_ID
),
Orders AS (
    SELECT
        SO.HUB_ID,
        SO.ORDER_DATE,
        SO.DELIVERY_DATE,
        SO.ORDER_STATUS,
        SO.ORDER_INFO
    FROM [datavault].[SAT_STOCKORDER] SO
    WHERE SO.CURRENT_FLAG = 1
      AND SO.ORDER_DATE BETWEEN @StartDate AND @EndDate
),
OrderSupplier AS (
    SELECT
        DSS.STOCKORDER_HUB_ID,
        DSS.SUPPLIER_HUB_ID
    FROM [datavault].[LNK_DISTRIBUTOR_STOCKORDER_SUPPLIER] DSS
),
OrderLocation AS (
    SELECT
        LSESO.STOCKORDER_HUB_ID,
        LLSE.LOCATION_HUB_ID,
        ROW_NUMBER() OVER(PARTITION BY LSESO.STOCKORDER_HUB_ID
                          ORDER BY LLSE.LOAD_TS DESC) AS rn
    FROM [datavault].[LNK_STOCKEVENT_STOCKORDER] LSESO
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LLSE
        ON LSESO.STOCKEVENT_HUB_ID = LLSE.STOCKEVENT_HUB_ID
)

SELECT
    OL.INVITEM_HUB_ID,
    ISNULL(OS.SUPPLIER_HUB_ID, CONVERT(BINARY(32), -999)) AS SUPPLIER_HUB_ID,
    ISNULL(OLOC.LOCATION_HUB_ID, CONVERT(BINARY(32), -999)) AS LOCATION_HUB_ID,
    OL.STOCKORDER_HUB_ID,
    O.ORDER_DATE,
    O.DELIVERY_DATE,
    O.ORDER_STATUS,
    OL.PRICE AS UNIT_PRICE,
    OL.ESTIMATED_COST AS UNIT_COST,
    OL.QUANTITY AS ORDER_QTY,
    OL.QUANTITY * OL.PRICE AS LINE_TOTAL,
    OL.CASE_SIZE AS PACK_SIZE,
    OL.CASE_PRICE AS PACK_PRICE,
    O.ORDER_INFO AS ORDER_REFERENCE

FROM OrderLines OL
INNER JOIN Orders O
    ON OL.STOCKORDER_HUB_ID = O.HUB_ID
LEFT JOIN OrderSupplier OS
    ON OL.STOCKORDER_HUB_ID = OS.STOCKORDER_HUB_ID
LEFT JOIN OrderLocation OLOC
    ON OL.STOCKORDER_HUB_ID = OLOC.STOCKORDER_HUB_ID
    AND OLOC.rn = 1

WHERE OL.rn = 1
```

## 4. UOM_COST Enrichment (Follow-up Enhancement)

Once F_PURCHASES_DAY exists, a `LatestPurchasePrice` CTE can be added to the F_INV_USAGE_DAY and F_INV_COUNTS_DAY build steps as a COALESCE fallback:

```sql
LatestPurchasePrice AS (
    SELECT INVITEM_HUB_ID, LOCATION_HUB_ID,
           UNIT_PRICE AS UOM_COST,
           ROW_NUMBER() OVER(PARTITION BY INVITEM_HUB_ID, LOCATION_HUB_ID
                             ORDER BY ORDER_DATE DESC) AS rn
    FROM [presentation].[F_PURCHASES_DAY]
    WHERE UNIT_PRICE IS NOT NULL AND UNIT_PRICE > 0
)
```

Existing cost resolution changes from:
```sql
COALESCE(ILC.UOM_COST, IC.UOM_COST) AS UOM_COST
```
To:
```sql
COALESCE(ILC.UOM_COST, IC.UOM_COST, LPP.UOM_COST) AS UOM_COST
```

**Impact:** This makes F_INV_USAGE_DAY and F_INV_COUNTS_DAY **Tier 2** (they must build after F_PURCHASES_DAY). F_INV_SALES_DAY remains Tier 2 (depends on F_INV_USAGE_DAY, now also indirectly on F_PURCHASES_DAY).

## 5. F_STOCK_FLOW — Future Development (TODO)

A complementary fact table for tracking cumulative stock movements without requiring COUNT event anchors. Design deferred — noted here for future planning.

### Concept

One row per **INVITEM x LOCATION x DAY**. Running cumulative balance of all stock movements.

| Column | Description |
|---|---|
| INVITEM_HUB_ID | Inventory item |
| LOCATION_HUB_ID | Location |
| FLOW_DATE | Event date |
| ORDER_IN_QTY | SUM(quantity) for EVENT_TYPE in ('ORDER') |
| SALE_OUT_QTY | SUM(quantity) for EVENT_TYPE in ('SALE') |
| WASTE_OUT_QTY | SUM(quantity) for EVENT_TYPE in ('WASTE') |
| TRANSFER_QTY | SUM(quantity) for EVENT_TYPE in ('TRANSFER') |
| PRODUCTION_QTY | SUM(quantity) for EVENT_TYPE in ('PRODUCTION') |
| NET_MOVEMENT | ORDER_IN - SALE_OUT - WASTE_OUT +/- TRANSFER +/- PRODUCTION |
| CUMULATIVE_BALANCE | Running SUM(NET_MOVEMENT) from earliest event |
| UOM_COST | From F_PURCHASES_DAY latest price or INVREPORT |

### Use Cases

- "Best-guess" stock position without physical counts (drifts over time)
- Marge Brut partial formula: Turnover - Purchases + Cumulative Depletion
- Stock rundown trend (reorder signal when approaching zero)
- Activates automatically for Growyze once F_PURCHASES_DAY provides UOM_COST

### Caveats

- Cumulative balance assumes zero starting stock unless a COUNT event establishes a baseline
- Drifts from reality without periodic count corrections
- Not a replacement for stocktake-based reconciliation

### Dependencies

- F_PURCHASES_DAY (for UOM_COST derivation)
- Would be Tier 2
- Can reuse the same STOCKEVENT_START/END date range

## 6. Deploy Order

1. Deploy `05_invitem_stockorder_entity_fix.sql` (prerequisite — adds SAT_LNK attributes)
2. Deploy F_PURCHASES_DAY PresentationTable DDL record
3. Deploy F_PURCHASES_DAY PresentationControl build step
4. Run `DeployPresentationTables` for target org
5. Run presentation build (sp_BuildPresentation or equivalent)
6. Verify data via MCP query
7. (Follow-up) Add UOM_COST enrichment to Steps 9 & 10, change their tier to 2
