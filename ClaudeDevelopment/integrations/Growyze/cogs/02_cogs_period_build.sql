/*  02_cogs_period_build.sql
    =========================
    Growyze Pantry COGS dashboard — Task 4: tier-110 PresentationControl build step.

    Registers the "Pantry COGS by Period" step (natural key: step_name + table_name)
    that builds presentation.F_COGS_PERIOD at INVITEM x LOCATION x stocktake-period
    grain, derived directly from the Data Vault (SAT_STOCKEVENT + SAT_INVITEM), per
    design doc docs/superpowers/specs/2026-07-30-growyze-pantry-cogs-dashboard-design.md
    §2.1/§4/§5.

    DEPLOY NOTE (mirrors 01_cogs_period_table.sql): this script only upserts a
    PresentationControl row. It does not create F_COGS_PERIOD (task 3,
    01_cogs_period_table.sql) and does not run the build. Deploy order per the
    design doc §9: table DDL -> this step -> GlobalParameters config -> deploy
    table -> run presentation rebuild -> vis queries -> report wiring -> verify.

    Two deliberate deviations from the task-4 brief's literal draft, evidence below:

    1. UOM CONVERSION SOURCE. The brief's Step 2 draft is a hardcoded inline
       UOMConversion CTE (10 literal rows: gr/Kg/lb/oz/ml/cl/L/Imperial Pint/Gal/EA).
       That is the EXACT CTE that ClaudeDevelopment/12_uom_conversion_fix.sql
       already replaced in all three existing inventory PresentationControl steps
       (F_INV_USAGE_DAY, F_INV_COUNTS_DAY, F_INV_SALES_DAY) — its own header states
       the hardcoded CTE caused "61.7% of Growyze F_INV_USAGE_DAY rows with NULL
       STANDARDISED_UOM" and "ORDER quantities understated by ~75% for Growyze",
       because Growyze's raw UOM strings ('each', 'g', 'kg', ...) are different
       WORDS from the MarketMan-shaped literal set in that inline CTE (not just a
       case difference — 'each' vs 'EA' and 'g' vs 'gr' do not match under any
       collation). Corroborated by ClaudeDevelopment/integrations/Growyze/
       14_dn_events_size_multiplier_fix.sql's own "out of scope" note: "ORDER
       events store 'kg'/'g'/'each' ... Downstream UOM_CONVERSION lookup
       currently handles both". Building a BRAND NEW Growyze-only build step on
       the very CTE already proven to null out Growyze quantities would
       reintroduce a fixed, high-impact silent-loss bug in the worst possible
       place. This step therefore defines the UOMConversion CTE with the SAME
       output shape (UOM, base_uom, conversion_factor) the brief expects, but
       backed by [core].[reference].[UOM_CONVERSION] — the exact reference table
       and column aliasing pattern 12_uom_conversion_fix.sql deployed, seeded by
       ClaudeDevelopment/integrations/Growyze/01_infrastructure.sql with native
       Growyze units (ml/cl/L/g/kg/oz/each/full/portion/percentage) plus
       MarketMan aliases. Every downstream CTE that references `uc.conversion_factor`
       / `uc.base_uom` is unaffected — only the CTE body changed, not its shape.

    2. PERIOD_LABEL NULL-safety. The brief's Step 9 draft concatenates
       CONVERT(...,PERIOD_START_DATE,106) + ' - ' + CONVERT(...,PERIOD_END_DATE,106)
       directly. For a first period PERIOD_START_DATE is NULL by design (team-lead's
       brief: "Rows where PERIOD_START_DATE IS NULL ... must not be silently
       dropped"), and plain string concatenation with a NULL operand yields NULL
       in SQL Server — so PERIOD_LABEL, a user-facing FilterList value
       (PantryCOGSPeriods, spec §7), would silently disappear for every venue's
       very first period. Fixed with a CASE so first periods render
       "Opening - <end date>" instead of NULL. This is an omission in the brief's
       snippet, not a contradiction of it — the brief and spec are explicit that
       first periods must be visible, this makes the one column that risked
       violating that literally true.

    Both are flagged in the task-4-report.md self-review section, not silently
    substituted.
*/

