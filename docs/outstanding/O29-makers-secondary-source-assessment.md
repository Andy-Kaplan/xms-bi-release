# O29 — Maker's of Hospitality: secondary source assessment (S4 Labour, Collins, Toggle, Wireless Social, Acteol)

> Detail file for ledger item **O29**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Priority** | 3 |
| **Area** | Integrations / new source assessment |
| **Owner / decides** | Andy |
| **Next action** | Assess each of the 5 sources for API availability and effort; promote any that becomes a committed build to its own ledger item |
| **Sources** | Discovery call 2026-07-30 — S4 Labour 6:06–9:34 + 36:03; Collins 9:49–11:14 + 24:36–26:08; Toggle 22:56–24:36; Wireless Social + Acteol 44:02–45:04; GDPR ruling 37:39–39:03 |

## Sub-tasks
| # | Status | Task | Note |
|---|--------|------|------|
| 1 | OPEN | **S4 Labour** — review the API we already have some knowledge of; scope headcount-level extraction | Andy: *"I'm aware of the S4 API, so we've done a little bit of work with that."* Possibly the **fastest first win** if Access proves slow |
| 2 | OPEN | **Collins** — establish bookings API availability | No bookings source exists on the platform today; this would be a first |
| 3 | OPEN | **Toggle** — establish gift-voucher API availability | Small, self-contained, high perceived value → the voucher-liability report |
| 4 | OPEN | **Wireless Social** — establish API/export capability | Scott: *"one of the good guys in terms of data is readily available"* |
| 5 | OPEN | **Acteol** — establish API availability; note it's an Access Group product | May share a commercial conversation with [O28](O28-access-hospitality-epos-integration.md) |
| 6 | OPEN | Apply the GDPR ruling below to the S4 design before any build | Agreed in the room — do not silently widen scope later |
| 7 | OPEN | Confirm the real product identities for Collins and Toggle | See [O27](O27-makers-of-hospitality-discovery.md) Open questions |

## Context

These are the five non-EPOS sources. None is on the critical path — [O28](O28-access-hospitality-epos-integration.md) is — but S4 Labour and Collins carry most of the *additional* analytical value, because blending labour and bookings against sales is where the platform does things the incumbent systems can't.

### 1. S4 Labour — rotas and time & attendance
Rotas are built in S4; it doubles as the clocking in/out system, with hours manually approved each week. Sales already feed in daily **from Access**, so S4 holds sales and labour side by side and produces a labour %.

The weekly routine, in Bex's words: check the labour % against budget — *"if it's on budget or below, happy days, we don't require them to do anything else"* — and only if there's an overspend do they break it down by day to find the culprit.

Forecast semantics, which Scott probed carefully and which matter for modelling:
- Actual sales are **pulled through automatically from Access**, not keyed.
- The weekly forecast **is** keyed by hand, and **is** split by food and drink.
- Once set, the forecast is deliberately left alone: *"Generally, once the forecast for the week is done, we won't touch it."*
- The single exception is a material change — a party of 22 booking on a Friday afternoon — where they may add labour and edit that day's forecast so the figures still justify the schedule.

> ### ⚠️ GDPR ruling — agreed in the call, do not widen without asking
> Andy raised the PII exposure in labour data unprompted and proposed the narrow scope: **aggregate headcount, hours and cost only in the first instance — nothing that identifies individuals.** Bex agreed explicitly: *"headcount would probably be sufficient… you've got three on Thursday lunch, your bookings have jumped up, last Thursday lunch you had four on and you needed them."*
>
> This mirrors the CRM-lane precedent on the Mews integration, where a GDPR ruling required purging already-loaded PII after the fact. **Design S4 to headcount grain from the start rather than landing individuals and aggregating later.**
>
> Two per-individual ideas *were* discussed and are explicitly **out of scope** unless separately agreed: Andy mentioned another client's team leaderboard (average transaction value, average tip), and Kerri raised staff-suitability flags (*"they're not a Sunday afternoon crew"*). Both need individual-level data. Interesting, not requested, not agreed.

