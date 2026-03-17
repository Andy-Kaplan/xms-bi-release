-- ============================================
-- Visualization Queries Export
-- Generated: 2026-01-20 11:54:42
-- Total Records: 109
-- Unique Datasets: 89
-- ============================================

-- Note: These INSERT statements will create visualization query definitions
-- If a query with the same DataSetName, VisualizationType, and Version already exists,
-- you may get a unique constraint violation. Consider deleting or updating existing records first.

-- To execute in target environment:
-- 1. Ensure the target database has the [core].[core].[VisualisationQueries] table
-- 2. Run this script in the target database
-- 3. Refresh the Visualization Queries app to see the imported queries

-- ============================================
-- Dataset: ATVChannelDayPart
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ATVChannelDayPart',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
	TEMPLATE.DAY_PERIOD AS Axis1
	,DENSE_RANK() OVER( ORDER BY TEMPLATE.DAY_PERIOD) AS AxisSort1
	,TEMPLATE.CHANNEL AS Label1
	,ISNULL(ACTUALS.ATV, 0) AS Value1
FROM
(
SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[GROSS_VALUE] ELSE 0 END) / SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS ATV
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS DAY_PERIOD
	,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME]) AS CHANNEL
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])
) ACTUALS

RIGHT OUTER JOIN
(
SELECT DAY_PERIOD,CHANNEL FROM 
 (SELECT DISTINCT DATEPART(HOUR, [LINEITEM_TIMESTAMP]) AS DAY_PERIOD FROM [presentation].[F_LINEITEM_15MIN] WHERE [LINEITEM_TIMESTAMP] IS NOT NULL) DP
 CROSS JOIN
 (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_CHANNEL_NAME]) AS CHANNEL FROM [presentation].[D_CHANNEL] WHERE COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_CHANNEL_NAME]) IS NOT NULL) OT
) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.CHANNEL = TEMPLATE.CHANNEL',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "Axis1",
    "AxisSort": "AxisSort1",
    "Label": "Label1",
    "Value": "Value1"
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "Chart Title",
        "Description": "Chart Description"
      }
    }
  ]
}',
    N'SELECT
    [Axis1] AS [Axis]
    ,    [AxisSort1] AS [AxisSort]
    ,    [Label1] AS [Label]
    ,    [Value1] AS [Value]
FROM
(
SELECT
	TEMPLATE.DAY_PERIOD AS Axis1
	,DENSE_RANK() OVER( ORDER BY TEMPLATE.DAY_PERIOD) AS AxisSort1
	,TEMPLATE.CHANNEL AS Label1
	,ISNULL(ACTUALS.ATV, 0) AS Value1
FROM
(
SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[GROSS_VALUE] ELSE 0 END) / SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS ATV
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS DAY_PERIOD
	,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME]) AS CHANNEL
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])
) ACTUALS

RIGHT OUTER JOIN
(
SELECT DAY_PERIOD,CHANNEL FROM 
 (SELECT DISTINCT DATEPART(HOUR, [LINEITEM_TIMESTAMP]) AS DAY_PERIOD FROM [presentation].[F_LINEITEM_15MIN] WHERE [LINEITEM_TIMESTAMP] IS NOT NULL) DP
 CROSS JOIN
 (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_CHANNEL_NAME]) AS CHANNEL FROM [presentation].[D_CHANNEL] WHERE COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_CHANNEL_NAME]) IS NOT NULL) OT
) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.CHANNEL = TEMPLATE.CHANNEL
) INPUTQUERY

SELECT
    ''Chart Title'' AS [Title]
    ,    ''Chart Description'' AS [Description]
    ,    NULL AS [Value]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ATVRevCentreDayPart
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ATVRevCentreDayPart',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
	TEMPLATE.DAY_PERIOD AS Axis1
	,DENSE_RANK() OVER( ORDER BY TEMPLATE.DAY_PERIOD) AS AxisSort1
	,TEMPLATE.REVCENTER AS Label1
	,ISNULL(ACTUALS.ATV, 0) AS Value1
FROM
(
SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[GROSS_VALUE] ELSE 0 END) / SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS ATV
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS DAY_PERIOD
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS REVCENTER
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])
) ACTUALS

RIGHT OUTER JOIN
(
SELECT DAY_PERIOD,REVCENTER FROM 
 (SELECT DISTINCT DATEPART(HOUR, [LINEITEM_TIMESTAMP]) AS DAY_PERIOD FROM [presentation].[F_LINEITEM_15MIN] WHERE [LINEITEM_TIMESTAMP] IS NOT NULL) DP
 CROSS JOIN
 (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) AS REVCENTER FROM [presentation].[D_REVCENTER] WHERE COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) IS NOT NULL) OT
) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.REVCENTER = TEMPLATE.REVCENTER',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "NOT_IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "Axis1",
    "AxisSort": "AxisSort1",
    "Label": "Label1",
    "Value": "Value1"
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "Average Transaction Value",
        "Description": "By Revenue Centre"
      }
    }
  ]
}',
    N'SELECT
    [Axis1] AS [Axis]
    ,    [AxisSort1] AS [AxisSort]
    ,    [Label1] AS [Label]
    ,    [Value1] AS [Value]
FROM
(
SELECT
	TEMPLATE.DAY_PERIOD AS Axis1
	,DENSE_RANK() OVER( ORDER BY TEMPLATE.DAY_PERIOD) AS AxisSort1
	,TEMPLATE.REVCENTER AS Label1
	,ISNULL(ACTUALS.ATV, 0) AS Value1
FROM
(
SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[GROSS_VALUE] ELSE 0 END) / SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS ATV
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS DAY_PERIOD
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS REVCENTER
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])
) ACTUALS

RIGHT OUTER JOIN
(
SELECT DAY_PERIOD,REVCENTER FROM 
 (SELECT DISTINCT DATEPART(HOUR, [LINEITEM_TIMESTAMP]) AS DAY_PERIOD FROM [presentation].[F_LINEITEM_15MIN] WHERE [LINEITEM_TIMESTAMP] IS NOT NULL) DP
 CROSS JOIN
 (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) AS REVCENTER FROM [presentation].[D_REVCENTER] WHERE COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) IS NOT NULL) OT
) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.REVCENTER = TEMPLATE.REVCENTER
) INPUTQUERY

SELECT
    ''Average Transaction Value'' AS [Title]
    ,    ''By Revenue Centre'' AS [Description]
    ,    NULL AS [Value]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Channels
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Channels',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[CHANNEL_NAME]) AS [CHANNEL_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[CHANNEL_NAME]) ELSE [CHANNEL_ID] END AS [CHANNEL_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_CHANNEL]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "CHANNEL_NAME",
    "ID": "CHANNEL_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Channels"
      }
    }
  ]
}',
    N'SELECT
    [CHANNEL_NAME] AS [Label]
    ,    [CHANNEL_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[CHANNEL_NAME]) AS [CHANNEL_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[CHANNEL_NAME]) ELSE [CHANNEL_ID] END AS [CHANNEL_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_CHANNEL]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Channels'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: DayOfWeek
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'DayOfWeek',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	C.[DayName] AS [DAY_NAME]
	,C.[DayOfWeek] AS [DAY_ID]
	,NULL AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [presentation].[CALENDAR] C
WHERE 1=1
@FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "DAY_NAME",
    "ID": "DAY_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Day of Week"
      }
    }
  ]
}',
    N'SELECT
    [DAY_NAME] AS [Label]
    ,    [DAY_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	C.[DayName] AS [DAY_NAME]
	,C.[DayOfWeek] AS [DAY_ID]
	,NULL AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [presentation].[CALENDAR] C
WHERE 1=1
@FilterClause
) INPUTQUERY

SELECT
    ''Day of Week'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: DealToggle
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'DealToggle',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT 
	''Yes'' AS [TOGGLE_NAME]
	,1 AS [TOGGLE_ID]
	,NULL AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [datavault].[SAT_CHANNEL]
UNION ALL
SELECT 
	''No'' AS [TOGGLE_NAME]
	,0 AS [TOGGLE_ID]
	,NULL AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [datavault].[SAT_CHANNEL]',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "TOGGLE_NAME",
    "ID": "TOGGLE_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Sold in Deals"
      }
    }
  ]
}',
    N'SELECT
    [TOGGLE_NAME] AS [Label]
    ,    [TOGGLE_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT 
	''Yes'' AS [TOGGLE_NAME]
	,1 AS [TOGGLE_ID]
	,NULL AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [datavault].[SAT_CHANNEL]
UNION ALL
SELECT 
	''No'' AS [TOGGLE_NAME]
	,0 AS [TOGGLE_ID]
	,NULL AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [datavault].[SAT_CHANNEL]
) INPUTQUERY

SELECT
    ''Sold in Deals'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Deals
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Deals',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[DEAL_NAME]) AS [DEAL_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[DEAL_NAME]) ELSE [DEAL_ID] END AS [DEAL_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_DEAL]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "DEAL_NAME",
    "ID": "DEAL_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Deals"
      }
    }
  ]
}',
    N'SELECT
    [DEAL_NAME] AS [Label]
    ,    [DEAL_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[DEAL_NAME]) AS [DEAL_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[DEAL_NAME]) ELSE [DEAL_ID] END AS [DEAL_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_DEAL]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Deals'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: DiscountPerc
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'DiscountPerc',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Discount % of Gross'' AS Title,
    FORMAT(ABS(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN GROSS_VALUE ELSE 0 END)/SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN GROSS_VALUE ELSE 0 END),4)), ''P2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Discount % of Gross'' AS Title,
    FORMAT(ABS(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN GROSS_VALUE ELSE 0 END)/SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN GROSS_VALUE ELSE 0 END),4)), ''P2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- StatCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'DiscountPerc',
    N'StatCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
FROM
(
SELECT
    C.[DATE] AS XAxisLabel,
    ABS(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN GROSS_VALUE ELSE 0 END)/SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN GROSS_VALUE ELSE 0 END),4)) * 100 AS Value,
	1 AS VisId,
	''A'' AS Stack
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause

    GROUP BY C.[DATE]

) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Discount %'' AS YAxisLabel,
''Discount Percent'' AS Title,
NULL AS Interval,
NULL AS Trend,
NULL AS Chip,
(SELECT
    ABS(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN GROSS_VALUE ELSE 0 END)/SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN GROSS_VALUE ELSE 0 END),4)) * 100 AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    
) AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "INT"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
FROM
(
SELECT
    C.[DATE] AS XAxisLabel,
    ABS(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN GROSS_VALUE ELSE 0 END)/SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN GROSS_VALUE ELSE 0 END),4)) * 100 AS Value,
	1 AS VisId,
	''A'' AS Stack
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause

    GROUP BY C.[DATE]

) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Discount %'' AS YAxisLabel,
''Discount Percent'' AS Title,
NULL AS Interval,
NULL AS Trend,
NULL AS Chip,
(SELECT
    ABS(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN GROSS_VALUE ELSE 0 END)/SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN GROSS_VALUE ELSE 0 END),4)) * 100 AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    
) AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Discounts
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Discounts',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
POSTX_DATE AS BarLabel,
ROW_NUMBER() OVER( ORDER BY POSTX_DATE) AS BarLabelSort,
--STORENAME AS Column1,
--DAY_PERIOD AS Column2,
--PRODUCT_TYPE AS Column3,
--ITEMS_SOLD AS Column4,
--SALES_TOTAL AS Column5,
--SALES_NET_TOTAL AS BarValue
DISCOUNT_TOTAL AS BarValue,
ROW_NUMBER() OVER( ORDER BY DISCOUNT_TOTAL) AS BarValueSort
--TAX_TOTAL AS Column8,
 

FROM (
SELECT [POSTX_DATE]
      --,[NAME] AS STORENAME
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
  @FilterClause
  GROUP BY [POSTX_DATE]
      --,[NAME]
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
) SUB
 
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Discount Value'' AS YAxisLabel,
''Discount Value by Business Day'' AS Title,
''Discount Value by Business Day Description'' AS Description,
NULL AS Trend,
(SELECT ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2)FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
  @FilterClause) AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "POSTX_DATE",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Discounts',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[DISCOUNT_NAME]) AS [DISCOUNT_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[DISCOUNT_NAME]) ELSE [DISCOUNT_ID] END AS [DISCOUNT_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_DISCOUNT]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "POSTX_DATE",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "DISCOUNT_NAME",
    "ID": "DISCOUNT_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Discounts"
      }
    }
  ]
}',
    N'SELECT
    [DISCOUNT_NAME] AS [Label]
    ,    [DISCOUNT_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[DISCOUNT_NAME]) AS [DISCOUNT_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[DISCOUNT_NAME]) ELSE [DISCOUNT_ID] END AS [DISCOUNT_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_DISCOUNT]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Discounts'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- LineChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Discounts',
    N'LineChartCard',
    1,
    N'LIVE',
    N'SELECT
BDATE AS LineLabel,
ROW_NUMBER() OVER( ORDER BY BDATE) AS LineLabelSort,
--STORENAME AS Column1,
--DAY_PERIOD AS Column2,
--PRODUCT_TYPE AS Column3,
--ITEMS_SOLD AS Column4,
--SALES_TOTAL AS Column5,
--SALES_NET_TOTAL AS BarValue
DISCOUNT_TOTAL AS LineValue,
ROW_NUMBER() OVER( ORDER BY DISCOUNT_TOTAL) AS LineValueSort
--TAX_TOTAL AS Column8,
 

FROM (
SELECT C.CalendarDate AS BDATE
      --,[NAME] AS STORENAME
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
  [threerocks].[dbo].Calendar C
  ON F.POSTX_DATE = C.CalendarDate
  WHERE 1=1
  @FilterClause
  GROUP BY C.CalendarDate
      --,[NAME]
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
) SUB
 
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Discount Value'' AS YAxisLabel,
''Discount Value by Business Day'' AS Title,
''Discount Value by Business Day Description'' AS Description,
NULL AS Trend,
(SELECT ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2)FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
  [threerocks].[dbo].Calendar C
  ON F.POSTX_DATE = C.CalendarDate
  WHERE 1=1
  @FilterClause
  ) AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: DiscountsRevCentreDayPart
-- ============================================
-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'DiscountsRevCentreDayPart',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN F.[ORDER_COUNT] ELSE 0 END) AS Value
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS XAxisLabel
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS LegendLabel
    ,DENSE_RANK() OVER (ORDER BY COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])) AS VisId
    ,''line'' AS VisType
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])

    ) SUB',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "C.[DayOfWeek]",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Hour of Day",
        "YAxisLabel": "Discount Volume",
        "Title": "Discounts by Hour",
        "Description": "By Revenue Centre"
      }
    }
  ]
}',
    N'SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN F.[ORDER_COUNT] ELSE 0 END) AS Value
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS XAxisLabel
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS LegendLabel
    ,DENSE_RANK() OVER (ORDER BY COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])) AS VisId
    ,''line'' AS VisType
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])

    ) SUB
) INPUTQUERY

SELECT
    ''Hour of Day'' AS [XAxisLabel]
    ,    ''Discount Volume'' AS [YAxisLabel]
    ,    ''Discounts by Hour'' AS [Title]
    ,    ''By Revenue Centre'' AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Distributors
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Distributors',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[DISTRIBUTOR_NAME]) AS [DISTRIBUTOR_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[DISTRIBUTOR_NAME]) ELSE [DISTRIBUTOR_ID] END AS [DISTRIBUTOR_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_DISTRIBUTOR]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "DISTRIBUTOR_NAME",
    "ID": "DISTRIBUTOR_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Distributors"
      }
    }
  ]
}',
    N'SELECT
    [DISTRIBUTOR_NAME] AS [Label]
    ,    [DISTRIBUTOR_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[DISTRIBUTOR_NAME]) AS [DISTRIBUTOR_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[DISTRIBUTOR_NAME]) ELSE [DISTRIBUTOR_ID] END AS [DISTRIBUTOR_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_DISTRIBUTOR]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Distributors'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ForecastDailyRevenue
-- ============================================
-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ForecastDailyRevenue',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
        FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
        FORMAT(ROUND(SUM(upper_bound),2), ''N2'') AS Value,
        1 AS VisId,
        ''line'' AS VisType,
        ''Upper Range Forecast'' AS LegendLabel
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

    UNION ALL

    SELECT
        FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
        FORMAT(ROUND(SUM(forecasted_quantity),2), ''N2'') AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Mid Range Forecast'' AS LegendLabel
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

    UNION ALL

    SELECT
        FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
        FORMAT(ROUND(SUM(lower_bound),2), ''N2'') AS Value,
        3 AS VisId,
        ''line'' AS VisType,
        ''Lower Range Forecast'' AS LegendLabel
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date
    
    ) SUB',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "forecast_date",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Forecast Date",
        "YAxisLabel": "Net Sales Forecast",
        "Title": "Net Sales Forecast",
        "Description": ""
      }
    }
  ]
}',
    N'SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
        FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
        FORMAT(ROUND(SUM(upper_bound),2), ''N2'') AS Value,
        1 AS VisId,
        ''line'' AS VisType,
        ''Upper Range Forecast'' AS LegendLabel
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

    UNION ALL

    SELECT
        FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
        FORMAT(ROUND(SUM(forecasted_quantity),2), ''N2'') AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Mid Range Forecast'' AS LegendLabel
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

    UNION ALL

    SELECT
        FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
        FORMAT(ROUND(SUM(lower_bound),2), ''N2'') AS Value,
        3 AS VisId,
        ''line'' AS VisType,
        ''Lower Range Forecast'' AS LegendLabel
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date
    
    ) SUB
) INPUTQUERY

SELECT
    ''Forecast Date'' AS [XAxisLabel]
    ,    ''Net Sales Forecast'' AS [YAxisLabel]
    ,    ''Net Sales Forecast'' AS [Title]
    ,    NULL AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- MultiLineChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ForecastDailyRevenue',
    N'MultiLineChartCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,Curve
	,Stack
	,Area
	,StackOrder
	,ShowMark
	,LegendLabel
FROM
(
SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(ROUND(SUM(upper_bound),2), ''N2'') AS Value,
	1 AS VisId,
	''natural'' AS Curve,
	''upper'' AS Stack,
	''false'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Upper Range'' AS LegendLabel
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

UNION ALL

SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(ROUND(SUM(forecasted_quantity),2), ''N2'') AS Value,
	2 AS VisId,
	''natural'' AS Curve,
	''mid'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''true'' AS ShowMark,
	''Mid Range'' AS LegendLabel
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

UNION ALL

SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(ROUND(SUM(lower_bound),2), ''N2'') AS Value,
	3 AS VisId,
	''natural'' AS Curve,
	''lower'' AS Stack,
	''false'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Lower Range'' AS LegendLabel
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date
 
 ) SUB
 
 
SELECT
''Forecast Date'' AS XAxisLabel,
''Net Sales Forecast'' AS YAxisLabel,
''Net Sales Forecast'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	FORMAT(ROUND(SUM(forecasted_quantity),2), ''N2'') AS Value
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause) AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "forecast_date",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,Curve
	,Stack
	,Area
	,StackOrder
	,ShowMark
	,LegendLabel
FROM
(
SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(ROUND(SUM(upper_bound),2), ''N2'') AS Value,
	1 AS VisId,
	''natural'' AS Curve,
	''upper'' AS Stack,
	''false'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Upper Range'' AS LegendLabel
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

UNION ALL

SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(ROUND(SUM(forecasted_quantity),2), ''N2'') AS Value,
	2 AS VisId,
	''natural'' AS Curve,
	''mid'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''true'' AS ShowMark,
	''Mid Range'' AS LegendLabel
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date

UNION ALL

SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(ROUND(SUM(lower_bound),2), ''N2'') AS Value,
	3 AS VisId,
	''natural'' AS Curve,
	''lower'' AS Stack,
	''false'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Lower Range'' AS LegendLabel
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date
 
 ) SUB
 
 
SELECT
''Forecast Date'' AS XAxisLabel,
''Net Sales Forecast'' AS YAxisLabel,
''Net Sales Forecast'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	FORMAT(ROUND(SUM(forecasted_quantity),2), ''N2'') AS Value
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_total_revenue''
    AND R.product_category = ''TOTAL_DAILY''
    @FilterClause) AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ForecastProductQuantity
-- ============================================
-- MultiLineChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ForecastProductQuantity',
    N'MultiLineChartCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,Curve
	,Stack
	,Area
	,StackOrder
	,ShowMark
	,LegendLabel
FROM
(
SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(
        ROUND(
            SUM(forecasted_quantity) * 100.0 / 
            SUM(SUM(forecasted_quantity)) OVER (PARTITION BY forecast_date)
        , 1)
    , ''N1'') AS Value,
    
	 DENSE_RANK() OVER (ORDER BY R.product_category) AS VisId,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	R.product_category AS LegendLabel

   FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date,R.product_category

) SUB
 
 
SELECT
''Forecast Date'' AS XAxisLabel,
''Net Sales Forecast'' AS YAxisLabel,
''Net Sales Forecast'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
        FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'')
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause
) AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "forecast_date",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,Curve
	,Stack
	,Area
	,StackOrder
	,ShowMark
	,LegendLabel
FROM
(
SELECT
	FORMAT(forecast_date, ''dd MMM yyyy'') AS XAxisLabel,
	FORMAT(
        ROUND(
            SUM(forecasted_quantity) * 100.0 / 
            SUM(SUM(forecasted_quantity)) OVER (PARTITION BY forecast_date)
        , 1)
    , ''N1'') AS Value,
    
	 DENSE_RANK() OVER (ORDER BY R.product_category) AS VisId,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	R.product_category AS LegendLabel

   FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date,R.product_category

) SUB
 
 
SELECT
''Forecast Date'' AS XAxisLabel,
''Net Sales Forecast'' AS YAxisLabel,
''Net Sales Forecast'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
        FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'')
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause
) AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ForecastProductQuantity',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
	R.product_category AS Label,
	FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'') AS Value,
	R.product_category AS Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Forecast Quantity'' AS LegendLabel
	--SELECT TOP 1000 *
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause

    GROUP BY R.product_category

 
