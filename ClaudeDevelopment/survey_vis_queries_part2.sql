-- ============================================================
-- survey_vis_queries_part2.sql
-- Score average vis queries: Lifestyle (6), Challenging Issues (5), Environment (3)
-- Tasks 8-10 from 2026-03-03-survey-fact-table-plan.md
--
-- Uses MERGE upsert on natural key (DataSetName, VisualizationType, Version).
-- All queries use [presentation].[F_SURVEY_RESPONSE] and [presentation].[D_QUESTION].
-- No hardcoded database names — run against any client database.
-- Single quotes doubled inside N'...' string literals.
-- ============================================================


-- ============================================================
-- TASK 8: LIFESTYLE PROVISION (6 records)
-- ============================================================

-- ============================================
-- Dataset: SurveyAverageLifestyleScore
-- PieChartCard — AVG score by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyAverageLifestyleScore', N'PieChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAverageLifestyleScore',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
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
-- Dataset: SurveyLifestyleProvision
-- BarChartCard — AVG score by BOTTOM_QUESTION_NAME
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyLifestyleProvision', N'BarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS BarLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS BarLabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS BarValue,
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Lifestyle Provision'' AS Title,
''Average Score by Lifestyle Provision'' AS Description,
NULL AS Trend,
NULL AS TotalValue,
NULL AS Chip',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleProvision',
    N'BarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS BarLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS BarLabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS BarValue,
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Lifestyle Provision'' AS Title,
''Average Score by Lifestyle Provision'' AS Description,
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
-- Dataset: SurveyLifestyleRadar
-- RadarChartCard — AVG by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyLifestyleRadar', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
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
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

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
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyEnvironmentRadar
-- RadarChartCard — uses Our Environment section with Poor scale
-- FIX 2026-03-04: was incorrectly filtering on 'Lifestyle provision' instead of 'Our Environment'
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyEnvironmentRadar', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
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
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

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
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyRespondentByLifestyle
-- StackedBarChartCard — AVG score by BOTTOM_QUESTION_NAME stacked by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyRespondentByLifestyle', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Activity & Provision'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByLifestyle',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Activity & Provision'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Activity & Provision'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
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
-- Dataset: SurveyLifestyleThoughts
-- SingleKPICard — STRING_AGG of "Any extra thoughts ?" under Lifestyle provision
-- FIX: legacy had @filterclause commented out and hardcoded to Influencer only.
-- Rewritten to use @FilterClause and no hardcoded involvement filter.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyLifestyleThoughts', N'SingleKPICard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
STRING_AGG(''• '' + f.ANSWER_TEXT, ''<br>'') AS Value,
''Lifestyle Provision Extra Thoughts'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyLifestyleThoughts',
    N'SingleKPICard',
    1,
    N'LIVE',
    N'SELECT
STRING_AGG(''• '' + f.ANSWER_TEXT, ''<br>'') AS Value,
''Lifestyle Provision Extra Thoughts'' AS Title
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
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


-- ============================================================
-- TASK 9: CHALLENGING ISSUES (5 records)
-- ============================================================

-- ============================================
-- Dataset: SurveyAverageChallengeScore
-- PieChartCard — AVG score by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyAverageChallengeScore', N'PieChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS PiePrimaryText,
NULL AS PieSecondaryText',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyAverageChallengeScore',
    N'PieChartCard',
    1,
    N'LIVE',
    N'SELECT
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value,
f.COMMUNITY_INVOLVEMENT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Community Involvement'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Community Involvement'' AS Title,
''Average Score by Community Involvement'' AS Description,
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
-- Dataset: SurveyChallengingRadar
-- RadarChartCard — AVG by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyChallengingRadar', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Provision'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
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
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengingRadar',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

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
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyRespondentByChallenge
-- StackedBarChartCard — AVG score by BOTTOM_QUESTION_NAME stacked by COMMUNITY_INVOLVEMENT
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyRespondentByChallenge', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Provision for Challenging Issues'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Provision'' AS Title,
''Average Score by Provision'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByChallenge',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Provision for Challenging Issues'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Provision'' AS Title,
''Average Score by Provision'' AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
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
-- Dataset: SurveyChallengeThoughts
-- CustomDataGrid — free-text listing for "Any extra thoughts ?" under Challenging issues
-- Church members only (hardcoded WHERE) — matches SurveyLifestyleProvisionThoughts pattern.
-- Use SurveyChallengeThoughtsnonChurch for all respondents with user-selectable filter.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyChallengeThoughts', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
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
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
''Challenging Issues - Extra Thoughts (Church Members)'' AS Title,
''Challenging Issues - Extra Thoughts'' AS Description,
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
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengeThoughts',
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
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
  AND q.BOTTOM_QUESTION_NAME = ''Any extra thoughts ?''
  AND f.COMMUNITY_INVOLVEMENT = ''Church congregation member''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause

