# Survey Presentation Layer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace all 38 legacy survey visualisation queries with Data Vault-backed presentation tables (D_QUESTION dimension + F_SURVEY_RESPONSE fact).

**Architecture:** Two new presentation tables built from the SurveyHero Data Vault entities (HUB_TOUCHPOINT, HUB_QUESTION, HUB_ANSWER, LNK_ANSWER_QUESTION_TOUCHPOINT). D_QUESTION provides a 3-level question hierarchy; F_SURVEY_RESPONSE is the fact at (TOUCHPOINT x QUESTION x ANSWER) grain with denormalized demographics. All 38 vis queries rewritten to use these tables.

**Tech Stack:** SQL Server (T-SQL), XMS BI platform control tables (PresentationTables, PresentationControl, VisualisationQueries, GlobalParameters)

**Design Doc:** `docs/plans/2026-03-03-survey-fact-table-design.md`

**All scripts:** `ClaudeDevelopment/` folder, MERGE upsert pattern, no hardcoded database names.

**Test org:** `20251202_XMS_3EBF26FE-E14A-40ED-A355-9A411B1273B4` (NeighboursSurvey, int_surveyhero001)

---

## Task 1: D_QUESTION PresentationTables Record

**Files:**
- Create: `ClaudeDevelopment/survey_presentation_tables.sql`

**Step 1: Write the D_QUESTION DDL record**

Write a MERGE upsert into `[core].[PresentationTables]` with natural key `(table_name, version)`. Follow the exact D_CHANNEL pattern from `8_PresentationTables.sql` (lines 90-148). D_QUESTION is a non-standard dimension — QUESTION has no ATTR_1-5 columns, so adapt the standard column set:

DDL columns:
```
[BOTTOM_HUB_ID] [binary](32) NULL
[BOTTOM_SRC] [nvarchar](255) NULL
[BOTTOM_LOAD_TS] [datetime2](7) NULL
[BOTTOM_EFFECTIVEFROM] [datetime2](7) NULL
[BOTTOM_EFFECTIVETO] [datetime2](7) NULL
[BOTTOM_CURRENT_FLAG] [bit] NULL
[BOTTOM_IS_DELETED] [bit] NULL
[BOTTOM_QUESTION_NAME] [nvarchar](500) NULL
[BOTTOM_QUESTION_ID] [nvarchar](255) NULL
[BOTTOM_LEVEL_NAME] [nvarchar](255) NULL
[BOTTOM_MICROSERVICE_ID] [nvarchar](255) NULL
[BOTTOM_MICROSERVICE_NAME] [nvarchar](255) NULL
[MIDDLE_1_HUB_ID] [binary](32) NULL
[MIDDLE_1_QUESTION_NAME] [nvarchar](255) NULL
[MIDDLE_1_LEVEL_NAME] [nvarchar](255) NULL
[TOP_HUB_ID] [binary](32) NULL
[TOP_QUESTION_NAME] [nvarchar](255) NULL
[TOP_LEVEL_NAME] [nvarchar](255) NULL
[HIERARCHY_PATH] [nvarchar](MAX) NULL
[TOTAL_LEVELS] [decimal](38,10) NULL
```

No indexes in the DDL (follows the existing auto-generated dimension pattern).

Record values: `table_name = N'D_QUESTION'`, `table_type = N'Dimension'`, `schema_name = N'presentation'`, `version = 1`, `status = N'live'`, `is_system_generated = 1`.

**Step 2: Verify via MCP**

Run the MERGE against `core` database via MCP to confirm it inserts/updates without error. Then SELECT back:
```sql
SELECT table_name, table_type, version, status FROM core.core.PresentationTables WHERE table_name = 'D_QUESTION'
```

---

## Task 2: F_SURVEY_RESPONSE PresentationTables Record

**Files:**
- Modify: `ClaudeDevelopment/survey_presentation_tables.sql` (append)

**Step 1: Write the F_SURVEY_RESPONSE DDL record**

Follow the F_LINEITEM_15MIN pattern from `8_PresentationTables.sql` (lines 1360-1455). MERGE upsert into `[core].[PresentationTables]` with natural key `(table_name, version)`.

