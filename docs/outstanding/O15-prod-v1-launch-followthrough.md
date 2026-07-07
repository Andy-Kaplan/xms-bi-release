# O15 — v1.0 Prod launch: deployed + validated, follow-through remaining

> Detail file for ledger item **O15**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Area** | Release / Prod launch |
| **Owner / decides** | Andy |
| **Next action** | Merge PR #2, then promote `releases/v1.0-baseline/` to the repo root (master files + snapshot in one commit) and tag `v1.0-baseline`. Then: provision real Prod orgs (SPs only), stand up the Prod report DB config, point fetchers at Prod. |
| **Sources** | `ClaudeDevelopment/prod-baseline/VALIDATION_RUNBOOK.md` (executed, template) · `releases/v1.0-baseline/BASELINE_NOTES.md` §"2026-07-06 Prod deployment record" · PR #2 (`feature/v1.0-baseline-refresh`) · `docs/release-guide.md` §6 "Execution Method: PowerShell Runners" · Memory: `memory/prod-v1.0-deployment.md` |

## Context

The v1.0 baseline (regenerated from UAT 2026-07-06, MargeBrut excluded, TBTBookingMetrics held, UAT casing kept) was **deployed to the Prod MI (`xms-mssqlman-ne-prod`) on 2026-07-06** via the PowerShell runner and fully validated: 39/39 scripts, core validation 30/30 PASS, five BaselineTest orgs provisioned, per-org parity 60/60 PASS, cleanup complete (0 VALTEST DBs remain). Prod holds a pristine `core` DB and no organisations.

Remaining to make the launch real:

1. **Merge PR #2** (baseline regen + rulings + validation kit + width fix + docs).
2. **Promote to root + tag** — copy `releases/v1.0-baseline/` over the root master files in a single commit, tag `v1.0-baseline` (per BASELINE_NOTES §Promoting to root). Also refresh CLAUDE.md's stale counts (109 vis queries / 5 integrations / 22 steps → baseline reality).
3. **Provision real Prod organisations** via `core.AddOrganisation` + `core.MapOrganisationToIntegration` (SPs only, never direct INSERT).
4. **Prod report DB** (Azure SQL, separate server) — dashboard config (`BiConfiguration`, `VisualisationConfig`, `VisualisationDataSetMap`, palettes) has **no prod extraction artefact yet**; needs extracting from the UAT report DB.
5. **Fetchers/Azure Functions** — point integration fetch configs at the Prod orgs; exclude the Mews customers endpoint (GDPR, see O14).
6. Optional deferred: data-slice load-cycle test was skipped at sign-off (schema-level validation deemed sufficient); first real org's first load is the de-facto test — watch it.

## Progress log
- **2026-07-06** — Baseline regenerated from UAT (only drift: 9 MargeBrut demo queries; excluded via extraction filter). Decision points resolved (MargeBrut EXCLUDE / TBT HOLD / casing KEEP). Validation kit built (90-96). Deployed to Prod: halted once at step 26 (GlobalParameters widths, see O16), fixed + resumed; 30/30 + 60/60 PASS; test orgs cleaned up. PS1-runner method documented in CLAUDE.md + release-guide §6 as the house method.

## Pick-up notes
- Deploy runner + validation scripts: `ClaudeDevelopment/prod-baseline/90-96`. Prod env vars are set on Andy's workstation (User scope, `XMS_BI_MANAGED_PROD_*`).
- The promote-to-root commit will show a large diff (upsert-pattern 8_ files replacing bare-INSERT originals + line-ending normalisation) — content was validated against Prod, review with whitespace off.
