# O16 — UAT hygiene: three defects surfaced by the Prod deploy

> Detail file for ledger item **O16**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DIAGNOSED |
| **Area** | UAT / deployment tooling |
| **Owner / decides** | Andy |
| **Next action** | Run `prod-baseline/96_fix_globalparameters_widths.sql` on UAT core + `CREATE OR ALTER` UAT's `sp_CreateIntegrationTables` with the patched widths (baseline `5_CreateIntegrationTables.sql` has the corrected definition). Then the two smaller fixes below. |
| **Sources** | `releases/v1.0-baseline/BASELINE_NOTES.md` §"2026-07-06 Prod deployment record" (defect list) · `ClaudeDevelopment/prod-baseline/96_fix_globalparameters_widths.sql` · QUERY_STATUS §91 |

## Context

The 2026-07-06 Prod deployment surfaced three latent UAT defects. All are **fixed or worked around on Prod**; UAT still carries them, and two will regress the next baseline regeneration if left:

1. **GlobalParameters widths (regen-regression risk — do first).** UAT's `sp_CreateIntegrationTables` creates `int_*.GlobalParameters` narrower than UAT's own tables (ParameterKey 100 vs 200, **ParameterValue 4000 vs MAX**, Category 50 vs 100, Description 500 vs 1000, CreatedBy/ModifiedBy 100 vs 200) — the tables were widened manually at some point, the SP never was. On a fresh instance the Growyze `DL_DISHES` DDL truncates (Msg 2628). Additionally `int_ncraloha001.GlobalParameters.ParameterValue` on UAT is *still* 4000 — one oversized NCRAloha DDL away from the same failure. **Fix:** run 96 on UAT (widen-only, idempotent) + apply the SP patch on UAT. Until the UAT SP is fixed, every baseline regen re-extracts the narrow definition.
2. **DDL extraction not re-runnable.** `01_extract_core_ddl.ps1` guards `CREATE TABLE` with `IF NOT EXISTS` but emits DEFAULT-constraint ALTERs unconditionally — re-running `2_CoreTableCreateScripts.sql` / `7_Dynamic Suggestion Tables.sql` on an existing DB fails (Msg 1781). Violates the release-guide idempotency requirement; harmless on first run. **Fix:** guard constraint ALTERs in the extractor, regen, spot-check.
3. **RuleOverrides DeploymentObjects record (benign noise).** Its CreationScript ends with a stray `ALTER TABLE [core].[RuleExecutionState] ADD DEFAULT (getdate()) FOR [UpdatedDate]`, duplicating RuleExecutionState's own default — every org provisioning logs `ERROR | TABLE | RuleOverrides` while leaving a fully correct end state (verified on Prod). Same noise on UAT since 2026-02-11. **Fix:** remove the stray ALTER from the record on UAT core (and it flows into the next regen).

## Progress log
- **2026-07-06** — All three found during the Prod deploy. #1 fixed on Prod (18 columns altered, SP patched in the baseline); #2 worked around by resuming past re-run steps; #3 verified benign on Prod by catalog inspection.

## Pick-up notes
- 96 is safe on UAT: widen-only, skips MAX, no data change. The SP patch is in `releases/v1.0-baseline/5_CreateIntegrationTables.sql` (GlobalParameters block).
- After #1 and #3 land on UAT, re-run the baseline regen to confirm the extracted files pick up the corrected SP and clean record.