DDL columns:
```
[TOUCHPOINT_HUB_ID] [binary](32) NOT NULL
[QUESTION_HUB_ID] [binary](32) NOT NULL
[ANSWER_HUB_ID] [binary](32) NOT NULL
[TOUCHPOINT_DATE] [datetime2](7) NULL
[TOUCHPOINT_STATUS] [nvarchar](255) NULL
[ANSWER_TEXT] [nvarchar](MAX) NULL
[ANSWER_NUMERIC] [decimal](38,10) NULL
[COMMUNITY_INVOLVEMENT] [nvarchar](255) NULL
[AGE_BRACKET] [nvarchar](255) NULL
[GENDER] [nvarchar](255) NULL
[POSTCODE] [nvarchar](255) NULL
```

Indexes in the DDL (follow F_LINEITEM_15MIN pattern):
```sql
CREATE CLUSTERED INDEX [F_SURVEY_RESPONSE-CLUSTERED] ON [presentation].[F_SURVEY_RESPONSE]
(
    [TOUCHPOINT_DATE] ASC,
    [QUESTION_HUB_ID] ASC
) WITH (PAD_INDEX = OFF, ...) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-TOUCHPOINT] ON [presentation].[F_SURVEY_RESPONSE]
(
    [TOUCHPOINT_HUB_ID] ASC
) WITH (...) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-QUESTION] ON [presentation].[F_SURVEY_RESPONSE]
(
    [QUESTION_HUB_ID] ASC
) WITH (...) ON [PRIMARY];

CREATE NONCLUSTERED INDEX [F_SURVEY_RESPONSE-ANSWER] ON [presentation].[F_SURVEY_RESPONSE]
(
    [ANSWER_HUB_ID] ASC
) WITH (...) ON [PRIMARY];
```

Record values: `table_name = N'F_SURVEY_RESPONSE'`, `table_type = N'Fact'`, `schema_name = N'presentation'`, `version = 1`, `status = N'live'`, `is_system_generated = 0`.

**Step 2: Verify via MCP**

Same as Task 1 — run MERGE, then SELECT back to confirm.

---

## Task 3: D_QUESTION PresentationControl Build Query

**Files:**
- Create: `ClaudeDevelopment/survey_presentation_control.sql`

**Step 1: Write the D_QUESTION build query**

MERGE upsert into `[core].[PresentationControl]` with natural key `(id)`. Use a new GUID. Follow the D_CHANNEL build pattern from `8_PresentationControl.sql` (lines 20-285) but adapted for QUESTION's hierarchy.

The query_sql must:
1. Use recursive CTE starting from `SAT_QUESTION WHERE BOTTOM_LEVEL = 1 AND CURRENT_FLAG = 1`
2. Join PARENT_ID to find MIDDLE nodes (these have `LEVEL_NAME = 'QUESTION MIDDLE'`)
3. For MIDDLE nodes, extract the TOP parent by using the portion of `QUESTION_ID` before the hyphen (e.g. `12051134-Poor` → parent_id `12051134`)
4. Join to TOP nodes (`LEVEL_NAME = 'QUESTION TOP'`)
5. For unparented leaf questions (PARENT_ID IS NULL), set TOP = 'Other', MIDDLE = 'Unknown'
6. UNION ALL a sentinel row with `CONVERT(BINARY(32), -999)` as BOTTOM_HUB_ID and 'Unknown' for all name columns
7. Final SELECT outputs columns matching D_QUESTION table DDL

Key adaptation from D_CHANNEL: QUESTION's hierarchy uses PARENT_ID directly for leaf→MIDDLE joins, but MIDDLE→TOP requires extracting the numeric prefix from MIDDLE's QUESTION_ID (format: `{top_element_id}-{scale_label}`). Use: `LEFT(SQ_MID.QUESTION_ID, CHARINDEX('-', SQ_MID.QUESTION_ID) - 1)` to get the TOP element_id, then join to SAT_QUESTION where QUESTION_ID matches and LEVEL_NAME = 'QUESTION TOP'.

For leaf questions where PARENT_ID points directly to a TOP node (not a MIDDLE), handle this by checking if the parent has `LEVEL_NAME = 'QUESTION TOP'` (these get MIDDLE = 'Unknown').

PresentationControl record values:
- `id = N'{generate new GUID}'`
- `step_name = N'Question Dimension'`
- `table_name = N'D_QUESTION'`
- `tier = 1`
- `table_type = N'Dimension'`
- `exclude = 0`, `priority = 100`, `retry_count = 3`, `timeout_minutes = 30`
- `time_series_entity = N'None'`, `time_series_target_column = NULL`
- `column_mappings` JSON array matching every SELECT column to its table column and target data type