DECLARE @colmap NVARCHAR(MAX) = N'[
{"query_column": "INVITEM_HUB_ID", "table_column": "INVITEM_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"},
{"query_column": "LOCATION_HUB_ID", "table_column": "LOCATION_HUB_ID", "data_type": "varchar(255)", "target_data_type": "[binary](32)"},
{"query_column": "PERIOD_START_DATE", "table_column": "PERIOD_START_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"},
{"query_column": "PERIOD_END_DATE", "table_column": "PERIOD_END_DATE", "data_type": "varchar(255)", "target_data_type": "[datetime2](7)"},
{"query_column": "PERIOD_DAYS", "table_column": "PERIOD_DAYS", "data_type": "varchar(255)", "target_data_type": "[int]"},
{"query_column": "PERIOD_SEQ", "table_column": "PERIOD_SEQ", "data_type": "varchar(255)", "target_data_type": "[int]"},
{"query_column": "PERIOD_MONTH", "table_column": "PERIOD_MONTH", "data_type": "varchar(255)", "target_data_type": "[date]"},
{"query_column": "PERIOD_LABEL", "table_column": "PERIOD_LABEL", "data_type": "varchar(255)", "target_data_type": "[varchar](50)"},
{"query_column": "OPENING_COUNT_DATE", "table_column": "OPENING_COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"},
{"query_column": "CLOSING_COUNT_DATE", "table_column": "CLOSING_COUNT_DATE", "data_type": "varchar(255)", "target_data_type": "[date]"},
{"query_column": "SOURCE", "table_column": "SOURCE", "data_type": "varchar(255)", "target_data_type": "[varchar](100)"},
{"query_column": "STANDARDISED_UOM", "table_column": "STANDARDISED_UOM", "data_type": "varchar(255)", "target_data_type": "[varchar](255)"},
{"query_column": "ITEM_NAME", "table_column": "ITEM_NAME", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"},
{"query_column": "CATEGORY", "table_column": "CATEGORY", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"},
{"query_column": "SUBCATEGORY", "table_column": "SUBCATEGORY", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"},
{"query_column": "REPORT_GROUP", "table_column": "REPORT_GROUP", "data_type": "varchar(255)", "target_data_type": "[nvarchar](255)"},
{"query_column": "OPENING_QTY", "table_column": "OPENING_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "DELIVERY_QTY", "table_column": "DELIVERY_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "TRANSFER_QTY", "table_column": "TRANSFER_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "CLOSING_QTY", "table_column": "CLOSING_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "CONSUMPTION_QTY", "table_column": "CONSUMPTION_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "WASTE_QTY", "table_column": "WASTE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "SALE_QTY", "table_column": "SALE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "THEO_CLOSING_QTY", "table_column": "THEO_CLOSING_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "VARIANCE_QTY", "table_column": "VARIANCE_QTY", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "UOM_COST", "table_column": "UOM_COST", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "OPENING_VALUE", "table_column": "OPENING_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "DELIVERY_VALUE", "table_column": "DELIVERY_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "COG_SPEND", "table_column": "COG_SPEND", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "COG_SOLD", "table_column": "COG_SOLD", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "CLOSING_VALUE", "table_column": "CLOSING_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "WASTE_VALUE", "table_column": "WASTE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "VARIANCE_VALUE", "table_column": "VARIANCE_VALUE", "data_type": "varchar(255)", "target_data_type": "[decimal](38, 6)"},
{"query_column": "IS_NEGATIVE_COGS", "table_column": "IS_NEGATIVE_COGS", "data_type": "varchar(255)", "target_data_type": "[bit]"},
{"query_column": "HAS_ZERO_COST", "table_column": "HAS_ZERO_COST", "data_type": "varchar(255)", "target_data_type": "[bit]"},
{"query_column": "IS_UNCOUNTED", "table_column": "IS_UNCOUNTED", "data_type": "varchar(255)", "target_data_type": "[bit]"},
{"query_column": "IS_FIRST_PERIOD", "table_column": "IS_FIRST_PERIOD", "data_type": "varchar(255)", "target_data_type": "[bit]"}
]';

DECLARE @sql NVARCHAR(MAX) = N'
WITH UOMConversion AS (
    -- Sourced from [core].[reference].[UOM_CONVERSION] (see header note 1),
    -- not the hardcoded MarketMan-shaped literal list — that list does not
    -- contain Growyze''s native UOM strings and would silently null every
    -- Growyze quantity/cost conversion.
    SELECT [FROM_UOM] AS UOM, [TO_UOM] AS base_uom,
           CAST([CONVERSION_FACTOR] AS DECIMAL(18,6)) AS conversion_factor
    FROM [core].[reference].[UOM_CONVERSION]
),
StockEvents AS (
    SELECT
         SE.[SRC]
        ,SE.[EVENT_TYPE]
        ,SE.[EVENT_BEHAVIOUR]
        ,CAST(SE.[EVENT_TS] AS DATE)                       AS [EVENT_TS]
        ,SE.[UOM]
        -- KNOWN LIMIT (final-review M13, documented not changed): quantities are
        -- converted with the factor for the EVENT''s unit (SE.[UOM]) while ItemCost
        -- below divides the cost by the factor for the ITEM MASTER''s unit
        -- (SAT_INVITEM.[UOM]). The two factors cancel — making every money column
        -- exactly qty x cost in one standardised unit — only where those two UOMs
        -- agree. Where an event is recorded in a different unit from the item master
        -- (e.g. an item held in ''kg'' with a delivery keyed in ''g''), the money
        -- column is not qty x cost in any single unit. This is the same shape as the
        -- three deployed inventory build steps (12_uom_conversion_fix.sql), so it is
        -- a pre-existing platform limit rather than a regression introduced here; it
        -- is recorded so it is a known limit and not a latent surprise. Fixing it
        -- properly means converting event quantities into the item master''s unit
        -- first, which is a change to the deployed convention and needs its own
        -- decision — do not do it in one fact in isolation.
        ,SE.[UOM_QUANITY] * uc.conversion_factor           AS [STANDARDISED_QTY]
        ,uc.base_uom                                       AS [STANDARDISED_UOM]
        ,SE.[INTERNAL_REF]
        ,LSE.[LOCATION_HUB_ID]
        ,LII.[INVITEM_HUB_ID]
    FROM [datavault].[SAT_STOCKEVENT] SE
    INNER JOIN [datavault].[LNK_LOCATION_STOCKEVENT] LSE ON SE.[HUB_ID] = LSE.[STOCKEVENT_HUB_ID]
    INNER JOIN [datavault].[LNK_INVITEM_STOCKEVENT] LII  ON SE.[HUB_ID] = LII.[STOCKEVENT_HUB_ID]
    LEFT OUTER JOIN UOMConversion uc ON SE.[UOM] = uc.[UOM]
    WHERE 1=1
      AND SE.[CURRENT_FLAG] = 1
      AND ISNULL(SE.[IS_DELETED], 0) = 0
      AND SE.[SRC] LIKE ''int_growyze%''
      -- Unbounded read (design §5.0): no EVENT_TS bound here. The 3-month
      -- comparison card needs full history; a load-window filter would
      -- silently hold only the last refresh''s window.
),
-- One SRC value per (location, item) pair for the fact''s provenance column.
-- Resolved via GROUP BY (not a DISTINCT tuple in a join key) so a rare item
-- whose events span more than one Growyze integration schema cannot fan out
-- the grain below (INVITEM_HUB_ID, LOCATION_HUB_ID, PERIOD_END_DATE).
InvItemSource AS (
    SELECT [LOCATION_HUB_ID], [INVITEM_HUB_ID], MAX([SRC]) AS [SRC]
    FROM StockEvents
    GROUP BY [LOCATION_HUB_ID], [INVITEM_HUB_ID]
),
StocktakeCalendar AS (
    -- Location-level stocktake calendar (Q1/Q3 deliberate divergence from step 9,
    -- which LAGs per INTERNAL_REF/item; INTERNAL_REF is the delivery-note id for
    -- ORDER events, not an item id, so it is not a safe per-item identity anyway).
    SELECT DISTINCT [LOCATION_HUB_ID], [EVENT_TS] AS [COUNT_DATE]
    FROM StockEvents
    WHERE [EVENT_BEHAVIOUR] = ''COUNT''
),
Periods AS (
    SELECT
         [LOCATION_HUB_ID]
        ,LAG([COUNT_DATE]) OVER (PARTITION BY [LOCATION_HUB_ID] ORDER BY [COUNT_DATE]) AS [PERIOD_START_DATE]
        ,[COUNT_DATE]                                                                  AS [PERIOD_END_DATE]
        ,ROW_NUMBER() OVER (PARTITION BY [LOCATION_HUB_ID] ORDER BY [COUNT_DATE] DESC) AS [PERIOD_SEQ]
    FROM StocktakeCalendar
),
ItemCounts AS (
    SELECT
         [LOCATION_HUB_ID], [INVITEM_HUB_ID], [EVENT_TS] AS [COUNT_DATE]
        ,[STANDARDISED_QTY], [STANDARDISED_UOM]
    FROM StockEvents
    WHERE [EVENT_BEHAVIOUR] = ''COUNT''
),
ItemFirstEvent AS (
    -- The earliest event date for each item at each location = the point from which
    -- that item exists at that venue as far as this feed is concerned.
    SELECT [LOCATION_HUB_ID], [INVITEM_HUB_ID], MIN([EVENT_TS]) AS [FIRST_EVENT_TS]
    FROM StockEvents
    GROUP BY [LOCATION_HUB_ID], [INVITEM_HUB_ID]
),
PeriodItems AS (
    -- Every period at a location x every item at that location, RESTRICTED to periods
    -- that end at or after the item''s first event there (final-review I11).
    -- Without the FIRST_EVENT_TS predicate an item first delivered in period 5 also got
    -- rows for periods 1-4. For those rows the closing OUTER APPLY finds no count, so
    -- IS_UNCOUNTED = 1, and they then filled the "Not counted at closing stocktake"
    -- branch of the exceptions card with items that did not yet exist. Per design D3
    -- that card is the ONLY mechanism driving bad Growyze data back to a fix, so an
    -- exception list dominated by pre-existence noise removes the mechanism.
    -- After this restriction IS_UNCOUNTED still covers two real cases — "counted
    -- earlier, carried forward" (CC found, but not at the boundary) and "has movement
    -- but was never counted at all" (CC IS NULL) — both of which are genuine
    -- exceptions worth surfacing for an item that exists in the period.
    SELECT DISTINCT P.[LOCATION_HUB_ID], P.[PERIOD_START_DATE], P.[PERIOD_END_DATE],
           P.[PERIOD_SEQ], I.[INVITEM_HUB_ID]
    FROM Periods P
    INNER JOIN ItemFirstEvent I
        ON  I.[LOCATION_HUB_ID]  = P.[LOCATION_HUB_ID]
        AND I.[FIRST_EVENT_TS]  <= P.[PERIOD_END_DATE]
),
Bounded AS (
    -- Opening/closing = the item''s most recent COUNT at or before each boundary
    -- (carry-forward). First periods (PERIOD_START_DATE IS NULL) get no OC match
    -- by construction (NULL comparison), which is correct: OPENING_QTY defaults
    -- to 0 downstream via ISNULL, never silently dropped.
    SELECT
         PI.*
        ,OC.[STANDARDISED_QTY] AS [OPENING_QTY]
        ,OC.[STANDARDISED_UOM] AS [OPENING_UOM]
        ,CC.[STANDARDISED_QTY] AS [CLOSING_QTY]
        ,CC.[STANDARDISED_UOM] AS [CLOSING_UOM]
        -- Which count date each boundary actually resolved to. Materialised on the fact
        -- (final-review I6) because carry-forward is invisible after the fact otherwise:
        -- period-level PERIOD_START_DATE/PERIOD_END_DATE are always distinct by
        -- construction, so the O8-sibling defect (opening and closing resolving to the
        -- SAME stocktake, collapsing consumption to purchases) happens per ITEM, inside
        -- these two OUTER APPLYs, and cannot be detected by any post-hoc query unless the
        -- resolved dates are stored. Check 6 in 99_verify_cogs_period.sql tests
        -- OPENING_COUNT_DATE = CLOSING_COUNT_DATE AND IS_FIRST_PERIOD = 0.
        ,OC.[COUNT_DATE]       AS [OPENING_COUNT_DATE]
        ,CC.[COUNT_DATE]       AS [CLOSING_COUNT_DATE]
        ,CASE WHEN CC.[COUNT_DATE] = PI.[PERIOD_END_DATE] THEN 0 ELSE 1 END AS [IS_UNCOUNTED]
        ,CASE WHEN PI.[PERIOD_START_DATE] IS NULL THEN 1 ELSE 0 END        AS [IS_FIRST_PERIOD]
    FROM PeriodItems PI
    OUTER APPLY (SELECT TOP 1 * FROM ItemCounts C
                 WHERE C.[LOCATION_HUB_ID] = PI.[LOCATION_HUB_ID]
                   AND C.[INVITEM_HUB_ID]  = PI.[INVITEM_HUB_ID]
                   AND C.[COUNT_DATE] <= PI.[PERIOD_START_DATE]
                 ORDER BY C.[COUNT_DATE] DESC) OC
    OUTER APPLY (SELECT TOP 1 * FROM ItemCounts C
                 WHERE C.[LOCATION_HUB_ID] = PI.[LOCATION_HUB_ID]
                   AND C.[INVITEM_HUB_ID]  = PI.[INVITEM_HUB_ID]
                   AND C.[COUNT_DATE] <= PI.[PERIOD_END_DATE]
                 ORDER BY C.[COUNT_DATE] DESC) CC
),
Movements AS (
    -- Summed over (PERIOD_START_DATE, PERIOD_END_DATE]. ISNULL guards the first
    -- period so the > predicate does not eliminate all pre-period movements
    -- when PERIOD_START_DATE is NULL.
    --
    -- SIGN CONVENTION — READ BEFORE CHANGING (final-review I4).
    -- Every bucket below is behaviour-aware, but the polarity differs between the
    -- INFLOW buckets and the OUTFLOW buckets, and that is deliberate:
    --   DELIVERY_QTY / TRANSFER_QTY are INFLOW-positive  (''-'' behaviour negates),
    --   WASTE_QTY    / SALE_QTY     are OUTFLOW-positive (''+'' behaviour negates).
    -- The reason is design §4.1''s derivation, which ADDS deliveries and transfers and
    -- SUBTRACTS waste and sales:
    --   THEO_CLOSING_QTY = OPENING + DELIVERY + TRANSFER - WASTE - SALE
    -- so each bucket must be positive in the direction its own sign in that formula
    -- expects. A ''+''-behaviour WASTE or SALE row is a reversal or correction, and it
    -- must NET OFF the outflow; before this fix these two buckets summed raw
    -- STANDARDISED_QTY and so ADDED a reversal to the outflow, inflating
    -- THEO_CLOSING_QTY and corrupting VARIANCE_QTY / VARIANCE_VALUE — the
    -- "unexplained shrink" KPI — by twice the reversal, silently.
    -- Do NOT "align" the two outflow buckets with step 9''s
    -- (8_PresentationControl.sql:2030-2070) uniform ''-''-negates pattern: step 9
    -- normalises every bucket into a signed MOVEMENT_QTY, whereas this fact keeps
    -- directional buckets that the formula above subtracts. Copying step 9 here would
    -- flip the sign of every reversal and add stock back instead of removing it.
    SELECT
         B.[LOCATION_HUB_ID], B.[INVITEM_HUB_ID], B.[PERIOD_END_DATE]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] IN (''ORDER'',''DELIVERY'')
                  THEN CASE WHEN SE.[EVENT_BEHAVIOUR] = ''-'' THEN -SE.[STANDARDISED_QTY] ELSE SE.[STANDARDISED_QTY] END
                  ELSE 0 END) AS [DELIVERY_QTY]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] = ''TRANSFER''
                  THEN CASE WHEN SE.[EVENT_BEHAVIOUR] = ''-'' THEN -SE.[STANDARDISED_QTY] ELSE SE.[STANDARDISED_QTY] END
                  ELSE 0 END) AS [TRANSFER_QTY]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] = ''WASTE''
                  THEN CASE WHEN SE.[EVENT_BEHAVIOUR] = ''+'' THEN -SE.[STANDARDISED_QTY] ELSE SE.[STANDARDISED_QTY] END
                  ELSE 0 END) AS [WASTE_QTY]
        ,SUM(CASE WHEN SE.[EVENT_TYPE] = ''SALE''
                  THEN CASE WHEN SE.[EVENT_BEHAVIOUR] = ''+'' THEN -SE.[STANDARDISED_QTY] ELSE SE.[STANDARDISED_QTY] END
                  ELSE 0 END) AS [SALE_QTY]
    -- UNHANDLED EVENT_TYPE (final-review M12, documented not changed). The four buckets
    -- above cover ORDER/DELIVERY, TRANSFER, WASTE and SALE. Step 9 also buckets
    -- PRODUCTION (8_PresentationControl.sql:2055). Any other EVENT_TYPE passes the
    -- EVENT_BEHAVIOUR IN (''+'',''-'') join filter, changes physical stock, contributes to
    -- no bucket here, and therefore lands in VARIANCE_QTY as unexplained shrink: a
    -- plausible number with no signal. Left as-is because adding a PRODUCTION bucket to
    -- a pantry fact would be speculative (a pantry has no production events) and the
    -- design does not define how production should net into COG Sold. The exposure is
    -- named rather than hidden: run
    --   SELECT DISTINCT [EVENT_TYPE] FROM [datavault].[SAT_STOCKEVENT]
    --   WHERE [SRC] LIKE ''int_growyze%''
    -- against the target org before trusting VARIANCE_VALUE, and if anything outside the
    -- four handled types appears, add its bucket here first.
    FROM Bounded B
    LEFT JOIN StockEvents SE
        ON  SE.[LOCATION_HUB_ID] = B.[LOCATION_HUB_ID]
        AND SE.[INVITEM_HUB_ID]  = B.[INVITEM_HUB_ID]
        AND SE.[EVENT_BEHAVIOUR] IN (''+'',''-'')
        AND SE.[EVENT_TS] >  ISNULL(B.[PERIOD_START_DATE], ''1900-01-01'')
        AND SE.[EVENT_TS] <= B.[PERIOD_END_DATE]
    GROUP BY B.[LOCATION_HUB_ID], B.[INVITEM_HUB_ID], B.[PERIOD_END_DATE]
),
ItemCost AS (
    -- Latest SAT_INVITEM.UOM_COST at or before PERIOD_END_DATE (never an
    -- average — Growyze values every money column at qty x latest cost price
    -- in the period, per design §1.2). Deliberately does NOT filter out a NULL
    -- UOM_COST the way the deployed InvItemCost (cost-path-redesign/04) does —
    -- that CTE serves F_INV_COUNTS_DAY''s "current cost" need and skips NULLs
    -- to fall back further; ours must report a genuinely-NULL latest cost as
    -- NULL so HAS_ZERO_COST correctly flags it (spec §8 check 5: zero/NULL
    -- cost items are reported, never hidden).
    SELECT
         B.[INVITEM_HUB_ID], B.[PERIOD_END_DATE]
        ,C.[UOM_COST] / NULLIF(uc.conversion_factor, 0) AS [UOM_COST]
    -- EFFECTIVEFROM FALLBACK (defect C4, found by executing this build against UAT org 21
    -- before deploying it). The predicate here was originally a hard
    -- "AND SI.[EFFECTIVEFROM] <= B.[PERIOD_END_DATE]" filter. That is the correct expression
    -- of design section 1.2 ("latest cost price IN the period") and it stays the FIRST
    -- preference below - but as a hard filter it silently returns NOTHING on a freshly-loaded
    -- org, because every SAT_INVITEM row carries EFFECTIVEFROM = the load date. On UAT org 21
    -- all 501 leaf items were stamped 2026-07-28 while the periods under test end 2026-05-31
    -- and 2026-06-30, so the OUTER APPLY matched zero rows, UOM_COST was NULL on every row of
    -- the fact, and EVERY money column (COG_SPEND, COG_SOLD, CLOSING_VALUE, WASTE_VALUE,
    -- VARIANCE_VALUE) came out NULL - 732 of 732 rows with HAS_ZERO_COST = 1 - while the
    -- quantities were all correct. Nothing errored. The three deployed sibling inventory facts
    -- do not have this problem because their InvItemCost CTE
    -- (cost-path-redesign/04_presentation_counts_cost.sql:177-187) resolves cost by
    -- CURRENT_FLAG = 1 with NO temporal predicate at all.
    --
    -- The ORDER BY below keeps the point-in-time intent and degrades instead of vanishing:
    --   1st key - versions effective at or before the period end rank ahead of later ones;
    --   2nd key - among those, the LATEST (this is the original, preferred behaviour, and it
    --             starts applying by itself the moment the satellite accumulates real T2
    --             history, with no further change here);
    --   3rd key - if there is no version at or before the period end, take the EARLIEST
    --             version that exists, i.e. the closest cost we actually hold.
    -- Do NOT collapse this back to a hard WHERE predicate, and do NOT switch it to
    -- CURRENT_FLAG = 1 - the first reintroduces C4, the second discards cost history the
    -- moment it exists and would value every historical period at today''s price.
    -- New verify check 12 is the gate that proves cost resolution actually resolved.
    FROM (SELECT DISTINCT [INVITEM_HUB_ID], [PERIOD_END_DATE] FROM Bounded) B
    OUTER APPLY (SELECT TOP 1 SI.[UOM_COST], SI.[UOM]
                 FROM [datavault].[SAT_INVITEM] SI
                 WHERE SI.[HUB_ID] = B.[INVITEM_HUB_ID]
                   AND SI.[BOTTOM_LEVEL] = 1
                   AND ISNULL(SI.[IS_DELETED], 0) = 0
                 ORDER BY CASE WHEN SI.[EFFECTIVEFROM] <= B.[PERIOD_END_DATE]
                               THEN 0 ELSE 1 END ASC
                         ,CASE WHEN SI.[EFFECTIVEFROM] <= B.[PERIOD_END_DATE]
                               THEN SI.[EFFECTIVEFROM] END DESC
                         ,SI.[EFFECTIVEFROM] ASC) C
    LEFT JOIN UOMConversion uc ON C.[UOM] = uc.[UOM]
),
BreakoutBuckets AS (
    -- Config: COGS_REPORT_GROUP_BREAKOUT, pipe-delimited (03_report_group_config.sql).
    --
    -- WHICH DATABASE THIS READS (final-review C1 — the bug was here at the seam, not in
    -- this line). The two-part [core].[GlobalParameters] below is CLIENT-LOCAL: this
    -- query_sql is executed by sp_ProcessPresentation in the calling ORGANISATION
    -- database, so it resolves to <client_db>.core.GlobalParameters, never to the
    -- central core database''s copy. That is the correct target — GlobalParameters is a
    -- per-database deployable object (8_Deployment_Objects_Records.sql:25, seeded
    -- per-database at line 2432) and every other fact step reads its own database''s copy
    -- the same way (97_rebuild_presentation.sql:20-24, LINEITEM_START / STOCKEVENT_*).
    -- 03_report_group_config.sql must therefore be deployed AGAINST THE CLIENT DATABASE.
    -- It was previously run against `core`, which left this read returning nothing.
    --
    -- Missing/empty parameter -> STRING_SPLIT(NULL,...) returns zero rows -> BB never
    -- matches -> REPORT_GROUP = CATEGORY everywhere. That is the spec''s "no break-out"
    -- behaviour when the config is deliberately absent, and it is ALSO exactly what a
    -- mis-targeted deploy looks like, with no error either way. Verify check 11 in
    -- 99_verify_cogs_period.sql exists to separate the two cases: it FAILs when the
    -- parameter IS set in this database yet no fact row has REPORT_GROUP <> CATEGORY.
    SELECT LTRIM(RTRIM(value)) AS [CATEGORY]
    FROM STRING_SPLIT(
        (SELECT [ParameterValue] FROM [core].[GlobalParameters]
         WHERE [ParameterKey] = ''COGS_REPORT_GROUP_BREAKOUT''), ''|'')
),
Calc AS (
    -- All ISNULL-defaulted quantities and the resolved cost, computed once so
    -- the final SELECT''s value/flag columns do not have to repeat the ISNULL
    -- chains and cannot drift from each other.
    SELECT
         B.[INVITEM_HUB_ID]
        ,B.[LOCATION_HUB_ID]
        ,B.[PERIOD_START_DATE]
        ,B.[PERIOD_END_DATE]
        ,B.[PERIOD_SEQ]
        ,B.[OPENING_COUNT_DATE]
        ,B.[CLOSING_COUNT_DATE]
        ,B.[IS_UNCOUNTED]
        ,B.[IS_FIRST_PERIOD]
        ,COALESCE(B.[CLOSING_UOM], B.[OPENING_UOM])                        AS [STANDARDISED_UOM]
        ,ISNULL(B.[OPENING_QTY], 0)                                        AS [OPENING_QTY]
        ,ISNULL(M.[DELIVERY_QTY], 0)                                       AS [DELIVERY_QTY]
        ,ISNULL(M.[TRANSFER_QTY], 0)                                       AS [TRANSFER_QTY]
        ,ISNULL(B.[CLOSING_QTY], 0)                                        AS [CLOSING_QTY]
        ,ISNULL(M.[WASTE_QTY], 0)                                          AS [WASTE_QTY]
        ,ISNULL(M.[SALE_QTY], 0)                                           AS [SALE_QTY]
        ,IC.[UOM_COST]                                                     AS [UOM_COST]
    FROM Bounded B
    LEFT JOIN Movements M
        ON M.[LOCATION_HUB_ID] = B.[LOCATION_HUB_ID]
       AND M.[INVITEM_HUB_ID]  = B.[INVITEM_HUB_ID]
       AND M.[PERIOD_END_DATE] = B.[PERIOD_END_DATE]
    LEFT JOIN ItemCost IC
        ON IC.[INVITEM_HUB_ID]  = B.[INVITEM_HUB_ID]
       AND IC.[PERIOD_END_DATE] = B.[PERIOD_END_DATE]
)
SELECT
     C.[INVITEM_HUB_ID]
    ,C.[LOCATION_HUB_ID]
    ,C.[PERIOD_START_DATE]
    ,C.[PERIOD_END_DATE]
    ,DATEDIFF(DAY, C.[PERIOD_START_DATE], C.[PERIOD_END_DATE])              AS [PERIOD_DAYS]
    ,C.[PERIOD_SEQ]
    ,DATEFROMPARTS(YEAR(C.[PERIOD_END_DATE]), MONTH(C.[PERIOD_END_DATE]), 1) AS [PERIOD_MONTH]
    ,CASE WHEN C.[PERIOD_START_DATE] IS NULL
          THEN ''Opening - '' + CONVERT(VARCHAR(11), C.[PERIOD_END_DATE], 106)
          ELSE CONVERT(VARCHAR(11), C.[PERIOD_START_DATE], 106) + '' - ''
               + CONVERT(VARCHAR(11), C.[PERIOD_END_DATE], 106)
          END                                                               AS [PERIOD_LABEL]
    ,C.[OPENING_COUNT_DATE]
    ,C.[CLOSING_COUNT_DATE]
    ,ISRC.[SRC]                                                             AS [SOURCE]
    ,C.[STANDARDISED_UOM]
    ,DI.[BOTTOM_INVITEM_NAME]                                               AS [ITEM_NAME]
    ,DI.[TOP_NAME]                                                          AS [CATEGORY]
    ,DI.[MIDDLE_1_NAME]                                                     AS [SUBCATEGORY]
    ,CASE WHEN BB.[CATEGORY] IS NOT NULL
          THEN DI.[TOP_NAME] + '' - '' + ISNULL(DI.[MIDDLE_1_NAME], ''Unspecified'')
          ELSE DI.[TOP_NAME] END                                            AS [REPORT_GROUP]
    ,C.[OPENING_QTY]
    ,C.[DELIVERY_QTY]
    ,C.[TRANSFER_QTY]
    ,C.[CLOSING_QTY]
    ,C.[OPENING_QTY] + C.[DELIVERY_QTY] + C.[TRANSFER_QTY] - C.[CLOSING_QTY] AS [CONSUMPTION_QTY]
    ,C.[WASTE_QTY]
    ,C.[SALE_QTY]
    ,C.[OPENING_QTY] + C.[DELIVERY_QTY] + C.[TRANSFER_QTY]
       - C.[WASTE_QTY] - C.[SALE_QTY]                                       AS [THEO_CLOSING_QTY]
    ,C.[CLOSING_QTY]
       - (C.[OPENING_QTY] + C.[DELIVERY_QTY] + C.[TRANSFER_QTY]
          - C.[WASTE_QTY] - C.[SALE_QTY])                                   AS [VARIANCE_QTY]
    ,C.[UOM_COST]
    ,C.[OPENING_QTY]  * C.[UOM_COST]                                        AS [OPENING_VALUE]
    ,C.[DELIVERY_QTY] * C.[UOM_COST]                                        AS [DELIVERY_VALUE]
    ,(C.[DELIVERY_QTY] - C.[TRANSFER_QTY]) * C.[UOM_COST]                   AS [COG_SPEND]
    ,(C.[OPENING_QTY] + C.[DELIVERY_QTY] + C.[TRANSFER_QTY] - C.[CLOSING_QTY]) * C.[UOM_COST] AS [COG_SOLD]
    ,C.[CLOSING_QTY] * C.[UOM_COST]                                         AS [CLOSING_VALUE]
    ,C.[WASTE_QTY]   * C.[UOM_COST]                                         AS [WASTE_VALUE]
    ,(C.[CLOSING_QTY]
       - (C.[OPENING_QTY] + C.[DELIVERY_QTY] + C.[TRANSFER_QTY]
          - C.[WASTE_QTY] - C.[SALE_QTY])) * C.[UOM_COST]                   AS [VARIANCE_VALUE]
    ,CASE WHEN (C.[OPENING_QTY] + C.[DELIVERY_QTY] + C.[TRANSFER_QTY] - C.[CLOSING_QTY]) < 0
          THEN 1 ELSE 0 END                                                 AS [IS_NEGATIVE_COGS]
    ,CASE WHEN C.[UOM_COST] IS NULL OR C.[UOM_COST] = 0 THEN 1 ELSE 0 END   AS [HAS_ZERO_COST]
    ,C.[IS_UNCOUNTED]
    ,C.[IS_FIRST_PERIOD]
