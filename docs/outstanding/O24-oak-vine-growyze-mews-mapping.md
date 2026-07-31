# O24 — Map The Oak & Vine (org 16) to Growyze + Mews in UAT (mirror Ibis Gloucester Road feed)

> Detail file for ledger item **O24**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | MONITOR — **complete and proven end-to-end.** Release-side mapping done + verified 2026-07-29; Integrations **O10** cloned the KV secrets and loaded both feeds (90-day); and on 2026-07-30 **[O8](O8-marge-brut-dashboard.md) consumed the feed successfully on org 16** — `F_MARGEBRUT_MONTH` built from it, `99_verify` 5-of-6 PASS. Awaiting Andrew's confirm to close. |
| **Priority** | 2 |
| **Area** | Provisioning / org + integration mapping |
| **Owner / decides** | Andy |
| **Next action** | **Nothing outstanding — confirm and close.** The whole chain (mapping → DL provisioning → load → DV → presentation → dashboard) is demonstrated on the mirrored org. If Oak & Vine mirroring is wanted in Test/Prod, raise a follow-on; that was explicitly out of scope here. |
| **Sources** | Integrations ledger **O10** (this request), Release **O19** (the Ibis sibling), [O8](O8-marge-brut-dashboard.md), planning conversation 2026-07-29 |

## Context
Andrew's decision (2026-07-29): **The Oak & Vine** (org 16) should mirror the **Ibis Gloucester Road** (org 21) Growyze org + Mews property — **two orgs, one source feed** — in **UAT**. Org 21 stays untouched; org 16 additionally pulls the same Growyze org GUID and same Mews property.

The Integrations side (**O10**) owns the Key Vault secrets and the load. Because it is the *same* source feed, O10 will **clone Gloucester's UAT secrets** into Oak & Vine's prefix (byte-identical Growyze login / `-org-filter` GUID / Mews `api-key`), plus the missing DB-login pair. The one thing O10 cannot do is the **org→integration mapping + DL-table provisioning**, which is this project's lane (same as O19). This item is that mapping — **UAT only** for now.

## Current state (mapping executed + verified on UAT 2026-07-29 22:24)
- **Org 16 = "The Oak & Vine"**, `DatabaseName = 20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87`, `IsActive=1`, `ACTIVE`.
- **Now mapped to 4 integrations:** `Marketman001` (1), `NCRAloha001` (2), **`Growyze001` (5)** and **`Mews001` (7)** — the last two added by this item (`OrganisationIntegrationID` 35 and 36, both `IsEnabled=1`, `SyncStatus=PENDING`).
- **DL tables provisioned by the trigger:** `int_growyze001` = **13** (expected 13, PASS), `int_mews001` = **21** (expected 21, PASS — no `DL_CUSTOMERS`).
- **Mirror proven:** the DL table *names* are byte-identical to Ibis Gloucester Road's — 13/13 and 21/21 matched, **0 missing, 0 extra** (independently re-checked via MCP after the runner's own diff returned zero rows).
- **UAT IntegrationIDs:** `int_growyze001` = **5**, `int_mews001` = **7**.
- **Mews `STAGE_DDL` = 21 rows, no `DL_CUSTOMERS`** (the permanent GDPR-safe shape from O19 `01b`) → the trigger will **not** create a customers table.
- **Central control planes already deployed on UAT (O19, 2026-07-29):** `core.int_mews001.StagingControl`/`.EntityMappings` (staging=15/load=16/mappings=16) and the Growyze path. These are **per-integration/central, not per-org**, so mapping a new org inherits them — **no control-plane re-deploy needed**, unlike the gap O19 hit. Mapping alone suffices.

## Scope
1. `MapOrganisationToIntegration` org 16 → Growyze (ID 5) and Mews (ID 7), **UAT only**.
2. Verify the trigger provisioned the DL tables in the Oak & Vine DB (13 Growyze + 21 Mews).
3. Hand back to Integrations **O10** (KV secrets cloned from Gloucester + fire the reload).

