# Simphony BI API — Dimension Endpoints Evaluation

**Date:** 2026-03-09
**Purpose:** Assess all Oracle Simphony BI API dimension endpoints for XMS BI integration, mapping to existing Data Vault entities and identifying gaps.

---

## 1. Summary Table

| # | Endpoint | Verdict | Proposed DL Table | Target DV Entity | Notes |
|---|---|---|---|---|---|
| 1 | getLocationDimensions | **Required** | `DL_LOCATIONS` | LOCATION | Core dimension; direct map to existing hub |
| 2 | getMenuItemDimensions | **Required** | `DL_MENUITEMS` | PRODUCT | Rich hierarchy; maps to existing PRODUCT hub |
| 3 | getEmployeeDimensions | **Required** | `DL_EMPLOYEES` | EMPLOYEE | Direct map; class fields are bonus data |
| 4 | getDiscountDimensions | **Required** | `DL_DISCOUNTS` | DISCOUNT | Direct map to existing hub |
| 5 | getOrderTypeDimensions | **Required** | `DL_ORDERTYPES` | OCCASION | Maps to OCCASION hub (service period / order type) |
| 6 | getOrderChannelDimensions | **Required** | `DL_ORDERCHANNELS` | CHANNEL | Direct map to existing hub |
| 7 | getRevenueCenterDimensions | **Required** | `DL_REVENUECENTERS` | REVCENTER | Direct map; has address fields as bonus |
| 8 | getTenderMediaDimensions | **Required** | `DL_TENDERMEDIA` | TENDER | First real mapping for the unmapped TENDER hub |
| 9 | getServiceChargeDimensions | **Required** | `DL_SERVICECHARGES` | SVCCHARGE | Direct map to existing hub |
| 10 | getTaxDimensions | **Required** | `DL_TAXES` | TAX | Direct map; includes rate + effective dates |
| 11 | getCashierDimensions | **Optional** | `DL_CASHIERS` | *(none — see below)* | May duplicate EMPLOYEE; evaluate after transactional data review |
| 12 | getMenuItemPrices | **Optional** | `DL_MENUITEMPRICES` | LOCATION_OCCASION_PRODUCT (SAT_LNK) | Pricing dimension — feeds link satellite, not a hub |
| 13 | getJobCodeDimensions | **Required** | `DL_JOBCODES` | JOB | Direct map to existing hub |
| 14 | getReasonCodeDimensions | **Optional** | `DL_REASONCODES` | *(new: REASONCODE)* | Useful for void/comp analysis; requires new hub entity |
| 15 | getLatestBusDt | **Skip** | — | — | Utility endpoint; not a dimension |
| 16 | getCashManagementItemDimensions | **Skip** | — | — | Cash management is out of scope for BI analytics |
| 17 | getPaymentAccountDimensions / Holders | **Skip** | — | — | Payment account/holder detail not needed for POS BI |

**Totals:** 10 Required, 3 Optional, 3 Skip (across 17 logical endpoints).

---

## 2. Detailed Endpoint Assessments

### 2.1 getLocationDimensions — REQUIRED

**Proposed DL Table:** `DL_LOCATIONS`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `locRef` | `locRef` | LOCATION | *Hub key* (`LOCATION_SRC_KEY`) | Simphony's location reference — natural business key |
| `name` | `name` | LOCATION | `LOCATION_NAME` (via hierarchy) | Top-level location name |
| `openDt` | `openDt` | LOCATION | *(new attr or ATTR_1)* | Location opening date — no current equivalent |
| `active` | `active` | LOCATION | `BOTTOM_LEVEL` or `ATTR_*` | Boolean; maps to IS_ACTIVE concept in presentation layer |
| `srcName` | `srcName` | — | — | Source system identifier; useful for SRC column in DV |
| `srcVer` | `srcVer` | — | — | Source version; metadata only |
| `tz` | `tz` | LOCATION | *(ATTR)* | Timezone; no current DV attribute but used in presentation |
| `curr` | `curr` | LOCATION | *(ATTR)* | Currency code |
| `addrLn1` | `addrLn1` | ADDRESS | `ADDRESS` | Can feed ADDRESS hub via ADDRESS_LOCATION link |
| `addrLn2` | `addrLn2` | ADDRESS | `ADDRESS` | Concatenate with addrLn1 |
| `addrLn3` | `addrLn3` | ADDRESS | `ADDRESS` | Concatenate with addrLn1+2 |
| `postalCode` | `postalCode` | ADDRESS | `POSTCODE` | |
| `phone` | `phone` | — | — | Not currently modelled in DV |
| `phoneCountryCode` | `phoneCountryCode` | — | — | Not currently modelled |
| `countryCode` | `countryCode` | ADDRESS | `COUNTRY` | ISO country code |
| `countryName` | `countryName` | ADDRESS | `COUNTRY` | Full country name (prefer this over code) |
| `regionCode` | `regionCode` | ADDRESS | `REGION` | |
| `regionName` | `regionName` | ADDRESS | `REGION` | |
| `workstations[].wsNum` | `workstations_wsNum` | — | — | Workstation-level detail; not needed for BI |
| `workstations[].wsName` | `workstations_wsName` | — | — | Workstation-level detail; not needed for BI |