SELECT
''Product Mix Forecast'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'') AS Value
	
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause
) AS PiePrimaryText,
''Product Quantity'' AS PieSecondaryText',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "forecast_date",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
	R.product_category AS Label,
	FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'') AS Value,
	R.product_category AS Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Forecast Quantity'' AS LegendLabel
	--SELECT TOP 1000 *
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause

    GROUP BY R.product_category

 
SELECT
''Product Mix Forecast'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'') AS Value
	
FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause
) AS PiePrimaryText,
''Product Quantity'' AS PieSecondaryText',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ForecastProductQuantity',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'select 

xAxisLabel,
ROW_NUMBER() OVER(ORDER BY xAxisLabel) AS LabelSort,
[Value],
ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
VisId,
Stack


from (
SELECT
        forecast_date AS XAxisLabel,
        FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'') AS Value,
        R.product_category AS VisId,
        ''A'' AS Stack
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date,R.product_category

) sub 



SELECT
''Forecast Date'' AS XAxisLabel,
''Forecast Quantity'' AS YAxisLabel,
''Product Forecast Mix (Quantity)'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
        FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'')
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause
) AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "forecast_date",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'select 

xAxisLabel,
ROW_NUMBER() OVER(ORDER BY xAxisLabel) AS LabelSort,
[Value],
ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
VisId,
Stack


from (
SELECT
        forecast_date AS XAxisLabel,
        FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'') AS Value,
        R.product_category AS VisId,
        ''A'' AS Stack
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause

    GROUP BY forecast_date,R.product_category

) sub 



SELECT
''Forecast Date'' AS XAxisLabel,
''Forecast Quantity'' AS YAxisLabel,
''Product Forecast Mix (Quantity)'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
        FORMAT(ROUND(SUM(forecasted_quantity),0), ''N0'')
    FROM
        [core].[ForecastResults] R

    INNER JOIN
        [core].[ForecastModels] F
    ON R.model_id = F.model_id

    INNER JOIN
        [presentation].[D_LOCATION] LOC
    ON R.location_hub_id = LOC.BOTTOM_HUB_ID

    WHERE F.model_type = ''gb_quantity''
    AND R.product_category != ''TOTAL_DAILY''
    @FilterClause
) AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: GrossATV
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'GrossATV',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Average Gross Transaction Value'' AS Title,
    FORMAT(ROUND(SUM(GROSS_VALUE)/SUM(ORDER_COUNT), 2), ''N2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Average Gross Transaction Value'' AS Title,
    FORMAT(ROUND(SUM(GROSS_VALUE)/SUM(ORDER_COUNT), 2), ''N2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- StatCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'GrossATV',
    N'StatCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
FROM
(
SELECT
    C.[DATE] AS XAxisLabel,
    FORMAT(ROUND(SUM(GROSS_VALUE)/SUM(ORDER_COUNT), 2), ''N2'') AS Value,
	1 AS VisId,
	''A'' AS Stack
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''

    GROUP BY C.[DATE]

) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''ATV'' AS YAxisLabel,
''Average Gross Transaction Value'' AS Title,
NULL AS Interval,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(GROSS_VALUE)/SUM(ORDER_COUNT), 2), ''N2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''
) AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
FROM
(
SELECT
    C.[DATE] AS XAxisLabel,
    FORMAT(ROUND(SUM(GROSS_VALUE)/SUM(ORDER_COUNT), 2), ''N2'') AS Value,
	1 AS VisId,
	''A'' AS Stack
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''

    GROUP BY C.[DATE]

) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''ATV'' AS YAxisLabel,
''Average Gross Transaction Value'' AS Title,
NULL AS Interval,
NULL AS Trend,
NULL AS Chip,
(SELECT
    FORMAT(ROUND(SUM(GROSS_VALUE)/SUM(ORDER_COUNT), 2), ''N2'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''
) AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: GrossDiscount
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'GrossDiscount',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Discount Gross Total'' AS Title,
    FORMAT(ROUND(SUM(GROSS_VALUE), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND discount.[BOTTOM_DISCOUNT_NAME] != ''Unknown''',
    N'{
  "LocationList": "",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Discount Gross Total'' AS Title,
    FORMAT(ROUND(SUM(GROSS_VALUE), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND discount.[BOTTOM_DISCOUNT_NAME] != ''Unknown''',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Integrations
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Integrations',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
    i.[IntegrationDisplayName],
    i.[SchemaName],
    1 AS BOTTOM_LEVEL,
    NULL AS PARENT_ID
FROM sys.schemas s
INNER JOIN [core].[core].[Integrations] i
    ON s.name = i.[SchemaName]',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "IntegrationDisplayName",
    "ID": "SchemaName",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Integration Sources"
      }
    }
  ]
}',
    N'SELECT
    [IntegrationDisplayName] AS [Label]
    ,    [SchemaName] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
    i.[IntegrationDisplayName],
    i.[SchemaName],
    1 AS BOTTOM_LEVEL,
    NULL AS PARENT_ID
FROM sys.schemas s
INNER JOIN [core].[core].[Integrations] i
    ON s.name = i.[SchemaName]
) INPUTQUERY

SELECT
    ''Integration Sources'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvActMargin
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvActMargin',
    N'PieChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS THEO_COST_PERC
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( (SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) / 10) / SUM(ISNULL(FS.NET_SALES,0)) * 100,2)
            END, ''N0'') AS ACTUAL_COST_PERC
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST
    ,SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) AS THEO_COST
    ,SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) / 10 AS ACTUAL_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(


SELECT
    ''Actual Costs'' AS Label
    ,ACTUAL_COST_PERC AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Actual Margin'' AS Label
    ,100 - (ACTUAL_COST_PERC) AS Value
    ,1 AS Id
FROM
    BASE

) SUB

 
SELECT
''Actual Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 - (FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( (SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) /10)/ SUM(ISNULL(FS.NET_SALES,0)) * 100.00,2)
            END, ''N0'')) AS ACTUAL_COST_PERC

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause

) AS PiePrimaryText,
''Actual Margin'' AS PieSecondaryText',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS THEO_COST_PERC
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( (SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) / 10) / SUM(ISNULL(FS.NET_SALES,0)) * 100,2)
            END, ''N0'') AS ACTUAL_COST_PERC
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST
    ,SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) AS THEO_COST
    ,SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) / 10 AS ACTUAL_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(


SELECT
    ''Actual Costs'' AS Label
    ,ACTUAL_COST_PERC AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Actual Margin'' AS Label
    ,100 - (ACTUAL_COST_PERC) AS Value
    ,1 AS Id
FROM
    BASE

) SUB

 
SELECT
''Actual Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 - (FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( (SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) /10)/ SUM(ISNULL(FS.NET_SALES,0)) * 100.00,2)
            END, ''N0'')) AS ACTUAL_COST_PERC

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause

) AS PiePrimaryText,
''Actual Margin'' AS PieSecondaryText',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvCountData
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvCountData',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVITEM
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
)
SELECT
LOCATION_NAME AS Column1,
INVITEM AS Column2,
COUNT_FREQUENCY AS Column3,
COUNT_RECENCY AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Counts


SELECT
    ''Inventory Item Count Information'' AS [Title]
    ,    ''Count Frequency and Recency'' AS [Description]
    ,    ''Location'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Inventory Item'' AS [Label2]
    ,    ''TEXT'' AS [Type2]
    ,    ''Count Frequency'' AS [Label3]
    ,    ''DECIMAL'' AS [Type3]
    ,    ''Count Recency'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    NULL AS [Label5]
    ,    NULL AS [Type5]
    ,    NULL AS [Label6]
    ,    NULL AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVITEM
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
)
SELECT
LOCATION_NAME AS Column1,
INVITEM AS Column2,
COUNT_FREQUENCY AS Column3,
COUNT_RECENCY AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Counts


SELECT
    ''Inventory Item Count Information'' AS [Title]
    ,    ''Count Frequency and Recency'' AS [Description]
    ,    ''Location'' AS [Label1]
    ,    ''TEXT'' AS [Type1]
    ,    ''Inventory Item'' AS [Label2]
    ,    ''TEXT'' AS [Type2]
    ,    ''Count Frequency'' AS [Label3]
    ,    ''DECIMAL'' AS [Type3]
    ,    ''Count Recency'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    NULL AS [Label5]
    ,    NULL AS [Type5]
    ,    NULL AS [Label6]
    ,    NULL AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvItems
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvItems',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_INVITEM_NAME]) AS [INVITEM_NAME]
	,COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_INVITEM_NAME]) AS [INVITEM_ID]
	,COALESCE([MIDDLE_1_MICROSERVICE_NAME],[MIDDLE_1_NAME]) AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [presentation].[D_INVITEM]

UNION ALL

SELECT DISTINCT
	COALESCE([MIDDLE_1_MICROSERVICE_NAME],[MIDDLE_1_NAME]) AS [INVITEM_NAME]
	,COALESCE([MIDDLE_1_MICROSERVICE_NAME],[MIDDLE_1_NAME]) AS [INVITEM_ID]
	,COALESCE([TOP_MICROSERVICE_NAME],[TOP_NAME]) AS [PARENT_ID]
	,0 AS [BOTTOM_LEVEL]
FROM [presentation].[D_INVITEM]


UNION ALL



SELECT DISTINCT

	COALESCE([TOP_MICROSERVICE_NAME],[TOP_NAME]) AS [INVITEM_NAME]

	,COALESCE([TOP_MICROSERVICE_NAME],[TOP_NAME]) AS [INVITEM_ID]

	,NULL AS [PARENT_ID]

	,0 AS [BOTTOM_LEVEL]

FROM [presentation].[D_INVITEM]',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "INVITEM_NAME",
    "ID": "INVITEM_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Inventory Items"
      }
    }
  ]
}',
    N'SELECT
    [INVITEM_NAME] AS [Label]
    ,    [INVITEM_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_INVITEM_NAME]) AS [INVITEM_NAME]
	,COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_INVITEM_NAME]) AS [INVITEM_ID]
	,COALESCE([MIDDLE_1_MICROSERVICE_NAME],[MIDDLE_1_NAME]) AS [PARENT_ID]
	,1 AS [BOTTOM_LEVEL]
FROM [presentation].[D_INVITEM]

UNION ALL

SELECT DISTINCT
	COALESCE([MIDDLE_1_MICROSERVICE_NAME],[MIDDLE_1_NAME]) AS [INVITEM_NAME]
	,COALESCE([MIDDLE_1_MICROSERVICE_NAME],[MIDDLE_1_NAME]) AS [INVITEM_ID]
	,COALESCE([TOP_MICROSERVICE_NAME],[TOP_NAME]) AS [PARENT_ID]
	,0 AS [BOTTOM_LEVEL]
FROM [presentation].[D_INVITEM]


UNION ALL



SELECT DISTINCT

	COALESCE([TOP_MICROSERVICE_NAME],[TOP_NAME]) AS [INVITEM_NAME]

	,COALESCE([TOP_MICROSERVICE_NAME],[TOP_NAME]) AS [INVITEM_ID]

	,NULL AS [PARENT_ID]

	,0 AS [BOTTOM_LEVEL]

FROM [presentation].[D_INVITEM]
) INPUTQUERY

SELECT
    ''Inventory Items'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvKPIGrouped
-- ============================================
-- CustomGroupedDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvKPIGrouped',
    N'CustomGroupedDataGrid',
    1,
    N'LIVE',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
),

Base AS
(
  SELECT
    LOCATION_NAME
    ,REPLACE(INVENTORY_ITEM_TOP,'''''''','''') AS INVENTORY_ITEM_TOP
    ,REPLACE(INVENTORY_ITEM_MIDDLE,'''''''','''') AS INVENTORY_ITEM_MIDDLE
    ,REPLACE(INVENTORY_ITEM,'''''''','''') AS INVENTORY_ITEM
    ,NET_SALES AS NET_SALES
    ,ABS(SALES_COST) AS RECIPE_COST
    ,ABS(WASTE_COST) AS WASTE_COST
    ,NEGATIVE_VARIANCE_COST AS VARIANCE_COST
    ,CASE WHEN NET_SALES !=0 THEN NEGATIVE_VARIANCE_COST / NET_SALES ELSE 0 END AS VARIANCE_COST_PERC
    ,CASE WHEN SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL
    ,CASE WHEN SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL_SALES
  FROM
    (
    SELECT 
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS INVENTORY_ITEM_TOP
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS INVENTORY_ITEM_MIDDLE
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVENTORY_ITEM
        ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
        ,SUM(ISNULL(FU.SALE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS SALES_COST
        ,SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS WASTE_COST
        ,SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0)) AS ORDER_VALUE_IN
        ,MAX(ISNULL(FC.THEO_QTY,0) * ISNULL(FU.UOM_COST,0)) AS STOCK_ON_HAND_AT_COUNT_VALUE
        ,SUM(CASE WHEN FU.COUNT_DATE > ISNULL(FC.COUNT_DATE,''1900-01-01'') THEN ISNULL(FU.THEO_USAGE,0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS THEO_STOCK_ON_HAND_VALUE
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_OUT
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) > 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) < 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_OUT
        ,MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS(MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    LEFT OUTER JOIN
        Counts FC
    ON FC.[LOCATION_HUB_ID] = FU.[LOCATION_HUB_ID]
    AND FC.[INVITEM_HUB_ID] = FU.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause

    GROUP BY
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME])
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
)SELECT
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_MIDDLE) AS ParentId,
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM) AS Id,
INVENTORY_ITEM AS GroupedColumn,
NET_SALES AS Column1,
RECIPE_COST AS Column2,
WASTE_COST AS Column3,
VARIANCE_COST AS Column4,
VARIANCE_COST_PERC AS Column5,
VARIANCE_COST_PERC_OF_TOTAL AS Column6,
VARIANCE_COST_PERC_OF_TOTAL_SALES AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base

UNION ALL

SELECT
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP) AS ParentId,
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_MIDDLE) AS Id,
INVENTORY_ITEM_MIDDLE AS GroupedColumn,
SUM(NET_SALES) AS Column1,
SUM(RECIPE_COST) AS Column2,
SUM(WASTE_COST) AS Column3,
SUM(VARIANCE_COST) AS Column4,
SUM(CASE WHEN NET_SALES !=0 THEN VARIANCE_COST / NET_SALES ELSE 0 END) AS Column5,
SUM(VARIANCE_COST_PERC_OF_TOTAL) AS Column6,
SUM(VARIANCE_COST_PERC_OF_TOTAL_SALES) AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base
GROUP BY
    CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP),
    CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_MIDDLE),
    INVENTORY_ITEM_MIDDLE

UNION ALL

SELECT
LOCATION_NAME AS ParentId,
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP) AS Id,
INVENTORY_ITEM_TOP AS GroupedColumn,
SUM(NET_SALES) AS Column1,
SUM(RECIPE_COST) AS Column2,
SUM(WASTE_COST) AS Column3,
SUM(VARIANCE_COST) AS Column4,
SUM(CASE WHEN NET_SALES !=0 THEN VARIANCE_COST / NET_SALES ELSE 0 END) AS Column5,
SUM(VARIANCE_COST_PERC_OF_TOTAL) AS Column6,
SUM(VARIANCE_COST_PERC_OF_TOTAL_SALES) AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base
GROUP BY
    LOCATION_NAME,
    CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP),
    INVENTORY_ITEM_TOP

UNION ALL

SELECT
NULL AS ParentId,
LOCATION_NAME AS Id,
LOCATION_NAME AS GroupedColumn,
SUM(NET_SALES) AS Column1,
SUM(RECIPE_COST) AS Column2,
SUM(WASTE_COST) AS Column3,
SUM(VARIANCE_COST) AS Column4,
SUM(CASE WHEN NET_SALES !=0 THEN VARIANCE_COST / NET_SALES ELSE 0 END) AS Column5,
SUM(VARIANCE_COST_PERC_OF_TOTAL) AS Column6,
SUM(VARIANCE_COST_PERC_OF_TOTAL_SALES) AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base
GROUP BY
    LOCATION_NAME',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "ParentId": "ParentId",
    "Id": "Id",
    "GroupedColumn": "GroupedColumn",
    "Column1": "Column1",
    "Column2": "Column2",
    "Column3": "Column3",
    "Column4": "Column4",
    "Column5": "Column5",
    "Column6": "Column6",
    "Column7": "Column7",
    "Column8": "",
    "Column9": "",
    "Column10": "",
    "Column11": "",
    "Column12": "",
    "Column13": "",
    "Column14": "",
    "Column15": "",
    "Column16": "",
    "Column17": "",
    "Column18": "",
    "Column19": "",
    "Column20": "",
    "Column21": "",
    "Column22": "",
    "Column23": "",
    "Column24": "",
    "Column25": "",
    "Column26": "",
    "Column27": "",
    "Column28": "",
    "Column29": ""
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "GroupedLabel",
        "GroupedType",
        "Label1",
        "Type1",
        "Label2",
        "Type2",
        "Label3",
        "Type3",
        "Label4",
        "Type4",
        "Label5",
        "Type5",
        "Label6",
        "Type6",
        "Label7",
        "Type7",
        "Label8",
        "Type8",
        "Label9",
        "Type9",
        "Label10",
        "Type10",
        "Label11",
        "Type11",
        "Label12",
        "Type12",
        "Label13",
        "Type13",
        "Label14",
        "Type14",
        "Label15",
        "Type15",
        "Label16",
        "Type16",
        "Label17",
        "Type17",
        "Label18",
        "Type18",
        "Label19",
        "Type19",
        "Label20",
        "Type20",
        "Label21",
        "Type11",
        "Label22",
        "Type22",
        "Label23",
        "Type23",
        "Label24",
        "Type24",
        "Label25",
        "Type25",
        "Label26",
        "Type26",
        "Label27",
        "Type27",
        "Label28",
        "Type28",
        "Label29",
        "Type29"
      ],
      "values": {
        "Title": "Inventory KPIs",
        "Description": "",
        "GroupedLabel": "",
        "GroupedType": "TEXT",
        "Label1": "Net Sales",
        "Type1": "DECIMAL",
        "Label2": "Recipe Cost",
        "Type2": "DECIMAL",
        "Label3": "Waste Cost",
        "Type3": "DECIMAL",
        "Label4": "Variance Cost",
        "Type4": "DECIMAL",
        "Label5": "Variance %",
        "Type5": "PERCENT",
        "Label6": "Variance % of Total",
        "Type6": "PERCENT",
        "Label7": "Variance % of Total Sales",
        "Type7": "PERCENT",
        "Label8": "",
        "Type8": "",
        "Label9": "",
        "Type9": "",
        "Label10": "",
        "Type10": "",
        "Label11": "",
        "Type11": "",
        "Label12": "",
        "Type12": "",
        "Label13": "",
        "Type13": "",
        "Label14": "",
        "Type14": "",
        "Label15": "",
        "Type15": "",
        "Label16": "",
        "Type16": "",
        "Label17": "",
        "Type17": "",
        "Label18": "",
        "Type18": "",
        "Label19": "",
        "Type19": "",
        "Label20": "",
        "Type20": "",
        "Label21": "",
        "Label22": "",
        "Type22": "",
        "Label23": "",
        "Type23": "",
        "Label24": "",
        "Type24": "",
        "Label25": "",
        "Type25": "",
        "Label26": "",
        "Type26": "",
        "Label27": "",
        "Type27": "",
        "Label28": "",
        "Type28": "",
        "Label29": "",
        "Type29": ""
      }
    }
  ]
}',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
),

Base AS
(
  SELECT
    LOCATION_NAME
    ,REPLACE(INVENTORY_ITEM_TOP,'''''''','''') AS INVENTORY_ITEM_TOP
    ,REPLACE(INVENTORY_ITEM_MIDDLE,'''''''','''') AS INVENTORY_ITEM_MIDDLE
    ,REPLACE(INVENTORY_ITEM,'''''''','''') AS INVENTORY_ITEM
    ,NET_SALES AS NET_SALES
    ,ABS(SALES_COST) AS RECIPE_COST
    ,ABS(WASTE_COST) AS WASTE_COST
    ,NEGATIVE_VARIANCE_COST AS VARIANCE_COST
    ,CASE WHEN NET_SALES !=0 THEN NEGATIVE_VARIANCE_COST / NET_SALES ELSE 0 END AS VARIANCE_COST_PERC
    ,CASE WHEN SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL
    ,CASE WHEN SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL_SALES
  FROM
    (
    SELECT 
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS INVENTORY_ITEM_TOP
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS INVENTORY_ITEM_MIDDLE
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVENTORY_ITEM
        ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
        ,SUM(ISNULL(FU.SALE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS SALES_COST
        ,SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS WASTE_COST
        ,SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0)) AS ORDER_VALUE_IN
        ,MAX(ISNULL(FC.THEO_QTY,0) * ISNULL(FU.UOM_COST,0)) AS STOCK_ON_HAND_AT_COUNT_VALUE
        ,SUM(CASE WHEN FU.COUNT_DATE > ISNULL(FC.COUNT_DATE,''1900-01-01'') THEN ISNULL(FU.THEO_USAGE,0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS THEO_STOCK_ON_HAND_VALUE
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_OUT
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) > 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) < 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_OUT
        ,MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS(MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    LEFT OUTER JOIN
        Counts FC
    ON FC.[LOCATION_HUB_ID] = FU.[LOCATION_HUB_ID]
    AND FC.[INVITEM_HUB_ID] = FU.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause

    GROUP BY
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME])
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
)SELECT
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_MIDDLE) AS ParentId,
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM) AS Id,
INVENTORY_ITEM AS GroupedColumn,
NET_SALES AS Column1,
RECIPE_COST AS Column2,
WASTE_COST AS Column3,
VARIANCE_COST AS Column4,
VARIANCE_COST_PERC AS Column5,
VARIANCE_COST_PERC_OF_TOTAL AS Column6,
VARIANCE_COST_PERC_OF_TOTAL_SALES AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base

UNION ALL
SELECT
    [ParentId] AS [ParentId]
    ,    [Id] AS [Id]
    ,    [GroupedColumn] AS [GroupedColumn]
    ,    [Column1] AS [Column1]
    ,    [Column2] AS [Column2]
    ,    [Column3] AS [Column3]
    ,    [Column4] AS [Column4]
    ,    [Column5] AS [Column5]
    ,    [Column6] AS [Column6]
    ,    [Column7] AS [Column7]
FROM
(
SELECT
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP) AS ParentId,
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_MIDDLE) AS Id,
INVENTORY_ITEM_MIDDLE AS GroupedColumn,
SUM(NET_SALES) AS Column1,
SUM(RECIPE_COST) AS Column2,
SUM(WASTE_COST) AS Column3,
SUM(VARIANCE_COST) AS Column4,
SUM(CASE WHEN NET_SALES !=0 THEN VARIANCE_COST / NET_SALES ELSE 0 END) AS Column5,
SUM(VARIANCE_COST_PERC_OF_TOTAL) AS Column6,
SUM(VARIANCE_COST_PERC_OF_TOTAL_SALES) AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base
GROUP BY
    CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP),
    CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_MIDDLE),
    INVENTORY_ITEM_MIDDLE

