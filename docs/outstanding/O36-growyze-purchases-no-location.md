# O36 — Most Growyze purchase lines carry no location, so deliveries can't be analysed per venue

> Detail file for ledger item **O36**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — quantified across all five Growyze orgs; root cause not yet traced past presentation |
| **Priority** | 2 |
| **Area** | Growyze staging / `F_PURCHASES_DAY` |
| **Owner / decides** | Andy |
| **Next action** | Trace why the stock-order staging leaves `LOCATION_HUB_ID` unresolved on most purchase lines — is the location absent from Growyze's `DL_STOCKORDER`/delivery-note payload, or present but unmapped? Then decide whether per-venue delivery analysis is achievable or should be dropped from the dashboards |
| **Found by** | [O5](O5-growyze-default-dashboards.md) Plan 2 Task B, 2026-07-31 — a planned `location <> 'Unknown'` guard silently destroyed 60% of the measure |
| **Related** | [O5](O5-growyze-default-dashboards.md), [O23](O23-growyze-supplier-bottom-level.md) (the same class: a Growyze dimension key not resolving) |

## What's wrong

`presentation.F_PURCHASES_DAY` rows carry the `CONVERT(BINARY(32), -999)` location
sentinel — meaning the purchase line resolved to **no venue at all** — on a large share
of lines, across every Growyze org:

| Org | Growyze purchase rows | Unattributed (sentinel) | Share of rows | Value unattributed |
|---|---|---|---|---|
| Padel Social (10) | 1,796 | 109 | 6% | £2,339.81 |
| The Oak & Vine (16) | 2,200 | 271 | 12% | — |
| **Dirty Sixth (18)** | 2,141 | **1,160** | **54%** | **£40,694.37 (60% of value)** |
| Ibis Heathrow (20) | 2,335 | 201 | 9% | — |
| Ibis Gloucester Road (21) | 2,200 | 271 | 12% | — |

The unattributed lines are **not** junk and not confined to a bad period — on Dirty
Sixth they span the fact's entire range, 2024-12-29 to 2026-07-28.

## Why it matters

It is easy to turn this into a wrong number without noticing. Every sales card in the
pack carries `AND location.[BOTTOM_LOCATION_NAME] <> 'Unknown'`, and Plan 2 rev 1
copied that guard onto the Deliveries KPI. On Dirty Sixth that made the card read
**£27,554.02 instead of £68,248.39** — reporting 40% of actual delivery spend under a
label that says "Deliveries". Nothing errored; the number was simply wrong.

`GrowyzeDeliveriesValue` (`reporting_queries/43_growyze_deliveries_value.sql`)
therefore deliberately omits the location guard, and its header explains why at
length so nobody "tidies" it back in. The `location` alias is still joined so the
Locations filter binds — filtering to a named venue correctly excludes the sentinel
rows, because that is a deliberately narrowed view rather than the headline figure.

**The consequence that remains:** deliveries **cannot** be broken down by venue for
most of Dirty Sixth's spend. Any future per-venue purchasing card will be materially
incomplete on that org, and will look precise while being wrong.

## Notes for whoever fixes it

- Start at the staging step that builds the stock-order/delivery lane and check
  whether Growyze's payload carries a location per order line at all. If it does not,
  this is a fetcher/API-scope question rather than a mapping bug.
- This is the same shape as [O23](O23-growyze-supplier-bottom-level.md), where Growyze
  suppliers never got a `BOTTOM_LEVEL` and so no supplier row reached `D_SUPPLIER`.
  Worth checking whether both share an upstream cause in the Growyze dimension build.
- **Do not "fix" this by re-adding the location guard to the Deliveries card.** That
  hides the gap by discarding the money.
- `99_verify_plan2.sql` check **B2** reports the guarded vs unguarded totals and the
  unattributed row count per org, so the size of this gap is visible on every run.
- Don't mark Closed until the user confirms.
