-- ============================================================
-- Survey Vis Queries Part 1: Filters, Demographics, Completion
-- Tasks 5-7 from 2026-03-03-survey-fact-table-plan.md
--
-- Rewrites 9 VisualisationQueries records to use:
--   [presentation].[F_SURVEY_RESPONSE] f
--   [presentation].[D_QUESTION] q
--
-- MERGE upsert pattern — safe to re-run.
-- Natural key: (DataSetName, VisualizationType, Version)
-- ============================================================


-- ============================================================
-- FILTERS (2 records)
-- ============================================================

-- ============================================================
-- Dataset: SurveyFilter
-- ============================================================
-- FilterList - Version 1
-- SELECT DISTINCT community involvement values for filter UI
-- FilterDefinitions: {} — this IS the filter source
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyFilter',
        N'FilterList',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT DISTINCT
f.COMMUNITY_INVOLVEMENT AS Label,
f.COMMUNITY_INVOLVEMENT AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Community Involvement'' AS Title',
        ParameterMappings = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        FilterDefinitions = N'{}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyFilter',
        N'FilterList',
        1,
        N'LIVE',
        N'SELECT DISTINCT
f.COMMUNITY_INVOLVEMENT AS Label,
f.COMMUNITY_INVOLVEMENT AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Community Involvement'' AS Title',
        N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
        N'{}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyFilterAge
-- ============================================================
-- FilterList - Version 1
-- SELECT DISTINCT age bracket values; filtered by SurveyFilter
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyFilterAge',
        N'FilterList',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT DISTINCT
f.AGE_BRACKET AS Label,
f.AGE_BRACKET AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Age Bracket'' AS Title',
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
  }
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyFilterAge',
        N'FilterList',
        1,
        N'LIVE',
        N'SELECT DISTINCT
f.AGE_BRACKET AS Label,
f.AGE_BRACKET AS ID,
NULL AS ParentID,
1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND 1=1
@FilterClause

SELECT
''Age Bracket'' AS Title',
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
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- DEMOGRAPHICS (5 records)
-- ============================================================

-- ============================================================
-- Dataset: SurveyAgeByGender
-- ============================================================
-- CustomDataGrid - Version 1
-- Cross-tab: Age_Bracket rows x Gender columns (pivot)
-- COUNT(DISTINCT TOUCHPOINT_HUB_ID) per age+gender combination
-- Deduplicates to one row per respondent by filtering to the
-- age bracket question so the outer pivot has a unique grain.
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeByGender',
        N'CustomDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.AGE_BRACKET AS Column1,
SUM(CASE WHEN f.GENDER = ''Female'' THEN 1 ELSE 0 END) AS Column2,
SUM(CASE WHEN f.GENDER = ''Male'' THEN 1 ELSE 0 END) AS Column3,
SUM(CASE WHEN f.GENDER = ''Other'' THEN 1 ELSE 0 END) AS Column4,
SUM(CASE WHEN f.GENDER = ''I would rather not say'' THEN 1 ELSE 0 END) AS Column5,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Column6,
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
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET


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
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeByGender',
        N'CustomDataGrid',
        1,
        N'LIVE',
        N'SELECT
f.AGE_BRACKET AS Column1,
SUM(CASE WHEN f.GENDER = ''Female'' THEN 1 ELSE 0 END) AS Column2,
SUM(CASE WHEN f.GENDER = ''Male'' THEN 1 ELSE 0 END) AS Column3,
SUM(CASE WHEN f.GENDER = ''Other'' THEN 1 ELSE 0 END) AS Column4,
SUM(CASE WHEN f.GENDER = ''I would rather not say'' THEN 1 ELSE 0 END) AS Column5,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Column6,
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
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET


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
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyAgeByGender
-- ============================================================
-- CustomPinnedDataGrid - Version 1
-- Same age x gender data in pinned column format
-- PinnedColumn = Age_Bracket, Columns = Gender, Value = count
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeByGender',
        N'CustomPinnedDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.AGE_BRACKET AS PinnedColumn,
f.GENDER AS Columns,
CASE
    WHEN f.GENDER = ''Female'' THEN 1
    WHEN f.GENDER = ''Male'' THEN 2
    WHEN f.GENDER = ''I would rather not say'' THEN 3
    WHEN f.GENDER = ''Other'' THEN 4
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


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
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeByGender',
        N'CustomPinnedDataGrid',
        1,
        N'LIVE',
        N'SELECT
