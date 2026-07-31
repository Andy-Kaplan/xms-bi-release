# O19 — Provision 2 Ibis hotel orgs + map to Growyze & Mews (Test/UAT/Prod)

> Detail file for ledger item **O19**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | IN PROGRESS |
| **Priority** | 2 |
| **Area** | Provisioning / org + integration mapping |
| **Owner / decides** | Andy |
| **Next action** | Pull the two Ibis GUIDs from the microservice Prod `Organisations` table; add both orgs via `AddOrganisation` and map each to **Growyze** + **Mews** via `MapOrganisationToIntegration`, in **Test, UAT and Prod**. Mews integration must exist per env first (ties to O14). Then hand to Integrations **O10** — recording the exact `db_name`+`schema_name` per org/feed/env (see handoff note below), which O10's KV secret names embed. **UAT first.** |
| **Sources** | [O8](O8-marge-brut-dashboard.md), `docs/superpowers/specs/2026-07-10-marge-brut-live-design.md`, `memory/uat-migration.md`, `memory/test-orgs.md`, Integrations ledger O10, this planning conversation (2026-07-22) |

## Context
The Marge Brut cost-of-sales dashboard (**O8**) needs a hotel org carrying **both** Mews (turnover) and Growyze (inventory) so the `Consumption ÷ Turnover` ratio reconciles with no double-count. The O8 live design originally assumed a single invented **"Three Rocks Hotel"** UAT org; the decision now is to stand up the **two real Accor Ibis hotels** instead, whose GUIDs already exist in the **Organisation microservice `Organisations` database (Prod)**.

**Scope of this item (the XMS BI Release half):**
1. **Provision** the two Ibis orgs in each of **Test, UAT, Prod** — via the stored procedures, never direct INSERT (`AddOrganisation`; `@OrganisationCode` is a `uniqueidentifier`), reusing the microservice GUIDs so the BI orgs align with the microservice orgs.
2. **Map** each org to **Growyze** and **Mews** (`MapOrganisationToIntegration`, integer IDs). The org↔integration INSERT trigger provisions the per-org schemas (`int_growyze001`, `int_mews001`, `stage`, `load`, `datavault`, `presentation`, …).
3. **Hand off** to Integrations **O10** — once the orgs + mappings exist, that project adds the Key Vault secrets and initiates the fetches/loads that populate the DL and DV tables.

