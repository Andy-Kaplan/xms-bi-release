# O27 — Maker's of Hospitality: discovery follow-through + source-system assessment

> Detail file for ledger item **O27**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Priority** | 2 |
| **Area** | Pre-sales / prospect discovery |
| **Owner / decides** | Andy (technical) · Kerri + Scott (commercial) |
| **Next action** | Assess the 6 source systems (O28 + O29), agree scope with Kerri/Scott, revert to the prospect **w/c 2026-08-03** with next steps + a follow-up meeting booked |
| **Sources** | Discovery call 2026-07-30 14:02, 46m32s — `three rocks x Makers of Hospitality-20260730_150257-Meeting Recording` (transcript + video). Attendees: Kerri Roberts, Scott Muncaster, Andrew Kaplan (Three Rocks); "Bex" (owner, Maker's of Hospitality) |

## Sub-tasks
| # | Status | Task | Note |
|---|--------|------|------|
| 1 | OPEN | Pull screenshots from the recording at the 17 timestamps listed below | Screen share runs 3:36–~34:00; without stills the transcript loses every on-screen artefact |
| 2 | OPEN | Confirm exact product identities before approaching any vendor | "Access" = Access Hospitality EPOS; "Actio" = **Acteol** (also Access Group); "Toggle" and "Collins" need confirming — see Open questions |
| 3 | OPEN | Access EPOS feasibility — the critical path | → [O28](O28-access-hospitality-epos-integration.md) |
| 4 | OPEN | Secondary sources: S4 Labour, Collins, Toggle, Wireless Social, Acteol | → [O29](O29-makers-secondary-source-assessment.md) |
| 5 | OPEN | Decide with Kerri + Scott whether Access goes on the integration roadmap, and at what cost | Andy flagged in-call that Access is **not** on the current integration list, so this is a commercial call, not just technical |
| 6 | OPEN | Ask Bex to sponsor the vendor approach ("tell Access to give Three Rocks access") | Kerri's action to trigger; warmer path than TR cold-approaching the vendor |
| 7 | OPEN | Map Bex's stated needs onto **existing** platform capability before proposing anything new | Several are already built or in flight — see Reuse opportunities. Materially changes the effort estimate |
| 8 | OPEN | Produce the next-steps proposal and book the follow-up | **Committed to w/c 2026-08-03** — the only hard external deadline on this item |

## Context

### The business
Independent, quality-led gastro pubs run by Bex and their wife, both ex-**Peach Pubs** (10 years). Two sites, same suppliers and same systems, each with a GM who runs it day to day while the owners stay hands-on:

| Site | Opened | Character | Mix | Walkable catchment | GM |
|---|---|---|---|---|---|
| **The Wildmoor** | ~2024 (2 yrs) | Country destination — guests drive, stay ~2 hrs, three courses, leisurely | **65–70% food-led** | ~400 | Emma *(inferred)* |
| **The Plough** | Sept 2025 | Town, relaxed, tables not laid up, high walk-in trade, pints + snacks/burgers | **60–70% wet-led** | ~10,000 | Nick *(inferred)* |

Site names spelled inconsistently by the transcriber ("Wild Moor Road", "Wildmore", "Wild Mower"); a supplier named **Worcester Produce** and Scott's remark that the footfall-tracking contact is "just down the road from you" both point to Wildmoor, Worcestershire. Confirm the trading names before anything client-facing.

**Guest crossover is confirmed and matters commercially:** when the Plough opened they were surprised how many customers already knew them from the Wildmoor, and they now see guests come to the Wildmoor for a Saturday-night birthday then drop into the Plough midweek for a pint. Bex's phrase: *"we do cross-pollinate our guest base."* Cross-site guest analytics is therefore a real ask, not a hypothetical.

### The problem being bought
A **~2-hour manual data-assembly job every Monday morning**. Each GM pulls a weekly roundup from four or five systems plus a spreadsheet; the owners then sit down with them to review last week and look ahead. Bex's framing, and the thing that stood out when they first heard Scott and Kerri: the information is valuable and the meeting is important, but *"they could be doing more valuable stuff rather than pulling all this data and presenting it on a Monday."*

Bex's own stated destination: **see the management-accounts-level picture weekly rather than monthly**, in one place, without the go-here-then-go-there.

### Systems inventory (6 systems + 2 spreadsheets)
| # | System | Role | What it holds |
|---|---|---|---|
| 1 | **Access** (Access Hospitality EPOS) | EPOS — the centre of gravity | Daily "business sheet" (sales vs budget vs last year), annual budget upload, food/drink split, complimentaries, adjustments/discounts, staff meals, waste, cash discrepancies, wet stock takes + deliveries + transfers + variance/GP reports, full wet **and** food product list with prices, recipe/dish costing, PLU sales |
| 2 | **S4 Labour** | Rotas + time & attendance | Rota build, clock in/out with manual approval, weekly forecast entry (split food/drink), labour %; **sales feed in daily from Access** |
| 3 | **Collins** | Bookings | Heads-in by session and site, tags/labels workflow (e.g. "await pre-order", deposit needed at 10+), deposits via payment link |
| 4 | **Toggle** | Gift vouchers | Voucher sales; accountant pulls monthly |
| 5 | **Wireless Social** | Guest Wi-Fi | Arrival + departure times, returning-customer recognition, categorisation, booking data. Scott rates them *"one of the good guys"* on data availability |
| 6 | **Acteol** ("Actio") | CRM + email marketing | Guest data still being collected, but **dormant** — one send in Jan 2026, none since; social media is their actual channel |
| 7 | *Food invoice spreadsheet* | Manual | Date / supplier / invoice value, keyed daily from **printed invoices on a clipboard**, plus predicted weekly food sales → food budget → daily spend allowance |
| 8 | *Owner's spreadsheet* | Manual | Weekly sales figure, forecasting + P&L for the accountant, quick vs-last-year/budget check |

### Blind spots Bex named unprompted
1. **Supplier price movement — "a complete blind spot."** Prices in Access are updated by hand, so they only learn of a rise if the supplier mentions it or someone checks a product. Bex on the ideal: *"if I could look at a report and it showed that the price had moved, I would then either be able to go back to the supplier or update it in the system."*
2. **Recipe costing built on stale, ambiguous product data.** Dishes are costed before going on the menu, but the product list carries many near-duplicates (*"semi-skimmed milk, there's one, two, three… so many"*) at different prices from different suppliers, some obsolete. Bex defaults to the most expensive and notes a price *"might be six months out of date."* Critically: *"I don't know necessarily which one is the most bought product, because if I did, I could probably just pick that for the recipe."*
3. **Food GP continually missed** — invoice-level reconciliation is manual, so causes surface late or not at all. The worked example: a 5-litre mayonnaise ordered Tuesday and another Wednesday because one person didn't know the other had ordered it. Currently over the (admittedly generous) food budget by roughly **£1,000/week**.
4. **Gift voucher liability unknown** — *"another massive blind spot."* Cannot say how many vouchers were sold in 12 months, how many expired, or how many remain live. Scott flagged the year-end tax/liability angle.
5. **Spend per head is not trustworthy** — a walk-in drinker counts as a cover but isn't dining, so SPH is diluted. Bex wants covers on **food-bearing bills only**. Consequently they cannot answer the question that actually matters when the management accounts show £10k down on last year: *is that cover decline or spend-per-head decline?* → [O31](O31-dining-covers-spend-per-head.md)
6. **No date filter in Access** — week-granularity only. To see the second week of last January, or Father's Day, they must work out which week that was and navigate to it.
7. **Constant switching between the two pubs** — every check is per-site, per-day, by hand; done only a couple of times a week as a result.
8. **PLU-level stock-out prevention is manual** — ran out of cauliflower cheese at 16:00 one Sunday; the fix is knowing they sell 50 on a busy day (and ~30 steak & frites on the Wednesday promo), but pulling that is a Monday job Bex does *"sometimes… sometimes I don't because I've run out of time."*

### What Andy positioned in-call
Central standardised model, all sources in one place; line-item-level POS capture; **parent → child org hierarchy** for the two pubs with per-GM access control so Nick can't see the Plough's… (i.e. each GM sees only their own site); pre-curated datasets and bespoke dashboards built by TR rather than self-serve measure-building; daily loads as standard with 15-minute capability; rule-driven notification banners (worked example: booking spike not reflected in the labour forecast); flat-file/email ingestion **in progress** for the emailed invoices; budgets extractable from Access directly so nobody re-keys them.

Andy also flagged **GDPR on the labour feed** and got agreement in the room — see [O29](O29-makers-secondary-source-assessment.md), where that ruling is recorded.

### Reuse opportunities — check these before estimating
Much of what Bex asked for already exists on this platform, which should pull the estimate down sharply:

- **Weekly food GP / cost-of-sales dashboard** — this is very close to the **Marge Brut** dashboard now live and verified on two UAT orgs ([O8](O8-marge-brut-dashboard.md)): turnover, consumption, cost %, GP %, purchases by supplier, filterable by date and F&B group.
- **Parent/child site rollup with per-site access** — the parent-org reporting work is deployed and "Group Overview" is live for a real org ([O4](O4-parent-org-1011.md)).
- **Stale/ambiguous product costs** — the duplicate-product and stale-price problem is *the same class of defect* as [O7](O7-xmse949-product-cost-matching.md) / [O10](O10-threerocks-sales-double-count.md) (product cost matching, ~95% NULL cost map and ~1.5× fan-out). Worth reading those before designing anything for Maker's.
- **Inventory variance + GP** — [O2](O2-inventory-variance-1315.md), [O5](O5-growyze-default-dashboards.md), [O6](O6-growyze-reporting-staging-fixes.md).
- **Rule-driven alerting** — the suggestion/inference engine ([O3](O3-suggestion-redesign-xmse948.md)) is the existing home for the "you ordered mayonnaise twice" and "bookings spiked, forecast didn't" flags.

### Screenshot timestamps (sub-task 1)
Screen share opens at **3:36** (*"I'll just share my entire screen"*) and runs to roughly **34:00**. Highest value first:

| Priority | Timestamp | What's on screen | Why it's worth capturing |
|---|---|---|---|
| ★★★ | **21:36–22:38** | Recipe/dish costing (a burger) + the duplicate semi-skimmed milk products at different prices | The single best evidence shot — proves the product-duplication + stale-cost problem in one frame |
| ★★★ | **11:43–13:33** | The manual food invoice spreadsheet (date / supplier / value) + weekly food sales prediction → food budget | The artefact to be replaced; needed to design flat-file ingestion ([O30](O30-invoice-ingestion-price-drift.md)) |
| ★★★ | **5:00–5:42** | Access "business sheet" weekly close — sales vs budget vs last year, food/drink split | The report to replicate on day one |
| ★★★ | **3:42–4:02** | Access landing page **and the browser tab bar** (*"sorry about all my tabs"*) | The tabs corroborate the whole system inventory |
| ★★ | **6:06–7:04** | S4 Labour rota/clocking + top summary with sales in, forecast entry, labour % | Shows the Access→S4 feed and what's keyed by hand |
| ★★ | **10:00–11:14** | Collins heads-in — Plough 9 tonight, Wildmoor 27, Wildmoor 40 tomorrow lunch | Shows the per-site/per-day manual switching |
| ★★ | **15:20–16:03** | Complimentaries + adjustments/discounts + staff meals | Maps onto `LINEITEM_TYPE` values (`DISCOUNT`, `SVC`, …) |
| ★★ | **17:00–18:19** | Wet stock take, deliveries, and the product list with prices | Where price staleness physically lives |
| ★★ | **27:00–28:09** | The Access week-picker with no date filter | Evidence for the "second week of January" pain |
| ★★ | **13:36–14:29** | Food budget vs actual — ~£1,500 allowance, continual overspend | Quantifies the GP problem |
| ★ | **7:45–8:27** | Partial-week actual vs forecast figure Scott probed | Clarifies forecast semantics |
| ★ | **18:55–19:50** | Stock variance / GP summary report (wet GP 67% that week) | Comparator for our own GP output |
| ★ | **16:24–16:32** | Waste report | Confirms waste is captured at till + report level |
| ★ | **23:00–23:55** | Toggle gift vouchers | The voucher blind spot |
| ★ | **24:36–25:38** | Collins enquiry + deposit (9 Aug booking at the Plough) and the tag system | Deposit + tag workflow |
| ★ | **26:37–27:00** | Bex's own forecasting / P&L spreadsheet | The shadow reporting layer |
| ★ | **33:46–34:00** | PLU sales report | The cauliflower cheese / steak & frites example |

### Open questions
- **Product identities.** "Access" is Access Hospitality EPOS with high confidence. "Actio" is almost certainly **Acteol** — an Access Group product, which may mean *one* commercial conversation covers both. "Collins" is most likely Collins by DesignMyNight; "Toggle" is unconfirmed. Verify from the video/audio or by asking Bex before approaching any vendor.
- **GM names** Nick (Plough) and Emma (Wildmoor) are inferred from *"sit down with Nick… We do the same with Emma"* — confirm.
- **Cover-count capture integrity** — Bex's own follow-up action: check whether a walk-in seated on the till gets the true headcount or just `1`. Gates [O31](O31-dining-covers-spend-per-head.md).
- Not yet discussed at all: commercial terms, timescales, contract, data-processing agreement.
- **Not a commitment:** Scott raised a possible footfall-tracking partner (beacons; counts in/out, adults vs children, table dwell time) as *"me thinking out loud"* — explicitly not a partnership yet, pending that contact returning from holiday. Do not carry it into any proposal.

## Progress log
- **2026-07-30** — Discovery call held (46m32s). Second meeting with this prospect; Bex had given a shorter intro previously. Full system walkthrough via screen share. Item raised from the transcript along with [O28](O28-access-hospitality-epos-integration.md)–[O31](O31-dining-covers-spend-per-head.md). ⚠️ The first transcript export supplied was **truncated** — it held only 0:03–0:27 and 43:40–46:28, silently dropping the 43 minutes containing the entire walkthrough. The complete text came from the `.docx` export (`~/Downloads/three rocks x Makers of Hospitality.docx`); plain text extracted to the session scratchpad. If revisiting, work from the `.docx`, not the pasted transcript.

## Pick-up notes (resume here)
- **The deadline is the point of this item:** Kerri promised a response *"beginning of next week"* — w/c **2026-08-03** — with thoughts, next steps and a follow-up booked. Everything else here serves that.
- Start with [O28](O28-access-hospitality-epos-integration.md). Access holds sales, budgets, comps/discounts/staff meals, waste, stock, products, recipes and PLU — if Access can't be integrated, the proposition largely collapses, and it is **not** on the current integration list.
- Do sub-task 7 (map onto existing capability) **before** sizing anything. Marge Brut plus parent-org reporting already cover a surprising amount of the ask.
- Don't approach Access or any other vendor until Bex has sponsored it — Kerri's point that a client-initiated request opens doors that a cold approach doesn't.
- Bex offered to send any reports TR would find useful, and to flag any further data sources they think of.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
