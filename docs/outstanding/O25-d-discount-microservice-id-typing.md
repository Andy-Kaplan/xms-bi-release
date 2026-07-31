# O25 — `D_DISCOUNT.*_MICROSERVICE_ID` is typed `uniqueidentifier`, dooming the build on non-GUID text

> Detail file for ledger item **O25**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED — root cause proven 2026-07-30; one-line fix identified, not applied |
| **Priority** | 2 |
| **Area** | Presentation / table DDL |
| **Owner / decides** | Andy |
| **Next action** | Change the three `*_MICROSERVICE_ID` columns in the `D_DISCOUNT` DDL in `core.core.PresentationTables` from `[uniqueidentifier]` to `[nvarchar](100)`, matching all 14 sibling dimensions, then redeploy that one table per affected org and rebuild it |
| **Sources** | `core.core.PresentationTables` (`D_DISCOUNT` `ddl_script` + `column_definitions`), `core.core.PresentationControl` step `Discount Dimension`, raised out of [O24](O24-oak-vine-growyze-mews-mapping.md)'s progress log |

## Why this is its own item
It surfaced during [O24](O24-oak-vine-growyze-mews-mapping.md): The Oak & Vine's DV load was being doomed by the `D_DISCOUNT` build, and Integrations cleared that org's NCR Aloha **dummy** discount data to unblock it. That was a data workaround — **the defect itself remains**, and it will recur the moment NCR Aloha dummy discounts are regenerated, or for any organisation carrying real NCR Aloha discount data. It was recorded only inside O24's progress log, where it would have been lost once that item closed.

## Corrected diagnosis
O24's log attributed this to *"the `D_DISCOUNT` build casting NCR Aloha discount codes (`DISC001`…`DISC_ALL`) → `uniqueidentifier`"*. That is **not** where the cast is, and the column named is wrong. Verified 2026-07-30:

- The `Discount Dimension` `query_sql` contains **no** `uniqueidentifier` cast at all — grepping it for one returns nothing.
- `datavault.SAT_DISCOUNT.DISCOUNT_ID` is **`nvarchar`**, as is `MICROSERVICE_ID`. So nothing on the data-vault side casts either.
- The typing is in the **target table DDL**. `presentation.D_DISCOUNT` declares `BOTTOM_MICROSERVICE_ID`, `MIDDLE_1_MICROSERVICE_ID` and `TOP_MICROSERVICE_ID` as **`uniqueidentifier`** — confirmed both in the live table and in the registered `ddl_script` *and* `column_definitions` in `core.core.PresentationTables`.

So the failure happens in `core.sp_ExecuteQuery`'s final step — `INSERT INTO presentation.D_DISCOUNT (…) SELECT … FROM ##TempResults` — where the `nvarchar` value is **implicitly converted** to `uniqueidentifier`. Any non-GUID text fails the whole step (`Msg 8169, Conversion failed when converting from a character string to uniqueidentifier`). That is why the build SQL looks innocent: the cast is a property of the destination column, not of the query.

**`D_DISCOUNT` is the sole outlier.** Every other dimension types these columns `nvarchar`:

| Typing | Dimensions |
|---|---|
| `uniqueidentifier` | **`D_DISCOUNT`** only |
| `nvarchar` | `D_CHANNEL`, `D_DEAL`, `D_DISTRIBUTOR`, `D_INVITEM`, `D_LOCATION`, `D_MOD`, `D_OCCASION`, `D_PRODUCT`, `D_QUESTION`, `D_REVCENTER`, `D_SERVICECHARGE`, `D_SUPPLIER`, `D_TAX`, `D_TENDER` (14) |

So this is a straightforward DDL inconsistency, not a design intent.

## Fix
1. In `8_PresentationTables.sql` / the `D_DISCOUNT` record in `core.core.PresentationTables`, change the three `*_MICROSERVICE_ID` columns from `[uniqueidentifier]` to `[nvarchar](100)` in **both** `ddl_script` and `column_definitions` (they agree today and must stay in step — `sp_ExecuteQuery` falls back to `column_definitions` for the temp-table schema when `dm_exec_describe_first_result_set` returns nothing).
2. Redeploy **only** `presentation.D_DISCOUNT` per affected org, from its registered `ddl_script` behind an `OBJECT_ID` guard. **Do not use `core.DeployPresentationTables`** — it DROPs and recreates *every* registered presentation table for that org (see [O8](O8-marge-brut-dashboard.md)).
3. Rebuild the `Discount Dimension` step for those orgs and confirm it succeeds with non-GUID codes present.

## Secondary question worth answering while in here
`MICROSERVICE_ID` is the platform's **manual-only MDM** column — staging pipelines are supposed to leave it NULL, and if it were NULL this conversion would never fire. So the fact that it held values like `DISC001` suggests an NCR Aloha staging step or entity mapping is **populating an MDM column**, which is a defect in its own right and the same class of mistake that [O20](O20-presentation-microservice-name-to-id.md) and the withdrawn Marge Brut `12_group_mapping.sql` are about. Worth checking whether the NCR Aloha DISCOUNT mapping writes `MICROSERVICE_ID`; if so, the typing fix removes the crash but the wrong data remains. (Not verified here — Oak & Vine's NCR discount rows were deleted before this was investigated, so there was nothing left to inspect.)

## Progress log
- **2026-07-30** — Raised from [O24](O24-oak-vine-growyze-mews-mapping.md)'s progress log while updating the ledger. Attempted to confirm the recorded diagnosis and found it did not hold: the cast is in the target table's DDL, not the build SQL, and the column is `MICROSERVICE_ID`, not `DISCOUNT_ID`. Proved `D_DISCOUNT` is the only one of 15 dimensions typing these columns `uniqueidentifier`, in the live table and in the registered DDL and `column_definitions`. Fix not applied — it changes a global control record and needs a per-org table redeploy, so it wants its own deliberate change.

## Pick-up notes (resume here)
- The diagnosis is settled; this item is about making and deploying the change.
- The blast radius is every org with NCR Aloha discount data, not just The Oak & Vine — a full-refresh org would hit it too.
- Check the secondary question above before assuming the typing fix is sufficient.
- Don't mark Closed until the user confirms.
