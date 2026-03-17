-- ============================================================
-- Survey Vis Queries Part 3: Building/Travel/Activity + Free-Text/KPI
-- Tasks 11-12 from 2026-03-03-survey-fact-table-plan.md
--
-- Rewrites ~15 DataSetNames from legacy threerocks.dbo.church_survey_results
-- to use [presentation].[F_SURVEY_RESPONSE] + [presentation].[D_QUESTION].
--
-- All MERGE upserts use natural key (DataSetName, VisualizationType, Version).
-- Single quotes doubled inside N'...' string literals.
-- FilterDefinitions cleaned of stale POS entries.
-- No hardcoded database names — scripts run against any client database.
-- ============================================================


-- ============================================
-- Dataset: SurveyBuildingActivities
-- ============================================
-- PieChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingActivities',
    N'PieChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Suitability for Activities'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the buildings well suited to the needs of the activities you attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Buildings Suited to Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingActivities',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Suitability for Activities'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the buildings well suited to the needs of the activities you attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Buildings Suited to Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyBuildingSuited
-- ============================================
-- PieChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingSuited',
    N'PieChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the church buildings well suited to the needs of those regularly using them?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Are the buildings suited Overall?'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingSuited',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Are the church buildings well suited to the needs of those regularly using them?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Are the buildings suited Overall?'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyBuildingUse
-- ============================================
-- BarChartCard - Version 1
-- Multi-choice: one row per answer per touchpoint (no STRING_SPLIT needed in DV)
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUse',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY f.ANSWER_TEXT) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Building Use'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUse',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY f.ANSWER_TEXT) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Building Use'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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


-- PieChartCard - Version 1
-- Question: 'Do you use, visit or hire the Eastleigh Baptist Church Buildings?'
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUse',
    N'PieChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Do you use, visit or hire the Eastleigh Baptist Church Buildings?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS Title,
''Building Use by Respondent'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUse',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Building Use'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Do you use, visit or hire the Eastleigh Baptist Church Buildings?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Building Use'' AS Title,
''Building Use by Respondent'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyMembersDistance
-- ============================================
-- BarChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyMembersDistance',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Less than 1 mile'' THEN 1
    WHEN f.ANSWER_TEXT = ''1 - 2 miles''       THEN 2
    WHEN f.ANSWER_TEXT = ''2 - 5 miles''       THEN 3
    WHEN f.ANSWER_TEXT = ''5 - 10 miles''      THEN 4
    WHEN f.ANSWER_TEXT = ''11+ miles''         THEN 5
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Distance Travelled'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Distance Travelled'' AS Title,
''Distance to Church by Church Members'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyMembersDistance',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Less than 1 mile'' THEN 1
    WHEN f.ANSWER_TEXT = ''1 - 2 miles''       THEN 2
    WHEN f.ANSWER_TEXT = ''2 - 5 miles''       THEN 3
    WHEN f.ANSWER_TEXT = ''5 - 10 miles''      THEN 4
    WHEN f.ANSWER_TEXT = ''11+ miles''         THEN 5
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Distance Travelled'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Distance Travelled'' AS Title,
''Distance to Church by Church Members'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyMembersTravel
-- ============================================
-- BarChartCard - Version 1
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyMembersTravel',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Car''              THEN 1
    WHEN f.ANSWER_TEXT = ''Cycle''            THEN 2
    WHEN f.ANSWER_TEXT = ''Public Transport'' THEN 3
    WHEN f.ANSWER_TEXT = ''Walk''             THEN 4
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Transport Method'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Transport Method'' AS Title,
''How Church Members Travel to Church'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyMembersTravel',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Car''              THEN 1
    WHEN f.ANSWER_TEXT = ''Cycle''            THEN 2
    WHEN f.ANSWER_TEXT = ''Public Transport'' THEN 3
    WHEN f.ANSWER_TEXT = ''Walk''             THEN 4
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Transport Method'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''# Respondents by Transport Method'' AS Title,
''How Church Members Travel to Church'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyDistanceTransport
-- ============================================
-- HeatmapCard - Version 1 — cross-tab Distance x Transport
-- Joins fact twice via TOUCHPOINT_HUB_ID to get both answers per respondent
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyDistanceTransport',
    N'HeatmapCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
dist.ANSWER_TEXT AS XAxisLabel,
trans.ANSWER_TEXT AS YAxisLabel,
COUNT(*) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] dist
INNER JOIN [presentation].[D_QUESTION] q1
    ON dist.QUESTION_HUB_ID = q1.BOTTOM_HUB_ID
INNER JOIN [presentation].[F_SURVEY_RESPONSE] trans
    ON dist.TOUCHPOINT_HUB_ID = trans.TOUCHPOINT_HUB_ID
INNER JOIN [presentation].[D_QUESTION] q2
    ON trans.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID
WHERE dist.TOUCHPOINT_STATUS = ''completed''
  AND q1.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND q2.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND dist.ANSWER_TEXT IS NOT NULL
  AND trans.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY dist.ANSWER_TEXT, trans.ANSWER_TEXT

SELECT
''Church Transport and Distance'' AS Title,
''Church Transport and Distance'' AS Description',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "dist.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "dist.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyDistanceTransport',
    N'HeatmapCard',
    1,
    N'LIVE',
    N'SELECT
dist.ANSWER_TEXT AS XAxisLabel,
trans.ANSWER_TEXT AS YAxisLabel,
COUNT(*) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] dist
INNER JOIN [presentation].[D_QUESTION] q1
    ON dist.QUESTION_HUB_ID = q1.BOTTOM_HUB_ID
INNER JOIN [presentation].[F_SURVEY_RESPONSE] trans
    ON dist.TOUCHPOINT_HUB_ID = trans.TOUCHPOINT_HUB_ID
INNER JOIN [presentation].[D_QUESTION] q2
    ON trans.QUESTION_HUB_ID = q2.BOTTOM_HUB_ID
WHERE dist.TOUCHPOINT_STATUS = ''completed''
  AND q1.BOTTOM_QUESTION_NAME = ''How far do you travel to the church ?''
  AND q2.BOTTOM_QUESTION_NAME = ''How do you usually get to the church ?''
  AND dist.ANSWER_TEXT IS NOT NULL
  AND trans.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY dist.ANSWER_TEXT, trans.ANSWER_TEXT

SELECT
''Church Transport and Distance'' AS Title,
''Church Transport and Distance'' AS Description',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "dist.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "dist.AGE_BRACKET",
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
-- Dataset: SurveyMemberActivities
-- ============================================
-- BarChartCard - Version 1
-- Same question as SurveyBuildingUse BarChart but different sort order / presentation
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyMemberActivities',
    N'BarChartCard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Regular Activities'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Church Member Regular Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyMemberActivities',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS BarLabel,
ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS BarLabelSort,
COUNT(*) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(*)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT

SELECT
''Regular Activities'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Church Member Regular Activities'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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


-- ============================================================
-- FREE-TEXT & KPI QUERIES (Task 12)
-- ============================================================


-- ============================================
-- Dataset: SurveyImprovementsNeeded
-- ============================================
-- CustomDataGrid - Version 1 — row listing
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyImprovementsNeeded',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyImprovementsNeeded',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyBuildingUseImprovements
-- ============================================
-- SingleKPICard - Version 1 — STRING_AGG of improvements text
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUseImprovements',
    N'SingleKPICard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Building Improvements Needed'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUseImprovements',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Building Improvements Needed'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What improvements need to be made to the buildings to support the work of the church better?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
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
-- Dataset: SurveyBuildingUseMessage
-- ============================================
-- SingleKPICard - Version 1 — STRING_AGG of visitor message text
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyBuildingUseMessage',
    N'SingleKPICard',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Message To Visitors'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyBuildingUseMessage',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
STRING_AGG(CAST(''• '' + f.ANSWER_TEXT AS NVARCHAR(MAX)), ''<br>'') AS Value,
''Message To Visitors'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
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
-- Dataset: SurveyVisitorMessage
-- ============================================
-- CustomDataGrid - Version 1 — row listing of visitor message text
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyVisitorMessage',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyVisitorMessage',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''What message do you think the church building and site give to visitors and passers by?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
-- Dataset: SurveyLifestyleProvisionThoughts
-- ============================================
-- CustomDataGrid - Version 1
-- Church members only (hardcoded WHERE, no SurveyFilter applied here —
-- matches legacy intent of filtering to church members without a user-selectable filter)
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyLifestyleProvisionThoughts',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyLifestyleProvisionThoughts',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
    N'{}',
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
-- Dataset: SurveyLifestyleProvisionThoughtsnonChurch
-- ============================================
-- CustomDataGrid - Version 1 — same question, SurveyFilter applied
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (
    N'SurveyLifestyleProvisionThoughtsnonChurch',
    N'CustomDataGrid',
    1
)) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName     = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version         = src.Version
WHEN MATCHED THEN UPDATE SET
    tgt.Status = N'LIVE',
    tgt.QueryTemplate = N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
    tgt.ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    tgt.FilterDefinitions = N'{
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
    tgt.OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    tgt.ModifiedBy = N'andrew.kaplan@threerocks.co.uk',
    tgt.ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT (
    DataSetName, VisualizationType, Version, Status,
    QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
    ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate
) VALUES (
    N'SurveyLifestyleProvisionThoughtsnonChurch',
    N'CustomDataGrid',
    1,
    N'LIVE',
    N'SELECT
f.ANSWER_TEXT AS Column1,
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
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

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
NULL AS TYPE21,
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
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  },
  "SurveyFilterAge": {
    "column": "f.AGE_BRACKET",
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