SELECT
''Challenging Issues - Extra Thoughts (Church Members)'' AS Title,
''Challenging Issues - Extra Thoughts'' AS Description,
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


-- ============================================
-- Dataset: SurveyChallengeThoughtsnonChurch
-- CustomDataGrid — free-text listing with SurveyFilter (community involvement filter)
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyChallengeThoughtsnonChurch', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
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
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
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
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyChallengeThoughtsnonChurch',
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
  AND q.TOP_QUESTION_NAME = ''Challenging issues''
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


-- ============================================================
-- TASK 10: ENVIRONMENT (3 records)
-- ============================================================

-- ============================================
-- Dataset: SurveyEnvironmentRadarBad
-- RadarChartCard — FIX BUG: legacy used wrong CASE labels (Lifestyle labels).
-- Now correctly uses TOP='Our Environment', MIDDLE='Poor'.
-- Axis labels come directly from BOTTOM_QUESTION_NAME (no CASE mapping needed).
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyEnvironmentRadarBad', N'RadarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
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
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentRadarBad',
    N'RadarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS Axis,
f.COMMUNITY_INVOLVEMENT AS Label,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
ORDER BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

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
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);


-- ============================================
-- Dataset: SurveyRespondentByEnvironment
-- StackedBarChartCard — FIX BUG: legacy was copy of RespondentByChallenge (Provision_for_*).
-- Now correctly uses TOP='Our Environment', MIDDLE='Poor'.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyRespondentByEnvironment', N'StackedBarChartCard', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Environmental Element'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyRespondentByEnvironment',
    N'StackedBarChartCard',
    1,
    N'LIVE',
    N'SELECT
q.BOTTOM_QUESTION_NAME AS XAxisLabel,
ROW_NUMBER() OVER (ORDER BY q.BOTTOM_QUESTION_NAME) AS LabelSort,
CAST(AVG(f.ANSWER_NUMERIC) AS DECIMAL(5,2)) AS [Value],
ROW_NUMBER() OVER (ORDER BY AVG(f.ANSWER_NUMERIC)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
f.COMMUNITY_INVOLVEMENT AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Our Environment''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT

SELECT
''Environmental Element'' AS XAxisLabel,
''Average Score (1-6)'' AS YAxisLabel,
''Average Score by Environmental Element'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
NULL AS Value',
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
-- Dataset: SurveyEnvironmentThoughts
-- CustomDataGrid — FIX BUG: legacy queried Extra_Thoughts_Lifestyle_Provision column.
-- Now filters to TOP='Our Environment' AND BOTTOM='Any extra thoughts ?'.
-- ============================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (VALUES (N'SurveyEnvironmentThoughts', N'CustomDataGrid', 1)) AS src (DataSetName, VisualizationType, Version)
ON tgt.DataSetName = src.DataSetName AND tgt.VisualizationType = src.VisualizationType AND tgt.Version = src.Version
WHEN MATCHED THEN UPDATE SET
    Status = N'LIVE',
    QueryTemplate = N'SELECT
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
  AND q.TOP_QUESTION_NAME = ''Our Environment''
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
    ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
    FilterDefinitions = N'{
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
    OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
    ModifiedDate = GETDATE()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'SurveyEnvironmentThoughts',
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
  AND q.TOP_QUESTION_NAME = ''Our Environment''
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