**Step 2: Test the build query via MCP**

Run the query_sql against the test org database using three-part naming (prefix all `[datavault].*` references with `[20251202_XMS_3EBF26FE-E14A-40ED-A355-9A411B1273B4]`). Verify:
- Scored questions have correct TOP/MIDDLE/BOTTOM hierarchy
- Unparented questions have TOP='Other', MIDDLE='Unknown'
- Sentinel row is present
- Row count is reasonable (~100+ rows)

**Step 3: Insert the PresentationControl record via MCP**

Run the MERGE statement. Verify with:
```sql
SELECT id, step_name, table_name, tier FROM core.core.PresentationControl WHERE table_name = 'D_QUESTION'
```

---

## Task 4: F_SURVEY_RESPONSE PresentationControl Build Query

**Files:**
- Modify: `ClaudeDevelopment/survey_presentation_control.sql` (append)

**Step 1: Write the F_SURVEY_RESPONSE build query**

MERGE upsert into `[core].[PresentationControl]`. The query_sql must:

1. Declare `@StartDate DATE`, `@EndDate DATE` from GlobalParameters keys `TOUCHPOINT_START` and `TOUCHPOINT_END`
2. Start from `[datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK`
3. `INNER JOIN [datavault].[SAT_TOUCHPOINT] TP ON LNK.TOUCHPOINT_HUB_ID = TP.HUB_ID AND TP.CURRENT_FLAG = 1 AND TP.IS_DELETED = 0`
4. `INNER JOIN [datavault].[SAT_QUESTION] SQ ON LNK.QUESTION_HUB_ID = SQ.HUB_ID AND SQ.CURRENT_FLAG = 1 AND SQ.BOTTOM_LEVEL = 1` — only leaf questions
5. `INNER JOIN [datavault].[SAT_ANSWER] SA ON LNK.ANSWER_HUB_ID = SA.HUB_ID AND SA.CURRENT_FLAG = 1`
6. Demographic denormalization — 4 LEFT JOINs:

```sql
-- Community Involvement (Survey Selection)
LEFT JOIN [datavault].[LNK_ANSWER_QUESTION_TOUCHPOINT] LNK_CI
    ON LNK.TOUCHPOINT_HUB_ID = LNK_CI.TOUCHPOINT_HUB_ID
LEFT JOIN [datavault].[SAT_QUESTION] SQ_CI
    ON LNK_CI.QUESTION_HUB_ID = SQ_CI.HUB_ID AND SQ_CI.CURRENT_FLAG = 1
    AND SQ_CI.QUESTION = 'Survey Selection'
LEFT JOIN [datavault].[SAT_ANSWER] SA_CI
    ON LNK_CI.ANSWER_HUB_ID = SA_CI.HUB_ID AND SA_CI.CURRENT_FLAG = 1

-- Repeat pattern for Age, Gender, Postcode with their respective question texts:
-- 'What age bracket are you in ?'
-- 'What is your gender ?'
-- 'What is your postcode ?'
```

7. WHERE clause: `CAST(TP.TOUCHPOINT_DATETIME AS DATE) BETWEEN @StartDate AND @EndDate`
8. SELECT:
```sql
SELECT
    ISNULL(LNK.TOUCHPOINT_HUB_ID, CONVERT(BINARY(32), -999)) AS TOUCHPOINT_HUB_ID,
    ISNULL(LNK.QUESTION_HUB_ID, CONVERT(BINARY(32), -999)) AS QUESTION_HUB_ID,
    ISNULL(LNK.ANSWER_HUB_ID, CONVERT(BINARY(32), -999)) AS ANSWER_HUB_ID,
    CAST(TP.TOUCHPOINT_DATETIME AS DATE) AS TOUCHPOINT_DATE,
    TP.TOUCHPOINT_STATUS,
    SA.ANSWER AS ANSWER_TEXT,
    TRY_CAST(SA.ANSWER AS DECIMAL(38,10)) AS ANSWER_NUMERIC,
    SA_CI.ANSWER AS COMMUNITY_INVOLVEMENT,
    SA_AGE.ANSWER AS AGE_BRACKET,
    SA_GEN.ANSWER AS GENDER,
    SA_PC.ANSWER AS POSTCODE
```