UNION ALL

SELECT
LOCATION_NAME AS ParentId,
CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP) AS Id,
INVENTORY_ITEM_TOP AS GroupedColumn,
SUM(NET_SALES) AS Column1,
SUM(RECIPE_COST) AS Column2,
SUM(WASTE_COST) AS Column3,
SUM(VARIANCE_COST) AS Column4,
SUM(CASE WHEN NET_SALES !=0 THEN VARIANCE_COST / NET_SALES ELSE 0 END) AS Column5,
SUM(VARIANCE_COST_PERC_OF_TOTAL) AS Column6,
SUM(VARIANCE_COST_PERC_OF_TOTAL_SALES) AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base
GROUP BY
    LOCATION_NAME,
    CONCAT_WS(''-'',LOCATION_NAME,INVENTORY_ITEM_TOP),
    INVENTORY_ITEM_TOP

UNION ALL

SELECT
NULL AS ParentId,
LOCATION_NAME AS Id,
LOCATION_NAME AS GroupedColumn,
SUM(NET_SALES) AS Column1,
SUM(RECIPE_COST) AS Column2,
SUM(WASTE_COST) AS Column3,
SUM(VARIANCE_COST) AS Column4,
SUM(CASE WHEN NET_SALES !=0 THEN VARIANCE_COST / NET_SALES ELSE 0 END) AS Column5,
SUM(VARIANCE_COST_PERC_OF_TOTAL) AS Column6,
SUM(VARIANCE_COST_PERC_OF_TOTAL_SALES) AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM
    Base
GROUP BY
    LOCATION_NAME
) INPUTQUERY

SELECT
    ''Inventory KPIs'' AS [Title]
    ,    NULL AS [Description]
    ,    NULL AS [GroupedLabel]
    ,    ''TEXT'' AS [GroupedType]
    ,    ''Net Sales'' AS [Label1]
    ,    ''DECIMAL'' AS [Type1]
    ,    ''Recipe Cost'' AS [Label2]
    ,    ''DECIMAL'' AS [Type2]
    ,    ''Waste Cost'' AS [Label3]
    ,    ''DECIMAL'' AS [Type3]
    ,    ''Variance Cost'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''Variance %'' AS [Label5]
    ,    ''PERCENT'' AS [Type5]
    ,    ''Variance % of Total'' AS [Label6]
    ,    ''PERCENT'' AS [Type6]
    ,    ''Variance % of Total Sales'' AS [Label7]
    ,    ''PERCENT'' AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvNegVar
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvNegVar',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Negative Variance'' AS Title
    ,FORMAT(SUM(NEGATIVE_VARIANCE_COST),''N0'') AS Value
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS((CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Negative Variance'' AS Title
    ,FORMAT(SUM(NEGATIVE_VARIANCE_COST),''N0'') AS Value
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS((CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvNetSales
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvNetSales',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT 
    ''Net Sales'' AS Title,    FORMAT(SUM(ISNULL(FS.NET_SALES,0)),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT 
    ''Net Sales'' AS Title,    FORMAT(SUM(ISNULL(FS.NET_SALES,0)),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvOrdersCost
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvOrdersCost',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT 
    ''Orders Cost'' AS Title,    FORMAT(ABS(SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT 
    ''Orders Cost'' AS Title,    FORMAT(ABS(SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvPosVar
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvPosVar',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Positive Variance'' AS Title
    ,FORMAT(SUM(POSITIVE_VARIANCE_COST),''N0'') AS Value
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS((CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Positive Variance'' AS Title
    ,FORMAT(SUM(POSITIVE_VARIANCE_COST),''N0'') AS Value
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS((CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvProdEventCost
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvProdEventCost',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT 
    ''Production Cost'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT 
    ''Production Cost'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvProdEventValue
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvProdEventValue',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT 
    ''Production Value'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT 
    ''Production Value'' AS Title,    FORMAT(ABS(SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvRecipeMargin
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvRecipeMargin',
    N'PieChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS THEO_COST_PERC
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS ACTUAL_COST_PERC
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST
    ,SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) AS THEO_COST
    ,SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) AS ACTUAL_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(


SELECT
    ''Recipe Costs'' AS Label
    ,RECIPE_COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Recipe Margin'' AS Label
    ,100 - RECIPE_COST AS Value
    ,1 AS Id
FROM
    BASE

) SUB

 
SELECT
''Recipe Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 -FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause

) AS PiePrimaryText,
''Recipe Margin'' AS PieSecondaryText',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Base AS
(
SELECT
    FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS THEO_COST_PERC
    ,FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS ACTUAL_COST_PERC
    ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
    ,SUM(ISNULL(FS.SALES_RECIPE_COST,0)) AS SALES_COST
    ,SUM(ISNULL(FS.THEO_USAGE,0) * ISNULL(FS.UOM_COST,0)) AS THEO_COST
    ,SUM(ISNULL(FS.ACTUAL_USAGE,0) * ISNULL(FS.UOM_COST,0)) AS ACTUAL_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(


SELECT
    ''Recipe Costs'' AS Label
    ,RECIPE_COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Recipe Margin'' AS Label
    ,100 - RECIPE_COST AS Value
    ,1 AS Id
FROM
    BASE

) SUB

 
SELECT
''Recipe Margin'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
    100 -FORMAT(CASE WHEN SUM(ISNULL(FS.NET_SALES,0)) = 0 THEN 0 
            ELSE ROUND( SUM(ISNULL(FS.SALES_RECIPE_COST,0)) / SUM(ISNULL(FS.NET_SALES,0)) * 100,0)
            END, ''N0'') AS RECIPE_COST

FROM
    [presentation].[F_INV_SALES_DAY] FS

INNER JOIN
    [presentation].[CALENDAR] C
ON FS.[REPORTING_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_LOCATION] location
    ON FS.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_INVITEM] invitem
    ON FS.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause

) AS PiePrimaryText,
''Recipe Margin'' AS PieSecondaryText',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvTheoMargin
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvTheoMargin',
    N'PieChartCard',
    1,
    N'LIVE',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS((CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
),

Base AS
(
  SELECT
     NET_SALES AS NET_SALES
    ,ROUND( ABS(SALES_COST),2) AS RECIPE_COST
    ,ROUND( ABS(WASTE_COST),2) AS WASTE_COST
    ,VARIANCE_COST
  FROM
    (
    SELECT 
        SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
        ,SUM(ISNULL(FU.SALE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS SALES_COST
        ,SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS WASTE_COST
        ,SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0)) AS ORDER_VALUE_IN
        ,MAX(ISNULL(FC.THEO_QTY,0) * ISNULL(FU.UOM_COST,0)) AS STOCK_ON_HAND_AT_COUNT_VALUE
        ,SUM(CASE WHEN FU.COUNT_DATE > ISNULL(FC.COUNT_DATE,''1900-01-01'') THEN ISNULL(FU.THEO_USAGE,0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS THEO_STOCK_ON_HAND_VALUE
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_OUT
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) > 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) < 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_OUT
        ,MAX(FC.POSITIVE_VARIANCE_COST) - MAX(NEGATIVE_VARIANCE_COST) AS VARIANCE_COST
    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    LEFT OUTER JOIN
        Counts FC
    ON FC.[LOCATION_HUB_ID] = FU.[LOCATION_HUB_ID]
    AND FC.[INVITEM_HUB_ID] = FU.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause
    ) SUB
)

SELECT

	Label,

	Value,

	Id,

	''linear'' AS Curve,

	''total'' AS Stack,

	''true'' AS Area,

	''ascending'' AS StackOrder,

	''false'' AS ShowMark,

	''Percent'' AS LegendLabel

FROM

(


SELECT

    ''Profit Margin'' AS Label

    ,FORMAT(NET_SALES - RECIPE_COST - WASTE_COST - VARIANCE_COST, ''N0'') AS Value

    ,1 AS Id

FROM

    BASE

UNION ALL


SELECT

    ''Recipe Costs'' AS Label

    ,FORMAT(RECIPE_COST, ''N0'') AS Value

    ,2 AS Id

FROM

    BASE

UNION ALL


SELECT

    ''Waste Costs'' AS Label

    ,FORMAT(WASTE_COST, ''N0'') AS Value

    ,3 AS Id

FROM

    BASE

UNION ALL


SELECT

    ''Variance Costs'' AS Label

    ,FORMAT(VARIANCE_COST, ''N0'') AS Value

    ,4 AS Id

FROM

    BASE







) SUB



SELECT

''Margin Analysis'' AS Title,

'''' AS Description,

NULL AS Trend,

NULL AS Chip,

(
  SELECT 
        FORMAT(SUM(ISNULL(FS.NET_SALES,0)), ''N0'') AS NET_SALES

    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause


) AS PiePrimaryText,

''Net Sales'' AS PieSecondaryText',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
        ,(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS((CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FC.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
),

Base AS
(
  SELECT
     NET_SALES AS NET_SALES
    ,ROUND( ABS(SALES_COST),2) AS RECIPE_COST
    ,ROUND( ABS(WASTE_COST),2) AS WASTE_COST
    ,VARIANCE_COST
  FROM
    (
    SELECT 
        SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
        ,SUM(ISNULL(FU.SALE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS SALES_COST
        ,SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS WASTE_COST
        ,SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0)) AS ORDER_VALUE_IN
        ,MAX(ISNULL(FC.THEO_QTY,0) * ISNULL(FU.UOM_COST,0)) AS STOCK_ON_HAND_AT_COUNT_VALUE
        ,SUM(CASE WHEN FU.COUNT_DATE > ISNULL(FC.COUNT_DATE,''1900-01-01'') THEN ISNULL(FU.THEO_USAGE,0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS THEO_STOCK_ON_HAND_VALUE
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_OUT
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) > 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) < 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_OUT
        ,MAX(FC.POSITIVE_VARIANCE_COST) - MAX(NEGATIVE_VARIANCE_COST) AS VARIANCE_COST
    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    LEFT OUTER JOIN
        Counts FC
    ON FC.[LOCATION_HUB_ID] = FU.[LOCATION_HUB_ID]
    AND FC.[INVITEM_HUB_ID] = FU.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause
    ) SUB
)

SELECT

	Label,

	Value,

	Id,

	''linear'' AS Curve,

	''total'' AS Stack,

	''true'' AS Area,

	''ascending'' AS StackOrder,

	''false'' AS ShowMark,

	''Percent'' AS LegendLabel

FROM

(


SELECT

    ''Profit Margin'' AS Label

    ,FORMAT(NET_SALES - RECIPE_COST - WASTE_COST - VARIANCE_COST, ''N0'') AS Value

    ,1 AS Id

FROM

    BASE

UNION ALL


SELECT

    ''Recipe Costs'' AS Label

    ,FORMAT(RECIPE_COST, ''N0'') AS Value

    ,2 AS Id

FROM

    BASE

UNION ALL


SELECT

    ''Waste Costs'' AS Label

    ,FORMAT(WASTE_COST, ''N0'') AS Value

    ,3 AS Id

FROM

    BASE

UNION ALL


SELECT

    ''Variance Costs'' AS Label

    ,FORMAT(VARIANCE_COST, ''N0'') AS Value

    ,4 AS Id

FROM

    BASE







) SUB



SELECT

''Margin Analysis'' AS Title,

'''' AS Description,

NULL AS Trend,

NULL AS Chip,

(
  SELECT 
        FORMAT(SUM(ISNULL(FS.NET_SALES,0)), ''N0'') AS NET_SALES

    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause


) AS PiePrimaryText,

''Net Sales'' AS PieSecondaryText',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvVariances
-- ============================================
-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvVariances',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
),

Base AS
(
  SELECT
    LOCATION_NAME
    ,REPLACE(INVENTORY_ITEM_TOP,'''''''','''') AS INVENTORY_ITEM_TOP
    ,REPLACE(INVENTORY_ITEM_MIDDLE,'''''''','''') AS INVENTORY_ITEM_MIDDLE
    ,REPLACE(INVENTORY_ITEM,'''''''','''') AS INVENTORY_ITEM
    ,NET_SALES AS NET_SALES
    ,ABS(SALES_COST) AS RECIPE_COST
    ,ABS(WASTE_COST) AS WASTE_COST
    ,NEGATIVE_VARIANCE_COST AS VARIANCE_COST
    ,POSITIVE_VARIANCE_COST
    ,NEGATIVE_VARIANCE_COST
    ,CASE WHEN NET_SALES !=0 THEN NEGATIVE_VARIANCE_COST / NET_SALES ELSE 0 END AS VARIANCE_COST_PERC
    ,CASE WHEN SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL
    ,CASE WHEN SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL_SALES
  FROM
    (
    SELECT 
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS INVENTORY_ITEM_TOP
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS INVENTORY_ITEM_MIDDLE
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVENTORY_ITEM
        ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
        ,SUM(ISNULL(FU.SALE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS SALES_COST
        ,SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS WASTE_COST
        ,SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0)) AS ORDER_VALUE_IN
        ,MAX(ISNULL(FC.THEO_QTY,0) * ISNULL(FU.UOM_COST,0)) AS STOCK_ON_HAND_AT_COUNT_VALUE
        ,SUM(CASE WHEN FU.COUNT_DATE > ISNULL(FC.COUNT_DATE,''1900-01-01'') THEN ISNULL(FU.THEO_USAGE,0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS THEO_STOCK_ON_HAND_VALUE
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_OUT
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) > 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) < 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_OUT
        ,MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS(MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    LEFT OUTER JOIN
        Counts FC
    ON FC.[LOCATION_HUB_ID] = FU.[LOCATION_HUB_ID]
    AND FC.[INVITEM_HUB_ID] = FU.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause

    GROUP BY
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME])
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
)
select 



LOCATION_NAME AS xAxisLabel,

ROW_NUMBER() OVER(ORDER BY LOCATION_NAME) AS LabelSort,

[Value],

ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,

Label AS VisId,

Stack

FROM



(

SELECT

    LOCATION_NAME

    ,''Positive Variance'' AS Label

    ,SUM(POSITIVE_VARIANCE_COST) AS Value

    ,''A'' AS Stack

FROM

    BASE
GROUP BY
    LOCATION_NAME


UNION ALL



SELECT

    LOCATION_NAME

    ,''Negative Variance'' AS Label

    ,SUM(NEGATIVE_VARIANCE_COST) AS Value

    ,''B'' AS Stack

FROM

    BASE
GROUP BY
    LOCATION_NAME

) SUB



 

SELECT

''Location'' AS XAxisLabel,

''Variances'' AS YAxisLabel,

''Inventory Variances'' AS Title,

NULL AS Description,

NULL AS Trend,

NULL AS Chip,

NULL AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Counts AS
(
SELECT
    SUB.*
    ,DATEDIFF(DAY,GETDATE(),[COUNT_DATE]) AS COUNT_RECENCY
FROM
    (
    SELECT
        FC.*
        ,AVG(FC.DAYS_SINCE_LAST_COUNT) OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID) AS COUNT_FREQUENCY
        ,ROW_NUMBER() OVER(PARTITION BY FC.LOCATION_HUB_ID, FC.INVITEM_HUB_ID ORDER BY FC.[COUNT_DATE] DESC) AS RN
    FROM
        [presentation].[F_INV_COUNTS_DAY] FC

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FC.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FC.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause
    ) SUB
WHERE RN = 1
),

Base AS
(
  SELECT
    LOCATION_NAME
    ,REPLACE(INVENTORY_ITEM_TOP,'''''''','''') AS INVENTORY_ITEM_TOP
    ,REPLACE(INVENTORY_ITEM_MIDDLE,'''''''','''') AS INVENTORY_ITEM_MIDDLE
    ,REPLACE(INVENTORY_ITEM,'''''''','''') AS INVENTORY_ITEM
    ,NET_SALES AS NET_SALES
    ,ABS(SALES_COST) AS RECIPE_COST
    ,ABS(WASTE_COST) AS WASTE_COST
    ,NEGATIVE_VARIANCE_COST AS VARIANCE_COST
    ,POSITIVE_VARIANCE_COST
    ,NEGATIVE_VARIANCE_COST
    ,CASE WHEN NET_SALES !=0 THEN NEGATIVE_VARIANCE_COST / NET_SALES ELSE 0 END AS VARIANCE_COST_PERC
    ,CASE WHEN SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NEGATIVE_VARIANCE_COST) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL
    ,CASE WHEN SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) !=0 THEN NEGATIVE_VARIANCE_COST / SUM(NET_SALES) OVER(PARTITION BY LOCATION_NAME) ELSE 0 END AS VARIANCE_COST_PERC_OF_TOTAL_SALES
  FROM
    (
    SELECT 
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS LOCATION_NAME
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME]) AS INVENTORY_ITEM_TOP
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME]) AS INVENTORY_ITEM_MIDDLE
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME]) AS INVENTORY_ITEM
        ,SUM(ISNULL(FS.NET_SALES,0)) AS NET_SALES
        ,SUM(ISNULL(FU.SALE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS SALES_COST
        ,SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0)) AS WASTE_COST
        ,SUM(ISNULL(FU.ORDER_QTY,0) * ISNULL(FU.UOM_COST,0)) AS ORDER_VALUE_IN
        ,MAX(ISNULL(FC.THEO_QTY,0) * ISNULL(FU.UOM_COST,0)) AS STOCK_ON_HAND_AT_COUNT_VALUE
        ,SUM(CASE WHEN FU.COUNT_DATE > ISNULL(FC.COUNT_DATE,''1900-01-01'') THEN ISNULL(FU.THEO_USAGE,0) * ISNULL(FU.UOM_COST,0) ELSE 0 END) AS THEO_STOCK_ON_HAND_VALUE
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) > 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.PRODUCTION_QTY,0) < 0 THEN FU.PRODUCTION_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS PRODUCTION_VALUE_OUT
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) > 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_IN
        ,SUM(CASE WHEN ISNULL(FU.TRANSFER_QTY,0) < 0 THEN FU.TRANSFER_QTY ELSE 0 END  * ISNULL(FU.UOM_COST,0)) AS TRANSFER_VALUE_OUT
        ,MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) > 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0)) AS POSITIVE_VARIANCE_COST
        ,ABS(MAX(CASE WHEN ISNULL(FC.[VARIANCE],0) < 0 THEN ISNULL(FC.[VARIANCE],0) ELSE 0 END * ISNULL(FU.UOM_COST,0))) AS NEGATIVE_VARIANCE_COST
    FROM
        [presentation].[F_INV_USAGE_DAY] FU

    LEFT OUTER JOIN    
        [presentation].[F_INV_SALES_DAY] FS
    ON FU.[COUNT_DATE] = FS.[INV_DATE]
    AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
    AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

    LEFT OUTER JOIN
        Counts FC
    ON FC.[LOCATION_HUB_ID] = FU.[LOCATION_HUB_ID]
    AND FC.[INVITEM_HUB_ID] = FU.[INVITEM_HUB_ID]

    INNER JOIN
        [presentation].[CALENDAR] C
    ON FU.[COUNT_DATE] = C.[DATE]

    LEFT JOIN
        [presentation].[D_LOCATION] location
    ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

    LEFT JOIN
        [presentation].[D_INVITEM] invitem
    ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

    WHERE 1=1
    AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
    @FilterClause

    GROUP BY
        COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
        ,COALESCE(invitem.[TOP_MICROSERVICE_NAME],invitem.[TOP_NAME])
        ,COALESCE(invitem.[MIDDLE_1_MICROSERVICE_NAME],invitem.[MIDDLE_1_NAME])
        ,COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])
    ) SUB
)
select 



LOCATION_NAME AS xAxisLabel,

ROW_NUMBER() OVER(ORDER BY LOCATION_NAME) AS LabelSort,

[Value],

ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,

Label AS VisId,

Stack

FROM



(

SELECT

    LOCATION_NAME

    ,''Positive Variance'' AS Label

    ,SUM(POSITIVE_VARIANCE_COST) AS Value

    ,''A'' AS Stack

FROM

    BASE
GROUP BY
    LOCATION_NAME


UNION ALL



SELECT

    LOCATION_NAME

    ,''Negative Variance'' AS Label

    ,SUM(NEGATIVE_VARIANCE_COST) AS Value

    ,''B'' AS Stack

FROM

    BASE
GROUP BY
    LOCATION_NAME

) SUB



 

SELECT

''Location'' AS XAxisLabel,

''Variances'' AS YAxisLabel,

''Inventory Variances'' AS Title,

NULL AS Description,

NULL AS Trend,

NULL AS Chip,

