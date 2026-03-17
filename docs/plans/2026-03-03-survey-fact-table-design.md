# Survey Presentation Layer Design

**Date:** 2026-03-03
**Status:** Approved
**Scope:** Replace legacy `threerocks.dbo.church_survey_results` references in all 38 survey visualisation queries with Data Vault-backed presentation tables.

---

## 1. Problem Statement

All 38 survey visualisation queries (DataSetName prefix `Survey*`) read from `threerocks.dbo.church_survey_results` — a flat external table outside the XMS BI platform. The SurveyHero integration now populates the Data Vault (HUB_TOUCHPOINT, HUB_QUESTION, HUB_ANSWER, LNK_ANSWER_QUESTION_TOUCHPOINT). We need presentation-layer fact table(s) and a dimension to serve the vis queries from the DV.

## 2. Data Vault Source Model

```
HUB_ANSWER ─────────┐
                     ├──► LNK_ANSWER_QUESTION_TOUCHPOINT (ternary)
HUB_QUESTION ────────┤
                     │
HUB_TOUCHPOINT ──────┘
```

- **HUB_TOUCHPOINT / SAT_TOUCHPOINT**: One record per survey response. `TOUCHPOINT_DATETIME` is the time-series column. `TOUCHPOINT_STATUS` = "completed" or "incomplete".
- **HUB_QUESTION / SAT_QUESTION**: Survey questions with 3-level hierarchy (`QUESTION TOP` → `QUESTION MIDDLE` → `QUESTION` leaf). Includes both scored questions (under TOP sections) and unparented demographic/building/travel questions.
- **HUB_ANSWER / SAT_ANSWER**: Answer values (always leaf, `BOTTOM_LEVEL = 1`). Numeric ratings stored as text ("1" through "6"), categorical choices, and free-text responses.
- **LNK_ANSWER_QUESTION_TOUCHPOINT**: One row per (respondent × question × answer). The central fact grain.

### Question Hierarchy Structure

**TOP level (4 sections):**
- "Lifestyle provision" — 10 provision categories, each rated on 3 scales
- "Challenging issues" — 8 provision categories, each rated on 3 scales
- "Our Environment" — 9 environment categories, each rated on 3 scales
- "Instructions" — survey routing question ("Survey Selection")

**MIDDLE level (3 rating scales per scored section):**
- "Poor" — the Poor → Excellent quality scale (all respondents)
- "Not called" — the Not called → Definitely called vocation scale (church members only)
- "No expertise & resources" — the resource availability scale (church members only)

**BOTTOM level (leaf questions):**
- ~27 scored questions per section (9-10 categories × 3 scales)
- ~14 unparented questions (demographics, building, travel, free-text)

### Key Data Mappings (Legacy → DV)

| Legacy Column | DV Question Text | Answer Type |
|---|---|---|
| `Community_Involvement` | "Survey Selection" | Categorical: "Church congregation member", "Community Leader", "Resident", "Worker" |
| `Age_Bracket` | "What age bracket are you in ?" | Categorical: "Age 16 - 19" through "Age 80+" |
| `Gender` | "What is your gender ?" | Categorical: "Female", "Male", "Other", "I would rather not say" |
| `Postcode` | "What is your postcode ?" | Free-text |
| `Survey_Status` | `TOUCHPOINT_STATUS` | "Complete" → "completed" (lowercase in DV) |
| `Distance_to_Church` | "How far do you travel to the church ?" | Categorical |
| `Transport_Method` | "How do you usually get to the church ?" | Categorical |
| `Use_Buildings_Regularly` | "Do you use, visit or hire the Eastleigh Baptist Church Buildings?" | Categorical |
| `Buildings_Suited_to_activities` | "Are the buildings well suited to the needs of the activities you attend?" | Categorical: Yes/No/Not sure |
| `Buildings_Suited_Overall` | "Are the church buildings well suited to the needs of those regularly using them?" | Categorical: Yes/No/Not sure |
| `Improvements_Needed` | "What improvements need to be made to the buildings to support the work of the church better?" | Free-text |
| `message_to_visitors` | "What message do you think the church building and site give to visitors and passers by?" | Free-text |
| `Involved_in` / `Regular_Activities` | "Which of the following do you regularly attend?" | Multi-choice (one link row per selection — no STRING_SPLIT needed) |
| 8× `Activities_Provision_for_*` | Under "Lifestyle provision" TOP | Numeric 1-6 (one row per category per scale) |
| 8× `Provision_for_*` | Under "Challenging issues" TOP | Numeric 1-6 |
| 10× Environmental scores | Under "Our Environment" TOP | Numeric 1-6 |
| `Extra_Thoughts_Lifestyle_Provision` | "Any extra thoughts ?" under "Lifestyle provision" | Free-text |
| `Extra_Thoughts_Challenging_Issues` | "Any extra thoughts ?" under "Challenging issues" | Free-text |

