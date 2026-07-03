# O14 — Mews001 DV mapping: scripts built + reviewed, deployment pending

> Detail file for ledger item **O14**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Area** | Integrations / Mews POS (ex-Bizon) / DV mapping |
| **Owner / decides** | Andy |
| **Next action** | Deploy per `ClaudeDevelopment/integrations/Mews/DEPLOY.txt` (01→02→03 vs core, then `sp_DataVaultLoad @SchemaList = N'int_mews001'` in org 19), then hand back for MCP post-load verification (04 sections B–E) |
| **Sources** | Spec: `docs/superpowers/specs/2026-07-03-mews-dv-mapping-design.md` · Plan: `docs/superpowers/plans/2026-07-03-mews-dv-mapping.md` · Scripts: `ClaudeDevelopment/integrations/Mews/` (01–04 + DEPLOY.txt) · QUERY_STATUS.md §Mews · Memory: `memory/bizon-integration.md` |

## Context

The Bizon integration (April 2026 design) deployed as **Mews001 / `int_mews001`** (IntegrationID 8), with real data landed in DEV org 19 "Three Rocks Hotel" (`20260413_XMS_B4E2F7A8-3C91-4D6E-9F05-8A1D2B5E7C43`). This item takes that landed data into the Data Vault: 17 staging steps + 25 entity mappings + generated Load steps, all against existing Live entities (no DDL, no new entities).

Key design decisions locked during the build:
- **Product hierarchy:** types=TOP, products=MIDDLE_1, variants + synthetic `{productId}-DEFAULT` rows=BOTTOM; line-item key `COALESCE(productVariantId, CONCAT(productId,'-DEFAULT'))` resolves 100% of sale lines.
- **DISCOUNT/REVCENTER hubs include inactive members** (review-caught orphan-link prevention — links carry keys regardless of active status). TENDER/CHANNEL still filter; revisit CHANNEL when a CHANNEL_CUSTORDER link is added.
- **Single-tax assumption:** invoice items carry no tax id; all TAX lines link to the sole tax profile; verification guards >1 active tax.
- **Deferred (no source / no data):** BOOKING entities, TENDER lines, MOD lines + LINEITEM_LINEITEM, SVC, CHANNEL_CUSTORDER link.

Known source-data gaps (not bugs; flag to fetcher team): 5/6 payment methods have NULL name (blank TENDER_NAME members); variants have no selector/sku/barcode (names synthesized as `{product} @ {price}`); no customer address data (MEWS_ADDRESS = 0 rows); area "Rooms" inactive (CHANNEL = 1 member).

## Progress log
- **2026-07-03** — Spec approved (rev §2a), plan written, all 7 tasks executed via subagent-driven development (Sonnet 5 workers). Commits `86a1cca..12cfe41` on `prod-baseline-regen`. Every staging query MCP-verified against org 19 live data pre-deployment. Per-task reviews + final whole-branch review: READY TO DEPLOY. Three review-caught fixes: orphan-link filter asymmetry (3e554ea), commit-scope contamination of user's uncommitted QUERY_STATUS edits (history split, 5cf9036), drift-fragile verification literals → DL-derived (c65e107, 12cfe41). Live baselines recorded in QUERY_STATUS §Mews (CUSTORDER=19, LINEITEM PROD=22/5 void, TAX lines=17, PRODUCT=389, CONTACT=257…). Deployment NOT yet run.

## Pick-up notes (resume here)
- Developer runs DEPLOY.txt steps 1–4 (SSMS; scripts are idempotent MERGE upserts; rollback = exclude/is_active flags, no DDL).
- Then Claude runs `04_verification.sql` sections B–E via MCP (org-prefixed, comments stripped) — expected values are largely DL-derived; Section A should then read 17/25/25.
- On PASS: flip QUERY_STATUS §Mews rows to "deployed to DEV — verified {date}", update this item + memory. SDD execution ledger (recovery map with all commit SHAs): `.superpowers/sdd/progress.md`.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