NULL AS Value',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: InvWasteCost
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'InvWasteCost',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT 
    ''Waste Cost'' AS Title,    FORMAT(ABS(SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "COALESCE(invitem.[BOTTOM_MICROSERVICE_NAME],invitem.[BOTTOM_INVITEM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT 
    ''Waste Cost'' AS Title,    FORMAT(ABS(SUM(ISNULL(FU.WASTE_QTY,0) * ISNULL(FU.UOM_COST,0))),''N0'') AS Value

FROM
    [presentation].[F_INV_USAGE_DAY] FU

LEFT OUTER JOIN    
    [presentation].[F_INV_SALES_DAY] FS
ON FU.[COUNT_DATE] = FS.[INV_DATE]
AND FU.[LOCATION_HUB_ID] = FS.[LOCATION_HUB_ID]
AND FU.[INVITEM_HUB_ID] = FS.[INVITEM_HUB_ID]

INNER JOIN
    [presentation].[CALENDAR] C
ON FU.[COUNT_DATE] = C.[DATE]

LEFT JOIN
    [presentation].[D_LOCATION] location
ON FU.LOCATION_HUB_ID = location.BOTTOM_HUB_ID

LEFT JOIN
    [presentation].[D_INVITEM] invitem
ON FU.INVITEM_HUB_ID = invitem.BOTTOM_HUB_ID

WHERE 1=1
AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL
@FilterClause',
    NULL,
    N'dbadmin',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Locations
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Locations',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) AS [LOCATION_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) ELSE [LOCATION_ID] END AS [LOCATION_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_LOCATION]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "LocationList": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "LOCATION_NAME",
    "ID": "LOCATION_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Locations"
      }
    }
  ]
}',
    N'SELECT
    [LOCATION_NAME] AS [Label]
    ,    [LOCATION_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) AS [LOCATION_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[LOCATION_NAME]) ELSE [LOCATION_ID] END AS [LOCATION_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_LOCATION]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Locations'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Mods
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Mods',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[MOD_NAME]) AS [MOD_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[MOD_NAME]) ELSE [MOD_ID] END AS [MOD_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_MOD]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "MOD_NAME",
    "ID": "MOD_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Modifications"
      }
    }
  ]
}',
    N'SELECT
    [MOD_NAME] AS [Label]
    ,    [MOD_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[MOD_NAME]) AS [MOD_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[MOD_NAME]) ELSE [MOD_ID] END AS [MOD_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_MOD]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Modifications'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: NetSales
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSales',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
POSTX_DATE AS BarLabel,
ROW_NUMBER() OVER( ORDER BY POSTX_DATE) AS BarLabelSort,
--STORENAME AS Column1,
--DAY_PERIOD AS Column2,
--PRODUCT_TYPE AS Column3,
--ITEMS_SOLD AS Column4,
--SALES_TOTAL AS Column5,
SALES_NET_TOTAL AS BarValue,
ROW_NUMBER() OVER( ORDER BY SALES_NET_TOTAL) AS BarValueSort
--DISCOUNT_TOTAL AS Column7,
--TAX_TOTAL AS Column8,
 

FROM (
SELECT [POSTX_DATE]
      --,[NAME] AS STORENAME
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
	@FilterClause
  GROUP BY [POSTX_DATE]
      --,[NAME]
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
) SUB
 
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Net Sales'' AS YAxisLabel,
''Net Sales by Business Day'' AS Title,
''Net Sales by Business Day Description'' AS Description,
NULL AS Trend,
(SELECT ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2)FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
	@FilterClause) AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "POSTX_DATE",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSales',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,VisType
	,LegendLabel
FROM
(
SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	1 AS VisId,
	''bar'' AS VisType,
	''Net Sales'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	2 AS VisId,
	''line'' AS VisType,
	''Last Week'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastWeekDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	3 AS VisId,
	''line'' AS VisType,
	''Last Year'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastYearDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate
 


) SUB',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Business Date",
        "YAxisLabel": "Net Sales",
        "Title": "Net Sales by Business Day",
        "Description": "Net Sales by Business Day Description"
      }
    }
  ]
}',
    N'SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,VisType
	,LegendLabel
FROM
(
SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	1 AS VisId,
	''bar'' AS VisType,
	''Net Sales'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	2 AS VisId,
	''line'' AS VisType,
	''Last Week'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastWeekDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	3 AS VisId,
	''line'' AS VisType,
	''Last Year'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastYearDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate
 


) SUB
) INPUTQUERY

SELECT
    ''Business Date'' AS [XAxisLabel]
    ,    ''Net Sales'' AS [YAxisLabel]
    ,    ''Net Sales by Business Day'' AS [Title]
    ,    ''Net Sales by Business Day Description'' AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- MultiLineChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSales',
    N'MultiLineChartCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,Curve
	,Stack
	,Area
	,StackOrder
	,ShowMark
	,LegendLabel
FROM
(
SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	1 AS VisId,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Net Sales'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	2 AS VisId,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Last Week'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastWeekDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	3 AS VisId,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Last Year'' AS LegendLabel
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastYearDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate
 
 ) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Net Sales'' AS YAxisLabel,
''Net Sales by Business Day'' AS Title,
''Net Sales by Business Day Description'' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2)
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause
) AS Value',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSales',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Net Sales Total'' AS Title,
    FORMAT(ROUND(SUM(NET_VALUE), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Net Sales Total'' AS Title,
    FORMAT(ROUND(SUM(NET_VALUE), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterClause',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSales',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,VisId
	,Stack
FROM
(
SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	''Net Sales'' AS VisId,
	''A'' AS Stack
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS Value,
	''Discount'' AS VisId,
	''A'' AS Stack
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastWeekDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate

UNION ALL

SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([ITEM_COUNT] AS FLOAT)),2) AS Value,
	''Item Count'' AS VisId,
	''A'' AS Stack
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.LastYearDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate
) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Net Sales'' AS YAxisLabel,
''Net Sales by Business Day'' AS Title,
''Net Sales by Business Day Description'' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2)
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause
) AS Value',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- StatCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSales',
    N'StatCard',
    1,
    N'LIVE',
    N'SELECT
	XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
FROM
(
SELECT
	C.CalendarDate AS XAxisLabel,
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS Value,
	1 AS VisId,
	''A'' AS Stack
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause

GROUP BY C.CalendarDate


) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Net Sales'' AS YAxisLabel,
''Net Sales by Business Day'' AS Title,
NULL AS Interval,
NULL AS Trend,
NULL AS Chip,
(SELECT
	ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2)
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause
) AS Value',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: NetSalesByHour
-- ============================================
-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'NetSalesByHour',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
        DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0) AS XAxisLabel,
        ROUND(SUM(NET_VALUE),2) AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Net Sales'' AS LegendLabel
    FROM [presentation].[F_LINEITEM_15MIN] F

        INNER JOIN
           [presentation].[CALENDAR] C
        ON F.[ORDER_DATE] = C.[DATE]

        LEFT JOIN [presentation].[D_DEAL] deal
        ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_DISCOUNT] discount
            ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_MOD] mod
            ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_OCCASION] occasion
            ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_PRODUCT] product
            ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
            ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_TAX] tax
            ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_LOCATION] location
            ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_REVCENTER] revcenter
            ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_CHANNEL] channel
            ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
        WHERE 1=1
        @FilterClause
        GROUP BY
            DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)

    UNION ALL

    SELECT
        DATEADD(DAY,7,DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)) AS XAxisLabel,
        ROUND(SUM(NET_VALUE),2) AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Last Week'' AS LegendLabel
    FROM [presentation].[F_LINEITEM_15MIN] F

        INNER JOIN
           [presentation].[CALENDAR] C
        ON F.[ORDER_DATE] = C.[SameDayLastWeek]

        LEFT JOIN [presentation].[D_DEAL] deal
        ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_DISCOUNT] discount
            ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_MOD] mod
            ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_OCCASION] occasion
            ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_PRODUCT] product
            ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
            ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_TAX] tax
            ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_LOCATION] location
            ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_REVCENTER] revcenter
            ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_CHANNEL] channel
            ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
        WHERE 1=1
        @FilterClause
        GROUP BY
            DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)

    UNION ALL

    SELECT
        DATEADD(DAY,364,DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)) AS XAxisLabel,
        ROUND(SUM(NET_VALUE),2) AS Value,
        3 AS VisId,
        ''line'' AS VisType,
        ''Last Year'' AS LegendLabel
    FROM [presentation].[F_LINEITEM_15MIN] F

        INNER JOIN
           [presentation].[CALENDAR] C
        ON F.[ORDER_DATE] = C.[SameDayLastYear]

        LEFT JOIN [presentation].[D_DEAL] deal
        ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_DISCOUNT] discount
            ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_MOD] mod
            ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_OCCASION] occasion
            ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_PRODUCT] product
            ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
            ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_TAX] tax
            ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_LOCATION] location
            ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_REVCENTER] revcenter
            ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_CHANNEL] channel
            ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
        WHERE 1=1
        @FilterClause
        GROUP BY
            DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)
    ) SUB',
    N'{
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]",
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])"
}',
    N'{
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Hour of Day",
        "YAxisLabel": "Net Sales",
        "Title": "Net Sales by Hour",
        "Description": "Net Sales by Hour Description"
      }
    }
  ]
}',
    N'SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
        DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0) AS XAxisLabel,
        ROUND(SUM(NET_VALUE),2) AS Value,
        1 AS VisId,
        ''bar'' AS VisType,
        ''Net Sales'' AS LegendLabel
    FROM [presentation].[F_LINEITEM_15MIN] F

        INNER JOIN
           [presentation].[CALENDAR] C
        ON F.[ORDER_DATE] = C.[DATE]

        LEFT JOIN [presentation].[D_DEAL] deal
        ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_DISCOUNT] discount
            ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_MOD] mod
            ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_OCCASION] occasion
            ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_PRODUCT] product
            ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
            ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_TAX] tax
            ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_LOCATION] location
            ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_REVCENTER] revcenter
            ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_CHANNEL] channel
            ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
        WHERE 1=1
        @FilterClause
        GROUP BY
            DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)

    UNION ALL

    SELECT
        DATEADD(DAY,7,DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)) AS XAxisLabel,
        ROUND(SUM(NET_VALUE),2) AS Value,
        2 AS VisId,
        ''line'' AS VisType,
        ''Last Week'' AS LegendLabel
    FROM [presentation].[F_LINEITEM_15MIN] F

        INNER JOIN
           [presentation].[CALENDAR] C
        ON F.[ORDER_DATE] = C.[SameDayLastWeek]

        LEFT JOIN [presentation].[D_DEAL] deal
        ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_DISCOUNT] discount
            ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_MOD] mod
            ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_OCCASION] occasion
            ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_PRODUCT] product
            ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
            ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_TAX] tax
            ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_LOCATION] location
            ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_REVCENTER] revcenter
            ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_CHANNEL] channel
            ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
        WHERE 1=1
        @FilterClause
        GROUP BY
            DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)

    UNION ALL

    SELECT
        DATEADD(DAY,364,DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)) AS XAxisLabel,
        ROUND(SUM(NET_VALUE),2) AS Value,
        3 AS VisId,
        ''line'' AS VisType,
        ''Last Year'' AS LegendLabel
    FROM [presentation].[F_LINEITEM_15MIN] F

        INNER JOIN
           [presentation].[CALENDAR] C
        ON F.[ORDER_DATE] = C.[SameDayLastYear]

        LEFT JOIN [presentation].[D_DEAL] deal
        ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_DISCOUNT] discount
            ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_MOD] mod
            ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_OCCASION] occasion
            ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_PRODUCT] product
            ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
            ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_TAX] tax
            ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_LOCATION] location
            ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_REVCENTER] revcenter
            ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
        LEFT JOIN [presentation].[D_CHANNEL] channel
            ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
        WHERE 1=1
        @FilterClause
        GROUP BY
            DATEADD(HOUR, DATEDIFF(HOUR, 0, LINEITEM_TIMESTAMP), 0)
    ) SUB
) INPUTQUERY

SELECT
    ''Hour of Day'' AS [XAxisLabel]
    ,    ''Net Sales'' AS [YAxisLabel]
    ,    ''Net Sales by Hour'' AS [Title]
    ,    ''Net Sales by Hour Description'' AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Occasions
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Occasions',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[OCCASION_NAME]) AS [OCCASION_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[OCCASION_NAME]) ELSE [OCCASSION_ID] END AS [OCCASION_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_OCCASION]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "OCCASION_NAME",
    "ID": "OCCASION_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Occasions"
      }
    }
  ]
}',
    N'SELECT
    [OCCASION_NAME] AS [Label]
    ,    [OCCASION_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[OCCASION_NAME]) AS [OCCASION_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[OCCASION_NAME]) ELSE [OCCASSION_ID] END AS [OCCASION_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_OCCASION]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Occasions'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: OrderRevCentreDayPart
-- ============================================
-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'OrderRevCentreDayPart',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS Value
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS XAxisLabel
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS LegendLabel
    ,DENSE_RANK() OVER (ORDER BY COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])) AS VisId
    ,''line'' AS VisType
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])

    ) SUB',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "C.[DayOfWeek]",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Hour of Day",
        "YAxisLabel": "Order Volume",
        "Title": "Order by Hour",
        "Description": "By Revenue Centre"
      }
    }
  ]
}',
    N'SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    CONVERT(NVARCHAR,XAxisLabel) AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS Value
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS XAxisLabel
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS LegendLabel
    ,DENSE_RANK() OVER (ORDER BY COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])) AS VisId
    ,''line'' AS VisType
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])

    ) SUB
) INPUTQUERY

SELECT
    ''Hour of Day'' AS [XAxisLabel]
    ,    ''Order Volume'' AS [YAxisLabel]
    ,    ''Order by Hour'' AS [Title]
    ,    ''By Revenue Centre'' AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: OrdersChannelDayPart
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'OrdersChannelDayPart',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
	TEMPLATE.DAY_PERIOD AS Axis1
	,DENSE_RANK() OVER( ORDER BY TEMPLATE.DAY_PERIOD) AS AxisSort1
	,TEMPLATE.REVCENTER AS Label1
	,ISNULL(ACTUALS.[ORDER_COUNT], 0) AS Value1
FROM
(
SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS [ORDER_COUNT]
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS DAY_PERIOD
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS REVCENTER
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])
) ACTUALS

RIGHT OUTER JOIN
(
SELECT DAY_PERIOD,REVCENTER FROM 
 (SELECT DISTINCT DATEPART(HOUR, [LINEITEM_TIMESTAMP]) AS DAY_PERIOD FROM [presentation].[F_LINEITEM_15MIN] WHERE [LINEITEM_TIMESTAMP] IS NOT NULL) DP
 CROSS JOIN
 (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) AS REVCENTER FROM [presentation].[D_REVCENTER] WHERE COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) IS NOT NULL) OT
) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.REVCENTER = TEMPLATE.REVCENTER',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "Axis1",
    "AxisSort": "AxisSort1",
    "Label": "Label1",
    "Value": "Value1"
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "Average Transaction Value",
        "Description": "By Revenue Centre"
      }
    }
  ]
}',
    N'SELECT
    [Axis1] AS [Axis]
    ,    [AxisSort1] AS [AxisSort]
    ,    [Label1] AS [Label]
    ,    [Value1] AS [Value]
FROM
(
SELECT
	TEMPLATE.DAY_PERIOD AS Axis1
	,DENSE_RANK() OVER( ORDER BY TEMPLATE.DAY_PERIOD) AS AxisSort1
	,TEMPLATE.REVCENTER AS Label1
	,ISNULL(ACTUALS.[ORDER_COUNT], 0) AS Value1
FROM
(
SELECT
	SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN F.[ORDER_COUNT] ELSE 0 END) AS [ORDER_COUNT]
	,DATEPART(HOUR, F.[LINEITEM_TIMESTAMP]) AS DAY_PERIOD
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME]) AS REVCENTER
FROM
	[presentation].[F_LINEITEM_15MIN] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

LEFT JOIN [presentation].[D_DEAL] deal
ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_MOD] mod
    ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
    ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_TAX] tax
    ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID

WHERE 1=1
@FilterClause

GROUP BY
	DATEPART(HOUR, F.[LINEITEM_TIMESTAMP])
	,COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])
) ACTUALS

RIGHT OUTER JOIN
(
SELECT DAY_PERIOD,REVCENTER FROM 
 (SELECT DISTINCT DATEPART(HOUR, [LINEITEM_TIMESTAMP]) AS DAY_PERIOD FROM [presentation].[F_LINEITEM_15MIN] WHERE [LINEITEM_TIMESTAMP] IS NOT NULL) DP
 CROSS JOIN
 (SELECT DISTINCT COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) AS REVCENTER FROM [presentation].[D_REVCENTER] WHERE COALESCE([BOTTOM_MICROSERVICE_NAME],[BOTTOM_NAME]) IS NOT NULL) OT
) TEMPLATE
ON ACTUALS.DAY_PERIOD = TEMPLATE.DAY_PERIOD
AND ACTUALS.REVCENTER = TEMPLATE.REVCENTER
) INPUTQUERY

SELECT
    ''Average Transaction Value'' AS [Title]
    ,    ''By Revenue Centre'' AS [Description]
    ,    NULL AS [Value]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProdMarg
-- ============================================
-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProdMarg',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'select 

xAxisLabel,
ROW_NUMBER() OVER(ORDER BY [Value]) AS LabelSort,
[Value],
ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
VisId,
Stack


from (

SELECT
	COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS XAxisLabel
	,FORMAT(ROUND(SUM([PROFIT])/SUM([NET_VALUE])*100,0), ''N0'') AS Value
	--,SUM([PROFIT]) AS PROFIT
    ,1 AS VisId
     ,''A'' AS Stack
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])

) sub 



SELECT
''Product'' AS XAxisLabel,
''Margin %'' AS YAxisLabel,
''Product Margins'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'select 

xAxisLabel,
ROW_NUMBER() OVER(ORDER BY [Value]) AS LabelSort,
[Value],
ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
VisId,
Stack


from (

SELECT
	COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS XAxisLabel
	,FORMAT(ROUND(SUM([PROFIT])/SUM([NET_VALUE])*100,0), ''N0'') AS Value
	--,SUM([PROFIT]) AS PROFIT
    ,1 AS VisId
     ,''A'' AS Stack
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])

) sub 



SELECT
''Product'' AS XAxisLabel,
''Margin %'' AS YAxisLabel,
''Product Margins'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductCategories
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductCategories',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
[PRODUCT_TYPE] AS Label,
[PRODUCT_TYPE_ID] AS ID,
[PRODUCT_GROUP_ID] AS ParentID,
1 AS BottomLevel
FROM [threerocks].[dbo].[CShopProductSales]
WHERE 1=1
@FilterClause

UNION ALL

SELECT DISTINCT
[PRODUCT_GROUP] AS Label,
[PRODUCT_GROUP_ID] AS ID,
NULL AS ParentID,
0 AS BottomLevel

FROM [threerocks].[dbo].[CShopProductSales]
WHERE 1=1
@FilterClause

SELECT
''Product Categories'' AS Title',
    N'{
  "LocationList": "POSTX_DATE",
  "StartDate": "SITE_HUB_ID",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductCount
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductCount',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
POSTX_DATE AS BarLabel,
ROW_NUMBER() OVER( ORDER BY POSTX_DATE) AS BarLabelSort,
--STORENAME AS Column1,
--DAY_PERIOD AS Column2,
--PRODUCT_TYPE AS Column3,
ITEMS_SOLD AS BarValue,
ROW_NUMBER() OVER( ORDER BY ITEMS_SOLD) AS BarValueSort
--SALES_TOTAL AS Column5,
--SALES_NET_TOTAL AS BarValue
--DISCOUNT_TOTAL AS BarValue
--TAX_TOTAL AS Column8,
 

FROM (
SELECT [POSTX_DATE]
      --,[NAME] AS STORENAME
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
  @FilterClause
  GROUP BY [POSTX_DATE]
      --,[NAME]
      --,[DAY_PERIOD]
      --,[PRODUCT_TYPE]
) SUB
 
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Product Count'' AS YAxisLabel,
''Products Sold by Business Day'' AS Title,
''Products Sold by Business Day Description'' AS Description,
NULL AS Trend,
(SELECT ROUND(SUM(CAST([ITEM_COUNT] AS FLOAT)),2)FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
  @FilterClause) AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "POSTX_DATE",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductCount',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
	[PRODUCT] AS Label,
	ROUND(SUM(CAST(ITEM_COUNT AS FLOAT)),2) AS Value,
	PRODUCT_HUB_ID AS Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Net Sales'' AS LegendLabel
	--SELECT TOP 1000 *
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause

GROUP BY [PRODUCT], PRODUCT_HUB_ID

 
SELECT
''Product Mix'' AS Title,
''Product Mix Description'' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	CAST(ROUND(SUM(CAST(ITEM_COUNT AS FLOAT)),2) AS VARCHAR)
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause
) AS PiePrimaryText,
''Total Products'' AS PieSecondaryText',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "PRODUCT_TYPE_ID",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductCount',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
''Product Mix'' AS Title,
(SELECT
	CAST(ROUND(SUM(CAST(ITEM_COUNT AS FLOAT)),2) AS VARCHAR)
FROM
	[threerocks].[dbo].[CShopProductSales] F
INNER JOIN
	[threerocks].[dbo].Calendar C
ON F.POSTX_DATE = C.CalendarDate

WHERE 1=1
@FilterClause
) AS Value',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "PRODUCT_TYPE_ID",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "PRODUCT_HUB_ID",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductGC
-- ============================================
-- HeatmapCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductGC',
    N'HeatmapCard',
    1,
    N'LIVE',
    N'SELECT
	 COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS XAxisLabel
    ,COALESCE(product_comp.[BOTTOM_MICROSERVICE_NAME],product_comp.[BOTTOM_PRODUCT_NAME]) AS YAxisLabel
    ,ROUND((SUM(COOC.GlobalOccurenceCount)*100)/SUM(COOC.DIstinctOrderCount),0) AS Value
FROM
	[presentation].[D_COOCCURRENCE] COOC
 
INNER JOIN [presentation].[D_OCCASION] occasion
    ON COOC.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_PRODUCT] product
    ON COOC.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_PRODUCT] product_comp
    ON COOC.PRODUCT_HUB_ID_COMP = product_comp.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_LOCATION] location
    ON COOC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_REVCENTER] revcenter
    ON COOC.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_CHANNEL] channel
    ON COOC.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
WHERE 1=1
@FilterClause

GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])
    ,COALESCE(product_comp.[BOTTOM_MICROSERVICE_NAME],product_comp.[BOTTOM_PRODUCT_NAME])


SELECT
    ''Product Comparison Heatmap'' AS Title
    ,''Product CoOccurrence'' AS Description',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductsComp": {
    "column": "COALESCE(product_comp.[BOTTOM_MICROSERVICE_NAME],product_comp.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
	 COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS XAxisLabel
    ,COALESCE(product_comp.[BOTTOM_MICROSERVICE_NAME],product_comp.[BOTTOM_PRODUCT_NAME]) AS YAxisLabel
    ,ROUND((SUM(COOC.GlobalOccurenceCount)*100)/SUM(COOC.DIstinctOrderCount),0) AS Value
FROM
	[presentation].[D_COOCCURRENCE] COOC
 