## 3. Presentation Table Design

### 3.1 D_QUESTION (Dimension — 3-level hierarchy)

| Column | Type | Nullable | Description |
|---|---|---|---|
| `BOTTOM_HUB_ID` | `binary(32)` | NOT NULL | Leaf question hub ID (PK, join key from fact table) |
| `BOTTOM_QUESTION_NAME` | `nvarchar(500)` | NULL | Question text |
| `BOTTOM_QUESTION_ID` | `nvarchar(255)` | NULL | Source element_id |
| `MIDDLE_1_HUB_ID` | `binary(32)` | NOT NULL | Scale label hub ID (sentinel for unparented) |
| `MIDDLE_1_QUESTION_NAME` | `nvarchar(255)` | NULL | "Poor", "Not called", "No expertise & resources", or "Unknown" |
| `TOP_HUB_ID` | `binary(32)` | NOT NULL | Section hub ID (sentinel for unparented) |
| `TOP_QUESTION_NAME` | `nvarchar(255)` | NULL | "Lifestyle provision", "Challenging issues", "Our Environment", or "Other" |

**Hierarchy mapping:**
- Scored questions: TOP = section name, MIDDLE = scale label, BOTTOM = question text
- Unparented questions: TOP = "Other", MIDDLE = "Unknown", BOTTOM = question text
- "Survey Selection" (under "Instructions" TOP): TOP = "Other", MIDDLE = "Unknown", BOTTOM = "Survey Selection"

**Clustered index:** `(TOP_HUB_ID ASC, MIDDLE_1_HUB_ID ASC, BOTTOM_HUB_ID ASC)`
**NC index:** `BOTTOM_HUB_ID`

### 3.2 F_SURVEY_RESPONSE (Fact — grain: TOUCHPOINT × leaf QUESTION × ANSWER)

| Column | Type | Nullable | Description |
|---|---|---|---|
| `TOUCHPOINT_HUB_ID` | `binary(32)` | NOT NULL | Survey response FK |
| `QUESTION_HUB_ID` | `binary(32)` | NOT NULL | Leaf question FK → D_QUESTION.BOTTOM_HUB_ID |
| `ANSWER_HUB_ID` | `binary(32)` | NOT NULL | Answer FK |
| `TOUCHPOINT_DATE` | `datetime2(7)` | NULL | Response date (time-series partition key) |
| `TOUCHPOINT_STATUS` | `nvarchar(255)` | NULL | "completed" / "incomplete" |
| `ANSWER_TEXT` | `nvarchar(MAX)` | NULL | Answer label or free-text content |
| `ANSWER_NUMERIC` | `decimal(38,10)` | NULL | TRY_CAST of ANSWER_TEXT — NULL if non-numeric |
| `COMMUNITY_INVOLVEMENT` | `nvarchar(255)` | NULL | Denormalized from "Survey Selection" answer |
| `AGE_BRACKET` | `nvarchar(255)` | NULL | Denormalized from "What age bracket..." answer |
| `GENDER` | `nvarchar(255)` | NULL | Denormalized from "What is your gender..." answer |
| `POSTCODE` | `nvarchar(255)` | NULL | Denormalized from "What is your postcode..." answer |

**Clustered index:** `(TOUCHPOINT_DATE ASC, QUESTION_HUB_ID ASC)`
**NC indexes:** `TOUCHPOINT_HUB_ID`, `QUESTION_HUB_ID`, `ANSWER_HUB_ID`

