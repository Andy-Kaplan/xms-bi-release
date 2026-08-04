/*  Pantry COGS Dashboard - Task 9: FilterList datasets

    Three FilterList records, natural key (DataSetName, VisualizationType, Status),
    Version 1, Status 'LIVE'. Re-runnable MERGE per record.

    ==========================================================================
    OUTPUT CONTRACT - Label / ID / ParentID / BottomLevel. DO NOT CHANGE IT BACK.
    ==========================================================================
    The first version of this file keyed OutputDefinitions.column_mappings
    "Value" / "Label" (plus "SortValue" on Periods) and projected columns of
    those names. It was internally consistent, which is exactly why a per-file
    review cleared it - and it was wrong. The final independent review
    enumerated all 21 FilterList records in 8_VisualisationQueries.sql:

      - 18 use exactly Label / ID / ParentID / BottomLevel. That includes
        Locations (8_VisualisationQueries.sql:9271-9278), the direct analogue of
        PantryCOGSVenues, and Channels (:571-575), the record
        00_CARD_CONTRACTS.md was written from.
      - 3 (ProductCategories, SurveyFilter, SurveyFilterAge) use
        "column_mappings": {} - bespoke single-column survey lists. No "Value"
        key either.
      - ZERO use a "Value" key. Every "Value": mapping in that file belongs to a
        RadarChartCard or a CombinedChartCard, not to a FilterList.

    These three widgets are the only source of @FilterClause for all 12 cards,
    so if the renderer reads ID and nothing emits ID, no selection is ever
    emitted and every card silently shows unfiltered totals - the exact failure
    08_report_db_config.sql:247 warns about ("the widget renders and does nothing
    when clicked"). Nobody should reintroduce "Value" here without first proving
    against the frontend that it is read.

    Shape now mirrors Locations/Channels exactly:
      QueryTemplate   - native-ish column names, NO ORDER BY.
      column_mappings - {"Label": <native>, "ID": <native>,
                         "ParentID": "PARENT_ID", "BottomLevel": "BOTTOM_LEVEL"}
      ExecutionQuery  - a COPY of the QueryTemplate text embedded as
                        `FROM ( ... ) INPUTQUERY`, re-aliased to [Label] / [ID] /
                        [ParentID] / [BottomLevel], with the ORDER BY on the OUTER
                        select, then the one-row Title header SELECT.

    WHY QueryTemplate CARRIES NO ORDER BY - the precise reason, because the obvious
    one is wrong. Nothing wraps QueryTemplate at runtime. The FilterList procedure
    (8_Deployment_Objects_Records.sql:506-513) does
    `@SQL = COALESCE(ExecutionQuery, QueryTemplate)`, then a REPLACE for
    @FilterClause, then `EXEC sp_executesql @SQL` - whichever column it took is
    executed verbatim, and QueryTemplate is only reached at all when
    ExecutionQuery is NULL, which it is not for any of these three records. What
    actually forbids an inner ORDER BY is that the ExecutionQuery AUTHORED HERE
    embeds a copy of the template text as a subquery, exactly as the live Locations
    record does - and a subquery may not carry ORDER BY without TOP. So the two
    copies must stay in step: if you add an ORDER BY to a QueryTemplate below, the
    ExecutionQuery that quotes it stops parsing.
    (Recorded because the earlier version of this comment said the template "has to
    be wrappable", implying the platform wraps it. It does not, and a wrong reason in
    a comment is how someone later "fixes" correct code.)
    All three lists are FLAT, so ParentID is NULL and BottomLevel is 1 on every
    row. Types follow the standard dimension hierarchy pattern
    (docs/data-vault-reference.md Appendix C): PARENT_ID NVARCHAR(255),
    BOTTOM_LEVEL BIGINT.

    ID carries the value the cards match on, so renaming the emitted COLUMN must
    not change the emitted EXPRESSION. For venues that expression stays
    byte-identical to every card's FilterDefinitions entry:
        CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)
    LOCATION_HUB_ID is binary(32); comparing it to a hex string implicitly takes
    the string's character bytes, matches nothing, and raises no error. Any change
    to that expression must touch 04, 05, 06 and 07 together.

    Three-part naming: [core].[core].[VisualisationQueries] - NOT [core].[VisualisationQueries].
    2_CoreTableCreateScripts.sql opens `USE [core]` before creating the table, so its real
    name is core DATABASE . core SCHEMA . VisualisationQueries. This script runs from a
    client database context; client DBs have their own `core` schema, so a two-part name
    would resolve to the wrong (client-local) object instead of erroring loudly. This
    mirrors 8_VisualisationQueries.sql's own INSERTs and the correction already propagated
    to Tasks 6-8.

    Sourced from presentation.F_COGS_PERIOD only, scoped WHERE F.[SOURCE] LIKE 'int_growyze%'
    on every query - never from a dimension table wholesale (00_CARD_CONTRACTS.md's O8
    lesson: a sibling dashboard's filter listed 'Wine' from the dimension while the fact held
    'Wines', and was not source-scoped, so every selection matched zero rows).

    Venue label uses D_LOCATION's NATIVE name column, BOTTOM_LOCATION_NAME - confirmed at
    8_PresentationTables.sql:509 - never COALESCE(BOTTOM_MICROSERVICE_NAME, ...). Growyze
    staging hardcodes the literal 'growyze' into MICROSERVICE_NAME (PREFLIGHT.md Q3), so
    COALESCE-ing it in would collapse every venue's label to "growyze".
*/