INNER JOIN [presentation].[D_OCCASION] occasion
    ON COOC.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_PRODUCT] product
    ON COOC.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_PRODUCT] product_comp
    ON COOC.PRODUCT_HUB_ID_COMP = product_comp.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_LOCATION] location
    ON COOC.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_REVCENTER] revcenter
    ON COOC.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
INNER JOIN [presentation].[D_CHANNEL] channel
    ON COOC.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
WHERE 1=1
@FilterClause

GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])
    ,COALESCE(product_comp.[BOTTOM_MICROSERVICE_NAME],product_comp.[BOTTOM_PRODUCT_NAME])


SELECT
    ''Product Comparison Heatmap'' AS Title
    ,''Product CoOccurrence'' AS Description',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductMargins
-- ============================================
-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductMargins',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
	F.[ORDER_DATE]
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

GROUP BY
    F.[ORDER_DATE]
)

SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(
SELECT
	[ORDER_DATE] AS XAxisLabel
    ,''Margin'' AS LegendLabel
    ,MARGIN AS Value
    ,1 AS VisId
    ,''line'' AS VisType
FROM
    BASE

UNION ALL

SELECT
	[ORDER_DATE] AS XAxisLabel
    ,''Cost'' AS LegendLabel
    ,[COST] AS Value
    ,2 AS VisId
    ,''line'' AS VisType
FROM
    BASE

UNION ALL

SELECT
	[ORDER_DATE] AS XAxisLabel
    ,''Discounts'' AS LegendLabel
    ,[DISCOUNTS] AS Value
    ,3 AS VisId
    ,''line'' AS VisType
FROM
    BASE


    ) SUB',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "F.[DEAL_FLAG]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "BETWEEN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Business Date",
        "YAxisLabel": "Margin Percentage",
        "Title": "Margins by Channel",
        "Description": ""
      }
    }
  ]
}',
    N'WITH Base AS
(
SELECT
	F.[ORDER_DATE]
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

GROUP BY
    F.[ORDER_DATE]
)
SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(
SELECT
	[ORDER_DATE] AS XAxisLabel
    ,''Margin'' AS LegendLabel
    ,MARGIN AS Value
    ,1 AS VisId
    ,''line'' AS VisType
FROM
    BASE

UNION ALL

SELECT
	[ORDER_DATE] AS XAxisLabel
    ,''Cost'' AS LegendLabel
    ,[COST] AS Value
    ,2 AS VisId
    ,''line'' AS VisType
FROM
    BASE

UNION ALL

SELECT
	[ORDER_DATE] AS XAxisLabel
    ,''Discounts'' AS LegendLabel
    ,[DISCOUNTS] AS Value
    ,3 AS VisId
    ,''line'' AS VisType
FROM
    BASE


    ) SUB
) INPUTQUERY

SELECT
    ''Business Date'' AS [XAxisLabel]
    ,    ''Margin Percentage'' AS [YAxisLabel]
    ,    ''Margins by Channel'' AS [Title]
    ,    NULL AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- MultiLineChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductMargins',
    N'MultiLineChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
	F.[ORDER_DATE] AS BUS_DATE
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    F.[ORDER_DATE]
)

SELECT
	FORMAT(BUS_DATE, ''dd MMM yyyy'') AS XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY BUS_DATE) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,Id AS VisId
	,''linear'' AS Curve
	,''total'' AS Stack
	,''true'' AS Area
	,''descending'' AS StackOrder
	,''false'' AS ShowMark
	,Label AS LegendLabel
FROM
(
SELECT
    BUS_DATE
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,3 AS Id
FROM
    BASE

UNION ALL

SELECT
    BUS_DATE
    ,''Costs'' AS Label
    ,COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    BUS_DATE
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,1 AS Id
FROM
    BASE
) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Percentage'' AS YAxisLabel,
''Product Margins'' AS Title,
''Product margins over time'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "F.[DEAL_FLAG]",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Base AS
(
SELECT
	F.[ORDER_DATE] AS BUS_DATE
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL
GROUP BY
    F.[ORDER_DATE]
)

SELECT
	FORMAT(BUS_DATE, ''dd MMM yyyy'') AS XAxisLabel
	,ROW_NUMBER() OVER(ORDER BY BUS_DATE) AS LabelSort
	,Value
	,ROW_NUMBER() OVER(ORDER BY Value) AS ValueSort
	,Id AS VisId
	,''linear'' AS Curve
	,''total'' AS Stack
	,''true'' AS Area
	,''descending'' AS StackOrder
	,''false'' AS ShowMark
	,Label AS LegendLabel
FROM
(
SELECT
    BUS_DATE
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,3 AS Id
FROM
    BASE

UNION ALL

SELECT
    BUS_DATE
    ,''Costs'' AS Label
    ,COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    BUS_DATE
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,1 AS Id
FROM
    BASE
) SUB
 
 
SELECT
''Business Date'' AS XAxisLabel,
''Percentage'' AS YAxisLabel,
''Product Margins'' AS Title,
''Product margins over time'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductMargins',
    N'PieChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
	FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(


SELECT
    ''Costs'' AS Label
    ,COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Margin'' AS Label
    ,MARGIN AS Value
    ,1 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,3 AS Id
FROM
    BASE
) SUB

 
SELECT
''Product Margins'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE]),2), ''P0'') AS MARGIN
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

) AS PiePrimaryText,
''Margin'' AS PieSecondaryText',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "F.[DEAL_FLAG]",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Base AS
(
SELECT
	FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

    )
SELECT
	Label,
	Value,
	Id,
	''linear'' AS Curve,
	''total'' AS Stack,
	''true'' AS Area,
	''ascending'' AS StackOrder,
	''false'' AS ShowMark,
	''Percent'' AS LegendLabel
FROM
(


SELECT
    ''Costs'' AS Label
    ,COST AS Value
    ,2 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Margin'' AS Label
    ,MARGIN AS Value
    ,1 AS Id
FROM
    BASE

UNION ALL

SELECT
    ''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,3 AS Id
FROM
    BASE
) SUB

 
SELECT
''Product Margins'' AS Title,
'''' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE]),2), ''P0'') AS MARGIN
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

) AS PiePrimaryText,
''Margin'' AS PieSecondaryText',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductMargins',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
	COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS PRODUCT_CATEGORY
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])
)

select 

PRODUCT_CATEGORY AS xAxisLabel,
ROW_NUMBER() OVER(ORDER BY PRODUCT_CATEGORY) AS LabelSort,
[Value],
ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
Label AS VisId,
Stack
FROM

(
SELECT
    PRODUCT_CATEGORY
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,''A'' AS Stack
FROM
    BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Costs'' AS Label
    ,COST AS Value
    ,''B'' AS Stack
FROM
    BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,''B'' AS Stack
FROM
    BASE
) SUB

 
SELECT
''Product Category'' AS XAxisLabel,
''Margin %'' AS YAxisLabel,
''Product Margins'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "F.[DEAL_FLAG]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'WITH Base AS
(
SELECT
	COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) AS PRODUCT_CATEGORY
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

GROUP BY
    COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])
)

select 

PRODUCT_CATEGORY AS xAxisLabel,
ROW_NUMBER() OVER(ORDER BY PRODUCT_CATEGORY) AS LabelSort,
[Value],
ROW_NUMBER() OVER(ORDER BY [Value]) AS ValueSort,
Label AS VisId,
Stack
FROM

(
SELECT
    PRODUCT_CATEGORY
    ,''Margin'' AS Label
    ,MARGIN AS Value
    ,''A'' AS Stack
FROM
    BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Costs'' AS Label
    ,COST AS Value
    ,''B'' AS Stack
FROM
    BASE

UNION ALL

SELECT
    PRODUCT_CATEGORY
    ,''Discounts'' AS Label
    ,DISCOUNTS AS Value
    ,''B'' AS Stack
FROM
    BASE
) SUB

 
SELECT
''Product Category'' AS XAxisLabel,
''Margin %'' AS YAxisLabel,
''Product Margins'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductMarginsChannel
-- ============================================
-- CombinedChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductMarginsChannel',
    N'CombinedChartCard',
    1,
    N'LIVE',
    N'WITH Base AS
(
SELECT
	F.[ORDER_DATE]
    ,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME]) AS CHANNEL
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

GROUP BY
    F.[ORDER_DATE]
    ,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])
)

SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
	[ORDER_DATE] AS XAxisLabel
    ,[CHANNEL] AS LegendLabel
    ,MARGIN AS Value
    ,DENSE_RANK() OVER (ORDER BY [CHANNEL]) AS VisId
    ,''line'' AS VisType
FROM
    BASE


    ) SUB',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "F.[DEAL_FLAG]",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "EQUALS",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "XAxisLabel": "XAxisLabel",
    "LabelSort": "LabelSort",
    "Value": "Value",
    "ValueSort": "ValueSort",
    "VisId": "VisId",
    "VisType": "VisType",
    "LegendLabel": "LegendLabel"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "XAxisLabel",
        "YAxisLabel",
        "Title",
        "Description"
      ],
      "values": {
        "XAxisLabel": "Business Date",
        "YAxisLabel": "Margin Percentage",
        "Title": "Margins by Channel",
        "Description": ""
      }
    }
  ]
}',
    N'WITH Base AS
(
SELECT
	F.[ORDER_DATE]
    ,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME]) AS CHANNEL
    ,FORMAT(ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0), ''N0'') AS MARGIN
	,FORMAT(ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0), ''N0'') AS COST
    ,100 - FORMAT((ROUND(SUM([PROFIT_LESS_DISCOUNT])/SUM([NET_VALUE])*100,0)) + (ROUND(SUM([QUANTITY]*[AVG_NET_COST])/SUM([NET_VALUE])*100,0)), ''N0'') AS DISCOUNTS
FROM
	[presentation].[F_PRODUCT_MARGIN_DAY] F

INNER JOIN
    [presentation].[CALENDAR] C
ON F.[ORDER_DATE] = C.[DATE]

    
LEFT JOIN [presentation].[D_OCCASION] occasion
    ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_PRODUCT] product
    ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_LOCATION] location
    ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_REVCENTER] revcenter
    ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_CHANNEL] channel
    ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
LEFT JOIN [presentation].[D_DISCOUNT] Discount
    ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
WHERE 1=1
@FilterClause
AND [PROFIT] IS NOT NULL
AND NULLIF([NET_VALUE],0) IS NOT NULL
AND COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME]) IS NOT NULL

GROUP BY
    F.[ORDER_DATE]
    ,COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])
)
SELECT
    [XAxisLabel] AS [XAxisLabel]
    ,    [LabelSort] AS [LabelSort]
    ,    [Value] AS [Value]
    ,    [ValueSort] AS [ValueSort]
    ,    [VisId] AS [VisId]
    ,    [VisType] AS [VisType]
    ,    [LegendLabel] AS [LegendLabel]
FROM
(
SELECT
    FORMAT(XAxisLabel, ''dd MMM yyyy'') AS XAxisLabel
    ,DENSE_RANK() OVER(ORDER BY XAxisLabel) AS LabelSort
    ,Value
    ,DENSE_RANK() OVER(ORDER BY Value) AS ValueSort
    ,VisId
    ,VisType
    ,LegendLabel
FROM
(SELECT
	[ORDER_DATE] AS XAxisLabel
    ,[CHANNEL] AS LegendLabel
    ,MARGIN AS Value
    ,DENSE_RANK() OVER (ORDER BY [CHANNEL]) AS VisId
    ,''line'' AS VisType
FROM
    BASE


    ) SUB
) INPUTQUERY

SELECT
    ''Business Date'' AS [XAxisLabel]
    ,    ''Margin Percentage'' AS [YAxisLabel]
    ,    ''Margins by Channel'' AS [Title]
    ,    NULL AS [Description]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductNetSales
-- ============================================
-- CustomPinnedDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductNetSales',
    N'CustomPinnedDataGrid',
    1,
    N'LIVE',
    N'SELECT
PRODUCT_TYPE AS PinnedColumn,
TradingDate AS Columns,
ROW_NUMBER() OVER(ORDER BY TradingDate ASC) AS ColumnsSort,
SALES_NET_TOTAL AS Value

FROM (
SELECT --[POSTX_DATE]
--CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END AS PARENT_ID
      --,[NAME] AS STORENAME
      --,SITE_HUB_ID AS ID
      C.CalendarDate AS TradingDate
      --,[DAY_PERIOD]
      ,[PRODUCT_TYPE]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
    [threerocks].[dbo].Calendar C
ON POSTX_DATE = C.CalendarDate
  WHERE 1=1
@FilterClause
  GROUP BY C.CalendarDate,[PRODUCT_TYPE]
) SUB
 


SELECT
''Product Net Sales'' AS Title,
''Product Net Sales Description'' AS Description,
''Product Group'' AS PinnedLabel,
''TEXT'' AS PinnedType,
''Business Date'' AS ColumnsLabel,
''DATE'' AS ColumnsType,
150 AS ColumnsMinWidth,
''Net Sales'' AS ValueLabel,
''DECIMAL'' AS ValueType',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "PRODUCT_TYPE",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Products
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Products',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) AS [PRODUCT_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) ELSE [PRODUCT_ID] END AS [PRODUCT_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_PRODUCT]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "POSTX_DATE",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "ProductCategories": {
    "column": "PRODUCT_TYPE_ID",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "PRODUCT_NAME",
    "ID": "PRODUCT_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Products"
      }
    }
  ]
}',
    N'SELECT
    [PRODUCT_NAME] AS [Label]
    ,    [PRODUCT_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) AS [PRODUCT_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) ELSE [PRODUCT_ID] END AS [PRODUCT_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_PRODUCT]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Products'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ProductsComp
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ProductsComp',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) AS [PRODUCT_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) ELSE [PRODUCT_ID] END AS [PRODUCT_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_PRODUCT]
WHERE [CURRENT_FLAG] = 1
AND [SRC] = ''int_ncraloha001''',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DayOfWeek": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "DealToggle": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "PRODUCT_NAME",
    "ID": "PRODUCT_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Comparison Products"
      }
    }
  ]
}',
    N'SELECT
    [PRODUCT_NAME] AS [Label]
    ,    [PRODUCT_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) AS [PRODUCT_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[PRODUCT_NAME]) ELSE [PRODUCT_ID] END AS [PRODUCT_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_PRODUCT]
WHERE [CURRENT_FLAG] = 1
AND [SRC] = ''int_ncraloha001''
) INPUTQUERY

SELECT
    ''Comparison Products'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: RevenueCentres
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'RevenueCentres',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[REVC_NAME]) AS [REVC_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[REVC_NAME]) ELSE [REVC_ID] END AS [REVC_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_REVCENTER]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "REVC_NAME",
    "ID": "REVC_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Revenue Centres"
      }
    }
  ]
}',
    N'SELECT
    [REVC_NAME] AS [Label]
    ,    [REVC_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[REVC_NAME]) AS [REVC_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[REVC_NAME]) ELSE [REVC_ID] END AS [REVC_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_REVCENTER]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Revenue Centres'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SalesKPI
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SalesKPI',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
POSTX_DATE AS Column1,
STORENAME AS Column2,
DAY_PERIOD AS Column3,
PRODUCT_GROUP AS Column4,
ITEMS_SOLD AS Column5,
SALES_TOTAL AS Column6,
''GBP'' AS CurrencyCode6,
SALES_NET_TOTAL AS Column7,
''GBP'' AS CurrencyCode7,
DISCOUNT_TOTAL AS Column8,
''GBP'' AS CurrencyCode8,
TAX_TOTAL AS Column9,
TAX_PERC AS Column10,
JSON_OBJECT(''labels'': SERIES_LABEL,''data'':ORDER_TYPE_SALES  ) AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
SELECT [POSTX_DATE]
      ,[NAME] AS STORENAME
      ,[DAY_PERIOD]
      ,[PRODUCT_GROUP]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C|Deliveroo|Eat In|JUST EAT|Take Away|UBER EATS|Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales]
  WHERE 1=1
    @FilterClause
  GROUP BY [POSTX_DATE]
      ,[NAME]
      ,[DAY_PERIOD]
      ,[PRODUCT_GROUP]
) SUB
 
 
SELECT
''Sales KPIs'' AS Title,
''Sales KPIs Description'' AS Description,
''Business Date'' AS Label1,
''DATE'' AS TYPE1,
150 AS MinWidth1,
''Location Name'' AS Label2,
''TEXT'' AS TYPE2,
150 AS MinWidth2,
''Day Period'' AS Label3,
''TEXT'' AS TYPE3,
150 AS MinWidth3,
''Product Group'' AS Label4,
''TEXT'' AS TYPE4,
150 AS MinWidth4,
''Items Sold'' AS Label5,
''INT'' AS TYPE5,
150 AS MinWidth5,
''Sales Total'' AS Label6,
''CURRENCY'' AS TYPE6,
150 AS MinWidth6,
''Sales Net Total'' AS Label7,
''CURRENCY'' AS TYPE7,
150 AS MinWidth7,
''Discount Total'' AS Label8,
''CURRENCY'' AS TYPE8,
150 AS MinWidth8,
''Tax Total'' AS Label9,
''DECIMAL'' AS TYPE9,
150 AS MinWidth9,
''Tax %'' AS Label10,
''PERCENT'' AS TYPE10,
150 AS MinWidth10,
''Order Type Sales'' AS Label11,
''JSON'' AS TYPE11,
150 AS MinWidth11,
NULL AS Label12,
NULL AS TYPE12,
150 AS MinWidth12,
NULL AS Label13,
NULL AS TYPE13,
150 AS MinWidth13,
NULL AS Label14,
NULL AS TYPE14,
150 AS MinWidth14,
NULL AS Label15,
NULL AS TYPE15,
150 AS MinWidth15,
NULL AS Label16,
NULL AS TYPE16,
150 AS MinWidth16,
NULL AS Label17,
NULL AS TYPE17,
150 AS MinWidth17,
NULL AS Label18,
NULL AS TYPE18,
150 AS MinWidth18,
NULL AS Label19,
NULL AS TYPE19,
150 AS MinWidth19,
NULL AS Label20,
NULL AS TYPE20,
150 AS MinWidth20,
NULL AS Label21,
NULL AS TYPE21,
150 AS MinWidth21,
NULL AS Label22,
NULL AS TYPE22,
150 AS MinWidth22,
NULL AS Label23,
NULL AS TYPE23,
150 AS MinWidth23,
NULL AS Label24,
NULL AS TYPE24,
150 AS MinWidth24,
NULL AS Label25,
NULL AS TYPE25,
150 AS MinWidth25,
NULL AS Label26,
NULL AS TYPE26,
150 AS MinWidth26,
NULL AS Label27,
NULL AS TYPE27,
150 AS MinWidth27,
NULL AS Label28,
NULL AS TYPE28,
150 AS MinWidth28,
NULL AS Label29,
NULL AS TYPE29,
150 AS MinWidth29,
NULL AS Label30,
NULL AS TYPE30,
150 AS MinWidth30',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "POSTX_DATE",
  "EndDate": "POSTX_DATE"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- CustomGroupedDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SalesKPI',
    N'CustomGroupedDataGrid',
    1,
    N'LIVE',
    N'SELECT
PARENT_ID AS ParentId,
ID AS Id,
STORENAME AS GroupedColumn,
ITEMS_SOLD AS Column1,
SALES_TOTAL AS Column2,
''GBP'' AS CurrencyCode2,
SALES_NET_TOTAL AS Column3,
''GBP'' AS CurrencyCode3,
DISCOUNT_TOTAL AS Column4,
''GBP'' AS CurrencyCode4,
TAX_TOTAL AS Column5,
''USD'' AS CurrencyCode5,
TAX_PERC AS Column6,
NULL AS Column7,
NULL AS Column8,
 
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM (
SELECT --[POSTX_DATE]
CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END AS PARENT_ID
      ,[NAME] AS STORENAME
      ,SITE_HUB_ID AS ID
      --,[DAY_PERIOD]
      --,[PRODUCT_GROUP]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
    [threerocks].[dbo].Calendar C
ON POSTX_DATE = C.CalendarDate
  WHERE 1=1
@FilterClause
  GROUP BY [NAME],SITE_HUB_ID
  ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END
) SUB
 
UNION ALL
 
