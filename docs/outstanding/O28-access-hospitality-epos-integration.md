# O28 — Access Hospitality EPOS integration feasibility (Maker's of Hospitality critical path)

> Detail file for ledger item **O28**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Priority** | 2 |
| **Area** | Integrations / Access Hospitality EPOS |
| **Owner / decides** | Andy (technical feasibility) · Kerri + Scott (roadmap decision) |
| **Next action** | Obtain Access API documentation and assess it; report effort back into [O27](O27-makers-of-hospitality-discovery.md) by **w/c 2026-08-03** |
| **Sources** | Discovery call 2026-07-30, screen-share walkthrough 3:42–28:09 and 33:46–34:00; Andy's commitment at 36:03–36:45 |

## Sub-tasks
| # | Status | Task | Note |
|---|--------|------|------|
| 1 | OPEN | Find out whether Access publishes API documentation, and whether it's obtainable without a partner agreement | Andy in-call: *"Access, I need to have a look at and see how easy it is to get hold of their API documentation"* |
| 2 | OPEN | Have Bex sponsor the approach before contacting Access | Kerri's action — a client-initiated request is a materially easier path than TR cold-calling |
| 3 | OPEN | Confirm which Access Hospitality product/module this is | "Access" is used loosely in the call for the EPOS; the group sells several products (and **Acteol**, their CRM, is also Access Group) |
| 4 | OPEN | Assess endpoint coverage against the 9 data domains below | Determines whether this is one integration or a staged set |
| 5 | OPEN | Confirm line-item-level availability | Andy committed to *"literally line item level"* capture; the platform's `LINEITEM_*` model depends on it |
| 6 | OPEN | Confirm the annual budget upload is extractable | Andy told Bex we should be able to read budgets straight from Access rather than have them re-keyed — **stated as an assumption in-call, not verified** |
| 7 | OPEN | Map each domain onto existing DV entities and flag genuine gaps | Most should land on existing POS + inventory entities; budgets and recipes are the likely gaps |
| 8 | OPEN | Size the work and feed the roadmap decision back to Kerri + Scott | Access is **not** on the current integration list — this is a commercial call as much as a technical one |

## Context

### Why this is the critical path
Access is the centre of gravity for this prospect. Nine distinct data domains sit inside it, and if it can't be reached, most of what was discussed in the call becomes unbuildable:

| # | Domain | Detail seen on screen | Likely DV / presentation home |
|---|---|---|---|
| 1 | **Sales** | Daily "business sheet"; weekly close with sales vs budget vs last year; food/drink split | `LINEITEM` (`PROD`), `F_LINEITEM_15MIN` |
| 2 | **Budgets** | Loaded once a year, manually, into Access | ⚠️ **Likely gap** — no budget entity exists today; cf. `FORECAST_ACTUALS_BASE` |
| 3 | **Comps, discounts, staff meals** | Complimentaries and adjustments each have their own till buttons and reports | `LINEITEM_TYPE` = `DISCOUNT` / `SVC`; `D_DISCOUNT` — ⚠️ see [O25](O25-d-discount-microservice-id-typing.md) |
| 4 | **Waste** | Recorded at the till, plus a waste report in Access | `STOCKEVENT` `EVENT_TYPE = 'WASTE'` |
| 5 | **Stock** | Weekly (Monday) wet stock take, wet deliveries, inter-site transfers, variance + GP report | `STOCKEVENT` `COUNT` / `ORDER` / `TRANSFER`; `F_INV_COUNTS_DAY` |
| 6 | **Products** | Full wet **and** food product list with prices, maintained by hand | `HUB_PRODUCT` / `HUB_INVITEM`, `D_PRODUCT` / `D_INVITEM` |
| 7 | **Recipes** | Dish costing — build a recipe, get food GP per dish | ⚠️ Partially novel; closest existing work is the MarketMan recipe-cost lane |
| 8 | **PLU sales** | Item-level sales reporting (cauliflower cheese, steak & frites) | `F_PRODUCT_MARGIN_DAY` |
| 9 | **Cash** | Daily cash discrepancy tracking | No existing entity — low priority, not asked for |

Domains 1, 3, 4, 5, 6 and 8 should land on existing entities with no model change. **Budgets (2) and recipes (7) are the two genuine gaps** and should be called out separately in any estimate.

### Known limitations of Access as the incumbent
These are the specific frustrations the integration is expected to remove, and they're worth keeping in the proposal because each is trivially solved once the data is in the warehouse:

- **No date filter — week granularity only.** Bex: *"There's no way of adding a date filter. You just have to choose the week."* Answering "what did we do the second week of last January?" or "how was Father's Day?" means working out which week that was and navigating there. Andy called this out in-call as *"very easily achievable with XMSBI"*.
- **Per-site switching.** Every view is one pub at a time. The platform's parent → child org hierarchy plus per-GM access control answers this directly ([O4](O4-parent-org-1011.md)).
- **Prices maintained by hand**, hence the price-drift blind spot ([O30](O30-invoice-ingestion-price-drift.md)) and stale recipe costs.
- **Near-duplicate products** — several semi-skimmed milks at different prices from different suppliers, some obsolete, with no indication of which is most purchased. This is the same defect class as [O7](O7-xmse949-product-cost-matching.md) / [O10](O10-threerocks-sales-double-count.md); read those first. Note Bex's own proposed fix — *"if I knew which was the most bought product, I could just pick that for the recipe"* — which is a **purchase-frequency-ranked product resolution** and is straightforward once purchase data is in the warehouse.

### Commercial position (verbatim substance, 36:03–37:15)
Andy was deliberately honest with Bex that Access is not currently supported: *"because access isn't currently on that integration list, we'll have to have a look and see sort of how much time really that's going to add."* He also set the expectation that *"most of that time is going to be down to the supplier and our actual technical journey is very quick on the integration side of things"* — i.e. the risk is vendor cooperation, not our build.

Kerri added the mitigation: if Bex tells their Access contact that Three Rocks needs access, the path is *"normally a lot easier… rather than just them thinking a random guy is trying to get in."*

**By contrast, S4 Labour is already partly known** — Andy: *"I'm aware of the S4 API, so we've done a little bit of work with that"* ([O29](O29-makers-secondary-source-assessment.md)). If Access proves slow, S4 may be the faster first win.

## Progress log
- **2026-07-30** — Raised from the discovery call. No technical work started; no vendor contact made. Andy committed in-call to investigating the API documentation and reporting back before the w/c 2026-08-03 response.

## Pick-up notes (resume here)
- **Do not contact Access before Bex has sponsored it** (sub-task 2) — Kerri owns that trigger and it materially changes the reception.
- The honest framing for the estimate is two-part: *technical build* (fast, well-trodden — five integrations already follow the `_INIT`/`_DDL`/`_Staging`/`_Mapping`/`_Final` pattern) versus *vendor access* (unknown, and the real risk). Don't blend them into one number.
- Read [O7](O7-xmse949-product-cost-matching.md) and [O10](O10-threerocks-sales-double-count.md) before designing product/recipe cost handling — the duplicate-product and stale-cost problems here are already-known platform problems, not new ones.
- Budgets and recipes are the two domains needing new modelling. Everything else maps onto existing entities.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