**time_series_entity:** `TOUCHPOINT`
**time_series_target_column:** `TOUCHPOINT_DATE`

### 3.3 Scale Filtering and COMMUNITY_INVOLVEMENT

All respondent types answered the "Poor" scale. Only church members ("Church congregation member") answered the "Not called" and "No expertise & resources" scales. This is self-filtering in the data — non-church respondents simply have no fact rows for those scales. Vis queries filtering by `MIDDLE_1_QUESTION_NAME` and/or `COMMUNITY_INVOLVEMENT` work without special logic.

## 4. PresentationControl Build Steps

### Step 1: D_QUESTION (Tier 1, Dimension)

```
Build approach:
- Recursive CTE from SAT_QUESTION (CURRENT_FLAG=1, IS_DELETED=0)
- Start with BOTTOM_LEVEL=1 leaf questions
- Join to MIDDLE parents via PARENT_ID
- Join MIDDLE to TOP parents via MIDDLE's PARENT_ID (strip the scale suffix)
- COALESCE unparented questions: TOP='Other', MIDDLE='Unknown'
- Sentinel binary(32) for NULL hub IDs: CONVERT(BINARY(32), -999)
```

### Step 2: F_SURVEY_RESPONSE (Tier 1, Fact)

```
Build approach:
- Date range from GlobalParameters (TOUCHPOINT_START / TOUCHPOINT_END — new keys needed)
- Start from LNK_ANSWER_QUESTION_TOUCHPOINT
- INNER JOIN SAT_TOUCHPOINT for date, status
- INNER JOIN SAT_ANSWER for answer text
- Only include leaf questions (BOTTOM_LEVEL=1 in SAT_QUESTION)
- Demographic denormalization via 4 self-joins on the ternary link:
    1. "Survey Selection" → COMMUNITY_INVOLVEMENT
    2. "What age bracket are you in ?" → AGE_BRACKET
    3. "What is your gender ?" → GENDER
    4. "What is your postcode ?" → POSTCODE
  Each self-join: match TOUCHPOINT_HUB_ID, filter SAT_QUESTION.QUESTION by text
- TRY_CAST(SA.ANSWER AS DECIMAL(38,10)) for ANSWER_NUMERIC
- ISNULL sentinel replacement on all hub ID FKs
```

## 5. Vis Query Rewrite Patterns

### 5.1 Demographic counts (e.g. SurveyAgeByRespondentTotal)

**Before:** `SELECT Age_Bracket, COUNT(Respondent_ID) FROM threerocks.dbo.church_survey_results WHERE Survey_Status='Complete' GROUP BY Age_Bracket`

**After:**
```sql
SELECT f.ANSWER_TEXT AS Age_Bracket, COUNT(DISTINCT f.TOUCHPOINT_HUB_ID) AS Respondent_Count
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = 'completed'
  AND q.BOTTOM_QUESTION_NAME = 'What age bracket are you in ?'
  AND f.ANSWER_TEXT IS NOT NULL
  @FilterClause
GROUP BY f.ANSWER_TEXT
```

### 5.2 Score averages (e.g. SurveyLifestyleRadar)

**Before:** UNPIVOT 8 `Activities_Provision_for_*` columns, `AVG(CAST(Score AS FLOAT))`

**After:**
```sql
SELECT q.BOTTOM_QUESTION_NAME AS Activity_Type,
       f.COMMUNITY_INVOLVEMENT,
       AVG(f.ANSWER_NUMERIC) AS Avg_Score
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = 'completed'
  AND q.TOP_QUESTION_NAME = 'Lifestyle provision'
  AND q.MIDDLE_1_QUESTION_NAME = 'Poor'
  AND f.ANSWER_NUMERIC IS NOT NULL
  @FilterClause
GROUP BY q.BOTTOM_QUESTION_NAME, f.COMMUNITY_INVOLVEMENT
```

### 5.3 Multi-choice counts (e.g. SurveyBuildingUse BarChart)

**Before:** `STRING_SPLIT(Involved_in, ';')` + `COUNT(*)`

**After:**
```sql
SELECT f.ANSWER_TEXT AS Activity, COUNT(*) AS Count
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = 'completed'
  AND q.BOTTOM_QUESTION_NAME = 'Which of the following do you regularly attend?'
  AND f.ANSWER_TEXT IS NOT NULL
  @FilterClause
GROUP BY f.ANSWER_TEXT
```