SELECT
PARENT_ID AS ParentId,
ID AS Id,
STORENAME AS GroupedColumn,
ITEMS_SOLD AS Column1,
SALES_TOTAL AS Column2,
''GBP'' AS CurrencyCode2,
SALES_NET_TOTAL AS Column3,
''GBP'' AS CurrencyCode3,
DISCOUNT_TOTAL AS Column4,
''GBP'' AS CurrencyCode4,
TAX_TOTAL AS Column5,
''USD'' AS CurrencyCode5,
TAX_PERC AS Column6,
NULL AS Column7,
NULL AS Column8,
 
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM (
SELECT --[POSTX_DATE]
NULL AS PARENT_ID
      ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''Area 1'' ELSE ''Area 51'' END AS STORENAME
      ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END AS ID
      --,[DAY_PERIOD]
      --,[PRODUCT_GROUP]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
    [threerocks].[dbo].Calendar C
ON POSTX_DATE = C.CalendarDate
  WHERE 1=1
	@FilterClause
  GROUP BY CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''Area 1'' ELSE ''Area 51'' END
  ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END
) SUB',
    N'{
  "LocationList": "SITE_HUB_ID",
  "StartDate": "C.CalendarDate",
  "EndDate": "C.CalendarDate"
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{

  "column_mappings": {

    "ParentId": "ParentId",

    "Id": "Id",

    "GroupedColumn": "GroupedColumn",

    "Column1": "Column1",

    "Column2": "Column2",

    "Column3": "Column3",

    "Column4": "Column4",

    "Column5": "Column5",

    "Column6": "Column6",

    "Column7": "",

    "Column8": "",

    "Column9": "",

    "Column10": "",

    "Column11": "",

    "Column12": "",

    "Column13": "",

    "Column14": "",

    "Column15": "",

    "Column16": "",

    "Column17": "",

    "Column18": "",

    "Column19": "",

    "Column20": "",

    "Column21": "",

    "Column22": "",

    "Column23": "",

    "Column24": "",

    "Column25": "",

    "Column26": "",

    "Column27": "",

    "Column28": "",

    "Column29": ""

  },

  "additional_datasets": [

    {

      "name": "Header1",

      "type": "Header",

      "columns": [

        "Title",

        "Description",

        "GroupedLabel",

        "GroupedType",

        "Label1",

        "Type1",

        "Label2",

        "Type2",

        "Label3",

        "Type3",

        "Label4",

        "Type4",

        "Label5",

        "Type5",

        "Label6",

        "Type6",

        "Label7",

        "Type7",

        "Label8",

        "Type8",

        "Label9",

        "Type9",

        "Label10",

        "Type10",

        "Label11",

        "Type11",

        "Label12",

        "Type12",

        "Label13",

        "Type13",

        "Label14",

        "Type14",

        "Label15",

        "Type15",

        "Label16",

        "Type16",

        "Label17",

        "Type17",

        "Label18",

        "Type18",

        "Label19",

        "Type19",

        "Label20",

        "Type20",

        "Label21",

        "Type11",

        "Label22",

        "Type22",

        "Label23",

        "Type23",

        "Label24",

        "Type24",

        "Label25",

        "Type25",

        "Label26",

        "Type26",

        "Label27",

        "Type27",

        "Label28",

        "Type28",

        "Label29",

        "Type29"

      ],

      "values": {

        "Title": "Sales KPIs",

        "Description": "Sales KPIs Description",

        "GroupedLabel": "Location",

        "GroupedType": "TEXT",

        "Label1": "Items Sold",

        "Type1": "INT",

        "Label2": "Sales Total",

        "Type2": "CURRENCY",

        "Label3": "Sales Net Total",

        "Type3": "CURRENCY",

        "Label4": "Discount Total",

        "Type4": "CURRENCY",

        "Label5": "Tax Total",

        "Type5": "CURRENCY",

        "Label6": "Tax %",

        "Type6": "PERCENT",

        "Label7": "",

        "Type7": "",

        "Label8": "",

        "Type8": "",

        "Label9": "",

        "Type9": "",

        "Label10": "",

        "Type10": "",

        "Label11": "",

        "Type11": "",

        "Label12": "",

        "Type12": "",

        "Label13": "",

        "Type13": "",

        "Label14": "",

        "Type14": "",

        "Label15": "",

        "Type15": "",

        "Label16": "",

        "Type16": "",

        "Label17": "",

        "Type17": "",

        "Label18": "",

        "Type18": "",

        "Label19": "",

        "Type19": "",

        "Label20": "",

        "Type20": "",

        "Label21": "",

        "Label22": "",

        "Type22": "",

        "Label23": "",

        "Type23": "",

        "Label24": "",

        "Type24": "",

        "Label25": "",

        "Type25": "",

        "Label26": "",

        "Type26": "",

        "Label27": "",

        "Type27": "",

        "Label28": "",

        "Type28": "",

        "Label29": "",

        "Type29": ""

      }

    }

  ]

}',
    N'SELECT
    [ParentId] AS [ParentId]
    ,    [Id] AS [Id]
    ,    [GroupedColumn] AS [GroupedColumn]
    ,    [Column1] AS [Column1]
    ,    [Column2] AS [Column2]
    ,    [CurrencyCode2] AS [CurrencyCode2]
    ,    [Column3] AS [Column3]
    ,    [CurrencyCode3] AS [CurrencyCode3]
    ,    [Column4] AS [Column4]
    ,    [CurrencyCode4] AS [CurrencyCode4]
    ,    [Column5] AS [Column5]
    ,    [CurrencyCode5] AS [CurrencyCode5]
    ,    [Column6] AS [Column6]
FROM
(
SELECT
PARENT_ID AS ParentId,
ID AS Id,
STORENAME AS GroupedColumn,
ITEMS_SOLD AS Column1,
SALES_TOTAL AS Column2,
''GBP'' AS CurrencyCode2,
SALES_NET_TOTAL AS Column3,
''GBP'' AS CurrencyCode3,
DISCOUNT_TOTAL AS Column4,
''GBP'' AS CurrencyCode4,
TAX_TOTAL AS Column5,
''USD'' AS CurrencyCode5,
TAX_PERC AS Column6,
NULL AS Column7,
NULL AS Column8,
 
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM (
SELECT --[POSTX_DATE]
CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END AS PARENT_ID
      ,[NAME] AS STORENAME
      ,SITE_HUB_ID AS ID
      --,[DAY_PERIOD]
      --,[PRODUCT_GROUP]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
    [threerocks].[dbo].Calendar C
ON POSTX_DATE = C.CalendarDate
  WHERE 1=1
@FilterClause
  GROUP BY [NAME],SITE_HUB_ID
  ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END
) SUB
 
UNION ALL
 
SELECT
PARENT_ID AS ParentId,
ID AS Id,
STORENAME AS GroupedColumn,
ITEMS_SOLD AS Column1,
SALES_TOTAL AS Column2,
''GBP'' AS CurrencyCode2,
SALES_NET_TOTAL AS Column3,
''GBP'' AS CurrencyCode3,
DISCOUNT_TOTAL AS Column4,
''GBP'' AS CurrencyCode4,
TAX_TOTAL AS Column5,
''USD'' AS CurrencyCode5,
TAX_PERC AS Column6,
NULL AS Column7,
NULL AS Column8,
 
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM (
SELECT --[POSTX_DATE]
NULL AS PARENT_ID
      ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''Area 1'' ELSE ''Area 51'' END AS STORENAME
      ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END AS ID
      --,[DAY_PERIOD]
      --,[PRODUCT_GROUP]
      ,SUM(CAST([ITEM_COUNT] AS INT)) AS ITEMS_SOLD
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)),2) AS SALES_TOTAL
      ,ROUND(SUM(CAST([NET_TOTAL] AS FLOAT)),2) AS SALES_NET_TOTAL
      ,ROUND(SUM(CAST([DISCOUNT_TOTAL] AS FLOAT)),2) AS DISCOUNT_TOTAL
      ,ROUND(SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT)),2)  AS TAX_TOTAL
      ,CASE WHEN SUM(CAST([NET_TOTAL] AS FLOAT))  = 0 THEN 0
      ELSE ROUND((SUM(CAST([CHECK_TOTAL] AS FLOAT)) - SUM(CAST([NET_TOTAL] AS FLOAT))) / SUM(CAST([NET_TOTAL] AS FLOAT)),2) END as TAX_PERC
      ,CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''C&C'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Deliveroo'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Eat In'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''JUST EAT'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''Take Away'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE = ''UBER EATS'' THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) ) + '','' +
      CAST (ROUND(SUM(CASE WHEN ORDER_TYPE IS NULL THEN CAST([CHECK_TOTAL] AS FLOAT)  ELSE 0 END),2 ) AS NVARCHAR(20) )  AS ORDER_TYPE_SALES
,''C&C,Deliveroo,Eat In,JUST EAT,Take Away,UBER EATS,Other'' AS SERIES_LABEL
      -- SELECT TOP 1000 *
  FROM [threerocks].[dbo].[CShopProductSales] F
  INNER JOIN
    [threerocks].[dbo].Calendar C
ON POSTX_DATE = C.CalendarDate
  WHERE 1=1
	@FilterClause
  GROUP BY CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''Area 1'' ELSE ''Area 51'' END
  ,CASE WHEN SUBSTRING([NAME],1,1) IN (''C'',''B'') THEN ''1'' ELSE ''2'' END
) SUB
) INPUTQUERY

SELECT
    ''Sales KPIs'' AS [Title]
    ,    ''Sales KPIs Description'' AS [Description]
    ,    ''Location'' AS [GroupedLabel]
    ,    ''TEXT'' AS [GroupedType]
    ,    ''Items Sold'' AS [Label1]
    ,    ''INT'' AS [Type1]
    ,    ''Sales Total'' AS [Label2]
    ,    ''CURRENCY'' AS [Type2]
    ,    ''Sales Net Total'' AS [Label3]
    ,    ''CURRENCY'' AS [Type3]
    ,    ''Discount Total'' AS [Label4]
    ,    ''CURRENCY'' AS [Type4]
    ,    ''Tax Total'' AS [Label5]
    ,    ''CURRENCY'' AS [Type5]
    ,    ''Tax %'' AS [Label6]
    ,    ''PERCENT'' AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SalesKPIGrouped
-- ============================================
-- CustomGroupedDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SalesKPIGrouped',
    N'CustomGroupedDataGrid',
    1,
    N'LIVE',
    N'SELECT
PARENT_ID AS ParentId,
ID AS Id,
STORENAME AS GroupedColumn,
ITEMS_SOLD AS Column1,
SALES_TOTAL AS Column2,
ATV AS Column3,
SALES_NET_TOTAL AS Column4,
DISCOUNT_TOTAL AS Column5,
TAX_TOTAL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM (
SELECT 
       NULL AS PARENT_ID
      ,COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS STORENAME
      ,COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS ID
      ,FORMAT(ROUND(SUM(F.[GROSS_VALUE])/SUM(F.[ORDER_COUNT]), 2), ''N2'') AS ATV
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''PROD'' THEN CAST(F.[QUANTITY] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS ITEMS_SOLD
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN CAST(F.[GROSS_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS SALES_TOTAL
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] != ''TENDER'' THEN CAST(F.[NET_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS SALES_NET_TOTAL
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN CAST(F.[GROSS_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS DISCOUNT_TOTAL
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] != ''TENDER'' THEN CAST(F.[TAX_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS TAX_TOTAL

FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
   -- AND F.[LI_TYPE] = ''TENDER''
   GROUP BY 
       COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
      
) SUB',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "ParentId": "ParentId",
    "Id": "Id",
    "GroupedColumn": "GroupedColumn",
    "Column1": "Column1",
    "Column2": "Column2",
    "Column3": "Column3",
    "Column4": "Column4",
    "Column5": "Column5",
    "Column6": "Column6",
    "Column7": "",
    "Column8": "",
    "Column9": "",
    "Column10": "",
    "Column11": "",
    "Column12": "",
    "Column13": "",
    "Column14": "",
    "Column15": "",
    "Column16": "",
    "Column17": "",
    "Column18": "",
    "Column19": "",
    "Column20": "",
    "Column21": "",
    "Column22": "",
    "Column23": "",
    "Column24": "",
    "Column25": "",
    "Column26": "",
    "Column27": "",
    "Column28": "",
    "Column29": ""
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "GroupedLabel",
        "GroupedType",
        "Label1",
        "Type1",
        "Label2",
        "Type2",
        "Label3",
        "Type3",
        "Label4",
        "Type4",
        "Label5",
        "Type5",
        "Label6",
        "Type6",
        "Label7",
        "Type7",
        "Label8",
        "Type8",
        "Label9",
        "Type9",
        "Label10",
        "Type10",
        "Label11",
        "Type11",
        "Label12",
        "Type12",
        "Label13",
        "Type13",
        "Label14",
        "Type14",
        "Label15",
        "Type15",
        "Label16",
        "Type16",
        "Label17",
        "Type17",
        "Label18",
        "Type18",
        "Label19",
        "Type19",
        "Label20",
        "Type20",
        "Label21",
        "Type11",
        "Label22",
        "Type22",
        "Label23",
        "Type23",
        "Label24",
        "Type24",
        "Label25",
        "Type25",
        "Label26",
        "Type26",
        "Label27",
        "Type27",
        "Label28",
        "Type28",
        "Label29",
        "Type29"
      ],
      "values": {
        "Title": "Sales KPIs",
        "Description": "Sales KPIs Description",
        "GroupedLabel": "Location",
        "GroupedType": "TEXT",
        "Label1": "Items Sold",
        "Type1": "INT",
        "Label2": "Sales Total",
        "Type2": "DECIMAL",
        "Label3": "ATV",
        "Type3": "DECIMAL",
        "Label4": "Sales Net Total",
        "Type4": "DECIMAL",
        "Label5": "Discount Total",
        "Type5": "DECIMAL",
        "Label6": "Tax Total",
        "Type6": "DECIMAL",
        "Label7": "",
        "Type7": "",
        "Label8": "",
        "Type8": "",
        "Label9": "",
        "Type9": "",
        "Label10": "",
        "Type10": "",
        "Label11": "",
        "Type11": "",
        "Label12": "",
        "Type12": "",
        "Label13": "",
        "Type13": "",
        "Label14": "",
        "Type14": "",
        "Label15": "",
        "Type15": "",
        "Label16": "",
        "Type16": "",
        "Label17": "",
        "Type17": "",
        "Label18": "",
        "Type18": "",
        "Label19": "",
        "Type19": "",
        "Label20": "",
        "Type20": "",
        "Label21": "",
        "Label22": "",
        "Type22": "",
        "Label23": "",
        "Type23": "",
        "Label24": "",
        "Type24": "",
        "Label25": "",
        "Type25": "",
        "Label26": "",
        "Type26": "",
        "Label27": "",
        "Type27": "",
        "Label28": "",
        "Type28": "",
        "Label29": "",
        "Type29": ""
      }
    }
  ]
}',
    N'SELECT
    [ParentId] AS [ParentId]
    ,    [Id] AS [Id]
    ,    [GroupedColumn] AS [GroupedColumn]
    ,    [Column1] AS [Column1]
    ,    [Column2] AS [Column2]
    ,    [Column3] AS [Column3]
    ,    [Column4] AS [Column4]
    ,    [Column5] AS [Column5]
    ,    [Column6] AS [Column6]
FROM
(
SELECT
PARENT_ID AS ParentId,
ID AS Id,
STORENAME AS GroupedColumn,
ITEMS_SOLD AS Column1,
SALES_TOTAL AS Column2,
ATV AS Column3,
SALES_NET_TOTAL AS Column4,
DISCOUNT_TOTAL AS Column5,
TAX_TOTAL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29
FROM (
SELECT 
       NULL AS PARENT_ID
      ,COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS STORENAME
      ,COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME]) AS ID
      ,FORMAT(ROUND(SUM(F.[GROSS_VALUE])/SUM(F.[ORDER_COUNT]), 2), ''N2'') AS ATV
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''PROD'' THEN CAST(F.[QUANTITY] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS ITEMS_SOLD
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''TENDER'' THEN CAST(F.[GROSS_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS SALES_TOTAL
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] != ''TENDER'' THEN CAST(F.[NET_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS SALES_NET_TOTAL
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] = ''DISCOUNT'' THEN CAST(F.[GROSS_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS DISCOUNT_TOTAL
      ,FORMAT(ROUND(SUM(CASE WHEN F.[LI_TYPE] != ''TENDER'' THEN CAST(F.[TAX_VALUE] AS FLOAT)  ELSE 0 END),2 ), ''N2'') AS TAX_TOTAL

FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
   -- AND F.[LI_TYPE] = ''TENDER''
   GROUP BY 
       COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])
      
) SUB
) INPUTQUERY

SELECT
    ''Sales KPIs'' AS [Title]
    ,    ''Sales KPIs Description'' AS [Description]
    ,    ''Location'' AS [GroupedLabel]
    ,    ''TEXT'' AS [GroupedType]
    ,    ''Items Sold'' AS [Label1]
    ,    ''INT'' AS [Type1]
    ,    ''Sales Total'' AS [Label2]
    ,    ''DECIMAL'' AS [Type2]
    ,    ''ATV'' AS [Label3]
    ,    ''DECIMAL'' AS [Type3]
    ,    ''Sales Net Total'' AS [Label4]
    ,    ''DECIMAL'' AS [Type4]
    ,    ''Discount Total'' AS [Label5]
    ,    ''DECIMAL'' AS [Type5]
    ,    ''Tax Total'' AS [Label6]
    ,    ''DECIMAL'' AS [Type6]
    ,    NULL AS [Label7]
    ,    NULL AS [Type7]
    ,    NULL AS [Label8]
    ,    NULL AS [Type8]
    ,    NULL AS [Label9]
    ,    NULL AS [Type9]
    ,    NULL AS [Label10]
    ,    NULL AS [Type10]
    ,    NULL AS [Label11]
    ,    NULL AS [Type11]
    ,    NULL AS [Label12]
    ,    NULL AS [Type12]
    ,    NULL AS [Label13]
    ,    NULL AS [Type13]
    ,    NULL AS [Label14]
    ,    NULL AS [Type14]
    ,    NULL AS [Label15]
    ,    NULL AS [Type15]
    ,    NULL AS [Label16]
    ,    NULL AS [Type16]
    ,    NULL AS [Label17]
    ,    NULL AS [Type17]
    ,    NULL AS [Label18]
    ,    NULL AS [Type18]
    ,    NULL AS [Label19]
    ,    NULL AS [Type19]
    ,    NULL AS [Label20]
    ,    NULL AS [Type20]
    ,    NULL AS [Label21]
    ,    NULL AS [Type11]
    ,    NULL AS [Label22]
    ,    NULL AS [Type22]
    ,    NULL AS [Label23]
    ,    NULL AS [Type23]
    ,    NULL AS [Label24]
    ,    NULL AS [Type24]
    ,    NULL AS [Label25]
    ,    NULL AS [Type25]
    ,    NULL AS [Label26]
    ,    NULL AS [Type26]
    ,    NULL AS [Label27]
    ,    NULL AS [Type27]
    ,    NULL AS [Label28]
    ,    NULL AS [Type28]
    ,    NULL AS [Label29]
    ,    NULL AS [Type29]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'dbadmin',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: ServiceCharges
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'ServiceCharges',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[SVCCHARGE_NAME]) AS [SVCCHARGE_NAME]
	,COALESCE([MICROSERVICE_NAME],[SVCCHARGE_NAME])  AS [SVCCHARGE_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_SVCCHARGE]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "SVCCHARGE_NAME",
    "ID": "SVCCHARGE_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Service Charges"
      }
    }
  ]
}',
    N'SELECT
    [SVCCHARGE_NAME] AS [Label]
    ,    [SVCCHARGE_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[SVCCHARGE_NAME]) AS [SVCCHARGE_NAME]
	,COALESCE([MICROSERVICE_NAME],[SVCCHARGE_NAME])  AS [SVCCHARGE_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_SVCCHARGE]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Service Charges'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Suppliers
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Suppliers',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[SUPPLIER_NAME]) AS [SUPPLIER_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[SUPPLIER_NAME]) ELSE [SUPPLIER_ID] END AS [SUPPLIER_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_SUPPLIER]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "SUPPLIER_NAME",
    "ID": "SUPPLIER_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Suppliers"
      }
    }
  ]
}',
    N'SELECT
    [SUPPLIER_NAME] AS [Label]
    ,    [SUPPLIER_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[SUPPLIER_NAME]) AS [SUPPLIER_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[SUPPLIER_NAME]) ELSE [SUPPLIER_ID] END AS [SUPPLIER_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_SUPPLIER]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Suppliers'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyAgeByGender
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAgeByGender',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Age_Bracket AS Column1,
Female AS Column2,
Male AS Column3,
Other AS Column4,
[I would rather not say] AS Column5,
total_respondents AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Age_Bracket,
SUM(CASE WHEN Gender = ''Female'' THEN 1 ELSE 0 END) as Female,
SUM(CASE WHEN Gender = ''Male'' THEN 1 ELSE 0 END) as Male,
SUM(CASE WHEN Gender = ''Other'' THEN 1 ELSE 0 END) as Other,
SUM(CASE WHEN Gender = ''I would rather not say'' THEN 1 ELSE 0 END) as [I would rather not say],
COUNT(Respondent_ID) as total_respondents -- select Distinct Gender
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
@FilterClause
Group by Age_Bracket
) SUB
 
 
SELECT
''Survey Age By Gender'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS Label1,
''TEXT'' AS TYPE1,
''Female'' AS Label2,
''INT'' AS TYPE2,
''Male'' AS Label3,
''INT'' AS TYPE3,
''Other'' AS Label4,
''INT'' AS TYPE4,
''I would rather not say'' AS Label5,
''INT'' AS TYPE5,
''Total Respondents'' AS Label6,
''INT'' AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
Age_Bracket AS Column1,
Female AS Column2,
Male AS Column3,
Other AS Column4,
[I would rather not say] AS Column5,
total_respondents AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Age_Bracket,
SUM(CASE WHEN Gender = ''Female'' THEN 1 ELSE 0 END) as Female,
SUM(CASE WHEN Gender = ''Male'' THEN 1 ELSE 0 END) as Male,
SUM(CASE WHEN Gender = ''Other'' THEN 1 ELSE 0 END) as Other,
SUM(CASE WHEN Gender = ''I would rather not say'' THEN 1 ELSE 0 END) as [I would rather not say],
COUNT(Respondent_ID) as total_respondents -- select Distinct Gender
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
@FilterClause
Group by Age_Bracket
) SUB
 
 
SELECT
''Survey Age By Gender'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS Label1,
''TEXT'' AS TYPE1,
''Female'' AS Label2,
''INT'' AS TYPE2,
''Male'' AS Label3,
''INT'' AS TYPE3,
''Other'' AS Label4,
''INT'' AS TYPE4,
''I would rather not say'' AS Label5,
''INT'' AS TYPE5,
''Total Respondents'' AS Label6,
''INT'' AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- CustomPinnedDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAgeByGender',
    N'CustomPinnedDataGrid',
    1,
    N'LIVE',
    N'SELECT 
Age_Bracket as PinnedColumn, 
Gender as Columns,
CASE 
WHEN Gender = ''Female'' then 1
WHEN Gender = ''Male'' then 2
WHEN Gender = ''I would rather not say'' then 3
WHEN Gender = ''Other'' then 4
else 999 end as ColumnsSort,
total_respondents as Value

From (

Select 
Age_Bracket,
Gender,
COUNT(Respondent_ID) as total_respondents
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
@FilterClause
Group by Age_Bracket, Gender

) SUB
 


SELECT
''Age By Gender Breakdown'' AS Title,
''Survey Age By Gender Description'' AS Description,
''Age Bracket'' AS PinnedLabel,
''TEXT'' AS PinnedType,
''Gender'' AS ColumnsLabel,
''TEXT'' AS ColumnsType,
150 AS ColumnsMinWidth,
''# Respondents'' AS ValueLabel,
''INT'' AS ValueType',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "CommunityInvolvement": {
    "column": "Community Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyAgeByRespondentTotal
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAgeByRespondentTotal',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT 
AGE_BRACKET AS BarLabel,
CASE 
	WHEN Age_Bracket = ''Age 12-15'' then 1
	WHEN Age_Bracket = ''Age 16-20'' then 2
	WHEN Age_Bracket = ''Age 21-30'' then 3
	WHEN Age_Bracket = ''Age 31-40'' then 4
	WHEN Age_Bracket = ''Age 41-50'' then 5
	WHEN Age_Bracket = ''Age 51-60'' then 6
	WHEN Age_Bracket = ''Age 61-70'' then 7
	WHEN Age_Bracket = ''Age 71-80'' then 8
	WHEN Age_Bracket = ''Age 81+'' then 9