FROM Calc C
LEFT JOIN InvItemSource ISRC
    ON ISRC.[LOCATION_HUB_ID] = C.[LOCATION_HUB_ID]
   AND ISRC.[INVITEM_HUB_ID] = C.[INVITEM_HUB_ID]
LEFT JOIN [presentation].[D_INVITEM] DI
    ON DI.[BOTTOM_HUB_ID] = C.[INVITEM_HUB_ID]
LEFT JOIN BreakoutBuckets BB
    ON BB.[CATEGORY] = DI.[TOP_NAME]
;';

MERGE INTO [core].[PresentationControl] AS tgt
USING (VALUES (N'Pantry COGS by Period', N'F_COGS_PERIOD')) AS src (step_name, table_name)
    ON tgt.[step_name] = src.[step_name] AND tgt.[table_name] = src.[table_name]
-- time_series_target_column IS NOT OPTIONAL ON A FACT (defect C6 - the worst one in this pack).
-- Both of these were originally NULL, which is silently catastrophic. sp_ExecuteQuery gates the
-- pre-insert DELETE on it:
--     ELSE IF @TableType = 'Fact' AND @TimeSeriesTargetColumn IS NOT NULL
--         ... DELETE FROM target WHERE [col] BETWEEN @MinDate AND @MaxDate
--     -- and then, UNCONDITIONALLY:
--     INSERT INTO target (...) SELECT ... FROM ##TempResults
-- With the column NULL the DELETE branch is skipped and the INSERT still runs, so the step is a
-- pure APPEND. It does not fail, it does not warn, and it COMPOUNDS: every scheduled presentation
-- rebuild adds another complete copy of the fact. Observed on 2026-07-31 - Padel Social reached
-- 35,112 rows for 17,556 distinct grain keys and Dirty Sixth 14,264 for 7,132, each an exact 2x,
-- within an hour of deployment, purely from one scheduled refresh. Every measure doubles with it.
-- ALL 19 other Fact steps in PresentationControl set this column; this step was the exception.
-- The value must name a TARGET column that also appears in column_mappings.table_column -
-- sp_ExecuteQuery resolves the matching query_column and RAISERRORs if it cannot, so a typo here
-- is loud rather than silent. PERIOD_END_DATE is the fact's time axis and is never NULL.
-- Because the build reads unbounded history, MIN..MAX spans every period and the DELETE is a true
-- full replace. Set in BOTH branches deliberately: leaving it out of the UPDATE branch is what
-- would stop a re-run of this script from repairing an already-broken control row.
WHEN MATCHED THEN UPDATE SET
     [query_sql]        = @sql
    ,[tier]             = 110
    ,[table_type]       = N'Fact'
    ,[column_mappings]  = @colmap
    ,[exclude]          = 0
    ,[priority]         = 100
    ,[retry_count]      = 3
    ,[timeout_minutes]  = 30
    ,[time_series_entity]        = N'STOCKEVENT'
    ,[time_series_target_column] = N'PERIOD_END_DATE'
    ,[description]      = N'Builds F_COGS_PERIOD at item x location x stocktake-period grain. Unbounded read - full refresh.'
    ,[updated_at]       = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (step_name, table_name, query_sql, tier, table_type, column_mappings,
     exclude, priority, retry_count, timeout_minutes, description,
     created_by, created_at, updated_at, time_series_entity, time_series_target_column)
VALUES
    (N'Pantry COGS by Period', N'F_COGS_PERIOD', @sql, 110, N'Fact', @colmap,
     0, 100, 3, 30, N'Builds F_COGS_PERIOD at item x location x stocktake-period grain.',
     N'PresentationControlApp', GETDATE(), GETDATE(), N'STOCKEVENT', N'PERIOD_END_DATE');
