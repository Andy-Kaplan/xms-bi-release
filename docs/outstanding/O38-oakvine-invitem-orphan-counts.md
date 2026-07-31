# O38 — 95% of Oak & Vine's inventory count rows have no `D_INVITEM` row, so item-level inventory cards show ~5% of the data

> Detail file for ledger item **O38**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — measured on Oak & Vine and confirmed absent on the other four orgs; root cause not traced |
| **Priority** | 2 |
| **Area** | Presentation / `D_INVITEM` build vs `F_INV_COUNTS_DAY` |
| **Owner / decides** | Andy |
| **Next action** | Establish which source's inventory items are missing from `D_INVITEM` on Oak & Vine (the org carries **Growyze and MarketMan**, and only 465 + 468 count rows resolve), then trace whether the `Inventory Item Dimension` build step excludes them or whether the hubs genuinely never reached the Data Vault |
| **Found by** | [O5](O5-growyze-default-dashboards.md) Plan 3's shared-dataset audit, 2026-07-31 |
| **Related** | [O24](O24-oak-vine-growyze-mews-mapping.md) (Oak & Vine's multi-integration shape), [O23](O23-growyze-supplier-bottom-level.md) (a dimension anchor matching nothing — same class), [O5](O5-growyze-default-dashboards.md) |

## What's wrong

On **The Oak & Vine (16)**, `presentation.F_INV_COUNTS_DAY` holds **19,185** rows. Of those:

| Category | Rows | Share |
|---|---|---|
| Resolve to a `D_INVITEM` row — `int_growyze001` | 465 | 2.4% |
| Resolve to a `D_INVITEM` row — `int_marketman001` | 468 | 2.4% |
| **`INVITEM_HUB_ID` with NO matching `D_INVITEM` row** | **18,252** | **95.1%** |

**These are not the sentinel.** A direct count of
`INVITEM_HUB_ID = CONVERT(BINARY(32), -999)` returns **0** on this org, so these are real hub
ids for which the dimension simply has no row — a different failure from
[O36](O36-growyze-purchases-no-location.md)'s unresolved-key sentinel.

The same check on the other four Growyze orgs returns **0 orphans** (Padel 8,083 rows all
resolve, Dirty Sixth 1,335, Heathrow 178, Gloucester 308). **Oak & Vine is the only affected
org measured so far** — but it is also the only one of the five carrying two inventory sources,
which is the obvious place to look. Worth checking the non-Growyze orgs too.

## Why it matters

Every item-level inventory card inner-guards on the dimension. `InvUseAnalisys` carries
`AND invitem.BOTTOM_INVITEM_NAME IS NOT NULL` after a `LEFT JOIN` to `D_INVITEM`, so on Oak & Vine
that grid silently shows **933 of 19,185 count rows — about 5%**. `InvKPIGrouped` and
`InvStockActivity` read `F_INV_USAGE_DAY`, which shows the same shape there (105,330 of 113,411
usage rows have no `D_INVITEM` match).

The card does not error, does not warn, and does not look empty — it looks like a short but
plausible list. That is the dangerous part: a grid showing 5% of the data is far harder to spot
than one showing none.

## Why it was invisible until now

The orphan rows are excluded by the *card*, not by the fact, so any check that counts what a card
**returns** sees a clean, non-zero result. It only surfaces by comparing the fact's row count
against the dimension-resolvable subset — reading the output and the input, not just the output.

This is the third time on this workstream that a Growyze/multi-source dimension key has failed to
resolve and taken a measure with it (O23 suppliers, O36 purchase locations, now O38 inventory
items). Worth asking whether the three share an upstream cause in the dimension build rather than
fixing each in isolation.

## Notes for whoever fixes it

- First split the 18,252 orphans by whatever source signal is available upstream
  (`datavault.SAT_INVITEM.SRC` / the hub's record source). If they are all one integration, the
  question is why that integration's items never reached `D_INVITEM`.
- Check the `Inventory Item Dimension` step in `8_PresentationControl.sql` for a `BOTTOM_LEVEL = 1`
  style anchor — that is precisely the pattern that made **O23** drop every Growyze supplier, and
  a multi-source org is where such an anchor breaks first.
- Do **not** "fix" this by relaxing the `BOTTOM_INVITEM_NAME IS NOT NULL` guard on the cards. That
  would replace a short grid with a grid full of unnamed rows; the dimension is what needs the rows.
- Verify any fix on **Oak & Vine** — the other four orgs return 0 orphans and therefore cannot
  detect this. It is the same lesson as `memory/feedback_degenerate_acceptance_org.md`: pick the org
  whose data shape can exercise the defect.
- Don't mark Closed until the user confirms.