f.AGE_BRACKET AS PinnedColumn,
f.GENDER AS Columns,
CASE
    WHEN f.GENDER = ''Female'' THEN 1
    WHEN f.GENDER = ''Male'' THEN 2
    WHEN f.GENDER = ''I would rather not say'' THEN 3
    WHEN f.GENDER = ''Other'' THEN 4
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


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
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyAgeByRespondentTotal
-- ============================================================
-- BarChartCard - Version 1
-- Count of distinct respondents by age bracket
-- Joins D_QUESTION to filter to the age bracket question only
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeByRespondentTotal',
        N'BarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Age 16 - 19'' THEN 1
    WHEN f.ANSWER_TEXT = ''Age 20 - 29'' THEN 2
    WHEN f.ANSWER_TEXT = ''Age 30 - 39'' THEN 3
    WHEN f.ANSWER_TEXT = ''Age 40 - 49'' THEN 4
    WHEN f.ANSWER_TEXT = ''Age 50 - 59'' THEN 5
    WHEN f.ANSWER_TEXT = ''Age 60 - 69'' THEN 6
    WHEN f.ANSWER_TEXT = ''Age 70 - 79'' THEN 7
    WHEN f.ANSWER_TEXT = ''Age 80+'' THEN 8
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Age Group'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Respondents by Age Group'' AS Title,
NULL AS Description,
NULL AS Trend,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
    WHERE f.TOUCHPOINT_STATUS = ''completed''
    AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
    AND 1=1
    @FilterClause
) AS TotalValue,
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
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeByRespondentTotal',
        N'BarChartCard',
        1,
        N'LIVE',
        N'SELECT
f.ANSWER_TEXT AS BarLabel,
CASE
    WHEN f.ANSWER_TEXT = ''Age 16 - 19'' THEN 1
    WHEN f.ANSWER_TEXT = ''Age 20 - 29'' THEN 2
    WHEN f.ANSWER_TEXT = ''Age 30 - 39'' THEN 3
    WHEN f.ANSWER_TEXT = ''Age 40 - 49'' THEN 4
    WHEN f.ANSWER_TEXT = ''Age 50 - 59'' THEN 5
    WHEN f.ANSWER_TEXT = ''Age 60 - 69'' THEN 6
    WHEN f.ANSWER_TEXT = ''Age 70 - 79'' THEN 7
    WHEN f.ANSWER_TEXT = ''Age 80+'' THEN 8
    ELSE 999
END AS BarLabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS BarValue,
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS BarValueSort
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Age Group'' AS XAxisLabel,
''# Respondents'' AS YAxisLabel,
''Respondents by Age Group'' AS Title,
NULL AS Description,
NULL AS Trend,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
    WHERE f.TOUCHPOINT_STATUS = ''completed''
    AND q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
    AND 1=1
    @FilterClause
) AS TotalValue,
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
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyAgeGender
-- ============================================================
-- HeatmapCard - Version 1
-- Age bracket x gender heatmap using denormalized columns
-- Fix: adds @FilterClause (legacy had hardcoded filter only)
-- Deduplicates to one row per respondent via question filter
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyAgeGender',
        N'HeatmapCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.AGE_BRACKET AS XAxisLabel,
f.GENDER AS YAxisLabel,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


SELECT
''Age / Gender Heatmap'' AS Title,
''Age / Gender Heatmap'' AS Description',
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
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyAgeGender',
        N'HeatmapCard',
        1,
        N'LIVE',
        N'SELECT
f.AGE_BRACKET AS XAxisLabel,
f.GENDER AS YAxisLabel,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL
AND f.GENDER IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?''
)
AND 1=1
@FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER


SELECT
''Age / Gender Heatmap'' AS Title,
''Age / Gender Heatmap'' AS Description',
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
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyGenderByRespondentTotal
-- ============================================================
-- PieChartCard - Version 1
-- Count of distinct respondents by gender
-- Joins D_QUESTION to filter to gender question only
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyGenderByRespondentTotal',
        N'PieChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.ANSWER_TEXT AS Label,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value,
f.ANSWER_TEXT AS Id,
''linear'' AS Curve,
''total'' AS Stack,
''true'' AS Area,
''ascending'' AS StackOrder,
''false'' AS ShowMark,
''Gender'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What is your gender ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Gender Breakdown'' AS Title,
NULL AS Description,
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
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyGenderByRespondentTotal',
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
''Gender'' AS LegendLabel
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND q.BOTTOM_QUESTION_NAME = ''What is your gender ?''
AND f.ANSWER_TEXT IS NOT NULL
AND 1=1
@FilterClause
GROUP BY f.ANSWER_TEXT


SELECT
''Gender Breakdown'' AS Title,
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
  }
}',
        N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- COMPLETION (2 records)
-- ============================================================

