# O1 — XMSE-944: MarketMan load failure (dup INVITEM_IDs) + fix scripts not deployed

> Detail file for ledger item **O1**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | MONITOR — dup-PK root cause gone (0 dupes); DEV pipeline dormant since ~Mar 10 |
| **Area** | MarketMan / Data Vault load |
| **Owner / decides** | Andy |
| **Next action** | Deploy the 11 MarketMan fix scripts to DEV in order, then re-run DV load and verify |
| **Sources** | `memory/xmse-944-investigation.md`, `memory/marketman-audit.md`, `docs/data-vault-reference.md` §8, `ClaudeDevelopment/integrations/MarketMan/`, [XMSE-944](https://threerocks.atlassian.net/browse/XMSE-944) |

## Context
27 duplicate `INVITEM_ID`s arise from a cross-branch `UNION ALL` in the MarketMan staging, causing a PK violation that fails **all** DV loads. Consequence: MarketMan DV has been stale since **Feb 3**, and NCRAloha DV loads have been blocked since **Mar 11** (shared load run aborts). Fix = dedup category rows in `DL_INVENTORY_ITEMS` + `DL_INVENTORY_PREPS`, plus deploy audit scripts + `UploadEntityMappings`.

11 fix scripts exist in `ClaudeDevelopment/integrations/MarketMan/`. **Verified 2026-03-11: not deployed to DEV, and not in the core DB either.**

## Progress log
- **2026-03-11** — Root cause diagnosed; 11 fix scripts authored. Confirmed not deployed anywhere.
- **2026-07-02** — Logged to ledger from memory.
- **2026-07-02 (DB audit, DEV `xms-mssqlman-ne-dev`)** — Dup INVITEM_IDs = **0**, not 27: Three Rocks Cafe `DL_INVENTORY_ITEMS` 6,296 rows / 6,296 distinct; `DL_INVENTORY_PREPS` 180/180. Kudu DL tables now empty. The dup-PK root cause no longer exists. DV freshness: MarketMan `SAT_INVITEM` max LOAD_TS **2026-03-10** (not frozen at Feb 3 as claimed); NCRAloha `SAT_LINEITEM` max LOAD_TS 2026-03-10. Last DL fetch LOADTS_UTC 2026-04-24 then stopped. Kudu DV never populated (0 rows). **Whole DEV pipeline appears dormant since ~Mar 10** — can't distinguish "load job disabled" from "failing" on DEV. Verdict: PARTIALLY-RESOLVED — the specific bug is gone; residual concern is DEV dormancy, which may just mean DEV is retired in favour of UAT.
- **Stale-memory flag:** the audit found DEV now carries the `C14CF568-588D-…` / `5AD1BEAC-31FD-…` GUIDs that memory lists under *UAT*. The DEV org GUIDs in `MEMORY.md` Test Organisation Reference look out of date.

## Pick-up notes (resume here)
- Deploy order: **C1 → C3 → H7 → C5 → C6 → H2 → C2 → C9 → XMSE944** (XMSE944 supersedes H5 + C10).
- Read `memory/xmse-944-investigation.md` and `memory/marketman-audit.md` first for full script-by-script detail.
- Before deploying, re-check current DV freshness (MarketMan + NCRAloha) — it's been months; state may have changed.
- Don't mark Closed until the user confirms.