-- ============================================
-- Dataset: PantryCOGSVenues
-- ============================================
-- FilterList - Version 1 - LIVE
-- Distinct venues, multi-select. ID = LOCATION_HUB_ID (binary hub key, string-converted
-- with style 2 so it round-trips through JSON/URL params unchanged, and so it matches the
-- cards' filter column expression exactly); Label = native venue name.
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSVenues', N'FilterList', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON tgt.[DataSetName] = src.[DataSetName]
   AND tgt.[VisualizationType] = src.[VisualizationType]
   AND tgt.[Status] = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate] = N'SELECT DISTINCT
     COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'') AS [LOCATION_NAME]
    ,CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)          AS [LOCATION_ID]
    ,CAST(NULL AS NVARCHAR(255))                           AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                                     AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE F.[SOURCE] LIKE ''int_growyze%''',
     [ParameterMappings] = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
     [FilterDefinitions] = N'{
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
     [OutputDefinitions] = N'{
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
        "Title": "Venues"
      }
    }
  ]
}',
     [ExecutionQuery] = N'SELECT
     [LOCATION_NAME] AS [Label]
    ,[LOCATION_ID]   AS [ID]
    ,[PARENT_ID]     AS [ParentID]
    ,[BOTTOM_LEVEL]  AS [BottomLevel]
FROM
(
SELECT DISTINCT
     COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'') AS [LOCATION_NAME]
    ,CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)          AS [LOCATION_ID]
    ,CAST(NULL AS NVARCHAR(255))                           AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                                     AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE F.[SOURCE] LIKE ''int_growyze%''
) INPUTQUERY
ORDER BY [LOCATION_NAME]

SELECT ''Venues'' AS [Title]',
     [Description] = N'Pantry COGS dashboard - venue filter (multi-select), sourced from F_COGS_PERIOD.LOCATION_HUB_ID, scoped to Growyze. Emits Label/ID/ParentID/BottomLevel; ID is the hex LOCATION_HUB_ID the cards filter on.',
     [ModifiedDate] = GETDATE(),
     [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'PantryCOGSVenues',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
     COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'') AS [LOCATION_NAME]
    ,CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)          AS [LOCATION_ID]
    ,CAST(NULL AS NVARCHAR(255))                           AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                                     AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE F.[SOURCE] LIKE ''int_growyze%''',
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
        "Title": "Venues"
      }
    }
  ]
}',
    N'SELECT
     [LOCATION_NAME] AS [Label]
    ,[LOCATION_ID]   AS [ID]
    ,[PARENT_ID]     AS [ParentID]
    ,[BOTTOM_LEVEL]  AS [BottomLevel]
FROM
(
SELECT DISTINCT
     COALESCE(L.[BOTTOM_LOCATION_NAME], ''Unknown venue'') AS [LOCATION_NAME]
    ,CONVERT(VARCHAR(64), F.[LOCATION_HUB_ID], 2)          AS [LOCATION_ID]
    ,CAST(NULL AS NVARCHAR(255))                           AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                                     AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
LEFT JOIN [presentation].[D_LOCATION] L ON L.[BOTTOM_HUB_ID] = F.[LOCATION_HUB_ID]
WHERE F.[SOURCE] LIKE ''int_growyze%''
) INPUTQUERY
ORDER BY [LOCATION_NAME]