## Prerequisites & interlocks
- **Mews integration is currently DEV-only.** To map Mews in Test/UAT/Prod, the Mews integration must first be **registered per environment** (`AddIntegration` — note it has no `@IntegrationType` param) and its STAGE_DDL seeded, before `MapOrganisationToIntegration`. See **O14** (Mews DV mapping) and Integrations **O1** (Mews integration data-enablement).
- **Growyze** lands DL data but has **no staging/DV mapping** in the release scripts (per CLAUDE.md). Marge Brut needs Growyze in the DV/presentation layer — see **O5**/**O6** (Growyze dashboards + quality, incl. the `UOM_COST` correctness gate).
- **SP gotchas** (from [[uat-migration]]): `AddOrganisation` `@OrganisationCode` = `uniqueidentifier`; `MapOrganisationToIntegration` takes int IDs; the provisioning trigger fires **once per insert** — map each integration as its own call.

## Dependency shape
```
THIS O19 — provision 2 Ibis orgs + map Growyze+Mews (per env)
        ▼
Integrations O10 — KV secrets + initiate loads  ──►  DL tables populated
        ▼
O14 (Mews DV mapping) + O5/O6 (Growyze DV/quality)  ──►  DV + presentation
        ▼
O8 — Marge Brut dashboard renders on real data
```

## Handoff mapping to O10 (deterministic — see below)
Because we **reuse the microservice GUID across envs** and **fix the prefix** (`20260722`), `DatabaseName = {prefix}_XMS_{GUID}` and therefore O10's `kv_prefix = f"{db_name}-{schema_name}"` (`_`→`-`) are **identical across Test/UAT/Prod** — only the target Key Vault differs. So O10's 12-row table collapses to **4 distinct `kv_prefix` values** (2 hotels × 2 feeds), computable now with the GUIDs as the only fill-in. This unblocks O10 step 1 (KV secrets) without waiting on provisioning.

Schema names are fixed: Growyze = `int_growyze001`, Mews = `int_mews001`.

**GUIDs (from microservice Prod):** Ibis Heathrow = `7CE02464-9A7E-F111-B337-002248A1EC3D`; Ibis Gloucester Road = `67CA4E6F-9A7E-F111-B337-002248A1EC3D`.

| Hotel | Feed | `kv_prefix` (all envs — verified live on UAT 2026-07-24) |
|---|---|---|
| Ibis Heathrow | Growyze | `20260722-XMS-7CE02464-9A7E-F111-B337-002248A1EC3D-int-growyze001` |
| Ibis Heathrow | Mews | `20260722-XMS-7CE02464-9A7E-F111-B337-002248A1EC3D-int-mews001` |
| Ibis Gloucester Road | Growyze | `20260722-XMS-67CA4E6F-9A7E-F111-B337-002248A1EC3D-int-growyze001` |
| Ibis Gloucester Road | Mews | `20260722-XMS-67CA4E6F-9A7E-F111-B337-002248A1EC3D-int-mews001` |

These are the **UAT** rows and, because the prefix+GUID are reused, the **Test/Prod** rows too (only the target Key Vault differs). O10 also wants each hotel's **Growyze org GUID** for the optional `-api-org-filter` secret. **This is the deliverable to Integrations O10 — it is now unblocked.**

## Progress log
- **2026-07-29 (gap found downstream — read if you touch Test/Prod)** — Provisioning + mapping were correct, but **mapping an org to Mews does not give it a staging/DV path**. On UAT, `core.int_mews001.StagingControl` and `.EntityMappings` were both **0 rows** — the trigger provisions the `int_mews001` schema and DL tables, but the Mews *staging steps and entity mappings* are a separate control-plane deploy (`ClaudeDevelopment/integrations/Mews/` `01`→`02`→`05`A→`03`). Result: Mews DL data landed and went nowhere. Deployed on UAT 2026-07-29 via the new `Mews/91_deploy_mews_uat.ps1` runner (verification staging=15/load=16/mappings=16/crm=0). **Test is in the same state — provisioned + mapped but with an empty Mews control plane**; run `91_deploy_mews_uat.ps1 -Environment TEST` when Test's SQL DB is resumed. Prod likewise, human-run. See [O8](O8-marge-brut-dashboard.md).
- **2026-07-22** — Item created from the O8 dependency review. Org plan changed from a single "Three Rocks Hotel" org to the **two real Ibis hotels** (GUIDs in microservice Prod). Nothing provisioned yet. Integrations side tracked as O10.
- **2026-07-24 (TEST COMPLETE)** — Test provisioned end-to-end via `Invoke-Sqlcmd` (01→01b→02→03, no timeouts — lesson applied). Preflight: Growyze001 present (ID 5), Mews absent, clean slate (max OrgID 6). Result: **Ibis Heathrow = OrgID 7, Ibis Gloucester Road = OrgID 8**, both `ACTIVE`; Mews001 = IntegrationID 7 + 21 STAGE_DDL; 4 mappings (IDs 8–11) enabled; both org DBs have int_growyze001 (13 DL) + int_mews001 (21 DL). `DatabaseName`s identical to UAT ⇒ **same O10 `kv_prefix` values** (no new handoff). **Remaining: Prod only** (human-run via runner per safety model).
- **2026-07-24 (UAT COMPLETE)** — **All of `02`→`03`→`04` executed on UAT; both Ibis orgs live + mapped.** `02` (org creation) timed out via MCP `execute` (15s request cap) leaving an empty half-built Heathrow DB — recovered by dropping it + deleting the CREATING row, then re-ran `02` via **`Invoke-Sqlcmd` (no 15s cap)**: **Ibis Heathrow = OrgID 20**, **Ibis Gloucester Road = OrgID 21**, both `ACTIVE`, full DB deploy. `03` (also via Invoke-Sqlcmd) created 4 mappings (IDs 31–34), all `IsEnabled=1`/`PENDING`; trigger provisioned `int_growyze001` (13 DL) + `int_mews001` (**21** DL, no DL_CUSTOMERS) in both org DBs — verified. O10 handoff `kv_prefix` values now concrete (above). **Learnings:** org creation MUST use the PowerShell runner, not MCP `execute` (15s cap); `ALTER DATABASE ... SET SINGLE_USER` is unsupported on MI (drop empty DBs directly). **Remaining:** Test + Prod env-prep + provisioning (01→01b→02→03→04, same scripts); hand O10 the mapping.
- **2026-07-24** — **UAT env-prep EXECUTED via the new MCP `execute` tool** (first live write through it). `01` registered **Mews001 = IntegrationID 7** (schema `int_mews001`, type POS; CreateIntegrationSchema 5/5 SUCCESS). `01b` seeded **21** STAGE_DDL rows — **`DL_CUSTOMERS` omitted per GDPR ruling** (Andy), now the permanent shape of `01b` for all envs. UAT is Mews-ready. **`02`→`03`→`04` still blocked on the 2 Ibis GUIDs** (microservice Prod) — not run. Test/Prod env-prep (`01`+`01b`) still to do.
- **2026-07-22 (late)** — **Mews STAGE_DDL extracted + scripted.** DEV came back up; pulled the 22 `int_mews001` STAGE_DDL rows (all `CREATE TABLE DL_*`, ParameterID identity, keys unique) and baked them verbatim into new `01b_seed_mews_stage_ddl.sql` (MERGE on ParameterKey, idempotent; whitespace collapsed, column names byte-faithful to DEV). DEPLOY order now 01→**01b**→02→03→04. **GDPR flag:** `DL_CUSTOMERS` (name/email/phone/address/DOB) is included for DEV parity — delete that VALUES row before running if we want to physically block PII landing for the Ibis orgs (confirm per O14). This clears the STAGE_DDL blocker; only the 2 Ibis GUIDs remain.
- **2026-07-22 (evening)** — **Scripts staged; Andy to run in the morning.** All four `ClaudeDevelopment/ibis-provisioning/` scripts + DEPLOY.txt are committed-ready and reviewed static-clean (no execution possible until GUIDs are in + DEV STAGE_DDL extracted). **Blocking before the morning run:** (1) drop the 2 Ibis GUIDs + names into scripts 02/03/04 (from microservice Prod); (2) extract `int_mews001` STAGE_DDL from DEV and seed it per env (else script 03 halts by design). **Run plan (UAT first):** `01` → seed Mews STAGE_DDL → `02` → `03` → `04`; capture `04` RESULT 3 → paste into Integrations O10 runbook. Prefix **confirmed fixed at `20260722`** (Andy, 2026-07-22) — deterministic, env-independent `kv_prefix`; date-per-env alternative declined.
- **2026-07-22** — **Scoped + scripts authored.** Confirmed live UAT state via MCP: **Growyze001 exists (IntegrationID 5); Mews is NOT registered in UAT** (only Marketman/NCRAloha/TROaP/SurveyHero/Growyze/TBTBookingMetrics); no Ibis orgs (max OrgID 18). DEV + Test MCP were login-down at authoring; only UAT reachable. Decisions taken with Andy: **reuse Prod GUID in all envs · register Mews in UAT now · author all three envs.** Verified SP signatures — key finding: `AddOrganisation.@OrganisationPrefix` is **caller-supplied** (not auto-dated), so fixing it + reusing the GUID makes `DatabaseName`/`kv_prefix` deterministic and env-independent → **O10's blocking input is now resolvable on paper** (handoff table above; GUIDs the only fill-in). Authored `ClaudeDevelopment/ibis-provisioning/` (01 register Mews, 02 add orgs, 03 map feeds, 04 verify+emit O10 rows, DEPLOY.txt). **One open sub-task:** the `int_mews001` STAGE_DDL (DL-table DDL) is not in the release repo — must be extracted from DEV and seeded before mapping to Mews (script 03 guards on it); tracked under O14/Integrations O1. Nothing executed yet — awaiting the 2 GUIDs + Andy running the runners, UAT first.
- **2026-07-22** — Integrations **O10** advanced and is now **blocked on this item**. O10's KV runbook (`Integrations/docs/outstanding/O10-keyvault-runbook.md`) is written and Andrew holds the Growyze creds + Mews API keys, but the KV secret **names cannot be finalised** until O19 assigns each org's identity: the runtime derives `kv_prefix = f"{db_name}-{schema_name}"` (`_`→`-`), and Growyze vs Mews land in **different schemas** (`int_growyze001` / `int_mews001`), so each org has **two** distinct prefixes per env. **This item's deliverable to O10 is that exact mapping** — see handoff note below.

## Pick-up notes (resume here)
- **Get the GUIDs + names first** — from the microservice Prod `Organisations` table (no Prod microservice MCP available here; pull them at execution). There is **no** Prod microservice MCP configured — DEV/TEST/UAT only.
- **Open question — GUID reuse across environments:** confirm whether to use the **same** (Prod microservice) GUID as `@OrganisationCode` in all three BI envs (org identity stable across environments), or pull each environment's own microservice GUID. This decides how the `AddOrganisation` calls are parameterised per env.
- **Order per environment:** ensure Growyze + Mews integrations exist in that env's `core` → `AddOrganisation` (×2) → `MapOrganisationToIntegration` for Growyze then Mews (×2 orgs). Verify schemas provisioned by the trigger before handing to O10.
- **UAT is the near-term critical path** (O8 Marge Brut targets UAT). Test/Prod can follow.
- All state-changing SQL runs via the **PowerShell runners**, executed by Andy — author any helper scripts under `ClaudeDevelopment/`; orgs/integrations added via SPs only.
- Relates to O8 (consumer), O14 (Mews DV), O5/O6 (Growyze), Integrations O10 (KV + loads).
- **Handoff to O10 — capture this per env after provisioning** (2 hotels × 2 feeds × 3 envs = 12 rows): for each org, the `db_name` and the `schema_name` of its Growyze and Mews integrations, i.e. the `org_int` tuple's first two elements. After the trigger provisions the schemas, verify the actual schema names (don't assume `int_growyze001`/`int_mews001` verbatim if the trigger names them differently) and pass them to O10 to fill its runbook mapping table. O10 also wants each hotel's **Growyze org GUID** for the optional `-api-org-filter` secret.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
