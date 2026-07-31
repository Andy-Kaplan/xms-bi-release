# O30 — Emailed supplier invoice ingestion → price-drift + duplicate-order detection

> Detail file for ledger item **O30**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Priority** | 3 |
| **Area** | Ingestion / flat-file + alerting |
| **Owner / decides** | Andy |
| **Next action** | Establish the current state of the flat-file/email ingestion work Andy referenced in-call, then scope invoice-line extraction against it |
| **Sources** | Discovery call 2026-07-30 — invoice spreadsheet 11:43–15:16; price blind spot 17:00–19:00; Andy on flat-file ingestion 28:09–30:15; duplicate-order use case 31:21–32:17 |

## Sub-tasks
| # | Status | Task | Note |
|---|--------|------|------|
| 1 | OPEN | Establish what the in-flight flat-file ingestion work actually supports today | Andy told the prospect *"what we are working on at the moment as well is sort of flat file ingestion"* — **confirm scope before it's promised again** |
| 2 | OPEN | Decide the extraction approach for emailed supplier invoices (PDF/attachment parsing vs supplier feeds) | 95–99% arrive by email; formats will vary by supplier |
| 3 | OPEN | Model invoice lines onto the existing purchase/stock-event model | `STOCKEVENT` `EVENT_TYPE = 'ORDER'`, `F_PURCHASES_DAY` |
| 4 | OPEN | Build **price-drift detection** — per product, per supplier, over time | The #1 blind spot Bex named |
| 5 | OPEN | Build **duplicate-order detection** across days within a delivery window | The mayonnaise/mint-sauce case |
| 6 | OPEN | Decide where the alerts surface — suggestion engine vs notification banner | See [O3](O3-suggestion-redesign-xmse948.md) |
| 7 | OPEN | Retire the manual invoice spreadsheet once coverage is proven | The visible, quantified win: removes daily keying from printed invoices |

## Context

### The manual process being replaced
Because food GP is *"such a big factor"* at the Wildmoor and they *"continually keep missing food GP"*, Maker's introduced a manual control: every invoice is keyed onto a spreadsheet daily.

The loop as it stands:
1. Printed invoices arrive with the delivery and go onto **a clipboard outside the office**.
2. Next morning the duty manager keys date, supplier and invoice value into a spreadsheet.
3. Weekly, someone enters predicted food sales, which yields a food budget and a remaining daily spend allowance.
4. On Monday the team are told what's left — *"guys, we're going into the weekend, you've only got £400 to spend"*, or in the week shown, £1,500 *"please be careful because you've got your meat deliveries coming in, only order what you need."*

Bex's own verdict: *"It's here as a tool and a system to help us talk about it, but it is very manual to get the data on here"* — and it isn't working: *"we're continually over budget… to be overspending by a grand a week is far too much."*

**The key enabling fact: 95–99% of invoices already arrive by email.** Both a paper and a digital copy exist; the team just happen to use the paper one on the clipboard. So the digital source is already there. One caveat Bex flagged: one supplier sends a week's invoices in arrears on a Monday, so **arrival date ≠ delivery date** and the model must key off the invoice/delivery date, not receipt.

### Use case 1 — supplier price-drift detection
The blind spot, in Bex's words: *"I only know that chicken has moved 25p if the supplier has told me, which they don't always, or if I've checked the product in the system."* Prices in Access are maintained by hand, so drift is invisible until someone stumbles on it.

They used to enter food deliveries into Access and stopped, because the effort wasn't repaid — *"there was no benefit in doing that. The only benefit really was if we noticed there was a change to a price."* They now add delivery notes ad hoc, purely to spot-check pricing.

The ask, stated plainly: *"if I could look at a report and it showed that the price had moved, I would then either be able to go back to the supplier or update it in the system. Yeah, that's a complete blind spot at the moment."*

Two compounding factors:
- **Split supply.** Milk is ordered from either of two suppliers depending on who is delivering next day — so the same product legitimately has two prices, and drift detection must be per product **per supplier**, not per product alone.
- **Stale recipe costs.** Dish costing draws on these hand-maintained prices, so a price *"might be six months out of date because I've not looked at an invoice recently."* Fixing drift fixes recipe accuracy downstream.

### Use case 2 — duplicate-order detection
The example Bex volunteered as the thing that would excite them most: *"they ordered a 5-litre mayonnaise on Tuesday and they ordered another one on Wednesday… because one of you didn't know the other one had ordered it."* Today, chasing that means telling a GM to go and read the invoices manually.

The desired output is a plain statement of cause: *"actually the invoices show you ordered a mint sauce on Wednesday and you'd already ordered one on Tuesday"* — *"and we could be like, well, that's the reason, guys."*

Design note: this is a **within-window repeat purchase of the same product** check, so it needs a per-product sensible-reorder-interval notion (or simply same-product-twice-inside-N-days as a first cut). Cheap to build, disproportionately persuasive.

### Use case 3 — most-purchased product resolution
Not framed as an ask, but it falls straight out of having invoice lines, and it solves a problem Bex articulated precisely. Access carries many near-duplicate products (*"semi-skimmed milk, there's one, two, three… so many"*), some obsolete, at different prices. When costing a recipe Bex defaults to the most expensive and acknowledges the risk: *"it can cause a risk that you're choosing the wrong products."*

Their own proposed fix: *"I don't know necessarily which one is the most bought product, because if I did, I could probably just pick that for the recipe, because that's the most common product bought."*

Once invoice lines are landed, **ranking products by actual purchase frequency/volume is trivial** and directly answers this. Note the strong overlap with [O7](O7-xmse949-product-cost-matching.md) / [O10](O10-threerocks-sales-double-count.md), where the platform's own cost map is ~95% NULL and fans out ~1.5× — read those before designing.

### Dependencies and cautions
- **Gated on [O27](O27-makers-of-hospitality-discovery.md)** — this is prospect-driven scope, not a committed build. Treat it as a requirement capture until the account converts.
- **Flat-file ingestion status is unverified.** Andy described it in-call as in progress; nothing in this repo has been checked to confirm what it supports. Sub-task 1 exists because the claim has already been made to a prospect once.
- **Cross-client value.** Emailed-invoice ingestion plus price-drift alerting is not specific to Maker's — every inventory-carrying client has the same blind spot, and the platform's existing purchase lane (`F_PURCHASES_DAY`, live on the Marge Brut dashboard, [O8](O8-marge-brut-dashboard.md)) is the natural home. If this is built, build it generically.
- Alert delivery should reuse the suggestion/inference engine ([O3](O3-suggestion-redesign-xmse948.md)) rather than introduce a parallel mechanism.

## Progress log
- **2026-07-30** — Raised from the discovery call. Three use cases captured (price drift, duplicate ordering, most-purchased product resolution), all traceable to specific prospect statements. No build work started; flat-file ingestion state not yet verified.

## Pick-up notes (resume here)
- **Do sub-task 1 first.** The flat-file capability was described to a prospect as in-flight; confirm what actually exists before it appears in a proposal.
- Model against `F_PURCHASES_DAY` and the `STOCKEVENT` `ORDER` lane — don't invent a parallel purchase model.
- **Price drift must be per product *per supplier*** — split supply (milk from either of two suppliers) makes a product-only comparison produce false positives.
- **Key off invoice/delivery date, not email receipt date** — one supplier batches a week's invoices on a Monday.
- Duplicate-order detection is the cheapest high-impact piece; consider it the demo.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