PresentationControl record values:
- `id = N'{generate new GUID}'`
- `step_name = N'Survey Response Fact'`
- `table_name = N'F_SURVEY_RESPONSE'`
- `tier = 1`
- `table_type = N'Fact'`
- `time_series_entity = N'TOUCHPOINT'`
- `time_series_target_column = N'TOUCHPOINT_DATE'`

**Step 2: Test the build query via MCP**

Run the query_sql against test org with three-part naming. Verify:
- Each fact row has correct TOUCHPOINT_HUB_ID, QUESTION_HUB_ID, ANSWER_HUB_ID
- COMMUNITY_INVOLVEMENT is populated for respondents who answered "Survey Selection"
- ANSWER_NUMERIC is populated for numeric answers (1-6), NULL for text
- Row count is reasonable (~50-100K)
- Demographic denorm columns are correctly populated

**Step 3: Insert the PresentationControl record**

Run the MERGE. Verify with SELECT.

---

## Task 5: Survey Filter Vis Queries (2 records)

**Files:**
- Create: `ClaudeDevelopment/survey_vis_queries.sql`

**Step 1: Rewrite SurveyFilter**

MERGE upsert into `[core].[core].[VisualisationQueries]` with natural key `(DataSetName, VisualizationType, Version)`.

QueryTemplate:
```sql
SELECT DISTINCT
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
''Community Involvement'' AS Title
```

FilterDefinitions: `{}` (this IS the filter source — no upstream filters)
ParameterMappings: `{"LocationList": "", "StartDate": "", "EndDate": ""}`
OutputDefinitions: `{}`

**Step 2: Rewrite SurveyFilterAge**

Same pattern but:
- Select `f.AGE_BRACKET AS Label, f.AGE_BRACKET AS ID`
- Add SurveyFilter FilterDefinition: `{"SurveyFilter": {"column": "f.COMMUNITY_INVOLVEMENT", "type": "IN", "dataType": "VARCHAR"}}`
- Title: `'Age Bracket'`

**Step 3: Test both filters via MCP**

Run each QueryTemplate against test org (with three-part naming on presentation tables). Verify DISTINCT values match expected.

---

## Task 6: Demographic Vis Queries (5 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

Rewrite these DataSetNames using the demographic count pattern from design doc section 5.1:

| DataSetName | CardType | Query Pattern |
|---|---|---|
| `SurveyAgeByGender` | CustomDataGrid | Cross-tab: Age_Bracket rows x Gender columns, `COUNT(DISTINCT TOUCHPOINT_HUB_ID)`. Join D_QUESTION for age question AND gender question via two separate subqueries per touchpoint. |
| `SurveyAgeByGender` | CustomPinnedDataGrid | Same data as above but with PinnedColumn output format |
| `SurveyAgeByRespondentTotal` | BarChartCard | `WHERE q.BOTTOM_QUESTION_NAME = 'What age bracket are you in ?'` + `COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)` grouped by `f.ANSWER_TEXT` |
| `SurveyAgeGender` | HeatmapCard | Cross-tab: AGE_BRACKET x GENDER from denorm columns, `COUNT(DISTINCT f.TOUCHPOINT_HUB_ID)` — can query fact directly using denorm columns |
| `SurveyGenderByRespondentTotal` | PieChartCard | Same pattern as AgeByRespondentTotal but for gender question |

Key simplification: For cross-tabs (AgeByGender, AgeGender), use the denormalized columns directly:
```sql
SELECT f.AGE_BRACKET, f.GENDER, COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS cnt
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = ''completed''
AND f.AGE_BRACKET IS NOT NULL AND f.GENDER IS NOT NULL
-- Deduplicate to one row per touchpoint by filtering to a single question
AND f.QUESTION_HUB_ID = (SELECT TOP 1 q.BOTTOM_HUB_ID FROM [presentation].[D_QUESTION] q
    WHERE q.BOTTOM_QUESTION_NAME = ''What age bracket are you in ?'')
AND 1=1 @FilterClause
GROUP BY f.AGE_BRACKET, f.GENDER
```

Update OutputDefinitions and FilterDefinitions per card type. Use `SurveyFilter` and `SurveyFilterAge` filters where the legacy queries had them:
```json
{
  "SurveyFilter": {"column": "f.COMMUNITY_INVOLVEMENT", "type": "IN", "dataType": "VARCHAR"},
  "SurveyFilterAge": {"column": "f.AGE_BRACKET", "type": "IN", "dataType": "VARCHAR"}
}
```

Test each query via MCP against test org.

---

## Task 7: Completion Vis Queries (2 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