**DL Table design note:** The `workstations[]` nested array should be **flattened out as a separate DL table** (`DL_LOCATIONS_WORKSTATIONS`) only if workstation-level analytics are needed. For the initial integration, skip workstations and land only the location-level row.

**Staging approach:** Single Tier 1 step producing `stage.SIM_LOCATION` with the location hub key and all dimension attributes. Address fields feed a second staging table `stage.SIM_ADDRESS` for the ADDRESS hub + ADDRESS_LOCATION link.

**LOCATION hub hierarchy mapping:**

The LOCATION entity uses the standard hierarchy pattern (`LOCATION_NAME`, `PARENT_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL`, `ATTR_1`-`ATTR_5`, `MICROSERVICE_ID/NAME/ID_BIN`). Simphony locations are flat (no parent-child hierarchy in the API response), so:

- `LOCATION_NAME` = `name`
- `PARENT_ID` = NULL (flat)
- `LEVEL_NAME` = `'LOCATION'` (single level)
- `BOTTOM_LEVEL` = `1`
- `MICROSERVICE_ID` = `locRef` (Simphony's unique location reference)
- `MICROSERVICE_NAME` = `name`
- `LOCATION_ID` = `locRef`
- `ATTR_1` through `ATTR_5` = timezone, currency, active flag, openDt, srcName (in that order)

---

### 2.2 getMenuItemDimensions — REQUIRED

**Proposed DL Table:** `DL_MENUITEMS`

This is the richest dimension endpoint. Simphony provides a **four-level product hierarchy**: Category Group > Family Group > Major Group > Menu Item. Each level has both local (`num`/`name`) and master (`mstrNum`/`mstrName`) identifiers.

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | PRODUCT | *Hub key* (`PRODUCT_SRC_KEY`) | Local menu item number — unique per location |
| `name` | `name` | PRODUCT | `PRODUCT_NAME` (via hierarchy) | Local menu item name |
| `name2` | `name2` | PRODUCT | *(ATTR)* | Alternate name / second language |
| `mstrNum` | `mstrNum` | PRODUCT | `MICROSERVICE_ID` | Enterprise-level master number |
| `mstrName` | `mstrName` | PRODUCT | `MICROSERVICE_NAME` | Enterprise-level master name |
| `name2MstrNum` | `name2MstrNum` | — | — | Master alt name number; land but deprioritise |
| `name2MstrName` | `name2MstrName` | — | — | Master alt name; land but deprioritise |
| `majGrpNum` | `majGrpNum` | PRODUCT | `PARENT_ID` (Level 2) | Major group local number |
| `majGrpName` | `majGrpName` | PRODUCT | hierarchy `PRODUCT_NAME` at L2 | |
| `majGrpMstrNum` | `majGrpMstrNum` | PRODUCT | hierarchy `MICROSERVICE_ID` at L2 | |
| `majGrpMstrName` | `majGrpMstrName` | PRODUCT | hierarchy `MICROSERVICE_NAME` at L2 | |
| `famGrpNum` | `famGrpNum` | PRODUCT | `PARENT_ID` (Level 3) | Family group local number |
| `famGrpName` | `famGrpName` | PRODUCT | hierarchy `PRODUCT_NAME` at L3 | |
| `famGrpMstrNum` | `famGrpMstrNum` | PRODUCT | hierarchy `MICROSERVICE_ID` at L3 | |
| `famGrpMstrName` | `famGrpMstrName` | PRODUCT | hierarchy `MICROSERVICE_NAME` at L3 | |
| `category` | `category` | PRODUCT | hierarchy level (L4 or ATTR) | Top-level category |
| `doNotIncludeInSales` | `doNotIncludeInSales` | PRODUCT | *(ATTR)* | Exclusion flag — important for sales reporting |
| `revFlag` | `revFlag` | PRODUCT | *(ATTR)* | Revenue flag |
| `catGrpName1`-`4` | `catGrpName1`-`4` | PRODUCT | *(ATTR)* | Custom category group names |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | PRODUCT | *(ATTR)* | Custom category hierarchy names |
| `mgCatGrpName1`-`4` | `mgCatGrpName1`-`4` | — | — | Major group custom categories; land for reference |
| `fgCatGrpName1`-`4` | `fgCatGrpName1`-`4` | — | — | Family group custom categories; land for reference |
| `extRef1`, `extRef2` | `extRef1`, `extRef2` | — | — | External references (e.g., PLU, third-party IDs) |

**PRODUCT hub hierarchy mapping:**

Simphony's four-level hierarchy maps naturally to the XMS BI three-tier dimension pattern (BOTTOM / MIDDLE_1 / TOP). The staging step must produce **multiple rows per menu item** to populate the hierarchy:

| Simphony Level | DV LEVEL_NAME | PRODUCT_NAME Source | PARENT_ID Source | BOTTOM_LEVEL |
|---|---|---|---|---|
| Menu Item (`num`/`name`) | `BOTTOM` | `name` | `majGrpNum` (or `mstrNum` composite) | `1` |
| Major Group (`majGrpNum`/`majGrpName`) | `MIDDLE_1` | `majGrpName` | `famGrpNum` (or composite) | `0` |
| Family Group (`famGrpNum`/`famGrpName`) | `TOP` | `famGrpName` | NULL | `0` |

**`category` field:** This is a fourth level that sits above family group. Options:
- **(a)** Extend the hierarchy to 4 tiers (requires presentation layer changes — not recommended initially)
- **(b)** Store `category` as an `ATTR_*` column on each row (simpler; allows filtering without hierarchy changes)
- **(c)** Use `category` as the TOP level and combine family+major into MIDDLE_1

**Recommendation:** Option (b) — store `category` as `ATTR_1` on all hierarchy rows. This preserves the standard 3-tier pattern and still enables category-based filtering and grouping in presentation queries.

**Master vs local number pattern:** Use `mstrNum` as the `PRODUCT_SRC_KEY` (hub key) to ensure cross-location consistency. The local `num` becomes a satellite attribute. This is critical — if we key on local `num`, the same menu item at two locations would create two separate hub records. See Section 4 for the full master/local recommendation.

---

### 2.3 getEmployeeDimensions — REQUIRED

**Proposed DL Table:** `DL_EMPLOYEES`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | EMPLOYEE | *(local identifier)* | Location-specific employee number |
| `uuid` | `uuid` | EMPLOYEE | *Hub key* (`EMP_SRC_KEY`) | Enterprise-unique identifier — use as hub key |
| `employeeId` | `employeeId` | — | — | Alternative ID; land for cross-reference |
| `fName` | `fName` | EMPLOYEE | `FIRST_NAME` | |
| `lName` | `lName` | EMPLOYEE | `SURNAME` | |
| `payrollId` | `payrollId` | EMPLOYEE | *(satellite attr)* | Simphony payroll ID |
| `externalPayrollID` | `externalPayrollID` | EMPLOYEE | *(satellite attr)* | External system payroll ID |
| `homeLocRef` | `homeLocRef` | LOCATION | *(link)* | Feeds EMPLOYEE_LOCATION link (if needed) |
| `className` | `className` | EMPLOYEE | `POST_DESC` | Employee class/type |
| `classNum` | `classNum` | — | — | Local class number |
| `classMstrName` | `classMstrName` | EMPLOYEE | `POST_DESC` (master) | Enterprise class name — prefer over local |
| `classMstrNum` | `classMstrNum` | — | — | Enterprise class number |

**Key decision:** Use `uuid` as `EMP_SRC_KEY`, not `num`. The `uuid` is enterprise-unique; `num` is location-specific and would create duplicate employees across locations.

**EMPLOYEE entity is non-hierarchical** in XMS BI, so mapping is straightforward: one staging row per employee, attributes map directly to SAT_EMPLOYEE columns.

---

### 2.4 getDiscountDimensions — REQUIRED

**Proposed DL Table:** `DL_DISCOUNTS`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | DISCOUNT | *(local number)* | Location-specific |
| `name` | `name` | DISCOUNT | `DISCOUNT_NAME` (via hierarchy) | |
| `posPercent` | `posPercent` | DISCOUNT | `VALUE` | Discount percentage at POS |
| `mstrNum` | `mstrNum` | DISCOUNT | *Hub key* (`DISCOUNT_SRC_KEY`) | Enterprise-level key |
| `mstrName` | `mstrName` | DISCOUNT | `MICROSERVICE_NAME` | |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | DISCOUNT | hierarchy levels or ATTR | Custom category hierarchies |
| `catGrpName1`-`4` | `catGrpName1`-`4` | DISCOUNT | *(ATTR)* | Custom category names |
| `rptGrpNum` | `rptGrpNum` | — | — | Reporting group number |
| `rptGrpName` | `rptGrpName` | — | — | Reporting group name |
| `extRef1`, `extRef2` | `extRef1`, `extRef2` | — | — | External references |

**DISCOUNT hub hierarchy mapping:**

The DISCOUNT entity has the standard hierarchy pattern. Simphony discounts have a flat structure (no parent-child in the API), but `catGrpHierName1`-`4` provide a custom hierarchy. Use:

- `DISCOUNT_NAME` = `name` (or `mstrName` via COALESCE)
- `VALUE_TYPE` = `'PERCENT'` (since `posPercent` is a percentage)
- `VALUE` = `posPercent`
- `MICROSERVICE_ID` = `mstrNum`
- `MICROSERVICE_NAME` = `mstrName`

---

### 2.5 getOrderTypeDimensions — REQUIRED

**Proposed DL Table:** `DL_ORDERTYPES`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | OCCASION | *(local number)* | |
| `name` | `name` | OCCASION | `OCCASION_NAME` | e.g., Dine-In, Takeaway, Delivery |
| `mstrNum` | `mstrNum` | OCCASION | *Hub key* (`OCC_SRC_KEY`) | Enterprise-level key |
| `mstrName` | `mstrName` | OCCASION | `MICROSERVICE_NAME` | |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | OCCASION | *(ATTR)* | Custom categories |
| `catGrpName1`-`4` | `catGrpName1`-`4` | OCCASION | *(ATTR)* | Custom category names |

**Mapping rationale:** Simphony "Order Types" (Dine-In, Takeaway, etc.) correspond directly to the XMS BI OCCASION concept — they define the service context for an order, just as NCR Aloha's `orderMode` maps to OCCASION. The name difference ("order type" vs "occasion") is a Simphony vocabulary choice; the semantics are equivalent.

---

### 2.6 getOrderChannelDimensions — REQUIRED

**Proposed DL Table:** `DL_ORDERCHANNELS`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | CHANNEL | *(local number)* | |
| `name` | `name` | CHANNEL | `CHANNEL` | e.g., POS, Online, Mobile |
| `mstrNum` | `mstrNum` | CHANNEL | `MICROSERVICE_ID` | Enterprise key |
| `mstrName` | `mstrName` | CHANNEL | `MICROSERVICE_NAME` | Enterprise name |

**Note:** The CHANNEL entity is hierarchical in XMS BI with a `CHANNEL_ID` extra column. The Simphony channel endpoint is very simple (4 fields). Staging maps directly: `CHANNEL` = `name`, `CHANNEL_ID` = `mstrNum`.

---

### 2.7 getRevenueCenterDimensions — REQUIRED

**Proposed DL Table:** `DL_REVENUECENTERS`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | REVCENTER | *(local number)* | |
| `name` | `name` | REVCENTER | `REVC_NAME` (via hierarchy) | Note: REVCENTER uses `REVC_NAME`, not `REVCENTER_NAME` |
| `mstrNum` | `mstrNum` | REVCENTER | *Hub key* (`REVENUE_CENTER_SRC_KEY`) | Enterprise key |
| `mstrName` | `mstrName` | REVCENTER | `MICROSERVICE_NAME` | |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | REVCENTER | *(ATTR)* | Custom categories |
| `catGrpName1`-`4` | `catGrpName1`-`4` | REVCENTER | *(ATTR)* | Custom category names |
| `addrLn1`-`3` | `addrLn1`-`3` | ADDRESS | `ADDRESS` | Revenue centre address (if distinct from location) |
| `postalCode` | `postalCode` | ADDRESS | `POSTCODE` | |
| `phone`/`phoneCountryCode` | `phone`/`phoneCountryCode` | — | — | Not modelled |
| `countryCode`/`countryName` | `countryCode`/`countryName` | ADDRESS | `COUNTRY` | |
| `regionCode`/`regionName` | `regionCode`/`regionName` | ADDRESS | `REGION` | |

**Note:** Revenue centres having their own address fields is unusual — in most deployments, RevCenters share the location's address. Land the address fields but don't create ADDRESS_REVCENTER links unless the addresses actually differ from the parent location.

---

### 2.8 getTenderMediaDimensions — REQUIRED

**Proposed DL Table:** `DL_TENDERMEDIA`

This is significant: the TENDER hub exists in XMS BI but has **zero integration mappings** currently. Simphony provides the first real dimension data for it.

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | TENDER | *(local number)* | |
| `name` | `name` | TENDER | `TENDER_NAME` (via hierarchy) | e.g., Cash, Visa, Amex |
| `mstrNum` | `mstrNum` | TENDER | *Hub key* (`TENDER_SRC_KEY`) | Enterprise key |
| `mstrName` | `mstrName` | TENDER | `MICROSERVICE_NAME` | |
| `type` | `type` | TENDER | `TENDER_TYPE` (via hierarchy or ATTR) | 1=Payment, 2=Pickup/PaidOut, 3=Loan/PaidIn |
| `subType` | `subType` | TENDER | *(ATTR)* | Enum 0-21; detailed tender classification |
| `cat` | `cat` | TENDER | *(ATTR)* | Category enum 1-15 |
| `autoClsdTnd` | `autoClsdTnd` | TENDER | *(ATTR)* | Auto-close tender flag |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | TENDER | *(ATTR)* | Custom categories |
| `catGrpName1`-`4` | `catGrpName1`-`4` | TENDER | *(ATTR)* | Custom category names |
| `extRef1`, `extRef2` | `extRef1`, `extRef2` | — | — | External references |

**TENDER hub hierarchy mapping:**

The existing TENDER entity follows the standard hierarchy pattern with `TENDER_NAME`, `PARENT_ID`, `LEVEL_NAME`, `BOTTOM_LEVEL`, `ATTR_1`-`ATTR_5`, `MICROSERVICE_*`, plus `TENDER_ID`. Map:

- `TENDER_NAME` = `name`
- `TENDER_ID` = `mstrNum`
- `MICROSERVICE_ID` = `mstrNum`
- `MICROSERVICE_NAME` = `mstrName`
- `ATTR_1` = `type` (decoded: Payment/Pickup-PaidOut/Loan-PaidIn)
- `ATTR_2` = `subType` (raw enum; decode in presentation layer)
- `ATTR_3` = `cat` (raw enum; decode in presentation layer)

**Type enum decode (for staging or presentation):**

| `type` Value | Meaning |
|---|---|
| 1 | Payment |
| 2 | Pickup / Paid Out |
| 3 | Loan / Paid In |

---

### 2.9 getServiceChargeDimensions — REQUIRED

**Proposed DL Table:** `DL_SERVICECHARGES`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | SVCCHARGE | *(local number)* | |
| `name` | `name` | SVCCHARGE | `SVC_NAME` (via hierarchy) | |
| `mstrNum` | `mstrNum` | SVCCHARGE | *Hub key* (`SVC_SRC_KEY`) | Enterprise key |
| `mstrName` | `mstrName` | SVCCHARGE | `MICROSERVICE_NAME` | |
| `posPercent` | `posPercent` | SVCCHARGE | `SVC_PERCENT` (via ATTR or link SAT) | Percentage rate |
| `revFlag` | `revFlag` | SVCCHARGE | *(ATTR)* | Revenue flag |
| `chrgTipsFlag` | `chrgTipsFlag` | SVCCHARGE | *(ATTR)* | Charge-to-tips flag |
| `category` | `category` | SVCCHARGE | *(ATTR)* | Category classification |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | SVCCHARGE | *(ATTR)* | Custom categories |
| `catGrpName1`-`4` | `catGrpName1`-`4` | SVCCHARGE | *(ATTR)* | Custom category names |
| `extRef1`, `extRef2` | `extRef1`, `extRef2` | — | — | External references |

---

### 2.10 getTaxDimensions — REQUIRED

**Proposed DL Table:** `DL_TAXES`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | TAX | *(local number)* | |
| `name` | `name` | TAX | `TAX_NAME` (via hierarchy) | |
| `mstrNum` | `mstrNum` | TAX | *Hub key* (`TAX_SRC_KEY`) | Enterprise key |
| `mstrName` | `mstrName` | TAX | `MICROSERVICE_NAME` | |
| `type` | `type` | TAX | *(ATTR)* | Enum 1-6; tax calculation type |
| `taxRate` | `taxRate` | TAX | `TAX_MULTIPLIER` | The existing TAX entity has `TAX_MULTIPLIER DECIMAL` |
| `effFrDt` | `effFrDt` | TAX | *(ATTR)* | Effective-from date |
| `effToDt` | `effToDt` | TAX | *(ATTR)* | Effective-to date |
| `catGrpHierName1`-`4` | `catGrpHierName1`-`4` | TAX | *(ATTR)* | Custom categories |
| `catGrpName1`-`4` | `catGrpName1`-`4` | TAX | *(ATTR)* | Custom category names |

**TAX type enum (for reference):**

| `type` Value | Likely Meaning |
|---|---|
| 1 | Inclusive (VAT-style) |
| 2 | Exclusive (added on top) |
| 3 | Inclusive + Exclusive |
| 4-6 | *(verify against Simphony docs)* |

**Note:** The existing TAX entity already has `TAX_MULTIPLIER (DECIMAL)` — the `taxRate` maps directly. The `effFrDt`/`effToDt` fields are valuable for SCD Type 2 tracking; they can drive historization in the satellite.

---

### 2.11 getCashierDimensions — OPTIONAL

**Proposed DL Table:** `DL_CASHIERS`

| API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | *(see below)* | | |
| `name` | `name` | *(see below)* | | |
| `mstrNum` | `mstrNum` | | | |
| `mstrName` | `mstrName` | | | |

**Assessment:** In many Simphony deployments, cashiers are a subset of employees — the cashier record exists as a POS login identity that maps 1:1 to an employee. However, in some configurations, a cashier number is a shared terminal login (e.g., "Till 1 Cashier") that doesn't correspond to a specific employee.

**Recommendation:** Land the data (`DL_CASHIERS`) but defer entity mapping until transactional data is available. If cashier IDs appear in transaction records and can be reliably joined to employee records, skip a separate CASHIER entity and join through to EMPLOYEE. If they represent distinct identities, either:
- Map to EMPLOYEE as a secondary key, or
- Create a new CASHIER hub (only if truly distinct from EMPLOYEE)

---

### 2.12 getMenuItemPrices — OPTIONAL

**Proposed DL Table:** `DL_MENUITEMPRICES`

This endpoint provides **price level data** for menu items — effectively a pricing matrix by location, occasion, or price level.

**Target DV entity:** Not a hub. This data feeds the `SAT_LNK_LOCATION_OCCASION_PRODUCT` link satellite, which already has `NET_PRICE` and `NET_COST` attributes. The Simphony price data would populate `NET_PRICE` in that satellite.

**Recommendation:** Include in the integration but defer until the core dimension and transactional endpoints are working. The pricing matrix requires understanding Simphony's price level structure (which price levels map to which occasions/locations).

---

### 2.13 getJobCodeDimensions — REQUIRED

**Proposed DL Table:** `DL_JOBCODES`

The response fields are not fully specified in the brief, but based on Simphony's standard pattern, expect:

| Expected API Field | DL Column | DV Entity | DV Attribute | Notes |
|---|---|---|---|---|
| `num` | `num` | JOB | *(local number)* | |
| `name` | `name` | JOB | `JOB_NAME` | |
| `mstrNum` | `mstrNum` | JOB | *Hub key* (`JOB_SRC_KEY`) | Enterprise key |
| `mstrName` | `mstrName` | JOB | `MICROSERVICE_NAME` | |
| *(pay code fields if present)* | | JOB | `PAY_CODE` | |
| *(tronc flag if present)* | | JOB | `TRONC_FLAG` | UK-specific tip pooling flag |

The existing JOB entity is non-hierarchical with: `JOB_NAME`, `TRONC_FLAG`, `JOB_CODE`, `PAY_CODE`, `MICROSERVICE_ID/NAME/ID_BIN`. Direct mapping.

---

### 2.14 getReasonCodeDimensions — OPTIONAL

**Proposed DL Table:** `DL_REASONCODES`

Reason codes categorise **why** a void, comp, or waste event occurred. This is valuable for operational analytics (e.g., "top void reasons", "comp reason breakdown").

**Target DV entity:** No existing hub. Would require a **new REASONCODE hub entity** with attributes like:
- `REASON_NAME` — the reason description
- `REASON_TYPE` — void, comp, waste, etc.
- `REASON_CODE` — the numeric code

**Recommendation:** Land the data now. Create the REASONCODE entity when transactional endpoints are being mapped — reason codes will appear as references in void/comp transaction records and need a hub to link against.

---

### 2.15 getLatestBusDt — SKIP

Utility endpoint returning the latest available business date. Not a dimension — used for extraction orchestration only. The API fetcher may use this to determine the date range for transactional pulls, but it does not produce a DL table.

---

### 2.16 getCashManagementItemDimensions — SKIP

Cash management items (till floats, safe drops, cash pickups) are operational cash-handling records. These are out of scope for the current BI analytics model which focuses on sales, product, and labour analytics.

**Revisit if:** Cash variance reporting is added to the platform.

---

### 2.17 getPaymentAccountDimensions / getPaymentAccountHolderDimensions — SKIP

Payment account and holder dimensions relate to stored-value / house-account programs. These require dedicated entity modelling (loyalty/stored-value domain) that is not part of the current XMS BI scope.

**Revisit if:** Loyalty or stored-value analytics are added.

---

## 3. Gaps Analysis

### 3.1 New Entities Needed

| Proposed Entity | Type | Triggered By | Priority |
|---|---|---|---|
| REASONCODE | Hub | getReasonCodeDimensions (#14) | Medium — needed when transactional void/comp data is mapped |

No other new hub entities are required. All 10 Required dimension endpoints map to existing DV hubs.

### 3.2 Existing Entities With No Prior Mappings (Now Filled)

| Entity | Previous Status | Simphony Fills It |
|---|---|---|
| TENDER | Hub exists, zero mappings | Yes — getTenderMediaDimensions provides full dimension data |
| COMP | Hub exists, zero mappings | **Partially** — Simphony comps appear in transactional data, not as a separate dimension endpoint. The comp dimension may be derivable from transaction comp records or reason codes |

### 3.3 Existing Entity Attribute Gaps

The current DV entity definitions were designed around NCR Aloha's field set. Simphony provides some fields that don't have natural homes:

| Entity | Simphony Field | Gap | Recommendation |
|---|---|---|---|
| LOCATION | `openDt` | No opening date attribute | Store in `ATTR_1` or add to next LOCATION entity version |
| LOCATION | `tz`, `curr` | No timezone/currency attributes | Store in `ATTR_*` columns |
| EMPLOYEE | `homeLocRef` | No home-location link | Could feed a new EMPLOYEE_LOCATION link or store as `ATTR_*` |
| EMPLOYEE | `className`/`classMstrName` | Partially maps to `POST_DESC` | Use `POST_DESC` for class name |
| EMPLOYEE | `payrollId`, `externalPayrollID` | No direct DV attribute (though entity doc mentions PAYROLL_ID in presentation) | Store in satellite as additional attrs — may need entity version bump |
| TAX | `effFrDt`/`effToDt` | No effective date attributes | Store in `ATTR_*` or let SCD Type 2 handle temporal changes |
| TENDER | `type`, `subType`, `cat` enums | No dedicated attributes beyond TENDER_NAME/TENDER_TYPE | Use `ATTR_*` columns and/or `TENDER_TYPE` for the main type |
| SVCCHARGE | `chrgTipsFlag`, `revFlag` | No specific attributes | Use `ATTR_*` columns |
| DISCOUNT | `rptGrpNum`/`rptGrpName` | No reporting group attribute | Store in `ATTR_*` |

**Overall assessment:** The existing entity definitions are flexible enough to absorb Simphony's fields via the `ATTR_1`-`ATTR_5` columns and `MICROSERVICE_*` columns. No entity version bumps are strictly required for the initial integration, though bumping EMPLOYEE and LOCATION to add explicit named attributes (instead of generic ATTR_*) would improve clarity for future integrations.

### 3.4 Links Activated by Dimension Data Alone

Dimension endpoints don't create links by themselves — links are formed during transactional staging when a check references a location, employee, product, etc. However, one dimension field creates a potential link:

- **EMPLOYEE.homeLocRef** could feed an `EMPLOYEE_LOCATION` link (not currently in the DV model). This is a low-priority enhancement — employee-location association is more naturally derived from transactional data (which employee rang sales at which location).

---

## 4. Master vs Local Number Pattern — Recommendation

### The Pattern

Most Simphony dimension endpoints return paired identifiers:
- **`num` / `name`** — Location-specific (local) number and name. A menu item might be `num=1001` at one location and `num=2001` at another, but represent the same enterprise item.
- **`mstrNum` / `mstrName`** — Enterprise-level (master) number and name. Consistent across all locations. `mstrNum=5001` is the same item everywhere.

Some endpoints extend this with `catGrpName1-4` / `catGrpHierName1-4` (custom category groups at local and hierarchy levels) and `name2` / `name2MstrName` (second-language names).

### Recommendation

**Use `mstrNum` as the hub key (`*_SRC_KEY`) for all dimension entities.**

Rationale:
1. **Cross-location consistency.** XMS BI's Data Vault is designed for multi-location analytics. Keying on `mstrNum` ensures one hub record per enterprise item, enabling cross-store comparisons. Keying on local `num` would create duplicate hubs for the same business entity.
2. **Matches the MICROSERVICE pattern.** The existing DV hierarchy entities already have `MICROSERVICE_ID` / `MICROSERVICE_NAME` / `MICROSERVICE_ID_BIN` columns designed for exactly this purpose — an enterprise-level identifier that resolves cross-integration name differences. Map `mstrNum` to `MICROSERVICE_ID` and `mstrName` to `MICROSERVICE_NAME`.
3. **Local `num` is still preserved.** Land it in the DL table and carry it into the satellite as an attribute (e.g., in an `ATTR_*` column or a dedicated column if entity is versioned up). This allows location-specific reporting if needed.
4. **NCR Aloha precedent.** NCR Aloha uses composite keys (`CONCAT_WS('-', storeId, typeId)`) for products that are inherently location-scoped. Simphony's master numbers are cleaner — use them.

**Exception:** If `mstrNum` is NULL or 0 for some records (e.g., location-only items not configured at enterprise level), fall back to a composite key: `CONCAT_WS('-', locRef, num)` to ensure uniqueness. The staging step should handle this with a `COALESCE` or `CASE` expression:

```sql
CASE
    WHEN mstrNum IS NOT NULL AND mstrNum != '0'
        THEN CAST(mstrNum AS NVARCHAR(255))
    ELSE CONCAT_WS('-', locRef, num)
END AS PRODUCT_SRC_KEY
```

### Storing Both Levels

For each dimension endpoint, the staging step should produce:
- `*_SRC_KEY` = `mstrNum` (or composite fallback) — feeds the hub hash key
- `*_NAME` = `COALESCE(mstrName, name)` — enterprise name preferred, local as fallback
- `MICROSERVICE_ID` = `mstrNum`
- `MICROSERVICE_NAME` = `mstrName`
- Local `num` and `name` stored as satellite attributes for reference

---

## 5. Proposed DL Table Summary

The full set of DL tables for the Simphony dimension endpoints:

| DL Table | Endpoint | Column Count (est.) | Entity Target |
|---|---|---|---|
| `DL_LOCATIONS` | getLocationDimensions | ~18 | LOCATION, ADDRESS |
| `DL_MENUITEMS` | getMenuItemDimensions | ~30 | PRODUCT |
| `DL_EMPLOYEES` | getEmployeeDimensions | ~12 | EMPLOYEE |
| `DL_DISCOUNTS` | getDiscountDimensions | ~14 | DISCOUNT |
| `DL_ORDERTYPES` | getOrderTypeDimensions | ~10 | OCCASION |
| `DL_ORDERCHANNELS` | getOrderChannelDimensions | ~4 | CHANNEL |
| `DL_REVENUECENTERS` | getRevenueCenterDimensions | ~18 | REVCENTER |
| `DL_TENDERMEDIA` | getTenderMediaDimensions | ~16 | TENDER |
| `DL_SERVICECHARGES` | getServiceChargeDimensions | ~16 | SVCCHARGE |
| `DL_TAXES` | getTaxDimensions | ~14 | TAX |
| `DL_JOBCODES` | getJobCodeDimensions | ~6 | JOB |
| `DL_CASHIERS` | getCashierDimensions (optional) | ~4 | *(deferred)* |
| `DL_MENUITEMPRICES` | getMenuItemPrices (optional) | *(TBD)* | SAT_LNK_LOCATION_OCCASION_PRODUCT |
| `DL_REASONCODES` | getReasonCodeDimensions (optional) | *(TBD)* | *(new REASONCODE hub)* |

**Required DL tables: 11** | **Optional DL tables: 3** | **Total: 14**

For comparison, NCR Aloha has 21 DL tables (most are transactional stream sub-tables). Simphony's 11 required dimension DL tables plus the transactional endpoints (to be evaluated separately) will likely total 15-20 DL tables.

---

## 6. Next Steps

1. **Evaluate transactional endpoints** — the sales/check/labour data endpoints determine the link mappings and complete the integration picture.
2. **Confirm `mstrNum` availability** — verify with a sample API call that `mstrNum` is consistently populated across all dimension types. If not, implement the composite fallback key pattern.
3. **Decide on REASONCODE entity** — if void/comp analysis is in scope, create the entity definition before mapping transactional data.
4. **Draft DDL script** — write the `_DDL.sql` file defining all DL tables with NVARCHAR(MAX) columns + LOADTS_UTC + INT_FETCH_DATE.
5. **Draft INIT script** — define the integration registration and endpoint configuration JSON.