### 5.4 Free-text listing (e.g. SurveyImprovementsNeeded)

**Before:** `SELECT Improvements_Needed FROM ... WHERE Improvements_Needed IS NOT NULL`

**After:**
```sql
SELECT f.ANSWER_TEXT AS Improvements_Needed
FROM [presentation].[F_SURVEY_RESPONSE] f
INNER JOIN [presentation].[D_QUESTION] q ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE f.TOUCHPOINT_STATUS = 'completed'
  AND q.BOTTOM_QUESTION_NAME = 'What improvements need to be made to the buildings to support the work of the church better?'
  AND f.ANSWER_TEXT IS NOT NULL
  @FilterClause
```

### 5.5 Filter lists (e.g. SurveyFilter)

**Before:** `SELECT DISTINCT Community_Involvement`

**After:**
```sql
SELECT DISTINCT f.COMMUNITY_INVOLVEMENT AS Label, f.COMMUNITY_INVOLVEMENT AS ID,
       NULL AS ParentID, 1 AS BottomLevel
FROM [presentation].[F_SURVEY_RESPONSE] f
WHERE f.TOUCHPOINT_STATUS = 'completed'
  AND f.COMMUNITY_INVOLVEMENT IS NOT NULL
  @FilterClause
```

### 5.6 Demographic filters in vis queries

**Before:** `WHERE Community_Involvement = 'Church Member'`

**After:** `WHERE f.COMMUNITY_INVOLVEMENT = 'Church congregation member'`

FilterDefinitions will map `SurveyFilter` → `COMMUNITY_INVOLVEMENT` column on F_SURVEY_RESPONSE. The `@FilterClause` injection pattern remains the same.

## 6. FilterDefinitions Changes

The SurveyFilter and SurveyFilterAge filter definitions need updating:

| Filter | Legacy Column | New Column | New Table |
|---|---|---|---|
| SurveyFilter | `Community_Involvement` | `COMMUNITY_INVOLVEMENT` | `F_SURVEY_RESPONSE` (aliased as `f`) |
| SurveyFilterAge | `Age_Bracket` | `AGE_BRACKET` | `F_SURVEY_RESPONSE` (aliased as `f`) |

## 7. New GlobalParameters Required

| ParameterKey | Category | Purpose |
|---|---|---|
| `TOUCHPOINT_START` | `DATE_RANGE` | Start date for F_SURVEY_RESPONSE build |
| `TOUCHPOINT_END` | `DATE_RANGE` | End date for F_SURVEY_RESPONSE build |

## 8. Known Issues & Bugs in Legacy Vis Queries

These should be corrected during the rewrite:

1. **SurveyStatusByInvolvement** — table name typo: `threerock.dbo.church_survey_results` (missing 's')
2. **SurveyRespondentByEnvironment** — copy-paste error: UNPIVOTs `Provision_for_*` (challenge columns) instead of environmental columns
3. **SurveyEnvironmentRadarBad** — CASE statement maps environment column names to lifestyle labels
4. **SurveyEnvironmentThoughts** — queries `Extra_Thoughts_Lifestyle_Provision` column despite being named "Environment"
5. **SurveyAgeGender** (HeatmapCard) — no `@FilterClause` applied (hardcoded filter only)
6. **Multiple queries** — FilterDefinitions contain stale POS template entries (Discounts, Products, ProductCategories) that map to empty columns

## 9. Implementation Steps

1. Create D_QUESTION PresentationTables record (DDL)
2. Create F_SURVEY_RESPONSE PresentationTables record (DDL)
3. Create D_QUESTION PresentationControl record (build query)
4. Create F_SURVEY_RESPONSE PresentationControl record (build query)
5. Create TOUCHPOINT_START/TOUCHPOINT_END GlobalParameters records
6. Rewrite all 38 survey VisualisationQueries records (QueryTemplate, OutputDefinitions, FilterDefinitions, ParameterMappings)
7. Fix legacy bugs listed in section 8

All scripts go into `ClaudeDevelopment/` using MERGE upsert pattern.
