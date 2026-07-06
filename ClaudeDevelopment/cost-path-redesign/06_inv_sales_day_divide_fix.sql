-- ============================================================
-- Cost Path Redesign: Task 6 (hotfix)
-- Fix divide-by-zero in "Inventory Sales by Day" (F_INV_SALES_DAY)
--
-- Root cause: The NET_SALES formula divides by
--   SUM(PIS.UOM_VALUE * INV.UOM_COST) OVER(PARTITION BY PIS.HUB_ID)
-- which is 0 when all inventory items in a lineitem partition
-- have NULL or 0 UOM_COST.  This was exposed by the cost-path
-- redesign (scripts 04/05) which changed UOM_COST sourcing from
-- a rolling SAT_INVREPORT average to direct SAT_INVITEM.UOM_COST,
-- producing more NULL/zero costs.
--
-- Fix: wrap the divisor with NULLIF(..., 0) so divide-by-zero
-- returns NULL, which the outer ISNULL converts to 0.
-- ============================================================

MERGE INTO [core].[core].[PresentationControl] AS tgt
USING (
    SELECT N'Inventory Sales by Day' AS step_name
) AS src
ON tgt.[step_name] = src.[step_name]

WHEN MATCHED THEN UPDATE SET
    tgt.[query_sql] = N'DECLARE @HasPOS BIT = CASE WHEN EXISTS (
    SELECT 1 FROM [core].[core].[OrganisationIntegrations] OI
    INNER JOIN [core].[core].[Integrations] I ON OI.IntegrationID = I.IntegrationID
    INNER JOIN [core].[core].[Organisations] O ON OI.OrganisationID = O.OrganisationID
    WHERE O.DatabaseName = DB_NAME()
    AND I.IntegrationType = ''POS''
) THEN 1 ELSE 0 END;

DECLARE @StartDate DATE;
DECLARE @EndDate DATE;

SELECT @StartDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''LINEITEM_START'';

SELECT @EndDate = CAST([ParameterValue] AS DATE)
FROM [core].[GlobalParameters]
WHERE [ParameterKey] = ''LINEITEM_END'';

WITH UOMConversion AS
	(
	SELECT [FROM_UOM] AS UOM, [TO_UOM] AS base_uom, CAST([CONVERSION_FACTOR] AS DECIMAL(18,6)) AS conversion_factor FROM [core].[reference].[UOM_CONVERSION]
),

Inventory AS
	(
	SELECT
		*
	FROM
		[presentation].[F_INV_USAGE_DAY] IR

	WHERE 1=1
	AND IR.[COUNT_DATE] BETWEEN @StartDate AND @EndDate

),

ProductSales AS
(
	SELECT
		LP.[PRODUCT_HUB_ID]
		,LL.[LOCATION_HUB_ID]
		,LO.[OCCASION_HUB_ID]
		,LI.*
	FROM
		[datavault].[SAT_LINEITEM] LI

	INNER JOIN
		[core].[core].[Integrations] IG
	ON LI.[SRC] = IG.[SchemaName]
	AND (@HasPOS = 0 OR IG.[IntegrationType] = ''POS'')

	LEFT OUTER JOIN
		[datavault].[LNK_LINEITEM_PRODUCT] LP
	ON LI.[HUB_ID] = LP.[LINEITEM_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[LNK_CUSTORDER_LINEITEM] LC
	ON LI.[HUB_ID] = LC.[LINEITEM_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[LNK_CUSTORDER_LOCATION] LL
	ON LC.[CUSTORDER_HUB_ID] = LL.[CUSTORDER_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[LNK_LINEITEM_OCCASION] LO
	ON LI.[HUB_ID] = LO.[LINEITEM_HUB_ID]

	WHERE 1=1
	AND LI.[ORDER_DATE] BETWEEN @StartDate AND @EndDate
	AND LI.[LINEITEM_TYPE] = ''PROD''
),


ProductInvSales AS
	(
	SELECT
		LLOP.INVITEM_HUB_ID
		,SLLOP.[UOM]
		,SLLOP.[UOM_VALUE] * UC.[conversion_factor] AS [UOM_VALUE]
		,PS.*
	FROM
		ProductSales PS

	LEFT OUTER JOIN
		[datavault].[LNK_INVITEM_LOCATION_OCCASION_PRODUCT] LLOP
	ON PS.[OCCASION_HUB_ID] = LLOP.[OCCASION_HUB_ID]
	AND PS.[LOCATION_HUB_ID] = LLOP.[LOCATION_HUB_ID]
	AND PS.[PRODUCT_HUB_ID] = LLOP.[PRODUCT_HUB_ID]

	LEFT OUTER JOIN
		[datavault].[SAT_LNK_INVITEM_LOCATION_OCCASION_PRODUCT] SLLOP
	ON LLOP.[LNK_ID] = SLLOP.[LNK_ID]

    LEFT JOIN
        UOMConversion uc
    ON SLLOP.[UOM] = uc.[UOM]
)

SELECT
	INVITEM_HUB_ID
	,LOCATION_HUB_ID
	,INV_DATE
	,AVG(UOM_COST) AS UOM_COST
	,SUM(SALES_RECIPE_COST) AS SALES_RECIPE_COST
	,SUM(NET_SALES) AS NET_SALES

FROM
(
	SELECT
		COALESCE(PIS.INVITEM_HUB_ID, INV.[INVITEM_HUB_ID]) AS [INVITEM_HUB_ID]
		,COALESCE(PIS.[LOCATION_HUB_ID], INV.  [LOCATION_HUB_ID]) AS [LOCATION_HUB_ID]
		,COALESCE(PIS.ORDER_DATE,INV.[COUNT_DATE]) AS INV_DATE
		,ISNULL(INV.UOM_COST,0) AS UOM_COST
		,ISNULL((PIS.UOM_VALUE * INV.UOM_COST),0) AS SALES_RECIPE_COST
		,ISNULL(((PIS.UOM_VALUE * INV.UOM_COST) / NULLIF(SUM(PIS.UOM_VALUE * INV.UOM_COST) OVER(PARTITION BY PIS.HUB_ID), 0)) * PIS.NET_VALUE,0) AS NET_SALES
	FROM
		Inventory INV
	LEFT OUTER JOIN
		ProductInvSales PIS
	ON INV.[LOCATION_HUB_ID] = PIS.[LOCATION_HUB_ID]
	AND INV.[INVITEM_HUB_ID] = PIS.[INVITEM_HUB_ID]
	AND INV.[COUNT_DATE] = PIS.[ORDER_DATE]
	) SUB
GROUP BY
	INVITEM_HUB_ID
	,LOCATION_HUB_ID
	,INV_DATE',

    tgt.[updated_at] = GETDATE();