**Out of scope:** Test/Prod (raise a follow-on only if Oak & Vine mirroring is wanted there); any new Growyze/Mews credentials (same source feed → O10 clones Gloucester's).

## Dependency shape
```
THIS O24 — map org 16 → Growyze + Mews (UAT); trigger provisions DL tables
        ▼
Integrations O10 — clone Gloucester's KV secrets into org-16 prefix + fire reload
        ▼
DL populated → DV load (central Growyze/Mews control plane already present) → presentation
```

## SP gotchas (from O19)
- `MapOrganisationToIntegration` takes **integer** IDs; the provisioning trigger fires **once per insert** — map each integration as its own call.
- Run via the **PowerShell runner (`Invoke-Sqlcmd`)**, not MCP `execute` (15s request cap can leave half-built state).
- `SchemaCreated` on `core.Integrations` is a red herring (always False) — verify via `sys.schemas`/`INFORMATION_SCHEMA.TABLES` in the org DB.

## Handoff back to Integrations O10
**Mapping done + verified 2026-07-29 — these values are confirmed live** (emitted by `02` RESULT 3, matching what was predicted when the item was raised). O10's prefix for org 16 is:
- Growyze: `20260317-XMS-7ED2E768-0D22-F111-832F-000D3AB27D87-int-growyze001`
- Mews: `20260317-XMS-7ED2E768-0D22-F111-832F-000D3AB27D87-int-mews001`
- DB-login (bare org prefix): `20260317-XMS-7ED2E768-0D22-F111-832F-000D3AB27D87-username`/`-password`

O10 clones these values from the corresponding Ibis Gloucester Road (`…67CA4E6F…`) UAT secrets.

## Scripts
`ClaudeDevelopment/oak-vine-mapping/` — modelled on the O19 `ibis-provisioning` set:

| File | Purpose |
|---|---|
| `01_map_oak_vine_to_growyze_mews.sql` | 5 preflight guards, then the two `MapOrganisationToIntegration` calls (one per feed) |
| `02_verify_dl_provisioning.sql` | Read-only: mappings, DL counts vs expected with PASS/FAIL, the O10 `kv_prefix` handoff rows, and a mirror diff vs Ibis Gloucester Road |
| `90_deploy_oak_vine_mapping.ps1` | Runner — `-WhatIf`, typed confirmation, halt-on-error + `-StartAt` resume, per-run log, `QueryTimeout 0`, `ValidateSet('UAT')` and a server-name Prod refusal |
| `deploy_O24_UAT_20260729_222404.log` | The executed run |

The guards are worth keeping for any future org that mirrors a feed: org identity cross-checked by name (not just ID), `DatabaseStatus` must be `ACTIVE`, both feeds' `STAGE_DDL` must be seeded, Mews `STAGE_DDL` must carry **no** `CUSTOMER` row (GDPR ruling O14/O19), and — the important one — a **halt if a mapping already exists while its `int_*` schema has 0 DL tables**, because the INSERT trigger has then been consumed and a re-run cannot repair it.

## Progress log
- **2026-07-30 (downstream consumption proven — this item's purpose is fulfilled)** — [O8](O8-marge-brut-dashboard.md) built `presentation.F_MARGEBRUT_MONTH` on org 16 off this feed: **24 rows**, June 2026 turnover ex-VAT £17,138.71 / consumption £4,676.89 / **cost 27.3%**, all 9 `MargeBrut*` cards executing, `99_verify` **5 of 6 PASS**. So the full chain — mapping → DL provisioning → O10's load → DV → presentation → dashboard — is now demonstrated end to end on the mirrored org, which is what this item existed to enable.
  - **The mirror is exact on the turnover side:** org 16's June Mews turnover is **identical to Ibis Gloucester Road's to the penny** (£17,138.71), and stock differs by only £24.48. Useful confirmation that "two orgs, one source feed" behaves as intended — and a caution that org 16's numbers are *not* an independent business.
  - The 90-day window (vs Gloucester's 60) gives org 16 **3 stocktakes** (30 Apr, 31 May, 30 Jun) instead of 2, so two months are computable rather than one. But its **May is not trustworthy** — the 30 Apr count is the feed's first (`DAYS_SINCE_LAST_COUNT` NULL) and shows the same first-count anomaly as Gloucester's opening count; see O8 for detail.
  - **Two things this org exposed that a single-feed org could not**, both now fixed in O8's scripts: the Marge Brut fact had no **source filter**, so NCRAloha's `D_PRODUCT.TOP_NAME = 'Food'` (£916,792.80) collided with the Mews Food group (£281.62) and cost of sales read ~0.5%; and a **global vis-query swap** had left org 16's already-wired dashboard erroring against a fact table it didn't have. Mapping a second org onto an existing dashboard is exactly what surfaced both — worth remembering for the next mirrored org.
  - **[O23](O23-growyze-supplier-bottom-level.md) corroborated here:** org 16's `D_SUPPLIER` has **7 rows** (MarketMan populates `BOTTOM_LEVEL` correctly) yet none match the Growyze purchase keys — confirming the defect is Growyze-specific rather than platform-wide.
- **2026-07-29 (Integrations O10 completed the load — mapping proven end-to-end)** — O10 cloned Gloucester's KV secrets and loaded both feeds into org 16 via **per-feed `reload_integration`** (90-day; `reload_db` can't be used — org 16's unconfigured NCR Aloha fails the shared orchestration). **Growyze** DL **19,233** (= Ibis Gloucester Road exactly); **Mews** `datavault.SAT_CUSTORDER` **1,613** (1.53× ≈ 90/60 of Gloucester's 1,052 — proportional mirror). **26 DV jobs completed, 0 errors, 0 orphans.** The mapping + DL provisioning from this item worked correctly. **One snag surfaced (warehouse, not this item):** org 16's `D_DISCOUNT` presentation build casts NCR Aloha discount codes (`DISC001`…`DISC_ALL`, non-GUID) → `uniqueidentifier`, dooming the DV load; O10 cleared the NCR Aloha **dummy** discount data (`datavault.{HUB,SAT}_DISCOUNT` + `LNK_DISCOUNT_LINEITEM`, `SRC='int_ncraloha001'`) per Andrew to unblock. **The `D_DISCOUNT` fragility remains** — will recur when NCR dummy discounts are regenerated or for any org with NCR Aloha discount data. ⚠️ **Now tracked as [O25](O25-d-discount-microservice-id-typing.md), where the diagnosis recorded here was checked and found to be WRONG:** there is no `uniqueidentifier` cast in the `Discount Dimension` build SQL, and `SAT_DISCOUNT.DISCOUNT_ID` is `nvarchar` — the offending column is `MICROSERVICE_ID` and the cast lives in the **target table's DDL**, firing on `sp_ExecuteQuery`'s final INSERT. `D_DISCOUNT` is the only 1 of 15 dimensions typing those columns `uniqueidentifier`, so the fix is a one-line DDL correction rather than a `TRY_CONVERT` in the build. O24's own scope is complete; **awaiting Andrew's confirm to close.**
- **2026-07-29** — Item created from Integrations O10. Andrew chose "both orgs, same source feed" (org 16 mirrors org 21's Growyze+Mews) and directed that the org→integration mapping be raised here in Release rather than run from the Integrations session. UAT only. Facts verified live on UAT. Nothing executed yet.
- **2026-07-29 22:24** — **EXECUTED on UAT via the runner.** `-WhatIf` preflight clean, then both mappings created (`OrganisationIntegrationID` 35 Growyze, 36 Mews). Trigger provisioned **13 + 21** DL tables; both PASS, mirror diff **0 rows**, re-verified independently via MCP. `kv_prefix` values match those predicted when the item was raised — **no change needed to O10's runbook**. Handed back to Integrations O10.
  - Runner had to be executed by Andrew: the permission classifier blocked Claude from running it, and Git Bash's `!` prefix needs `powershell.exe -File …` (plus `-Force`, since `Read-Host` doesn't render through Git Bash without `winpty`).

## Pick-up notes (resume here)
- **Release side is complete** — do not re-run `01`. Re-running would take the SP's UPDATE path and cannot re-provision anything; guard 5 exists precisely to stop a re-run from looking like a success.
- Next signal to watch: DL tables in `20260317_XMS_7ED2E768-0D22-F111-832F-000D3AB27D87` going from created → **populated**, which is O10's load. `SyncStatus` is `PENDING` on both mappings until then.
- After DL populates, the DV load should need no new control plane (central `int_growyze001`/`int_mews001` `StagingControl`+`EntityMappings` already deployed per O19).
- Don't mark Closed until Andrew confirms.
- Relates to Integrations **O10** (consumer), **O19** (Ibis sibling), **O8** (ultimate consumer). Note **O23** (Growyze `BOTTOM_LEVEL`/`D_SUPPLIER`) will affect this org's supplier reporting too, once loaded.
