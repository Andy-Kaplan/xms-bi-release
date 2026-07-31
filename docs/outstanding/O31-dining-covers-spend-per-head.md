# O31 — Dining covers + spend-per-head measure (and cover-count data-quality flagging)

> Detail file for ledger item **O31**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN |
| **Priority** | 4 |
| **Area** | Presentation / measures + data quality |
| **Owner / decides** | Andy |
| **Next action** | Requirement capture only until [O27](O27-makers-of-hospitality-discovery.md) converts; blocked on Bex confirming whether walk-in cover counts are keyed truthfully |
| **Sources** | Discovery call 2026-07-30, 39:47–43:00 |

## Sub-tasks
| # | Status | Task | Note |
|---|--------|------|------|
| 1 | BLOCKED | Bex to check whether a seated walk-in is keyed with its true headcount or just `1` | **Bex's own action**, taken in-call — gates the whole item |
| 2 | OPEN | Define a **dining cover** — covers on food-bearing bills only | The measure Bex actually wants; a bar-only drinker must not dilute it |
| 3 | OPEN | Build spend per head on that denominator | Wet/dry split matters given one site is 65–70% food and the other 60–70% wet |
| 4 | OPEN | Decompose a period-on-period revenue movement into cover change vs SPH change | Answers the question the management accounts currently can't |
| 5 | OPEN | Add a cover-count **plausibility flag** (e.g. 1 cover against 4 mains) | ⚠️ Flag to managers — **do not** auto-correct; see the ruling below |
| 6 | OPEN | Check whether this generalises to other POS clients | The dining-cover definition is likely reusable platform-wide |

## Context

### The gap
Spend per head was a core metric at Peach Pubs and Bex misses it: *"that was quite a common metric we used to measure… I don't believe the covers in access."*

The reason it can't be trusted is structural rather than a data error. A walk-in sitting in the bar drinking counts as a cover, *"but actually they're not dining, so it shouldn't be counting towards my cover count."* With a wet-led site and a food-led site in the same estate, a single undifferentiated cover count makes SPH meaningless on both.

What Bex wants is precise and buildable: *"if it's a guest who's got food on their bill, how many people are on that cover, to give me an accurate spend per head?"* — i.e. **covers on food-bearing bills only**.

### Why it matters commercially
This is the question the current reporting stack cannot answer. When the monthly management accounts show them £10k down on last year, Bex cannot tell whether that's fewer guests or lower spend per guest: *"It's such a manual thing for me to work out. Is that cover decline? Is it spend per head decline?… the information's there, but I haven't got the time to find it."* Scott's read: *"more people coming in for a pint."*

A single card decomposing a revenue movement into **cover change vs SPH change**, split wet/dry and by site, answers it directly.

### The capture-vs-calculation distinction (Andy's assessment)
Andy drew the line that makes this tractable, and it's worth preserving because it's the reusable judgement:

> *"That's an easier challenge than most operators have with cover counts, because… you do trust the actual individual counts. We know this was one person here or two people. It's more just the calculation that's applied after the fact. And that is a very easy challenge to solve in the data. What's not so easy is… some operators, their method of capturing that cover count isn't usually the trustworthy bit. And then you're in a world of just fuzziness because you've got to make so many assumptions."*

So: the **calculation** is a straightforward measure change; the **capture** is the risk. Bex immediately conceded the capture may not be clean — *"when they sit a walk-in, whether a walk-in gets set as a one count when it might be 4… they're just pressing one or pressing 6 or pressing whatever"* — and took the action to check (sub-task 1).

> ### ⚠️ Ruling: flag capture problems, don't paper over them
> A plausibility check is welcome (one cover against four mains is implausible), but Andy was explicit that the flag must drive behaviour, not silently rewrite data:
>
> *"We could have a go at generating some sort of flags to identify when you think that might be happening… but that's not something we'd ever try and — I mean, we could, I wouldn't advise it… I would really be using that to flag to the managers to say, look, we're not doing this accurately enough. If you guys pay better attention to this, we're going to get better results."*
>
> Bex agreed and asked TR to make that case to the team directly: *"can you speak to the team about that? Get the root of the problem sorted."*
>
> **So: surface implausible cover counts as a data-quality signal to management. Never infer or overwrite a corrected headcount.** Inferring covers from main-course counts would manufacture a plausible wrong number and destroy the measure's credibility — the same trap as [O8](O8-marge-brut-dashboard.md)'s `NULL`-rendered-as-`0.00` and the `MICROSERVICE_NAME` supplier collapse in [O23](O23-growyze-supplier-bottom-level.md): an empty or flagged output beats a confident wrong one.

### Scope note
Lowest priority of the items raised from this call — it's a measure refinement, and it can't start until sub-task 1 comes back. But it is the most *articulate* ask in the meeting: Bex knows exactly what they want, why the current number is wrong, and what decision it would inform. Worth building early once the account converts, and worth checking whether the dining-cover definition should become a platform-wide measure rather than a bespoke one.

Related: covers must **never** be divided across split bills — see the existing split-bill covers ruling in project memory before implementing.

## Progress log
- **2026-07-30** — Raised from the discovery call. Requirement well-specified by the prospect; blocked on their own check of till capture behaviour. No design work started.

## Pick-up notes (resume here)
- **Blocked on Bex** (sub-task 1) — chase it as part of the [O27](O27-makers-of-hospitality-discovery.md) follow-up rather than separately.
- Denominator = covers on **food-bearing bills only**. That single decision is the whole measure.
- **Never infer covers from dish counts.** Flag to managers; leave the number as captured.
- Check the split-bill covers rule before touching cover arithmetic.
- Don't mark this item Closed until the user confirms (per the no-close-without-confirmation rule).