| DataSetName | CardType | Notes |
|---|---|---|
| `SurveyCompletion` | StackedBarChartCard | Group by COMMUNITY_INVOLVEMENT, count per value. Use denorm column, filter to a single question to avoid duplicates. |
| `SurveyStatusByInvolvement` | CustomPinnedDataGrid | Cross-tab: COMMUNITY_INVOLVEMENT x TOUCHPOINT_STATUS. **Fix legacy bug:** table name typo. Include both completed and incomplete statuses. |

---

## Task 8: Score Average Vis Queries — Lifestyle (6 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

All use the score average pattern from design doc section 5.2:

| DataSetName | CardType | TOP filter | MIDDLE filter | Group by |
|---|---|---|---|---|
| `SurveyAverageLifestyleScore` | PieChartCard | 'Lifestyle provision' | 'Poor' | COMMUNITY_INVOLVEMENT |
| `SurveyLifestyleProvision` | BarChartCard | 'Lifestyle provision' | 'Poor' | BOTTOM_QUESTION_NAME |
| `SurveyLifestyleRadar` | RadarChartCard | 'Lifestyle provision' | 'Poor' | BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT |
| `SurveyEnvironmentRadar` | RadarChartCard | 'Lifestyle provision' | 'Poor' | BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT |
| `SurveyRespondentByLifestyle` | StackedBarChartCard | 'Lifestyle provision' | 'Poor' | BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT |
| `SurveyLifestyleThoughts` | SingleKPICard | Free-text: `q.TOP_QUESTION_NAME = 'Lifestyle provision' AND q.BOTTOM_QUESTION_NAME = 'Any extra thoughts ?'` | n/a | STRING_AGG |

Standard score query template:
```sql
SELECT q.BOTTOM_QUESTION_NAME AS Activity_Type,
       f.COMMUNITY_INVOLVEMENT,
       AVG(f.ANSWER_NUMERIC) AS Avg_Score
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.TOP_QUESTION_NAME = ''Lifestyle provision''
  AND q.MIDDLE_1_QUESTION_NAME = ''Poor''
  AND f.ANSWER_NUMERIC IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
```

Adapt OutputDefinitions per card type (XAxis, YAxis, Series, etc.).

---

## Task 9: Score Average Vis Queries — Challenging Issues (5 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

Same pattern as Task 9 but `TOP_QUESTION_NAME = 'Challenging issues'`:

| DataSetName | CardType | Notes |
|---|---|---|
| `SurveyAverageChallengeScore` | PieChartCard | Group by COMMUNITY_INVOLVEMENT |
| `SurveyChallengingRadar` | RadarChartCard | Group by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT |
| `SurveyRespondentByChallenge` | StackedBarChartCard | Group by BOTTOM_QUESTION_NAME + COMMUNITY_INVOLVEMENT |
| `SurveyChallengeThoughts` | CustomDataGrid | Free-text listing. **Fix legacy bug:** was hardcoded to Church Member only |
| `SurveyChallengeThoughtsnonChurch` | CustomDataGrid | Free-text with SurveyFilter |

---

## Task 10: Score Average Vis Queries — Environment (3 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

`TOP_QUESTION_NAME = 'Our Environment'`:

| DataSetName | CardType | Notes |
|---|---|---|
| `SurveyEnvironmentRadarBad` | RadarChartCard | **Fix legacy bug:** was using challenge columns + wrong CASE labels. Now correctly uses Environment TOP. |
| `SurveyRespondentByEnvironment` | StackedBarChartCard | **Fix legacy bug:** was copy of RespondentByChallenge. Now correctly uses Environment TOP. |
| `SurveyEnvironmentThoughts` | CustomDataGrid | **Fix legacy bug:** was querying wrong column (Lifestyle instead of Environment free-text). Filter to `q.TOP_QUESTION_NAME = 'Our Environment' AND q.BOTTOM_QUESTION_NAME = 'Any extra thoughts ?'`. |

---

## Task 11: Building/Travel/Activity Vis Queries (8 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

These use the demographic count pattern with specific question names:

| DataSetName | CardType | Question filter |
|---|---|---|
| `SurveyBuildingActivities` | PieChartCard | 'Are the buildings well suited to the needs of the activities you attend?' |
| `SurveyBuildingSuited` | PieChartCard | 'Are the church buildings well suited to the needs of those regularly using them?' |
| `SurveyBuildingUse` | BarChartCard | 'Which of the following do you regularly attend?' (multi-choice) |
| `SurveyBuildingUse` | PieChartCard | 'Do you use, visit or hire the Eastleigh Baptist Church Buildings?' |
| `SurveyMembersDistance` | BarChartCard | 'How far do you travel to the church ?' |
| `SurveyMembersTravel` | BarChartCard | 'How do you usually get to the church ?' |
| `SurveyDistanceTransport` | HeatmapCard | Cross-tab using two question subqueries for Distance x Transport |
| `SurveyMemberActivities` | BarChartCard | 'Which of the following do you regularly attend?' (same multi-choice, different presentation) |

Multi-choice pattern (SurveyBuildingUse BarChart):
```sql
SELECT f.ANSWER_TEXT AS Activity, COUNT(*) AS cnt
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''Which of the following do you regularly attend?''
  AND f.ANSWER_TEXT IS NOT NULL
  AND 1=1 @FilterClause
GROUP BY f.ANSWER_TEXT
ORDER BY cnt DESC
```

---

## Task 12: Free-Text & KPI Vis Queries (7 records)

**Files:**
- Modify: `ClaudeDevelopment/survey_vis_queries.sql` (append)

| DataSetName | CardType | Question filter | Notes |
|---|---|---|---|
| `SurveyImprovementsNeeded` | CustomDataGrid | 'What improvements need to be made...' | Row listing |
| `SurveyBuildingUseImprovements` | SingleKPICard | 'What improvements need to be made...' | STRING_AGG |
| `SurveyBuildingUseMessage` | SingleKPICard | 'What message do you think...' | STRING_AGG |
| `SurveyVisitorMessage` | CustomDataGrid | 'What message do you think...' | Row listing |
| `SurveyLifestyleProvisionThoughts` | CustomDataGrid | 'Any extra thoughts ?' under Lifestyle | Row listing |
| `SurveyLifestyleProvisionThoughtsnonChurch` | CustomDataGrid | Same, with SurveyFilter | Row listing |
| `SurveyLifestyleThoughts` | SingleKPICard | 'Any extra thoughts ?' under Lifestyle | STRING_AGG (if not already in Task 9) |

Free-text row listing pattern:
```sql
SELECT f.ANSWER_TEXT AS Response_Text
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''<question text>''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause
```

STRING_AGG KPI pattern:
```sql
SELECT STRING_AGG(f.ANSWER_TEXT, CHAR(10)) AS Aggregated_Text
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = ''completed''
  AND q.BOTTOM_QUESTION_NAME = ''<question text>''
  AND f.ANSWER_TEXT IS NOT NULL
  AND LEN(LTRIM(RTRIM(f.ANSWER_TEXT))) > 0
  AND 1=1 @FilterClause
```

---

## Task 13: Verify and Update QUERY_STATUS.md

**Files:**
- Modify: `ClaudeDevelopment/QUERY_STATUS.md`

**Step 1:** Run a final count check via MCP to verify all 38 vis query records have been rewritten:
```sql
SELECT DataSetName, VisualizationType, Version, Status
FROM core.core.VisualisationQueries
WHERE DataSetName LIKE 'Survey%'
ORDER BY DataSetName
```

**Step 2:** Update `ClaudeDevelopment/QUERY_STATUS.md` with entries for all new scripts:
- `survey_presentation_tables.sql` — purpose, test results
- `survey_presentation_control.sql` — purpose, test results
- `survey_global_parameters.sql` — purpose, test results
- `survey_vis_queries.sql` — purpose, test results, count of records

---

## Execution Notes

- **All MCP test queries** use three-part naming from `core` database. Never save three-part names in the script files.
- **MERGE natural keys:**
  - PresentationTables: `(table_name, version)`
  - PresentationControl: `(id)` (GUID)
  - VisualisationQueries: `(DataSetName, VisualizationType, Version)`
  - GlobalParameters: `(ParameterKey)`
- **Single quotes in query_sql** must be doubled (`''`) since they're inside an N'...' string literal in the PresentationControl INSERT.
- **FilterDefinitions** for SurveyFilter map to `f.COMMUNITY_INVOLVEMENT`; SurveyFilterAge maps to `f.AGE_BRACKET`. The `f.` alias prefix must be included since vis queries alias the fact table as `f`.
- **OutputDefinitions** vary by card type — copy the JSON structure from the existing legacy record for each DataSetName, updating only column names/references.