-- ============================================================
-- Dataset: SurveyCompletion
-- ============================================================
-- StackedBarChartCard - Version 1
-- Count by community involvement (using denorm column)
-- Deduplicates via single-question filter to avoid fan-out
-- Simplified from legacy multi-UNION pattern
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyCompletion',
        N'StackedBarChartCard',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.TOUCHPOINT_STATUS AS xAxisLabel,
ROW_NUMBER() OVER (ORDER BY f.TOUCHPOINT_STATUS) AS LabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS [Value],
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
''A'' AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.TOUCHPOINT_STATUS, f.COMMUNITY_INVOLVEMENT


SELECT
''Survey Status'' AS XAxisLabel,
''Total respondents'' AS YAxisLabel,
''Completion Status by Community Involvement'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    WHERE 1=1
    @FilterClause
) AS Value',
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
  }
}',
        OutputDefinitions = N'{
  "column_mappings": {},
  "additional_datasets": []
}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyCompletion',
        N'StackedBarChartCard',
        1,
        N'LIVE',
        N'SELECT
f.TOUCHPOINT_STATUS AS xAxisLabel,
ROW_NUMBER() OVER (ORDER BY f.TOUCHPOINT_STATUS) AS LabelSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS [Value],
ROW_NUMBER() OVER (ORDER BY COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)) AS ValueSort,
f.COMMUNITY_INVOLVEMENT AS VisId,
''A'' AS Stack
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.TOUCHPOINT_STATUS, f.COMMUNITY_INVOLVEMENT


SELECT
''Survey Status'' AS XAxisLabel,
''Total respondents'' AS YAxisLabel,
''Completion Status by Community Involvement'' AS Title,
NULL AS Description,
NULL AS Trend,
NULL AS Chip,
(
    SELECT COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)
    FROM [presentation].[F_SURVEY_RESPONSE] f
    WHERE 1=1
    @FilterClause
) AS Value',
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
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );


-- ============================================================
-- Dataset: SurveyStatusByInvolvement
-- ============================================================
-- CustomPinnedDataGrid - Version 1
-- Cross-tab: Community Involvement rows x Touchpoint Status cols
-- Fix: corrects table typo (threerock -> F_SURVEY_RESPONSE)
-- Includes both completed and incomplete statuses (no filter)
-- ============================================================
MERGE INTO [core].[VisualisationQueries] AS tgt
USING (
    VALUES (
        N'SurveyStatusByInvolvement',
        N'CustomPinnedDataGrid',
        1
    )
) AS src (DataSetName, VisualizationType, Version)
ON  tgt.DataSetName      = src.DataSetName
AND tgt.VisualizationType = src.VisualizationType
AND tgt.Version           = src.Version
WHEN MATCHED THEN
    UPDATE SET
        Status            = N'LIVE',
        QueryTemplate     = N'SELECT
f.COMMUNITY_INVOLVEMENT AS PinnedColumn,
f.TOUCHPOINT_STATUS AS Columns,
CASE
    WHEN f.TOUCHPOINT_STATUS = ''completed'' THEN 1
    WHEN f.TOUCHPOINT_STATUS = ''incomplete'' THEN 2
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT, f.TOUCHPOINT_STATUS


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
  }
}',
        OutputDefinitions = N'{}',
        ExecutionQuery    = NULL,
        ModifiedBy        = N'claude',
        ModifiedDate      = GETDATE()
WHEN NOT MATCHED THEN
    INSERT (DataSetName, VisualizationType, Version, Status,
            QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
            ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
    VALUES (
        N'SurveyStatusByInvolvement',
        N'CustomPinnedDataGrid',
        1,
        N'LIVE',
        N'SELECT
f.COMMUNITY_INVOLVEMENT AS PinnedColumn,
f.TOUCHPOINT_STATUS AS Columns,
CASE
    WHEN f.TOUCHPOINT_STATUS = ''completed'' THEN 1
    WHEN f.TOUCHPOINT_STATUS = ''incomplete'' THEN 2
    ELSE 999
END AS ColumnsSort,
COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Value
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.COMMUNITY_INVOLVEMENT IS NOT NULL
AND f.QUESTION_HUB_ID = (
    SELECT TOP 1 q2.BOTTOM_HUB_ID
    FROM [presentation].[D_QUESTION] q2
    WHERE q2.BOTTOM_QUESTION_NAME = ''Survey Selection''
)
AND 1=1
@FilterClause
GROUP BY f.COMMUNITY_INVOLVEMENT, f.TOUCHPOINT_STATUS


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
  "SurveyFilter": {
    "column": "f.COMMUNITY_INVOLVEMENT",
    "type": "IN",
    "dataType": "VARCHAR"
  }
}',
        N'{}',
        NULL,
        NULL,
        N'claude',
        N'claude',
        GETDATE(),
        GETDATE()
    );
