# XMS BI Documentation Audit — Consolidated Findings

**Date:** 2026-03-01
**Scope:** Cross-reference of HTML docs, markdown docs, and SQL release files
**Method:** 9 parallel review agents, each focused on a specific comparison area
**Total findings:** ~210 (after deduplication of cross-agent overlaps)

---

## How to Use This Document

Each finding has a unique ID, severity, and category. Use the IDs to track corrections. Findings are grouped by theme/area. Where multiple agents found the same issue, it is listed once with a note.

**Severity key:**
- **CRITICAL** — Operationally dangerous; could cause data loss or deployment failure
- **HIGH** — Factual error that would mislead a developer
- **MEDIUM** — Stale data, omission, or ambiguity
- **LOW** — Minor cosmetic or ordering issue

---

## Table of Contents

1. [Critical / Operationally Dangerous](#1-critical--operationally-dangerous)
2. [index.html Factual Errors](#2-indexhtml-factual-errors)
3. [Data Vault Entity Discrepancies (diagram.html / reference.md / SQL)](#3-data-vault-entity-discrepancies)
4. [Integration Mapping Discrepancies (mappings.html / reference.md / SQL)](#4-integration-mapping-discrepancies)
5. [Visualisation Query Discrepancies (docs vs SQL)](#5-visualisation-query-discrepancies)
6. [Presentation Layer Discrepancies (docs vs SQL)](#6-presentation-layer-discrepancies)
7. [Architecture & Pipeline Discrepancies (docs vs SQL)](#7-architecture--pipeline-discrepancies)
8. [index.html Content Omissions vs Markdown Sources](#8-indexhtml-content-omissions-vs-markdown-sources)
9. [Stale Counts & Line Numbers](#9-stale-counts--line-numbers)
10. [MEMORY.md Corrections Needed](#10-memorymd-corrections-needed)

---

## 1. Critical / Operationally Dangerous

These findings represent code-level bugs, broken dependencies, or documentation that could cause data loss if trusted.

### CRIT-001: DeployPresentationTables DOES Drop Existing Tables
**Found by:** 5 agents independently (architecture, pipeline, pres-vis, integrations, DV ref)
**Affects:** `index.html`, `MEMORY.md`, `CLAUDE.md`
> ✅ **FIXED — Ready for QA (2026-03-02)** — `index.html` corrected. `MEMORY.md` was already correct from a prior session.

The procedure **unconditionally drops and recreates** every Live presentation table on each run. Three sources incorrectly claim it never drops tables:

- `index.html` line 769: "It will never drop existing tables"
- `MEMORY.md`: "DeployPresentationTables never drops existing tables — safe to run against live organisation"
- `CLAUDE.md`: "DeployPresentationTables never drops existing tables"

**But** `index.html` line 772 (same section!) correctly says: "drops existing table, executes DDL" — directly contradicting the line above it.

The SQL source (`6_DeployPresentationTables.sql` lines 119-125) is unambiguous:
```sql
-- Check if table already exists and drop it (optional - you may want to modify this behavior)
IF EXISTS (SELECT 1 FROM sys.tables t ...) BEGIN DROP TABLE [...]; END;
```

The markdown source (`presentation-and-visualisation.md` line 38-50) is also correct: "Always drops and re-creates, so re-runs are safe."

**Action:** Fix index.html line 769, MEMORY.md, and CLAUDE.md. The procedure IS safe to re-run (it rebuilds from DV), but it DOES drop tables.

---

### CRIT-002: sp_ProcessStagingDuplicates Called with NULL @SchemaName
**Found by:** architecture-vs-SQL agent
**Affects:** `8_Deployment_Objects_Records.sql`, `data-pipeline.md`

In `sp_DataVaultLoad`, `sp_ProcessStagingDuplicates` is called ONCE at the very start of the procedure body — before the `BEGIN TRY` block, before schema discovery, with `@SchemaName` still NULL (uninitialized). It is NOT called per-schema inside the loop as `data-pipeline.md §4.4` documents.

- SQL line 2658-2659: `EXEC core.sp_ProcessStagingDuplicates @SchemaName = @SchemaName` — placed before schema discovery
- `data-pipeline.md §4.4`: "For each int_% schema: 1. EXEC core.sp_ProcessStagingDuplicates"

**Impact:** Deduplication silently fails on every pipeline run. Already noted in MEMORY.md known bugs.

---

### CRIT-003: sp_CreateGlobalParametersTools — Broken Dependency
**Found by:** architecture-vs-SQL agent
**Affects:** `3_CoreStoredProceduresAndFunctions.sql`

`CreateIntegrationSchema` calls `sp_CreateGlobalParametersTools` (line 789-794) but this procedure is only defined in retired files (`Retired/2__GlobalParamInit.sql`, `Retired/4_GlobalParamTools`). It is missing from all active release scripts.

**Impact:** Integration schema creation may fail silently if this code path is reached.

---

### CRIT-004: sp_GenerateCDC CURRENT_FLAG Filter Never Applied by Default
**Found by:** architecture-vs-SQL agent
**Affects:** `8_Deployment_Objects_Records.sql`, `data-pipeline.md`

The `@TARGET_TABLE_FILTER_IN` parameter defaults to `' '` (single space, length 1). The code applies `WHERE CURRENT_FLAG = 1` only when `LEN >= 2`. So the CURRENT_FLAG filter is **never applied** with default parameters — CDC compares against ALL historical SAT rows, not just current ones.

- SQL lines 2043-2046: `WHEN LEN(RTRIM(LTRIM(@TARGET_TABLE_FILTER_IN))) >= 2 THEN ' WHERE CURRENT_FLAG = 1' ELSE ' '`
- `data-pipeline.md §4.5`: documents detection as running against `WHERE CURRENT_FLAG = 1` — this is wrong for default invocations

---

### CRIT-005: Trailing Comma Syntax Errors in Deployment Objects
**Already in MEMORY.md known bugs (C1)**
**Affects:** `8_Deployment_Objects_Records.sql` (~lines 1841, 1892)

ForecastResults and ModelPerformanceHistory DDL have trailing commas that will cause deployment failure. Already documented but included here for completeness.

---

## 2. index.html Factual Errors

These are incorrect facts in `index.html` that need correction. Grouped by section.

> **Section status (2026-03-02):** All 32 findings in this section (IE-001 through IE-032) have been corrected in `index.html`. Each finding is also marked individually below.

### 2.1 Wrong Column/Field Names

#### IE-001: SAT Column Names in DV Prose (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 542:** "every change is retained with `LOAD_DATE`, `END_DATE`, and `IS_CURRENT`"
**Correct names:** `LOAD_TS`, `EFFECTIVETO`, `CURRENT_FLAG` (shown correctly in the SAT DDL tab on the same page, lines 564-565)

#### IE-002: VisualisationQueries Field Name — CardType vs VisualizationType (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 828:** Lists field as `CardType`
**Correct field name:** `VisualizationType` (per SQL and all markdown sources)

#### IE-003: VisualisationQueries Field Name — QueryName Does Not Exist (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 824:** Lists field as `QueryName`
**Correct:** This field does not exist. The actual lookup field is `DataSetName`.

#### IE-004: Card Procedure Parameter — @QueryName vs @DataSet (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 841:** "Each accepts `@QueryName` and filter parameters"
**Correct parameter name:** `@DataSet NVARCHAR(100)` (per SQL and `presentation-and-visualisation.md`)

#### IE-005: Organisations Table — OrganisationID Type (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 341:** `OrganisationID UNIQUEIDENTIFIER PK`
**Correct:** `OrganisationID int IDENTITY PK`. The GUID column is `OrganisationCode`.

#### IE-006: Organisations Table — Column Name DatabaseState (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 342:** `DatabaseState NVARCHAR(50)`
**Correct:** Column is `DatabaseStatus varchar(20)`. Also missing states `MAINTENANCE` and `ARCHIVED`.

#### IE-007: SHA256Hash Return Type (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 374:** Returns `BINARY(32)`
**Correct:** Returns `VARBINARY(32)` per `architecture-overview.md`

#### IE-008: Lookup Function Return Types (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html lines 375-376:** `GetDatabaseFromOrganisationID` and `GetSchemaFromIntegrationID` return `NVARCHAR(128)`
**Correct:** Both return `nvarchar(4000)`

#### IE-009: SRC Column Nullability (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Applied to HUB, SAT, and LNK DDL examples.

**index.html lines 556, 572:** `[SRC] NVARCHAR(255)` (no NOT NULL) in HUB and LNK DDL
**Correct:** `[SRC] NVARCHAR(255) NOT NULL`

#### IE-010: SAT_LNK DDL Column Types (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html lines 581-582:** `NET_PRICE` and `NET_COST` typed as `NVARCHAR(255)`
**Correct:** `DECIMAL(38,10)` per `data-vault-reference.md` and SQL

#### IE-011: sp_SingleKPICard Spurious Prefix (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 424:** `sp_SingleKPICard`
**Correct:** `SingleKPICard` (no `sp_` prefix). All card procedures are unprefixed.

#### IE-012: Dimension Join Column (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Corrected in example SQL, prose, callout, and Key Conventions.

**index.html line 835:** `JOIN presentation.D_LOCATION d ON f.LOCATION_HUB_ID = d.HUB_ID`
**Correct join column:** `d.BOTTOM_HUB_ID` (not `d.HUB_ID`). Also at line 778: "All dimensions join to facts on HUB_ID" should say `BOTTOM_HUB_ID`.

### 2.2 Wrong Lists/Counts

#### IE-013: Trigger Names — 3 of 4 Wrong (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — All 4 rows replaced with correct names and events.

**index.html lines 360-363:**
| index.html shows | Correct name | Issue |
|---|---|---|
| `trg_Organisations_AfterInsert` | `trg_CreateOrganisationDatabase` | Wrong name |
| `trg_Organisations_AfterUpdate` | Does not exist | Invented |
| `trg_DataVaultEntities_AfterInsert` | `trg_DataVaultEntities_RetireOlderVersions` | Wrong name AND wrong event (UPDATE not INSERT) |
| Missing entirely | `trg_CreateIntegrationSchema` | Absent (fires on Integrations INSERT) |

#### IE-014: Function List — 4 Wrong, 4 Missing (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Function table replaced with correct 7 functions and accurate return types.

**index.html lines 373-382:** Lists `BuildColumnList`, `BuildSelectClause`, `FormatDateFilter`, `ParseJSON` as functions.
- `BuildColumnList` and `BuildSelectClause` are **stored procedures** (not functions)
- `FormatDateFilter` and `ParseJSON` do not exist anywhere in the source
- **Missing:** `GetParameter`, `GetParameterWithType`, `GetParameterDataType`, `GetTypedParameter`

#### IE-015: Card Type Count — 14 vs 16 (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Count updated to 16 in all 3 locations; `TreeViewCard` and `MarkdownCard` added to the card grid.

**index.html lines 286, 331, 487:** Says "14 card types" in three places
**Correct:** 16 card-type procedures deployed (orders 49-64). Missing: `TreeViewCard`, `MarkdownCard`. (The markdown source also inconsistently says 15 in narrative but lists 16 in table.)

#### IE-016: Dimension Table Names — 3 Don't Exist, 7 Missing (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Non-existent tables removed; all 7 missing tables added.

**index.html line 782:** Lists `D_EMPLOYEE`, `D_QUESTION`, `D_ANSWER` as dimensions.
**These tables do not exist** in `8_PresentationTables.sql` or anywhere in the codebase.
**Missing from list:** D_DISCOUNT, D_DISTRIBUTOR, D_MOD, D_REVCENTER, D_SERVICECHARGE, D_TAX, D_TENDER

#### IE-017: Dimension Count 12 vs 14 (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Count updated to (16), reflecting all 15 D_* tables plus DimCustomer.

**index.html line 782:** "Dimensions (12)"
**Correct:** 14 standard hierarchy dimensions exist in `8_PresentationTables.sql`. (Note: the markdown source also says "12" in prose but lists 14 in its table — internal inconsistency.)

#### IE-018: DeploymentObjects Table Schema — Wrong Column Names (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Column names corrected; `Category`, `Description`, `DropScript` added; prose reference updated to `ExecutionOrder`.

**index.html lines 527-536:** Uses `ObjectDefinition` and `DeploymentOrder`
**Correct column names:** `CreationScript` and `ExecutionOrder`. Also missing columns: `Category`, `Description`, `DropScript`.

#### IE-019: DeploymentOrder Comment Wrong (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 533:** `-- 120-135 DV procs, 200+ cards`
**Correct:** Card procedures are at orders 49-62, not 200+.

#### IE-020: Deployed Objects Count Mismatch (LOW)
> ⏳ **DEFERRED** — Low severity; requires a full recount of DeploymentObjects records against accordion groups before correcting.

**index.html line 433:** Claims 46 objects, accordion groups total only 37. Nine objects unaccounted for.

### 2.3 Wrong Descriptions

#### IE-021: NCRAloha Staging Tier Descriptions (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 668:** "Tier 2: aggregations; Tier 3: joins"
**Correct:** Tier 2: Link Staging (14 steps); Tier 3: Self-Link (1 step). It is Tier 1 that uses aggregations.

#### IE-022: Organisation Provisioning Step 3 — Wrong Table Type (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 620:** "creates the `int_ncraloha001` schema and all `DL_*` tables"
**Correct:** The trigger creates the schema and executes `STAGE_DDL` to create `stage.*` tables, not `DL_*` tables directly.

#### IE-023: TROAP Staging Description — "SQL-to-SQL" (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Both tables updated; staging shown as `—` with a brief description of the direct table-copy approach.

**index.html lines 672, 761:** Describes TROAP staging as "SQL-to-SQL"
**Correct:** TROAP has no staging (n/a). It uses a table-copy / direct SQL database read approach. The term "SQL-to-SQL" is not used in any source document.

#### IE-024: MarketMan Tiers — "Multiple" (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)**

**index.html line 669:** Shows "Multiple" for MarketMan tiers
**Correct:** Exactly 2 tiers (Tier 1: 16 steps, Tier 2: 1 step)

#### IE-025: SurveyHero DL Tables — "8+" (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Updated to 22.

**index.html line 760:** "8+" DL tables
**Correct:** 8 DDL-declared tables + 14 staging-referenced tables = 22 total. "8+" significantly understates.

#### IE-026: "dynamically generated at runtime" (LOW)
> ⏳ **DEFERRED** — Low severity; the current wording in context is ambiguous but not misleading enough to prioritise.

**index.html line 680:** States load table SQL is "dynamically generated from EntityMappings at runtime"
**Correct:** Generated once at deployment/configuration time by `UploadEntityMappings`, then read at runtime.

#### IE-027: Dual-Result Pattern — Inconsistent (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Both occurrences updated to "title, description, trend value, and supplementary metadata".

**index.html line 837:** "Result Set 2 = header metadata (title, subtitle, axis labels)"
**index.html line 874:** "Result set 2 = header metadata (title, axis labels)" — no subtitle
**Correct (per source):** "title, description, trend value, and supplementary metadata" — neither "subtitle" nor "axis labels" appear in the source.

#### IE-028: "no transformation logic lives in application code" (LOW)
> ⏳ **DEFERRED** — Low severity; requires nuanced rewording that accurately reflects the configuration-driven approach without overstating it.

**index.html line 625:** Strong claim that is contradicted by `UploadEntityMappings` (generates SQL in procedure code) and SurveyHero hardcoded VALUES mapping.

### 2.4 Internal Contradictions Within index.html

#### IE-029: T1 Description (LOW)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Standardised to "T1 = Type 1 change (overwrite, no history)" in Key Conventions.

**Line 871:** "T1 = Type 1 overwrite"
**Line 704:** "T1 = Type 1 change"

#### IE-030: sp_ProcessStagingDuplicates Described Twice (LOW)
> ⏳ **DEFERRED** — Low severity; both descriptions remain but are accurate; the second is simply more detailed.

**Line 658:** First mention — no exclusion list
**Line 675:** Second mention — adds "(excluding LOADTS_UTC and RequestID)"

#### IE-031: TROAP Staging Representation (LOW)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Both tables now consistently show `—` with a brief description.

**Line 672:** Staging shown as "—" (dash)
**Line 761:** Staging shown as "SQL-to-SQL"
These are in different tables for the same integration.

#### IE-032: Hash Key Terminology (LOW)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Key Conventions updated to use "hash value" terminology consistent with the EntityMappings description.

**Line 864:** "Mode 1 = salted" / "mode 2 = unsalted"
**Line 638:** "Hash values: 0 = pass through, 1 = SHA-256 salted, 2 = SHA-256 unsalted"
The terms "mode" vs "hash values" are used inconsistently.

---

## 3. Data Vault Entity Discrepancies

Cross-reference of `data-vault-diagram.html` JS data, `data-vault-reference.md` entity catalog, and `8_DataVaultEntities.sql`.

> ✅ **Section 3 FIXED — Ready for QA (2026-03-02)** — All findings below applied to `data-vault-diagram.html` and `data-vault-reference.md`. SQL files unchanged (source of truth).

### 3.1 Systemic: ATTR_1-ATTR_5 Missing from Diagram (~12 entities)

> ✅ **FIXED — Ready for QA (2026-03-02)** — Added ATTR_2–5 to all affected entities in diagram `HUB_ATTRS`. Updated `data-vault-reference.md` §2.2 with exceptions noted.

The diagram's `HUB_ATTRS` object omits ATTR_2 through ATTR_5 for most hierarchical dimension entities while the SQL includes them. Affected entities (all HIGH):

| Entity | DIAG shows | SQL has | Notes |
|---|---|---|---|
| CHANNEL | ATTR_1 only | ATTR_1-5 | |
| COMP | ATTR_1 only | ATTR_1-5 | Also missing MICROSERVICE columns entirely (see DV-COMP below) |
| DEAL | ATTR_1 only | ATTR_1-5 | |
| DISCOUNT | No ATTRs | ATTR_1-5 | |
| DISTRIBUTOR | No ATTRs | ATTR_1-5 | |
| INVITEM | No ATTRs | ATTR_1-5 | |
| MOD | No ATTRs | ATTR_1-5 | |
| OCCASION | No ATTRs | ATTR_1-5 | |
| SUPPLIER | No ATTRs | ATTR_1-5 | |
| SVCCHARGE | No ATTRs | ATTR_1-5 | |
| TAX | No ATTRs | ATTR_1-5 | |
| TENDER | No ATTRs | ATTR_1-5 | |

PRODUCT and LOCATION correctly show all ATTRs in the diagram.

### 3.2 Major Entity-Level Discrepancies

#### DV-CUSTORDER: Complete Attribute Divergence (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Both DIAG and REF replaced with correct 30 attrs from SQL v2 Live.

The DIAG and REF document ~30 attributes including `GROSS_SALES_INCL`, `DISCOUNT_TOTAL`, `REFUND_TOTAL`, `SURCHARGE_TOTAL`, `TIPS_TOTAL`, `DELIVERY_FEE`, `EMPLOYEE_ID`, `EMPLOYEE_NAME`, `OPEN_DATE`, `CLOSE_DATE`, `ORDER_TYPE` — **none of which exist in the SQL**.

The SQL has `*_SRC` duplicate columns (`GRAND_TOTAL_SRC`, `DISCOUNT_GROSS_SRC`, `GROSS_SALES_SRC`, `TAX_TOTAL_SRC`, `NET_SALES_SRC`, `ITEM_COUNT_SRC`, `DISCOUNT_NET_SRC`, `DISCOUNT_TAX_SRC`) and `TENDERED_SALES` — **none of which appear in the DIAG/REF**.

Either the SQL is stale (new design documented but not deployed) or the docs are aspirational.

#### DV-JOB: Misclassified as Hierarchical (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — DIAG: JOB reclassified as `nonhierarchical` in `HUB_TYPE`, hierarchy columns removed from `HUB_ATTRS`. REF: JOB moved to §2.3 with correct non-hierarchical attribute list.

SQL v3 Live JOB has: `JOB_NAME, TRONC_FLAG, JOB_CODE, PAY_CODE, MICROSERVICE_ID, MICROSERVICE_NAME, MICROSERVICE_ID_BIN` — **no PARENT_ID, LEVEL_NAME, BOTTOM_LEVEL, no ATTR columns**.

Both DIAG and REF classify JOB as a hierarchical dimension and show hierarchy columns. The physical SAT_JOB table is non-hierarchical.

#### DV-COMP: Missing MICROSERVICE Columns (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — DIAG: Removed MICROSERVICE cols from COMP `HUB_ATTRS`. REF: Added exception note to §2.2 table.

SQL v2 Live COMP has: `COMP_NAME, PARENT, LEVEL_NAME, BOTTOM_LEVEL, ATTR_1-5, IS_WASTE` — **no MICROSERVICE_ID, MICROSERVICE_NAME, or MICROSERVICE_ID_BIN**.

Both DIAG and REF show MICROSERVICE columns for COMP. The physical SAT_COMP does not have them.

#### DV-COMP: PARENT vs PARENT_ID (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — DIAG: `PARENT_ID` → `PARENT` in COMP `HUB_ATTRS` with bug note. REF: Exception noted in §2.2 table.

SQL uses attribute name `PARENT` (not `PARENT_ID`). Both DIAG and REF show `PARENT_ID`. Any query using `PARENT_ID` against SAT_COMP will fail.

#### DV-REVCENTER: Invented Attribute (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — DIAG: Removed `REVCENTER_NAME`, set `REVC_NAME` as first attr, added ATTR_1-5. REF: Exception noted in §2.2 table.

DIAG shows `REVCENTER_NAME` as first attribute. SQL has `REVC_NAME` — `REVCENTER_NAME` does not exist as a physical column.

#### DV-QUESTION: Wrong Attribute Name in Diagram (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — DIAG: `QUESTION_NAME` → `QUESTION`.

DIAG shows `QUESTION_NAME`. SQL and REF both use `QUESTION` (no `_NAME` suffix).

#### DV-EMPLOYEE: Wrong Source Type in Diagram (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — DIAG: `EMPLOYEE:'PoS'` → `EMPLOYEE:'NULL'` in `HUB_SOURCE`.

DIAG `HUB_SOURCE` assigns `EMPLOYEE:'PoS'`. SQL has `PRIMARY_SOURCE_TYPE = NULL`.

### 3.3 Diagram Header Stats

#### DV-HEADER: Live Links Count (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Header stat updated: 40 → 39.

**Diagram line 142:** Shows **40** Live Links
**Correct:** 39 (32 binary + 4 ternary + 1 quaternary + 2 self-ref)

### 3.4 Data Vault Reference.md Internal Issues

#### DV-REF-001: LOCATION_OCCASION_PRODUCT Missing from Ternary Table (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Added LOCATION_OCCASION_PRODUCT to §3.2; updated section count to "5 Live".

REF §3.2 "Ternary Links — 4 Live" lists only 4 but misses LOCATION_OCCASION_PRODUCT v2 (3-hub link with SAT_LNK). Should be 5 ternary links.

#### DV-REF-002: Unmapped Entity Sub-Counts Wrong (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Updated sub-counts in §6.3: CRM 7→9, POS 7→10, Inventory 3→4.

REF §6.3 says "CRM/Contact cluster (7 entities)" but lists 9; "POS entities (7)" but lists 10; "Inventory entities (3)" but lists 4.

#### DV-REF-003: INVREPORT Attribute Types Wrong (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Fixed in both REF §2.1 and DIAG `HUB_ATTRS`: all 6 attrs changed from NVARCHAR(255) to DECIMAL(38,10).

REF and DIAG both list `UOM_COST`, `SALES_QTY`, `ORDER_QTY`, `TRANSFER_QTY`, `COUNT_FREQUENCY`, `COUNT_RECENCY` as `NVARCHAR(255)`. SQL defines all 6 as `DECIMAL(38,10)`.

#### DV-REF-004: QUESTION Implied to Have ATTRs (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Added exception note to §2.2 standard pattern header and to QUESTION row in table.

REF §2.2 lists QUESTION under "Standard Pattern" hierarchy (implying ATTR_1-ATTR_5), but SQL has no ATTR columns for QUESTION.

---

## 4. Integration Mapping Discrepancies

Cross-reference of `integration-mappings.html`, `integrations-reference.md`, and actual SQL files.

> ✅ **Section 4 FIXED — Ready for QA (2026-03-02)** — All findings below applied to `integration-mappings.html` and `integrations-reference.md`. SQL files unchanged (source of truth).

### 4.1 Staging Table Names — Systemic (21 tables wrong in docs)

Both HTML and markdown use descriptive/expanded names that don't match the actual `staging_table` values in the SQL.

#### NCRAloha Tier 1 — 6 wrong names (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Corrected in both `integration-mappings.html` (tier visualization) and `integrations-reference.md` (staging steps table and DISCOUNT entity mapping source).

| Step | SQL (actual) | Docs show |
|---|---|---|
| Discount | `NCR_DISC` | `NCR_DISCOUNT` |
| Modifications | `NCR_MODS` | `NCR_MOD` |
| Occasion | `NCR_OCCASSION` | `NCR_OCCASION` |
| Product | `NCR_PROD` | `NCR_PRODUCT` |
| Revenue Center | `NCR_REVC` | `NCR_REVCENTER` |
| Service Charge | `NCR_SVC` | `NCR_SVC_CHARGE` |

#### NCRAloha Tier 2/3 — 7 wrong names (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Corrected in both `integration-mappings.html` (tier visualization) and `integrations-reference.md` (staging steps table and relevant entity mapping source columns: LINEITEM_LINEITEM, LINEITEM_TENDER, LOCATION_OCCASION_PRODUCT).

| Step | SQL (actual) | Docs show |
|---|---|---|
| Deals & LI to LI | `NCR_DEAL_LI_LI` | `DEAL_LI_TO_LI` |
| Discount & LI to LI | `NCR_DISC_LI_LI` | `DISC_LI_TO_LI` |
| Product to Loc & Occasion | `LOC_OCC_PROD_LNK` | `PROD_LOC_OCC` |
| Svc Charge & LI to LI | `NCR_SVC_LI_LI` | `SVC_LI_TO_LI` |
| Tax & LI to LI | `NCR_TAX_LI_LI` | `TAX_LI_TO_LI` |
| Tender to Line Item | `TEND_LI_LINK` | `TENDER_LI_LNK` |
| Line Item to Line Item | `LI_LI_LINK` | `LI_TO_LI` |

#### MarketMan — 8 wrong names (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Corrected in both `integration-mappings.html` (tier visualization) and `integrations-reference.md` (staging steps table and SUPPLIER entity mapping source). Step names "production" and "vendors" also capitalised to match convention.

| Step | SQL (actual) | Docs show |
|---|---|---|
| Inventory Items | `MMAN_INVITEMS` | `MMAN_INVENTORY_ITEMS` |
| Invoice Items | `MMAN_PRE_INVOICE` | `MMAN_INVOICE_ITEMS` |
| Order Items | `MMAN_PRE_ORDEREVENT` | `MMAN_ORDER_ITEMS` |
| Production | `MMAN_PRE_PRODUCTION` | `MMAN_PRODUCTION` |
| Stock Count | `MMAN_PRE_STOCK_COUNT` | `MMAN_STOCKCOUNT` |
| Transfers | `MMAN_TRANSFERS` | `MMAN_TRANSFER` |
| Vendors | `MMAN_VENDORS` | `MMAN_VENDOR` |
| Waste Events | `MMAN_WASTE_EVENTS` | `MMAN_WASTE` |

### 4.2 Entity Classification Errors

#### INT-LINEITEM: Hub Misclassified as Link in integrations-reference.md (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — LINEITEM moved from Links to Hubs in `integrations-reference.md`. Hub key updated to `SRC_KEY`. Counts remain 9 Hub / 13 Link (net unchanged because LOP was simultaneously moved the other way; see INT-LOC_OCC_PROD).

MarketMan LINEITEM is listed under "Links (13)" in the markdown. It has no underscore = Hub entity. Description even says "Line item hub". Correct breakdown: 10 hubs, 12 links (not 9/13).

#### INT-LOC_OCC_PROD: "Ternary Hub" Label Wrong (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — LOCATION_OCCASION_PRODUCT moved from Hubs to Links in `integrations-reference.md`; description changed from "Type 2 SCD ternary hub" to "Ternary link: product at location for occasion (Type 2 SCD; see Notable Patterns)". HTML was already correct.

MarketMan LOCATION_OCCASION_PRODUCT is called "ternary hub" in markdown. It is a Link entity (underscores in name). HTML and SQL are correct.

#### INT-EMPLOYEE: Wrong Source Table in Markdown (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Source table changed from `NCR_LINE_ITEM_DETAIL` to `NCR_EMP_TIME`; hub key column changed from `EMPLOYEE_SRC_KEY` to `EMP_SRC_KEY` in `integrations-reference.md`.

NCRAloha EMPLOYEE source listed as `NCR_LINE_ITEM_DETAIL` in `integrations-reference.md`. Correct: `NCR_EMP_TIME` (per SQL and HTML).

### 4.3 Other Integration Issues

#### INT-UNMAPPED: Internal Contradiction in mappings.html (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Overview stat card updated from 24 to 30 in `integration-mappings.html` to match the coverage tab's authoritative list.

Overview card says "24 Unmapped Entities" (line 182) but coverage tab says "30 live entities" unmapped (line 2101).

#### INT-NAMING: MarketMan_Final.sql Breaks Convention (MEDIUM)
> ✅ **FIXED — Ready for QA (2026-03-02)** — Note added to the `MarketMan_Final.sql` row in the Files table in `integrations-reference.md` explaining the missing `001` version suffix.

All other integrations use `{Name}001_Final.sql`. MarketMan uses `MarketMan_Final.sql` (no version suffix). Undocumented.

#### INT-MDM: SAT_QUESTION_MDM.sql Undocumented (HIGH)
> ⏳ **NO ACTION REQUIRED** — `SAT_QUESTION_MDM.sql` was already documented in `integrations-reference.md`: listed in the SurveyHero Files table and covered in a dedicated "MDM Pattern" subsection. Audit finding was a false positive.

`SurveyHero/SAT_QUESTION_MDM.sql` exists in the repository but is not referenced in any documentation.

#### INT-VENDORS: Missing from Markdown Staging Table (LOW)
> ⏳ **NO ACTION REQUIRED** — `vendors` / `MMAN_VENDOR` staging step was already present in `integrations-reference.md` staging table. Audit finding was a false positive. (The table name itself was corrected to `MMAN_VENDORS` as part of §4.1.)

MarketMan `vendors` staging step is in SQL and HTML but absent from `integrations-reference.md`.

---

## 5. Visualisation Query Discrepancies

Cross-reference of `presentation-and-visualisation.md` vs `8_VisualisationQueries.sql`.

### 5.1 Card Type Counts — 6 of 16 Wrong (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — All six counts corrected in the §4.5 summary table in `presentation-and-visualisation.md`.

The §4.5 summary table is unreliable:

| Card Type | Docs Count | SQL Count | Delta |
|---|---|---|---|
| FilterList | 18 | **21** | +3 |
| SingleKPICard | 13 | **17** | +4 |
| BarChartCard | 7 | **9** | +2 |
| StackedBarChartCard | 7 | **9** | +2 |
| CustomDataGrid | 8 | **10** | +2 |
| CombinedChartCard | 8 | **7** | -1 |

Docs subtotal: 97. SQL actual: 109. The docs total claims 109 but the per-type breakdown only adds to 97.

Note: The §4.6 catalogue lists 21 FilterList datasets correctly, contradicting the §4.5 count of 18 in the same document.

### 5.2 Survey Card Types Scrambled (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — All three rows corrected in the §4.6 Survey section of `presentation-and-visualisation.md` to match SQL: SurveyAgeByGender → CustomDataGrid + CustomPinnedDataGrid; SurveyAgeByRespondentTotal → BarChartCard; SurveyAgeGender → HeatmapCard.

Three `SurveyAge*` datasets have their card types assigned to the wrong dataset:

| Dataset | Docs Say | SQL Has |
|---|---|---|
| SurveyAgeByGender | BarChartCard | CustomDataGrid + CustomPinnedDataGrid |
| SurveyAgeByRespondentTotal | HeatmapCard | BarChartCard |
| SurveyAgeGender | PieChartCard | HeatmapCard |

### 5.3 Missing Query Records

#### VIS-DISCOUNTPERC: StatCard Variant Undocumented (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — `DiscountPerc` entry in §4.6 updated to `SingleKPICard` + `StatCard` in `presentation-and-visualisation.md`.

`DiscountPerc|StatCard` exists in SQL but docs only list `DiscountPerc|SingleKPICard`.

#### VIS-NETSALES: CombinedChartCard Phantom (MEDIUM)
> ⏳ **NO ACTION REQUIRED** — SQL verification confirms `NetSales|CombinedChartCard` **does** exist in `8_VisualisationQueries.sql`. The docs are correct. Audit finding was a false positive.

Docs list `NetSales|CombinedChartCard` but this record does not exist in SQL. NetSales has BarChartCard, MultiLineChartCard, SingleKPICard, StackedBarChartCard, and StatCard only.

### 5.4 Card Procedure Count — Internal Inconsistency (HIGH)
> ✅ **FIXED — Ready for QA (2026-03-02)** — All three narrative occurrences of "15 card-type stored procedures" corrected to "16" in `presentation-and-visualisation.md` (document scope line, §5 prose, §8 file reference).

The markdown says "15 card-type stored procedures" in three places (document scope, §5 heading, §8 file reference) but §5.3 table correctly lists 16 procedures. The SQL has 16 (orders 49-64). The narrative text is wrong; the table is right.

---

## 6. Presentation Layer Discrepancies

### 6.1 D_REVCENTER Schema (HIGH)

#### PRES-REVC-001: Generic Column Names
SQL DDL uses `BOTTOM_NAME`/`BOTTOM_ID` (generic). Docs claim `BOTTOM_REVCENTER_NAME`/`BOTTOM_REVCENTER_ID`. Any query using the documented names will fail.

> ✅ **FIXED** — `presentation-and-visualisation.md` D_REVCENTER row updated to `BOTTOM_NAME`, `BOTTOM_ID`.

#### PRES-REVC-002: Wrong Version
SQL has version = 1. Docs say v3. All other dimensions were promoted to v3; D_REVCENTER was missed.

> ✅ **FIXED** — `presentation-and-visualisation.md` D_REVCENTER version corrected to `v1`.

### 6.2 PresentationControl Column Structure (HIGH)
Docs §3.1 lists 13 columns but SQL INSERTs have 17 columns. Missing: `description`, `created_by`, `created_at`, `updated_at`.

> ✅ **FIXED** — `presentation-and-visualisation.md` §3.1 column table updated to include all 17 columns (added `description`, `created_by`, `created_at`, `updated_at` between `timeout_minutes` and `time_series_entity`).

### 6.3 Dimension Count Internal Inconsistency (MEDIUM)
Docs §2.1 says "12 dimensions follow this template exactly" then lists 14 in the table immediately below.

> ✅ **FIXED** — `presentation-and-visualisation.md` §2.1 prose updated to "14 dimensions follow this template exactly".

### 6.4 F_LINEITEM_15MIN Index Count (MEDIUM)
Docs say 12 non-clustered indexes. SQL has 10.

> ✅ **FIXED** — `presentation-and-visualisation.md` F_LINEITEM_15MIN description updated to "10 non-clustered indexes".

### 6.5 Suggestion Engine Tables — Missing Columns (MEDIUM)
All three suggestion tables (`DescriptionRules`, `DescriptionTemplates`, `MetricDefinitions`) are missing audit columns (`CreatedDate`, `UpdatedDate`, `Notes`, and for Templates also `CreatedBy`) from docs.

> ✅ **FIXED** — `presentation-and-visualisation.md` §6.2 DescriptionRules, §6.3 DescriptionTemplates, and §6.4 MetricDefinitions tables updated with missing audit columns.

---

## 7. Architecture & Pipeline Discrepancies

### 7.1 Docs vs SQL Code Behavior

#### AP-001: sp_Staging Sort Order (HIGH)
`architecture-overview.md §7.2` says `sp_Staging` uses a `priority` column. No such column exists in StagingControl. Actual sort: `ORDER BY tier, step_name`.

> ✅ **FIXED** — `architecture-overview.md` §7.2 corrected: "ordered by `tier, step_name`" with a note that StagingControl has no `priority` column.

#### AP-002: sp_DataVaultLoad Post-Loop Steps Missing (HIGH)
Neither doc mentions that after processing all schemas, `sp_DataVaultLoad` calls: `sp_PopulateCalendar`, `sp_ProcessPresentation`, `sp_InitEntityDeltaParameters`.

> ✅ **FIXED** — Post-loop calls documented in `architecture-overview.md` §7.1 and in `data-pipeline.md` §4.4 (with exact signatures).

#### AP-003: Trigger Implementation Mismatch (HIGH)
`data-pipeline.md §2.3` says the trigger uses the metasql pattern. The authoritative trigger in `2_CoreTableCreateScripts.sql` calls `CreateDatabaseSchemas` as a direct procedure call instead.

> ✅ **FIXED** — `data-pipeline.md` §2.3 step 2 corrected: schema creation uses a direct `EXEC [core].[CreateDatabaseSchemas]` call; the metasql pattern applies to subsequent DDL execution in step 4.

#### AP-004: sp_GenerateCDC — MICROSERVICE Exclusion Undocumented (MEDIUM)
The code excludes `[MICROSERVICE%` from CDC (via broken `!=` comparison). Not documented anywhere.

> ✅ **FIXED** — MICROSERVICE exclusion behaviour documented in `architecture-overview.md` §7.3 and `data-pipeline.md` §4.5, including the known bug that `%` is treated as a literal (so MICROSERVICE_ID/NAME are not actually excluded).

#### AP-005: AddIntegration Schema Derivation (MEDIUM)
Docs say "derives schema name as `int_` + lower(name)". Actual code also replaces spaces and hyphens with underscores.

> ✅ **FIXED** — `architecture-overview.md` updated in both the `Integrations` table SchemaName description and the `AddIntegration` procedure entry.

#### AP-006: Self-Referencing LNK AGG Naming (LOW)
Self-referencing links generate `PARENT_AGG`/`CHILD_AGG`, not entity-name-based AGG columns. Not documented.

> ✅ **FIXED** — Added note to `architecture-overview.md` technical notes section explaining PARENT_AGG/CHILD_AGG for self-referencing links vs. entity-name-based AGG for binary links.

### 7.2 Deployment Object Catalogue Gaps

#### AP-007: LOCATION Table (order 108) Missing (MEDIUM)
Not in the architecture-overview deployment catalogue.

> ✅ **FIXED** — LOCATION (order 108) added to Core Tables catalogue in `architecture-overview.md`.

#### AP-008: CTL/LOG Tables (orders 100-103) Missing (MEDIUM)
`CTL_DV_PROCESS`, `CTL_STG_PROCESS`, `LOG_DV`, `LOG_STG` — not in the catalogue.

> ✅ **FIXED** — CTL_DV_PROCESS (100), CTL_STG_PROCESS (101), LOG_DV (102), LOG_STG (103) added to Core Tables catalogue in `architecture-overview.md`. Section header updated to "execution order 10–108".

#### AP-009: sp_ExecuteQuery (order 130) Missing (MEDIUM)
Omitted from the Data Vault Procedures catalogue.

> ✅ **FIXED** — sp_ExecuteQuery (order 130) added to Data Vault Procedures catalogue in `architecture-overview.md`.

#### AP-010: sp_UpdateEntityDeltaParameters (order 126) Missing (MEDIUM)
Omitted from the catalogue.

> ✅ **FIXED** — sp_UpdateEntityDeltaParameters (order 126) added to Data Vault Procedures catalogue in `architecture-overview.md`. Also added to the file reference list in `data-pipeline.md`.

#### AP-011: 4_DeploymentTools.sql Stale Examples (MEDIUM)
Usage examples at end of file reference retired `sp_CreateGlobalParametersTools` instead of `sp_DeployObjects`.

> ⏳ **NO ACTION REQUIRED** — This is a stale reference within the SQL source file itself. SQL files are the source of truth and are not modified. A note has been added to `architecture-overview.md` technical notes flagging this as a known stale reference.

### 7.3 Missing Documentation Sections

#### AP-012: DeployPresentationTables — @LogResults Parameter (MEDIUM)
Fourth parameter `@LogResults BIT = 1` exists in SQL but not in docs.

> ✅ **FIXED** — `architecture-overview.md` `DeployPresentationTables` signature updated to include `@LogResults`.

#### AP-013: DataVaultEntities — CREATED_AT/UPDATED_AT Columns (LOW)
Table description omits these two columns.

> ✅ **FIXED** — `architecture-overview.md` DataVaultEntities table updated to include `CREATED_AT` and `UPDATED_AT`.

#### AP-014: GlobalParameters — Audit Columns (LOW)
Table description omits `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`.

> ✅ **FIXED** — `architecture-overview.md` GlobalParameters table updated to include `Description`, `CreatedBy`, `CreatedDate`, `ModifiedBy`, `ModifiedDate`.

---

## 8. index.html Content Omissions vs Markdown Sources

These are sections present in the markdown docs but absent from index.html. Whether these should be added depends on the intended scope of index.html. Listed for completeness.

### 8.1 From data-vault-reference.md (all MEDIUM-HIGH)

| Markdown Section | Status in index.html |
|---|---|
| §2 Entity Catalog (84 entities with attributes) | Entirely absent |
| §3 Link Entity List (39 live links with hub endpoints) | Entirely absent |
| §4 Link Satellite Attributes (5 SAT_LNK tables) | Names only, no column detail |
| §5 ER Diagrams (4 Mermaid diagrams) | Links to external diagram.html only |
| §6 Integration Coverage Matrix | Entirely absent |
| §7 DV Infrastructure & Generation Logic | Partially covered |
| §8 Issues, Bugs & Inconsistencies (13 items) | Entirely absent |
| §9 Recommendations (15 items) | Entirely absent |
| Appendices A-C (version history, source distribution, patterns) | Entirely absent |

### 8.2 From data-pipeline.md (all MEDIUM)

| Markdown Section | Status in index.html |
|---|---|
| StagingControl schema (9 of 14 columns missing) | Truncated |
| EntityMappings schema (8 of 13 columns missing) | Truncated |
| GlobalParameters schema (8 of 11 columns missing) | Truncated |
| StagingControl indexes | Absent |
| APIEndpointDetail structure / TROAP config | Absent |
| Trigger §2.3 detailed logic | One sentence only |
| sp_Staging signature and execution detail | Name only |
| sp_DataVaultLoad signature (3 parameters) | Not shown |
| sp_GenerateCDC signature (6 parameters) | Not shown |
| NULL type2_columns default behavior | Absent |
| SAT_LNK switch for link entities | Absent |
| Steps 7-8 gap in sp_ProcessHubSat | Unexplained |
| EFFECTIVETO = DATEADD(DAY, -1, LOAD_TS) formula | Absent |
| §5 Per-integration pipeline detail | Absent (by design) |
| §6 Complete Data Flow Summary with procedure annotations | Simplified only |
| §7 Key File Reference with source line numbers | Absent |

### 8.3 From presentation-and-visualisation.md (all MEDIUM-HIGH)

| Markdown Section | Status in index.html |
|---|---|
| PresentationControl 22 build steps (§3) | Entirely absent (no nav link) |
| Complete dataset catalogue — 89 datasets (§4.6) | Approximate counts only |
| Per-card-type query counts (§4.5) | Absent |
| Card procedure complete list with execution orders | 14 of 16 shown (no TreeView/Markdown) |
| BuildDynamicWhereClause signature and logic (§5.4) | Name only |
| Supporting infrastructure objects (§5.5) — 13 objects | 3 of 13 listed |
| JSON schema details (ParameterMappings, FilterDefinitions, OutputDefinitions) | One-line mention |
| SQL query patterns — sentinel joins, radar template, etc. (§4.8) | Absent |
| Fact table column schemas | Names only |
| DV-to-presentation entity mapping table (§3.4) | Absent |
| Suggestion engine table column schemas | Absent |

### 8.4 From architecture-overview.md (all MEDIUM-HIGH)

| Markdown Section | Status in index.html |
|---|---|
| Full column schemas for 5 of 8 core tables | Absent |
| §9 Forecasting Infrastructure (schemas, model_types, confidence intervals) | One-line mentions only |
| §11 Dynamic SQL Patterns (3 patterns with examples) | Single bullet point |
| §12 Deployment Script Execution Order (integration package sequence) | Absent |
| §13 Integration Package Structure (APIEndpointDetail JSON) | Absent |
| §14 Known Quirks and Notes (5 operational warnings) | Absent |
| UploadEntityMappings pipeline detail (hash key logic, MERGE pattern) | Absent |
| Entity lifecycle — trigger-enforced single-active-version rule | Absent |
| Hash key computation HASHBYTES formulas | Absent |

---

## 9. Stale Counts & Line Numbers

These are point-in-time figures in documentation that no longer match the actual files.

| Location | Documented | Actual | Finding |
|---|---|---|---|
| `presentation-and-visualisation.md` §8 | `8_Deployment_Objects_Records.sql` ~1,800 lines | **10,529 lines** | 6x larger |
| `presentation-and-visualisation.md` §4 | `8_VisualisationQueries.sql` 21,520 lines | **36,273 lines** | 1.7x larger |
| `presentation-and-visualisation.md` §3 | `8_PresentationControl.sql` 5,206 lines | **9,213 lines** | 1.8x larger |
| `presentation-and-visualisation.md` §2 | `8_PresentationTables.sql` 1,625 lines | **2,457 lines** | 1.5x larger |
| `index.html` line 906 | `8_Deployment_Objects_Records.sql` 3,797 lines | **10,529 lines** | 2.8x larger |
| `index.html` lines 327-331 | Point-in-time counts (148 records, 84 entities, 22 steps, 24 tables) | May change | Per user preferences, avoid in index.html |
| `CLAUDE.md` file map | Multiple line counts | Various | Several are stale |

---

## 10. MEMORY.md Corrections Needed

### MEM-001: DeployPresentationTables Claim (CRITICAL)
**Current:** "DeployPresentationTables never drops existing tables — safe to run against live organisation"
**Correct:** The procedure always drops and recreates Live presentation tables. It IS safe to re-run (data rebuilds from DV) but it DOES drop tables.

### MEM-002: Also in CLAUDE.md
The same incorrect claim appears in `CLAUDE.md` and should be corrected there too.

---

## Summary Statistics

| Category | HIGH | MEDIUM | LOW | Total |
|---|---|---|---|---|
| Critical / Operational | 5 | — | — | 5 |
| index.html Factual Errors | 18 | 8 | 6 | 32 |
| DV Entity Discrepancies | 15 | 5 | 3 | 23 |
| Integration Mapping Discrepancies | 5 | 5 | 2 | 12 |
| Visualisation Query Discrepancies | 7 | 3 | — | 10 |
| Presentation Layer Discrepancies | 3 | 4 | — | 7 |
| Architecture & Pipeline Discrepancies | 4 | 8 | 2 | 14 |
| index.html Omissions | — | ~50 | — | ~50 |
| Stale Counts | — | 7 | — | 7 |
| MEMORY.md Corrections | 1 | 1 | — | 2 |
| **Total** | **~58** | **~91** | **~13** | **~162** |

Note: The omissions in §8 are listed as individual items but represent expected behavior — index.html is a summary view, not a complete mirror of all markdown docs. Whether to add missing content is a design decision, not a bug.