else 999 end as BarLabelSort,
total_respondents as BarValue,
ROW_NUMBER() OVER (ORDER BY total_respondents) AS BarValueSort


From (

Select 
Age_Bracket, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where 1=1
and Survey_Status = ''Complete''
@FilterClause
Group by Age_Bracket

) SUB


SELECT
''Age Group'' AS XAxisLabel,
''# Respondents'' as YAxisLabel,
''Respondents by Age Group'' as Title,
NULL as Description,
NULL as Trend, 
(SELECT
	COUNT(*)
FROM
	[threerocks].[dbo].church_survey_results

WHERE 1=1
and Survey_Status = ''Complete''
@FilterClause
) as TotalValue, 
NULL as Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyAgeGender
-- ============================================
-- HeatmapCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAgeGender',
    N'HeatmapCard',
    1,
    N'LIVE',
    N'SELECT
    Age_Bracket AS XAxisLabel
    ,gender AS YAxisLabel
    ,count AS Value
FROM
(
select 
    age_bracket
    , Gender
    , COUNT(*) as count
FROM threerocks.dbo.church_survey_results
where Survey_Status = ''Complete''
group by Age_Bracket, gender
) sub

SELECT
    ''Age / Gender Heatmap'' AS Title
    ,''Age / Gender Heatmap'' AS Description',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyAverageChallengeScore
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAverageChallengeScore',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT 
VisId AS Label,
average_score as Value,
VisId as Id, 
''linear'' as Curve,
''total'' as Stack,
''true'' as Area,
''ascending'' as StackOrder,
''false'' as ShowMark,
''Gender'' as LegendLabel


From (


    SELECT 
        Community_Involvement AS VisId,
        CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS average_score
    FROM (
        SELECT 
            Survey_Status,
            Community_Involvement,
            Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
        FROM threerocks.dbo.church_survey_results
        WHERE 1=1
@FilterClause
--Community_Involvement IN (''Church Member'', ''Influencer'', ''Resident'', ''Worker'')
            AND Survey_Status = ''Complete''
    ) AS SourceTable
    UNPIVOT (
        Score FOR Activity_Type IN (
            Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
        )
    ) AS UnpivotedTable
    GROUP BY Community_Involvement

) SUB


Select 
''Average Score by Community Involvement'' as Title,
''Average Score by Community Involvement'' as Description,
NULL as Trend,
NULL as Chip,
NULL as PiePrimaryText, 
NULL as PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyAverageLifestyleScore
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAverageLifestyleScore',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT 
VisId AS Label,
average_score as Value,
VisId as Id, 
''linear'' as Curve,
''total'' as Stack,
''true'' as Area,
''ascending'' as StackOrder,
''false'' as ShowMark,
''Gender'' as LegendLabel


From (


    SELECT 
        Community_Involvement AS VisId,
        CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS average_score
    FROM (
        SELECT 
            Survey_Status,
            Community_Involvement,
            Activities_Provision_for_Families,
            Activities_Provision_for_Young_People,
            Activities_Provision_for_Elderly,
            Activities_Provision_for_Children,
            Activities_Provision_for_Healthcare,
            Activities_Provision_for_Sport,
            Activities_Provision_for_Education,
            Activities_Provision_for_Arts
        FROM threerocks.dbo.church_survey_results
        WHERE Community_Involvement IN (''Church Member'', ''Influencer'', ''Resident'', ''Worker'')
            AND Survey_Status = ''Complete''
    ) AS SourceTable
    UNPIVOT (
        Score FOR Activity_Type IN (
            Activities_Provision_for_Families,
            Activities_Provision_for_Young_People,
            Activities_Provision_for_Elderly,
            Activities_Provision_for_Children,
            Activities_Provision_for_Healthcare,
            Activities_Provision_for_Sport,
            Activities_Provision_for_Education,
            Activities_Provision_for_Arts
        )
    ) AS UnpivotedTable
    GROUP BY Community_Involvement

) SUB


Select 
''Average Score by Community Involvement'' as Title,
''Average Score by Community Involvement'' as Description,
NULL as Trend,
NULL as Chip,
NULL as PiePrimaryText, 
NULL as PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyBuildingActivities
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyBuildingActivities',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT 
Buildings_Suited_to_activities AS Label,
total_respondents as Value,
Buildings_Suited_to_activities as Id, 
''linear'' as Curve,
''total'' as Stack,
''true'' as Area,
''ascending'' as StackOrder,
''false'' as ShowMark,
''Building Use'' as LegendLabel


From (

Select 
Buildings_Suited_to_activities, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where Survey_Status = ''Complete''
and Buildings_Suited_to_activities is not null
Group by Buildings_Suited_to_activities

) SUB


Select 
''Buildings_Suited_to_activities'' as Title,
NULL as Description,
NULL as Trend,
NULL as Chip,
NULL as PiePrimaryText, 
NULL as PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyBuildingSuited
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyBuildingSuited',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT 
Buildings_Suited_Overall AS Label,
total_respondents as Value,
Buildings_Suited_Overall as Id, 
''linear'' as Curve,
''total'' as Stack,
''true'' as Area,
''ascending'' as StackOrder,
''false'' as ShowMark,
''Building Use'' as LegendLabel


From (

Select 
Buildings_Suited_Overall, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where Survey_Status = ''Complete''
and Buildings_Suited_Overall is not null
Group by Buildings_Suited_Overall

) SUB


Select 
''Are the buildings suited Overall?'' as Title,
NULL as Description,
NULL as Trend,
NULL as Chip,
NULL as PiePrimaryText, 
NULL as PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyBuildingUse
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyBuildingUse',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT 
service AS BarLabel,
CASE 
	WHEN service = ''[other activities]'' then 1
	WHEN service = ''Care Activities'' then 2
	WHEN service = ''Services'' then 3
	WHEN service = ''Children''''s work'' then 4
	WHEN service = ''Youth work'' then 5
	WHEN service = ''Lunch Clubs'' then 6
	WHEN service = ''Other'' then 7
else 999 end as BarLabelSort,
count as BarValue,
ROW_NUMBER() OVER (ORDER BY count) AS BarValueSort


From (

SELECT 
    TRIM(value) AS service,
    COUNT(*) AS count
FROM threerocks.dbo.church_survey_results
CROSS APPLY STRING_SPLIT(Involved_in, '';'')
WHERE TRIM(value) != ''''
    AND Survey_Status = ''Complete''
	@FilterClause
GROUP BY TRIM(value)
--ORDER BY count DESC

) SUB


SELECT
''Building Use'' AS XAxisLabel,
''# Respondents'' as YAxisLabel,
''# Respondents by Building Use'' as Title,
NULL as Description,
NULL as Trend, 
NULL as TotalValue, 
NULL as Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyBuildingUse',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT 
Use_Buildings_Regularly AS Label,
total_respondents as Value,
Use_Buildings_Regularly as Id, 
''linear'' as Curve,
''total'' as Stack,
''true'' as Area,
''ascending'' as StackOrder,
''false'' as ShowMark,
''Building Use'' as LegendLabel


From (

Select 
Use_Buildings_Regularly, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where 1=1 
and Survey_Status = ''Complete''
@FilterClause
Group by Use_Buildings_Regularly

) SUB


Select 
''Building Use'' as Title,
''Building Use by Respondent'' as Description,
NULL as Trend,
NULL as Chip,
NULL as PiePrimaryText, 
NULL as PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyBuildingUseImprovements
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyBuildingUseImprovements',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Building Improvements Needed'' AS Title,
    STRING_AGG(CAST(''• '' + Improvements_Needed AS VARCHAR(MAX)), ''<br>'') AS Value
FROM threerocks.dbo.church_survey_results
WHERE 1=1 
    --@filterclause
    AND Survey_Status = ''Complete''
    AND Use_Buildings_Regularly = ''Yes''
    AND Improvements_Needed IS NOT NULL',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyBuildingUseMessage
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyBuildingUseMessage',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Message To Visitors'' AS Title,
    STRING_AGG(CAST(''• '' + message_to_visitors AS VARCHAR(MAX)), ''<br>'') AS Value
FROM threerocks.dbo.church_survey_results
WHERE 1=1 
    --@filterclause
    AND Survey_Status = ''Complete''
    AND Use_Buildings_Regularly = ''Yes''
    AND Improvements_Needed IS NOT NULL',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyChallengeThoughts
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengeThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Extra_Thoughts_Challenging_Issues AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Extra_Thoughts_Challenging_Issues
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and community_involvement = ''Church Member''
and Extra_Thoughts_Challenging_Issues is not null


) SUB
 
 
SELECT
''Challenging Issues - Extra Thoughts'' AS Title,
''Challenging Issues - Extra Thoughts'' AS Description,
''Extra Thoughts - Church Members'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyChallengeThoughtsnonChurch
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengeThoughtsnonChurch',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Extra_Thoughts_Challenging_Issues AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Extra_Thoughts_Challenging_Issues
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and Extra_Thoughts_Challenging_Issues is not null
@filterclause


) SUB
 
 
SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyChallengingRadar
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengingRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT 
    
    CASE WHEN Activity_Type = ''Provision_for_Financial_Help'' then ''Financial Help''
    when Activity_Type = ''Provision_for_Domestic_Abuse'' then ''Domestic Abuse''
    when Activity_Type = ''Provision_for_Behavior_Crime'' then ''Crime''
    when Activity_Type = ''Provision_for_Discrimination'' then ''Discrimination''
    when Activity_Type = ''Provision_for_Unemployment'' then ''Unemployment''
    when Activity_Type = ''Provision_for_Addiction'' then ''Addiction''
    when Activity_Type = ''Provision_for_Homelessness'' then ''Homelessness''
    when Activity_Type = ''Provision_for_Disability'' then ''Disability''
    end as Axis,
    Community_Involvement as Label,
    CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS Value
FROM (
    SELECT 
        Community_Involvement,
        Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
    FROM threerocks.dbo.church_survey_results
    WHERE 1=1
    and Survey_Status = ''Complete''
    @FilterClause
) AS SourceTable
UNPIVOT (
    Score FOR Activity_Type IN (
       Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
    )
) AS UnpivotedTable
GROUP BY Community_Involvement, Activity_Type
ORDER BY Community_Involvement, Activity_Type


SELECT
''Average Score by Provision'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyCompletion
-- ============================================
-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyCompletion',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'select 

Survey_Status as xAxisLabel,
ROW_NUMBER() OVER(ORDER BY Survey_status) AS LabelSort,
total_respondents as [Value],
ROW_NUMBER() OVER(ORDER BY total_respondents) AS ValueSort,
Community_Involvement as VisId,
stack as Stack


from (
select 
COUNT(*) as total_respondents
, survey_status
, Community_involvement 
, ''A'' as stack
from 
threerocks.dbo.church_survey_results
Where Community_Involvement = ''Church Member''
group by Survey_Status, Community_Involvement

union All

select 
COUNT(*) as total_respondents
, survey_status
, Community_involvement 
, ''A'' as stack
from 
threerocks.dbo.church_survey_results
Where Community_Involvement = ''Influencer''
group by Survey_Status, Community_Involvement

union All

select 
COUNT(*) as total_respondents
, survey_status
, Community_involvement 
, ''A'' as stack
from 
threerocks.dbo.church_survey_results
Where Community_Involvement = ''Resident''
group by Survey_Status, Community_Involvement

union All

select 
COUNT(*) as total_respondents
, survey_status
, Community_involvement 
, ''A'' as stack
from 
threerocks.dbo.church_survey_results
Where Community_Involvement = ''Worker''
group by Survey_Status, Community_Involvement


) sub 



SELECT
''Survey Status'' AS XAxisLabel,
''Total respondents'' AS YAxisLabel,
''Completion Status by Community Involvement'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	COUNT(*)
FROM
	[threerocks].[dbo].church_survey_results

WHERE 1=1
@FilterClause
) AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyDistanceTransport
-- ============================================
-- HeatmapCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyDistanceTransport',
    N'HeatmapCard',
    1,
    N'LIVE',
    N'SELECT
    Distance_to_Church AS XAxisLabel
    ,Transport_Method AS YAxisLabel
    ,count AS Value
FROM
(
select 
    Distance_to_Church
    , Transport_Method
    , COUNT(*) as count
FROM threerocks.dbo.church_survey_results
where Survey_Status = ''Complete''
and Community_Involvement = ''Church Member''
group by Distance_to_Church, Transport_Method
) sub

SELECT
    ''Church Transport and Distance'' AS Title
    ,''Church Transport and Distance'' AS Description',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyEnvironmentRadar
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT 
    
    CASE WHEN Activity_Type = ''Activities_Provision_for_Arts'' then ''Arts''
    when Activity_Type = ''Activities_Provision_for_Children'' then ''Children''
    when Activity_Type = ''Activities_Provision_for_Education'' then ''Education''
    when Activity_Type = ''Activities_Provision_for_Elderly'' then ''Elderly''
    when Activity_Type = ''Activities_Provision_for_Families'' then ''Families''
    when Activity_Type = ''Activities_Provision_for_Healthcare'' then ''Healthcare''
    when Activity_Type = ''Activities_Provision_for_Sport'' then ''Sport''
    when Activity_Type = ''Activities_Provision_for_Young_People'' then ''Young People''
    end as Axis,
    Community_Involvement as Label,
    CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS Value
FROM (
    SELECT 
        Community_Involvement,
        Activities_Provision_for_Families,
        Activities_Provision_for_Young_People,
        Activities_Provision_for_Elderly,
        Activities_Provision_for_Children,
        Activities_Provision_for_Healthcare,
        Activities_Provision_for_Sport,
        Activities_Provision_for_Education,
        Activities_Provision_for_Arts
    FROM threerocks.dbo.church_survey_results
    WHERE 1=1
    and Survey_Status = ''Complete''
    @FilterClause
) AS SourceTable
UNPIVOT (
    Score FOR Activity_Type IN (
        Activities_Provision_for_Families,
        Activities_Provision_for_Young_People,
        Activities_Provision_for_Elderly,
        Activities_Provision_for_Children,
        Activities_Provision_for_Healthcare,
        Activities_Provision_for_Sport,
        Activities_Provision_for_Education,
        Activities_Provision_for_Arts
    )
) AS UnpivotedTable
GROUP BY Community_Involvement, Activity_Type
ORDER BY Community_Involvement, Activity_Type


SELECT
''Average Score by Activity / Provision'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyEnvironmentRadarBad
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentRadarBad',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT 
    
    CASE WHEN Activity_Type = ''Green_Space'' then ''Arts''
    when Activity_Type = ''Public_Open_Space'' then ''Children''
    when Activity_Type = ''Food_Grocery_Shops'' then ''Education''
    when Activity_Type = ''Other_Shops'' then ''Elderly''
    when Activity_Type = ''Local_Amenities'' then ''Families''
    when Activity_Type = ''Public_Transport_Links'' then ''Healthcare''
    when Activity_Type = ''Public_Buildings'' then ''Sport''
    when Activity_Type = ''Cleanliness_of_Street_Public_Spaces'' then ''Young People''
    when Activity_Type = ''Upkeep_of_Buildings'' then ''Young People''
    when Activity_Type = ''Climate_Change_Sustainability'' then ''Young People''
    end as Axis,
    Community_Involvement as Label,
    CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS Value
FROM (
    SELECT 
        Community_Involvement,
        Green_Space,
        Public_Open_Space,
        Food_Grocery_Shops,
        Other_Shops,
        Local_Amenities,
        Public_Transport_Links,
        Public_Buildings,
        Cleanliness_of_Street_Public_Spaces,
        Upkeep_of_Buildings,
        Climate_Change_Sustainability
    FROM threerocks.dbo.church_survey_results
    WHERE 1=1
    and Survey_Status = ''Complete''
    @FilterClause
) AS SourceTable
UNPIVOT (
    Score FOR Activity_Type IN (
        Green_Space,
        Public_Open_Space,
        Food_Grocery_Shops,
        Other_Shops,
        Local_Amenities,
        Public_Transport_Links,
        Public_Buildings,
        Cleanliness_of_Street_Public_Spaces,
        Upkeep_of_Buildings,
        Climate_Change_Sustainability
    )
) AS UnpivotedTable
GROUP BY Community_Involvement, Activity_Type
ORDER BY Community_Involvement, Activity_Type


SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyEnvironmentThoughts
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Extra_Thoughts_Lifestyle_Provision AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Extra_Thoughts_Lifestyle_Provision
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and Extra_Thoughts_Lifestyle_Provision is not null
@FilterClause


) SUB
 
 
SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyFilter
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyFilter',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
Community_Involvement AS Label,
Community_Involvement AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM threerocks.dbo.church_survey_results
WHERE 1=1
@FilterClause

SELECT
''Community Involvement'' AS Title',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyFilterAge
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyFilterAge',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
Age_Bracket AS Label,
Age_Bracket AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM threerocks.dbo.church_survey_results
WHERE 1=1
@FilterClause

SELECT
''Age Bracket'' AS Title',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyGenderByRespondentTotal
-- ============================================
-- PieChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyGenderByRespondentTotal',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT 
Gender AS Label,
total_respondents as Value,
Gender as Id, 
''linear'' as Curve,
''total'' as Stack,
''true'' as Area,
''ascending'' as StackOrder,
''false'' as ShowMark,
''Gender'' as LegendLabel


From (

Select 
Gender, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where 1=1 
and Survey_Status = ''Complete''
@FilterClause
Group by Gender

) SUB


Select 
''Gender Breakdown'' as Title,
NULL as Description,
NULL as Trend,
NULL as Chip,
NULL as PiePrimaryText, 
NULL as PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyImprovementsNeeded
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyImprovementsNeeded',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Improvements_Needed AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Improvements_Needed
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and Improvements_Needed is not null
@FilterClause


) SUB
 
 
SELECT
NULL AS Title,
NULL AS Description,
''Building Improvements Needed'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "DECIMAL"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyLifestyleProvision
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleProvision',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT 
Activities AS BarLabel,
CASE 
	WHEN Activities = ''Families'' then 1
	WHEN Activities = ''Young People'' then 2
	WHEN Activities = ''Elderly'' then 3
	WHEN Activities = ''Children'' then 4
	WHEN Activities = ''Healthcare'' then 5
	WHEN Activities = ''Sports'' then 6
	WHEN Activities = ''Education'' then 7
	WHEN Activities = ''Arts'' then 8
else 999 end as BarLabelSort,
average_score as BarValue,
ROW_NUMBER() OVER (ORDER BY average_score) AS BarValueSort