SELECT ''Venues'' AS [Title]',
    N'Pantry COGS dashboard - venue filter (multi-select), sourced from F_COGS_PERIOD.LOCATION_HUB_ID, scoped to Growyze. Emits Label/ID/ParentID/BottomLevel; ID is the hex LOCATION_HUB_ID the cards filter on.',
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: PantryCOGSPeriods
-- ============================================
-- FilterList - Version 1 - LIVE
-- Distinct period labels, newest first, so the frontend's default selection lands on the
-- latest period. SORT_DATE = MAX(PERIOD_END_DATE) is projected by the inner query purely to
-- drive the ORDER BY at the outer level; it is NOT one of the four mapped output columns
-- (the old shape mapped a "SortValue" key, which no live FilterList record uses). The
-- ORDER BY has to sit on the OUTER query because the inner one is wrapped as a subquery.
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSPeriods', N'FilterList', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON tgt.[DataSetName] = src.[DataSetName]
   AND tgt.[VisualizationType] = src.[VisualizationType]
   AND tgt.[Status] = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate] = N'SELECT
     F.[PERIOD_LABEL]             AS [PERIOD_LABEL]
    ,F.[PERIOD_LABEL]             AS [PERIOD_ID]
    ,CAST(NULL AS NVARCHAR(255))  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)            AS [BOTTOM_LEVEL]
    ,MAX(F.[PERIOD_END_DATE])     AS [SORT_DATE]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
GROUP BY F.[PERIOD_LABEL]',
     [ParameterMappings] = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
     [FilterDefinitions] = N'{
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
     [OutputDefinitions] = N'{
  "column_mappings": {
    "Label": "PERIOD_LABEL",
    "ID": "PERIOD_ID",
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
        "Title": "Periods"
      }
    }
  ]
}',
     [ExecutionQuery] = N'SELECT
     [PERIOD_LABEL] AS [Label]
    ,[PERIOD_ID]    AS [ID]
    ,[PARENT_ID]    AS [ParentID]
    ,[BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT
     F.[PERIOD_LABEL]             AS [PERIOD_LABEL]
    ,F.[PERIOD_LABEL]             AS [PERIOD_ID]
    ,CAST(NULL AS NVARCHAR(255))  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)            AS [BOTTOM_LEVEL]
    ,MAX(F.[PERIOD_END_DATE])     AS [SORT_DATE]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
GROUP BY F.[PERIOD_LABEL]
) INPUTQUERY
ORDER BY [SORT_DATE] DESC

SELECT ''Periods'' AS [Title]',
     [Description] = N'Pantry COGS dashboard - period filter, newest period first for default selection, sourced from F_COGS_PERIOD.PERIOD_LABEL, scoped to Growyze. Emits Label/ID/ParentID/BottomLevel; ID is the PERIOD_LABEL the cards filter on.',
     [ModifiedDate] = GETDATE(),
     [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'PantryCOGSPeriods',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT
     F.[PERIOD_LABEL]             AS [PERIOD_LABEL]
    ,F.[PERIOD_LABEL]             AS [PERIOD_ID]
    ,CAST(NULL AS NVARCHAR(255))  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)            AS [BOTTOM_LEVEL]
    ,MAX(F.[PERIOD_END_DATE])     AS [SORT_DATE]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
GROUP BY F.[PERIOD_LABEL]',
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
    "Label": "PERIOD_LABEL",
    "ID": "PERIOD_ID",
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
        "Title": "Periods"
      }
    }
  ]
}',
    N'SELECT
     [PERIOD_LABEL] AS [Label]
    ,[PERIOD_ID]    AS [ID]
    ,[PARENT_ID]    AS [ParentID]
    ,[BOTTOM_LEVEL] AS [BottomLevel]
FROM
(
SELECT
     F.[PERIOD_LABEL]             AS [PERIOD_LABEL]
    ,F.[PERIOD_LABEL]             AS [PERIOD_ID]
    ,CAST(NULL AS NVARCHAR(255))  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)            AS [BOTTOM_LEVEL]
    ,MAX(F.[PERIOD_END_DATE])     AS [SORT_DATE]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
GROUP BY F.[PERIOD_LABEL]
) INPUTQUERY
ORDER BY [SORT_DATE] DESC

SELECT ''Periods'' AS [Title]',
    N'Pantry COGS dashboard - period filter, newest period first for default selection, sourced from F_COGS_PERIOD.PERIOD_LABEL, scoped to Growyze. Emits Label/ID/ParentID/BottomLevel; ID is the PERIOD_LABEL the cards filter on.',
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);