### 2. Collins — bookings
Used for reservations across both sites. The owners watch **heads-in** per session and react: at the Plough there were 9 covers in that evening; the Wildmoor 27; the Wildmoor's Friday lunch was showing 40, which Bex flagged as *"unusual for a Friday lunch"* and would trigger a message to the team asking whether they have enough staff on.

The pain is manual navigation — *"it's quite manual to check each day, to check each pub"* — so the check happens only a couple of times a week.

Also in Collins:
- **Tags/labels workflow** for booking state (e.g. "await pre-order"); a deposit is required at 10+ covers.
- **Deposits** taken via payment link. Confirming a paid deposit in the diary is **manual** (Kerri checked this explicitly). The deposit then auto-deducts from the bill when the guest is seated on the till. Reports are pulled for the accountant monthly.

**This is the source behind the flagship alerting use case** Andy pitched: detect a booking spike that the labour forecast hasn't accounted for, and surface it as a notification. That requires Collins **and** S4 together, which is precisely the cross-source argument for the platform.

⚠️ No bookings integration exists on the platform today — this would be a first, and the `HUB_*` model has no booking entity.

### 3. Toggle — gift vouchers
Small scope, and one of the clearest wins available. Currently a total blind spot: Bex cannot say how many vouchers were sold in the last 12 months, how many expired, or how many are still live — *"the data would be there, I've just never dug into getting it."* The accountant pulls something monthly.

Scott made the case that lands commercially: outstanding vouchers are a **balance-sheet liability** that can be offset for tax, and unknown exposure is a genuine risk — *"in theory you could have millions of pounds worth of gift vouchers out there, and if they all came in at once, you'd have a problem."*

Deliverable is a single small report: vouchers sold / redeemed / expired / **outstanding liability**, by period and site.

### 4. Wireless Social — guest Wi-Fi
Captures arrival time, departure time (hence dwell), returning-customer recognition, categorisation, and booking data from Wi-Fi users. Scott's assessment: *"they're one of the good guys in terms of data is readily available. So yeah, that's a big one."*

⚠️ **Novel data shape for the platform** — nothing today carries footfall, dwell time or visit recency/frequency. Also inherently guest-level, so the GDPR question applies here at least as much as to S4; settle the intended use case before designing.

Note the adjacency: this is the same measurement problem Scott's prospective footfall-tracking contact would address (counts in/out, adults vs children, table dwell). Wireless Social may already answer much of it from data Maker's is **already paying for**. Worth checking before anything is bought.

### 5. Acteol ("Actio") — CRM and email marketing
Their CRM and email platform. Effectively **dormant**: Bex discovered they'd sent one email for the Wildmoor in January 2026 and none since, because *"social media is massive for us. So we're focused on that."* The guest data is still accumulating.

Two things make it worth keeping on the list despite the dormancy:
- The platform has **live CRM entities with no integration mappings at all** — per the DV coverage matrix, 9 CRM entities sit unmapped. Acteol could be the first real consumer. *(Verify against `docs/data-vault-reference.md` §6 before relying on that count.)*
- Acteol is an **Access Group product**, so it likely shares a commercial route with [O28](O28-access-hospitality-epos-integration.md) — worth raising in the same vendor conversation rather than a separate one.

Lowest priority of the five: a dormant channel yields little immediate insight, and the guest-crossover analysis Bex actually cares about is better served by POS plus Wireless Social.

## Progress log
- **2026-07-30** — Raised from the discovery call. All five identified from the walkthrough; Wireless Social and Acteol surfaced late (44:02) as an afterthought by Bex rather than part of the prepared tour, so they may be less central to the weekly routine than the other three. No assessment work started.

## Pick-up notes (resume here)
- **Start with S4 Labour** — it's the only one of the five where we already have API knowledge, and labour % against sales is a headline weekly metric. If [O28](O28-access-hospitality-epos-integration.md) stalls on vendor access, this is the fastest route to showing something real.
- **Bank the GDPR ruling in the design, not just the notes.** Headcount grain from the outset. The Mews CRM lane shows what the alternative costs.
- Collins + S4 together unlock the booking-spike-vs-forecast alert — the most persuasive single demo available from this account.
- Toggle is the cheapest credible win: one small integration, one report, a blind spot closed and a real tax/liability angle.
- Promote any of these to its own ledger item once it becomes a committed build rather than an assessment.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