From (
select * From (
Select 
SURVEY_status,
Community_involvement,
''Families'' as Activities,
cast(AVG(cast(activities_provision_for_families as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Young People'' as Activities,
cast(AVG(cast(Activities_Provision_for_Young_People as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Elderly'' as Activities,
cast(AVG(cast(Activities_Provision_for_Elderly as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Children'' as Activities,
cast(AVG(cast(Activities_Provision_for_Children as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Healthcare'' as Activities,
cast(AVG(cast(Activities_Provision_for_Healthcare as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Sports'' as Activities,
cast(AVG(cast(Activities_Provision_for_Sport as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Education'' as Activities,
cast(AVG(cast(Activities_Provision_for_Education as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement

UNION ALL

Select
SURVEY_status,
Community_involvement,
''Arts'' as Activities,
cast(AVG(cast(Activities_Provision_for_Arts as FLOAT)) AS decimal(5,2)) as average_score
from threerocks.dbo.church_survey_results
GROUP BY SURVEY_status,
Community_involvement





) sub

where 1=1
@FilterClause
and Survey_Status = ''Complete''
and Community_Involvement = ''Influencer''

) SUB


SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' as YAxisLabel,
''Average Score by Lifestyle Provision'' as Title,
''Average Score by Lifestyle Provision'' as Description,
NULL as Trend, 
NULL as TotalValue, 
NULL as Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyLifestyleProvisionThoughts
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleProvisionThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Extra_Thoughts_Lifestyle_Provision AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Extra_Thoughts_Lifestyle_Provision
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and community_involvement = ''Church Member''
and Extra_Thoughts_Lifestyle_Provision is not null


) SUB
 
 
SELECT
''Lifestyle Provision - Extra Thoughts'' AS Title,
''Lifestyle Provision - Extra Thoughts'' AS Description,
''Extra Thoughts - Church Members'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyLifestyleProvisionThoughtsnonChurch
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleProvisionThoughtsnonChurch',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Extra_Thoughts_Lifestyle_Provision AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Extra_Thoughts_Lifestyle_Provision
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and Extra_Thoughts_Lifestyle_Provision is not null
@FilterClause


) SUB
 
 
SELECT
NULL AS Title,
NULL AS Description,
''Extra Thoughts'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyLifestyleRadar
-- ============================================
-- RadarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT 
    
    CASE WHEN Activity_Type = ''Activities_Provision_for_Arts'' then ''Arts''
    when Activity_Type = ''Activities_Provision_for_Children'' then ''Children''
    when Activity_Type = ''Activities_Provision_for_Education'' then ''Education''
    when Activity_Type = ''Activities_Provision_for_Elderly'' then ''Elderly''
    when Activity_Type = ''Activities_Provision_for_Families'' then ''Families''
    when Activity_Type = ''Activities_Provision_for_Healthcare'' then ''Healthcare''
    when Activity_Type = ''Activities_Provision_for_Sport'' then ''Sport''
    when Activity_Type = ''Activities_Provision_for_Young_People'' then ''Young People''
    end as Axis,
    Community_Involvement as Label,
    CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS Value
FROM (
    SELECT 
        Community_Involvement,
        Activities_Provision_for_Families,
        Activities_Provision_for_Young_People,
        Activities_Provision_for_Elderly,
        Activities_Provision_for_Children,
        Activities_Provision_for_Healthcare,
        Activities_Provision_for_Sport,
        Activities_Provision_for_Education,
        Activities_Provision_for_Arts
    FROM threerocks.dbo.church_survey_results
    WHERE 1=1
    and Survey_Status = ''Complete''
    @FilterClause
) AS SourceTable
UNPIVOT (
    Score FOR Activity_Type IN (
        Activities_Provision_for_Families,
        Activities_Provision_for_Young_People,
        Activities_Provision_for_Elderly,
        Activities_Provision_for_Children,
        Activities_Provision_for_Healthcare,
        Activities_Provision_for_Sport,
        Activities_Provision_for_Education,
        Activities_Provision_for_Arts
    )
) AS UnpivotedTable
GROUP BY Community_Involvement, Activity_Type
ORDER BY Community_Involvement, Activity_Type


SELECT
''Average Score by Activity / Provision'' AS Title,
NULL AS Description,
NULL AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Axis": "",
    "AxisSort": "",
    "Label": "",
    "Value": ""
  },
  "additional_datasets": [
    {
      "name": "Header",
      "type": "Header",
      "columns": [
        "Title",
        "Description",
        "Value"
      ],
      "values": {
        "Title": "",
        "Description": "",
        "Value": ""
      }
    }
  ]
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyLifestyleThoughts
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleThoughts',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Lifestyle Provision Extra Thoughts'' AS Title,
    STRING_AGG(''• '' + Extra_Thoughts_Lifestyle_Provision, ''<br>'') AS Value
FROM threerocks.dbo.church_survey_results
WHERE 1=1 
    --@filterclause
    AND Survey_Status = ''Complete''
    AND Community_Involvement = ''Influencer''
    AND Extra_Thoughts_Lifestyle_Provision IS NOT NULL',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyMemberActivities
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyMemberActivities',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT 
service AS BarLabel,
CASE 
	WHEN service = ''Children''''s work'' then 1
	WHEN service = ''Services'' then 2
	WHEN service = ''Youth work'' then 3
	WHEN service = ''Outreach groups'' then 4
	WHEN service = ''Street pastors'' then 5
	WHEN service = ''Breakfast / lunch groups'' then 6
	WHEN service = ''Home / Study / Prayer Groups'' then 7
else 999 end as BarLabelSort,
count as BarValue,
ROW_NUMBER() OVER (ORDER BY count) AS BarValueSort


From (

SELECT 
    TRIM(value) AS service,
    COUNT(*) AS count
FROM threerocks.dbo.church_survey_results
CROSS APPLY STRING_SPLIT(Regular_Activities, '';'')
WHERE TRIM(value) != ''''
    AND Survey_Status = ''Complete''
GROUP BY TRIM(value)
--ORDER BY count DESC

) SUB


SELECT
''Regular Activities'' AS XAxisLabel,
''# Respondents'' as YAxisLabel,
''Church Member Regular Activities'' as Title,
NULL as Description,
NULL as Trend, 
NULL as TotalValue, 
NULL as Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyMembersDistance
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyMembersDistance',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT 
Distance_to_Church AS BarLabel,
CASE 
	WHEN Distance_to_Church = ''Less than 1 mile'' then 1
	WHEN Distance_to_Church = ''2-5 miles'' then 2
	WHEN Distance_to_Church = ''5-10 miles'' then 3
	WHEN Distance_to_Church = ''11+ miles'' then 4

else 999 end as BarLabelSort,
total_respondents as BarValue,
ROW_NUMBER() OVER (ORDER BY total_respondents) AS BarValueSort


From (

Select 
Distance_to_Church, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where Survey_Status = ''Complete''
and Distance_to_Church is not null
Group by Distance_to_Church

) SUB


SELECT
''Distance Travelled'' AS XAxisLabel,
''# Respondents'' as YAxisLabel,
''# Respondents by Distance Travelled'' as Title,
''Distance to Church by Church Members'' as Description,
NULL as Trend, 
NUll as TotalValue, 
NULL as Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyMembersTravel
-- ============================================
-- BarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyMembersTravel',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT 
Transport_Method AS BarLabel,
CASE 
	WHEN Transport_Method = ''Car'' then 1
	WHEN Transport_Method = ''Cycle'' then 2
	WHEN Transport_Method = ''Public Transport'' then 3
	WHEN Transport_Method = ''Walk'' then 4

else 999 end as BarLabelSort,
total_respondents as BarValue,
ROW_NUMBER() OVER (ORDER BY total_respondents) AS BarValueSort


From (

Select 
Transport_Method, 
COUNT(Respondent_ID) as total_respondents
From [threerocks].[dbo].[church_survey_results]
where Survey_Status = ''Complete''
and Transport_Method is not null
Group by Transport_Method

) SUB


SELECT
''Transport Method'' AS XAxisLabel,
''# Respondents'' as YAxisLabel,
''# Respondents by Transport Method'' as Title,
''How Church Members Travel to Church'' as Description,
NULL as Trend, 
NUll as TotalValue, 
NULL as Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyRespondentByChallenge
-- ============================================
-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByChallenge',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
    CASE WHEN XAxisLabel = ''Provision_for_Financial_Help'' then ''Financial Help''
    when XAxisLabel = ''Provision_for_Domestic_Abuse'' then ''Domestic Abuse''
    when XAxisLabel = ''Provision_for_Behavior_Crime'' then ''Crime''
    when XAxisLabel = ''Provision_for_Discrimination'' then ''Discrimination''
    when XAxisLabel = ''Provision_for_Unemployment'' then ''Unemployment''
    when XAxisLabel = ''Provision_for_Addiction'' then ''Addiction''
    when XAxisLabel = ''Provision_for_Disability'' then ''Disability''
    when XAxisLabel = ''Provision_for_Homelessness'' then ''Homelessness''
    end as XAxisLabel,
    ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort,
    average_score AS [Value],
    ROW_NUMBER() OVER(ORDER BY average_score) AS ValueSort,
    VisId,
    Stack
FROM (
    SELECT 
        Activity_Type AS XAxisLabel,
        CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS average_score,
        Community_Involvement AS VisId,
        CASE Community_Involvement
            WHEN ''Church Member'' THEN ''A''
            WHEN ''Influencer'' THEN ''B''
            WHEN ''Resident'' THEN ''C''
            WHEN ''Worker'' THEN ''D''
        END AS Stack
    FROM (
        SELECT 
            Survey_Status,
            Community_Involvement,
            Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
        FROM threerocks.dbo.church_survey_results
        WHERE 1=1
@FilterClause
--Community_Involvement IN (''Church Member'', ''Influencer'', ''Resident'', ''Worker'')
            AND Survey_Status = ''Complete''
    ) AS SourceTable
    UNPIVOT (
        Score FOR Activity_Type IN (
            Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
        )
    ) AS UnpivotedTable
    GROUP BY Community_Involvement, Activity_Type
) AS sub



SELECT
''Provision for Challenging Issues'' AS XAxisLabel,
''Total Respondents'' AS YAxisLabel,
''Average score by Provision'' AS Title,
''Average score by Provision'' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	COUNT(*)
FROM
	[threerocks].[dbo].church_survey_results

WHERE 1=1
and Survey_Status = ''Complete''
@FilterClause
) AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyRespondentByEnvironment
-- ============================================
-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByEnvironment',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
    CASE WHEN XAxisLabel = ''Provision_for_Financial_Help'' then ''Financial Help''
    when XAxisLabel = ''Provision_for_Domestic_Abuse'' then ''Domestic Abuse''
    when XAxisLabel = ''Provision_for_Behavior_Crime'' then ''Crime''
    when XAxisLabel = ''Provision_for_Discrimination'' then ''Discrimination''
    when XAxisLabel = ''Provision_for_Unemployment'' then ''Unemployment''
    when XAxisLabel = ''Provision_for_Addiction'' then ''Addiction''
    when XAxisLabel = ''Provision_for_Disability'' then ''Disability''
    when XAxisLabel = ''Provision_for_Homelessness'' then ''Homelessness''
    end as XAxisLabel,
    ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort,
    average_score AS [Value],
    ROW_NUMBER() OVER(ORDER BY average_score) AS ValueSort,
    VisId,
    Stack
FROM (
    SELECT 
        Activity_Type AS XAxisLabel,
        CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS average_score,
        Community_Involvement AS VisId,
        CASE Community_Involvement
            WHEN ''Church Member'' THEN ''A''
            WHEN ''Influencer'' THEN ''B''
            WHEN ''Resident'' THEN ''C''
            WHEN ''Worker'' THEN ''D''
        END AS Stack
    FROM (
        SELECT 
            Survey_Status,
            Community_Involvement,
            Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
        FROM threerocks.dbo.church_survey_results
        WHERE 1=1
@FilterClause
--Community_Involvement IN (''Church Member'', ''Influencer'', ''Resident'', ''Worker'')
            AND Survey_Status = ''Complete''
    ) AS SourceTable
    UNPIVOT (
        Score FOR Activity_Type IN (
            Provision_for_Financial_Help,
            Provision_for_Domestic_Abuse,
            Provision_for_Behavior_Crime,
            Provision_for_Discrimination,
            Provision_for_Unemployment,
            Provision_for_Addiction,
            Provision_for_Disability,
            Provision_for_Homelessness
        )
    ) AS UnpivotedTable
    GROUP BY Community_Involvement, Activity_Type
) AS sub



SELECT
''Provision for Challenging Issues'' AS XAxisLabel,
''Total Respondents'' AS YAxisLabel,
''Average score by Provision'' AS Title,
''Average score by Provision'' AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	COUNT(*)
FROM
	[threerocks].[dbo].church_survey_results

WHERE 1=1
and Survey_Status = ''Complete''
@FilterClause
) AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyRespondentByLifestyle
-- ============================================
-- StackedBarChartCard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByLifestyle',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
    CASE WHEN XAxisLabel = ''Activities_Provision_for_Arts'' then ''Arts''
    when XAxisLabel = ''Activities_Provision_for_Children'' then ''Children''
    when XAxisLabel = ''Activities_Provision_for_Education'' then ''Education''
    when XAxisLabel = ''Activities_Provision_for_Elderly'' then ''Elderly''
    when XAxisLabel = ''Activities_Provision_for_Families'' then ''Families''
    when XAxisLabel = ''Activities_Provision_for_Healthcare'' then ''Healthcare''
    when XAxisLabel = ''Activities_Provision_for_Sport'' then ''Sport''
    when XAxisLabel = ''Activities_Provision_for_Young_People'' then ''Young People''
    end as XAxisLabel,
    ROW_NUMBER() OVER(ORDER BY XAxisLabel) AS LabelSort,
    average_score AS [Value],
    ROW_NUMBER() OVER(ORDER BY average_score) AS ValueSort,
    VisId,
    Stack
FROM (
    SELECT 
        Activity_Type AS XAxisLabel,
        CAST(AVG(CAST(Score AS FLOAT)) AS DECIMAL(5,2)) AS average_score,
        Community_Involvement AS VisId,
        CASE Community_Involvement
            WHEN ''Church Member'' THEN ''A''
            WHEN ''Influencer'' THEN ''B''
            WHEN ''Resident'' THEN ''C''
            WHEN ''Worker'' THEN ''D''
        END AS Stack
    FROM (
        SELECT 
            Survey_Status,
            Community_Involvement,
            Activities_Provision_for_Families,
            Activities_Provision_for_Young_People,
            Activities_Provision_for_Elderly,
            Activities_Provision_for_Children,
            Activities_Provision_for_Healthcare,
            Activities_Provision_for_Sport,
            Activities_Provision_for_Education,
            Activities_Provision_for_Arts
        FROM threerocks.dbo.church_survey_results
        WHERE 1=1 and
		Community_Involvement IN (''Church Member'', ''Influencer'', ''Resident'', ''Worker'')
            AND Survey_Status = ''Complete''
	@filterclause
    ) AS SourceTable
    UNPIVOT (
        Score FOR Activity_Type IN (
            Activities_Provision_for_Families,
            Activities_Provision_for_Young_People,
            Activities_Provision_for_Elderly,
            Activities_Provision_for_Children,
            Activities_Provision_for_Healthcare,
            Activities_Provision_for_Sport,
            Activities_Provision_for_Education,
            Activities_Provision_for_Arts
        )
    ) AS UnpivotedTable
    GROUP BY Community_Involvement, Activity_Type
) AS sub



SELECT
''Activity & Provision'' AS XAxisLabel,
''Total Respondents'' AS YAxisLabel,
''Average score by Activity & Provision'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(SELECT
	COUNT(*)
FROM
	[threerocks].[dbo].church_survey_results

WHERE 1=1
and Survey_Status = ''Complete''
@FilterClause
) AS Value',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_Bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyStatusByInvolvement
-- ============================================
-- CustomPinnedDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyStatusByInvolvement',
    N'CustomPinnedDataGrid',
    1,
    N'LIVE',
    N'SELECT 
Community_Involvement as PinnedColumn, 
Survey_Status as Columns,
CASE 
WHEN Survey_Status = ''Complete'' then 1
WHEN Survey_Status = ''Incomplete'' then 2
else 999 end as ColumnsSort,
total_respondents as Value

From (

Select 
Community_Involvement,
Survey_Status,
COUNT(Respondent_ID) as total_respondents
From threerock.dbo.church_survey_results
--where Survey_Status = ''Complete''
Group by Community_Involvement, Survey_Status

) SUB
 


SELECT
''Survey Completion'' AS Title,
''Survey Completion Description'' AS Description,
NULL AS PinnedLabel,
NULL AS PinnedType,
''Completion Status'' AS ColumnsLabel,
''TEXT'' AS ColumnsType,
150 AS ColumnsMinWidth,
''# Respondents'' AS ValueLabel,
''INT'' AS ValueType',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: SurveyVisitorMessage
-- ============================================
-- CustomDataGrid - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyVisitorMessage',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
Message_to_Visitors AS Column1,
NULL AS Column2,
NULL AS Column3,
NULL AS Column4,
NULL AS Column5,
NULL AS Column6,
NULL AS Column7,
NULL AS Column8,
NULL AS Column9,
NULL AS Column10,
NULL AS Column11,
NULL AS Column12,
NULL AS Column13,
NULL AS Column14,
NULL AS Column15,
NULL AS Column16,
NULL AS Column17,
NULL AS Column18,
NULL AS Column19,
NULL AS Column20,
NULL AS Column21,
NULL AS Column22,
NULL AS Column23,
NULL AS Column24,
NULL AS Column25,
NULL AS Column26,
NULL AS Column27,
NULL AS Column28,
NULL AS Column29,
NULL AS Column30
FROM (
Select 
Message_to_Visitors
From threerocks.dbo.church_survey_results
where 1=1
and Survey_Status = ''Complete''
and Message_to_Visitors is not null
@FilterClause


) SUB
 
 
SELECT
NULL AS Title,
NULL AS Description,
''Message to Visitors'' AS Label1,
''TEXT'' AS TYPE1,
NULL AS Label2,
NULL AS TYPE2,
NULL AS Label3,
NULL AS TYPE3,
NULL AS Label4,
NULL AS TYPE4,
NULL AS Label5,
NULL AS TYPE5,
NULL AS Label6,
NULL AS TYPE6,
NULL AS Label7,
NULL AS TYPE7,
NULL AS Label8,
NULL AS TYPE8,
NULL AS Label9,
NULL AS TYPE9,
NULL AS Label10,
NULL AS TYPE10,
NULL AS Label11,
NULL AS TYPE11,
NULL AS Label12,
NULL AS TYPE12,
NULL AS Label13,
NULL AS TYPE13,
NULL AS Label14,
NULL AS TYPE14,
NULL AS Label15,
NULL AS TYPE15,
NULL AS Label16,
NULL AS TYPE16,
NULL AS Label17,
NULL AS TYPE17,
NULL AS Label18,
NULL AS TYPE18,
NULL AS Label19,
NULL AS TYPE19,
NULL AS Label20,
NULL AS TYPE20,
NULL AS Label21,
NULL AS TYPE11,
NULL AS Label22,
NULL AS TYPE22,
NULL AS Label23,
NULL AS TYPE23,
NULL AS Label24,
NULL AS TYPE24,
NULL AS Label25,
NULL AS TYPE25,
NULL AS Label26,
NULL AS TYPE26,
NULL AS Label27,
NULL AS TYPE27,
NULL AS Label28,
NULL AS TYPE28,
NULL AS Label29,
NULL AS TYPE29,
NULL AS Label30,
NULL AS TYPE30',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "Community_Involvement",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "Age_bracket",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    NULL,
    NULL,
    N'mike.bushell-torr@threerocks.co.uk',
    N'mike.bushell-torr@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Tax
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Tax',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[TAX_NAME]) AS [TAX_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[TAX_NAME]) ELSE [TAX_ID] END AS [TAX_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_TAX]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "TAX_NAME",
    "ID": "TAX_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Tax Rates"
      }
    }
  ]
}',
    N'SELECT
    [TAX_NAME] AS [Label]
    ,    [TAX_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[TAX_NAME]) AS [TAX_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[TAX_NAME]) ELSE [TAX_ID] END AS [TAX_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_TAX]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Tax Rates'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: TaxTotal
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'TaxTotal',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Tax Total'' AS Title,
    FORMAT(ROUND(SUM(TAX_VALUE), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Tax Total'' AS Title,
    FORMAT(ROUND(SUM(TAX_VALUE), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: Tenders
-- ============================================
-- FilterList - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'Tenders',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[TENDER_NAME]) AS [TENDER_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[TENDER_NAME]) ELSE [TENDER_ID] END AS [TENDER_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_TENDER]
WHERE [CURRENT_FLAG] = 1',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "Channels": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {
    "Label": "TENDER_NAME",
    "ID": "TENDER_ID",
    "ParentID": "PARENT_ID",
    "BottomLevel": "BOTTOM_LEVEL"
  },
  "additional_datasets": [
    {
      "name": "Header1",
      "type": "Header",
      "columns": [
        "Title"
      ],
      "values": {
        "Title": "Tender Types"
      }
    }
  ]
}',
    N'SELECT
    [TENDER_NAME] AS [Label]
    ,    [TENDER_ID] AS [ID]
    ,    [PARENT_ID] AS [ParentID]
    ,    [BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT DISTINCT
	COALESCE([MICROSERVICE_NAME],[TENDER_NAME]) AS [TENDER_NAME]
	,CASE WHEN [BOTTOM_LEVEL] = 1 THEN COALESCE([MICROSERVICE_NAME],[TENDER_NAME]) ELSE [TENDER_ID] END AS [TENDER_ID]
	,[PARENT_ID]
	,[BOTTOM_LEVEL]
FROM [datavault].[SAT_TENDER]
WHERE [CURRENT_FLAG] = 1
) INPUTQUERY

SELECT
    ''Tender Types'' AS [Title]',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: TotalOrders
-- ============================================
-- SingleKPICard - Version 1 - LIVE
INSERT INTO [core].[core].[VisualisationQueries]
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'TotalOrders',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
    ''Total Orders'' AS Title,
    FORMAT(ROUND(SUM(ORDER_COUNT), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''',
    N'{
  "LocationList": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
  "StartDate": "C.[DATE]",
  "EndDate": "C.[DATE]"
}',
    N'{
  "Channels": {
    "column": "COALESCE(channel.[BOTTOM_MICROSERVICE_NAME],channel.[BOTTOM_CHANNEL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Deals": {
    "column": "COALESCE(deal.[BOTTOM_MICROSERVICE_NAME],deal.[BOTTOM_DEAL_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Discounts": {
    "column": "COALESCE(discount.[BOTTOM_MICROSERVICE_NAME],discount.[BOTTOM_DISCOUNT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Distributors": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Integrations": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "InvItems": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Mods": {
    "column": "COALESCE(mod.[BOTTOM_MICROSERVICE_NAME],mod.[BOTTOM_MOD_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Occasions": {
    "column": "COALESCE(occasion.[BOTTOM_MICROSERVICE_NAME],occasion.[BOTTOM_OCCASION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ProductCategories": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Products": {
    "column": "COALESCE(product.[BOTTOM_MICROSERVICE_NAME],product.[BOTTOM_PRODUCT_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "RevenueCentres": {
    "column": "COALESCE(revcenter.[BOTTOM_MICROSERVICE_NAME],revcenter.[BOTTOM_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "ServiceCharges": {
    "column": "COALESCE(svccharge.[BOTTOM_MICROSERVICE_NAME],svccharge.[BOTTOM_SVCCHARGE_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Suppliers": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilter": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tax": {
    "column": "COALESCE(tax.[BOTTOM_MICROSERVICE_NAME],tax.[BOTTOM_TAX_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Tenders": {
    "column": "",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "Locations": {
    "column": "COALESCE(location.[BOTTOM_MICROSERVICE_NAME],location.[BOTTOM_LOCATION_NAME])",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    N'SELECT
    ''Total Orders'' AS Title,
    FORMAT(ROUND(SUM(ORDER_COUNT), 0), ''N0'') AS Value
FROM [presentation].[F_LINEITEM_15MIN] F

    INNER JOIN
        [presentation].[CALENDAR] C
    ON F.[ORDER_DATE] = C.[DATE]

    LEFT JOIN [presentation].[D_DEAL] deal
    ON F.DEAL_HUB_ID = deal.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_DISCOUNT] discount
        ON F.DISCOUNT_HUB_ID = discount.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_MOD] mod
        ON F.MOD_HUB_ID = mod.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_OCCASION] occasion
        ON F.OCCASION_HUB_ID = occasion.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_PRODUCT] product
        ON F.PRODUCT_HUB_ID = product.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_SERVICECHARGE] svccharge
        ON F.SVCCHARGE_HUB_ID = svccharge.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_TAX] tax
        ON F.TAX_HUB_ID = tax.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_LOCATION] location
        ON F.LOCATION_HUB_ID = location.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_REVCENTER] revcenter
        ON F.REVCENTER_HUB_ID = revcenter.BOTTOM_HUB_ID
    
    LEFT JOIN [presentation].[D_CHANNEL] channel
        ON F.CHANNEL_HUB_ID = channel.BOTTOM_HUB_ID
    WHERE 1=1
    @FilterCLause
    AND F.[LI_TYPE] = ''TENDER''',
    NULL,
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- End of Export
-- ============================================