-- ============================================
-- Dataset: PantryCOGSCategories
-- ============================================
-- FilterList - Version 1 - LIVE
-- Distinct REPORT_GROUP values (already reflects the break-out-by-subcategory config from
-- 03_report_group_config.sql - see PREFLIGHT.md Q2 for the 'All INVITEMs' sentinel caveat).
--
-- NULL REPORT_GROUP is now rendered as '(no category)' and IS listed (final-review M15).
-- It used to be excluded with AND F.[REPORT_GROUP] IS NOT NULL, which meant that as soon as
-- any category selection was active, every uncategorised row silently dropped out of every
-- card with nothing on screen to say so. Check 4 gates a deploy in that state but does not
-- protect against drift afterwards. The cards' FilterDefinitions column expression carries
-- the SAME ISNULL(...) wrapper, so the emitted ID still matches what the cards compare
-- against - if you change the sentinel text here, change it in 04, 05 and 06 too.
-- 06:115 already does exactly this for the billing grid (ISNULL([CATEGORY], N'Unspecified')).
MERGE INTO [core].[core].[VisualisationQueries] AS tgt
USING (VALUES (N'PantryCOGSCategories', N'FilterList', N'LIVE')) AS src (DataSetName, VisualizationType, Status)
    ON tgt.[DataSetName] = src.[DataSetName]
   AND tgt.[VisualizationType] = src.[VisualizationType]
   AND tgt.[Status] = src.[Status]
WHEN MATCHED THEN UPDATE SET
     [QueryTemplate] = N'SELECT DISTINCT
     ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_NAME]
    ,ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_ID]
    ,CAST(NULL AS NVARCHAR(255))                  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                            AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''',
     [ParameterMappings] = N'{
  "LocationList": "",
  "StartDate": "",
  "EndDate": ""
}',
     [FilterDefinitions] = N'{
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
     [OutputDefinitions] = N'{
  "column_mappings": {
    "Label": "REPORT_GROUP_NAME",
    "ID": "REPORT_GROUP_ID",
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
        "Title": "Categories"
      }
    }
  ]
}',
     [ExecutionQuery] = N'SELECT
     [REPORT_GROUP_NAME] AS [Label]
    ,[REPORT_GROUP_ID]   AS [ID]
    ,[PARENT_ID]         AS [ParentID]
    ,[BOTTOM_LEVEL]      AS [BottomLevel]
FROM
(
SELECT DISTINCT
     ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_NAME]
    ,ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_ID]
    ,CAST(NULL AS NVARCHAR(255))                  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                            AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
) INPUTQUERY
ORDER BY [REPORT_GROUP_NAME]

SELECT ''Categories'' AS [Title]',
     [Description] = N'Pantry COGS dashboard - category filter, sourced from F_COGS_PERIOD.REPORT_GROUP with NULLs surfaced as "(no category)" rather than dropped, scoped to Growyze. Emits Label/ID/ParentID/BottomLevel.',
     [ModifiedDate] = GETDATE(),
     [ModifiedBy] = SUSER_SNAME()
WHEN NOT MATCHED THEN INSERT
    (DataSetName, VisualizationType, Version, Status,
     QueryTemplate, ParameterMappings, FilterDefinitions, OutputDefinitions,
     ExecutionQuery, Description, CreatedBy, ModifiedBy, CreatedDate, ModifiedDate)
VALUES (
    N'PantryCOGSCategories',
    N'FilterList',
    1,
    N'LIVE',
    N'SELECT DISTINCT
     ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_NAME]
    ,ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_ID]
    ,CAST(NULL AS NVARCHAR(255))                  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                            AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''',
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
    "Label": "REPORT_GROUP_NAME",
    "ID": "REPORT_GROUP_ID",
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
        "Title": "Categories"
      }
    }
  ]
}',
    N'SELECT
     [REPORT_GROUP_NAME] AS [Label]
    ,[REPORT_GROUP_ID]   AS [ID]
    ,[PARENT_ID]         AS [ParentID]
    ,[BOTTOM_LEVEL]      AS [BottomLevel]
FROM
(
SELECT DISTINCT
     ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_NAME]
    ,ISNULL(F.[REPORT_GROUP], N''(no category)'') AS [REPORT_GROUP_ID]
    ,CAST(NULL AS NVARCHAR(255))                  AS [PARENT_ID]
    ,CAST(1 AS BIGINT)                            AS [BOTTOM_LEVEL]
FROM [presentation].[F_COGS_PERIOD] F
WHERE F.[SOURCE] LIKE ''int_growyze%''
) INPUTQUERY
ORDER BY [REPORT_GROUP_NAME]

SELECT ''Categories'' AS [Title]',
    N'Pantry COGS dashboard - category filter, sourced from F_COGS_PERIOD.REPORT_GROUP with NULLs surfaced as "(no category)" rather than dropped, scoped to Growyze. Emits Label/ID/ParentID/BottomLevel.',
    N'andrew.kaplan@threerocks.co.uk',
    N'andrew.kaplan@threerocks.co.uk',
    GETDATE(),
    GETDATE()
);
