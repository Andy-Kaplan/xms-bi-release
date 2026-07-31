# O26 — Bespoke org palettes are defined but never applied (no org-level palette selection exists)

> Detail file for ledger item **O26**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | **CONFIRMED — not a bug. The default-palette feature was never built.** Needs a product decision, then FE work |
| **Area** | Microservice report DB / palettes + front end |
| **Owner / decides** | Andy + front-end team (Ian Hamlin / Craig Gingell) |
| **Next action** | ✅ **Raised as [XMSE-1756](https://threerocks.atlassian.net/browse/XMSE-1756)** (Story, assigned Ian Hamlin, agreed not to be worked on now). Release-side: nothing to do — **do not write selection rows**, nothing consumes them. Optionally confirm whether `Apply` persists (§4a) and add it to the ticket |
| **Jira** | [XMSE-1756](https://threerocks.atlassian.net/browse/XMSE-1756) — *Allow an organisation's dashboard palette to be set as that org's default* |
| **Raised** | 2026-07-30, from the 2026-07-29 report-DB re-audit |
| **Sources** | `docs/microservice-report-database.md` §6.2, §6.3; `ClaudeDevelopment/integrations/Growyze/growyze_org_palette.sql`; FE confirmation from Ian Hamlin, 2026-07-30 |

> **Resolution (FE thread + live UI check, 2026-07-30).** Two findings, in sequence:
>
> 1. **Ian Hamlin:** *"I dont think we added a default? Just the ability to add palettes — you can add system, org or staff palettes."* Then: *"could be a caching issue, I've cleared the cache."*
> 2. **After the cache clear, the Growyze palette DOES appear** in the UI palette picker for Padel Social, under an `Organisation` heading. Confirmed by screenshot.
>
> **So the original symptom had two causes, and only one is a missing feature:**
> - *Not appearing as an option* = **a stale cache.** Fixed. The FE does call `OrganisationDashboardPalettes_Load` and does group palettes by tier.
> - *Not applying as a default* = **genuinely never built.** Still true, and the narrower remaining gap.
>
> See §4a for what the UI proves about the FE contract.

## 1. Symptom

Bespoke Growyze-branded palettes were deployed for **Padel Social** and **Dirty Sixth** on UAT. The UI never picked them up. This has been assumed to be a failed or partial deployment.

**It isn't.** The deployment did exactly what it was written to do. The gap is in the schema.

## 2. What is actually in UAT (verified 2026-07-30)

Server `xms-mssql-ne-uat`, database `report`. (`xms-sql-fog-uat` in the MCP config is the failover-group listener in front of this same server — there is no second report DB, so a wrong-target write is ruled out.)

**The hex codes are present, live, and correct:**

| OrganisationId | Org | Palette | `SortOrder` 0 | 10 | 20 | 30 |
|---|---|---|---|---|---|---|
| `94A4B719-EB0F-421F-AD03-ABECDD888B14` | Padel Social | `Growyze` | `#000055` | `#34DBD1` | `#FC3762` | `#F3F3FF` |
| `7B50D717-124C-4902-ADD2-439A9310326A` | Dirty Sixth | `Growyze` | `#000055` | `#34DBD1` | `#FC3762` | `#F3F3FF` |

- Written 2026-04-16 08:45:31. Nothing soft-deleted (`IsDeleted = 0` on all palette and colour rows).
- Both hex sets match `growyze_org_palette.sql` exactly, including sort orders.
- Both org GUIDs are **live, real orgs**: each has a `BiConfig` row (Padel Social `DbPrefix` `20251208`, Dirty Sixth `20260327`), 4 live dashboards, 1 live palette. So the UI is loading with the correct identifier and `OrganisationDashboardPalettes_Load(@OrganisationIdentifier)` returns the palette for both.
- A third palette, `trocs` (org `61376EF0-…`, single colour `#F4A0C3`, 2026-02-05), is seed debris — that org has **no** `BiConfig` row, no groups and no dashboards.

## 3. Root cause — proven by the audit mirrors

The report DB separates **defining** a palette from **selecting** one, and only the definition half has an organisation tier.

**Definition** — 3 sibling tier pairs, no inheritance, no FK between tiers:

| Tier | Table | Owner columns |
|---|---|---|
| System | `DashboardPalette` / `…Colour` | *(global)* |
| Organisation | `OrganisationDashboardPalette` / `…Colour` | `OrganisationId` |
| Staff | `StaffDashboardPalette` / `…Colour` | `OrganisationId` + `StaffId` |

**Selection** — 3 tables, and **every one requires `StaffId NOT NULL`**:

| Table | Key | Grain |
|---|---|---|
| `StaffDefaultPalette` | Org + **Staff** | that person, everywhere |
| `StaffDashboardDefaultPalette` | Org + **Staff** + `DashboardGridId` | that person, one dashboard |
| `StaffDashboardItemDefaultPalette` | Org + **Staff** + `DashboardGridId` + `DashboardGridItemId` | that person, one card |

**There is no organisation-level selection table.** Defining an `OrganisationDashboardPalette` row makes the palette *available in that org's picker*; it does not apply it. Applying it requires a row per staff member.

The audit mirrors make this conclusive:

```sql
SELECT 'StaffDefaultPalette' AS tbl, COUNT(*) FROM dbo.StaffDefaultPalette
UNION ALL SELECT 'Audit.StaffDefaultPalette', COUNT(*) FROM Audit.StaffDefaultPalette
UNION ALL SELECT 'Audit.StaffDashboardItemDefaultPalette', COUNT(*) FROM Audit.StaffDashboardItemDefaultPalette
UNION ALL SELECT 'Audit.OrganisationDashboardPalette', COUNT(*) FROM Audit.OrganisationDashboardPalette;
```

- All three selection tables: **0 live rows and 0 audit rows.** Not written-then-deleted — **never written once, by anyone, in this environment.**
- `Audit.OrganisationDashboardPalette` = **3 rows** = exactly 3 inserts, no updates, no deletes. The palettes were created once and never touched.

So no palette selection has ever been attempted, and no amount of correcting the deployment script could have produced an org-wide default.

## 3a. Why it looked undeployed for three months — the config cache

Ian Hamlin, 2026-07-30: *"If you use the admin tools, it will clear the cache for you when you add data."*

The application caches report-DB configuration, and **a direct SQL write does not invalidate that cache.** `growyze_org_palette.sql` was applied straight to the `report` database on 2026-04-16, so the palette was present and correct but never surfaced in the UI until the cache was manually cleared three months later.

**Reusable rule: before concluding a report-DB change failed, query the tables.** If the rows are there, suspect the cache, not the script. Prefer the admin tools for anything they cover, since they invalidate the cache as part of the write. This applies to *all* hand-run report-DB config — dashboards, grids, entitlements, palettes — not just palettes.

## 4a. What the live UI proves about the FE contract (2026-07-30)

The palette picker on Padel Social's "Cost & Margins" dashboard renders in three labelled groups, and comparing them against the database is highly informative:

| Picker group | Contents | Matches DB? |
|---|---|---|
| **Default** | `Rainbow` | ❌ **Not in the database.** No `DashboardPalette` row is named Rainbow |
| **Core** | Purple, Blue, Cyan, Green, Yellow, Orange, Red, Pink, Blueberry Twilight, Mango Fusion, Cheerful Fiesta | ✅ **Byte-exact match** for all 11 `DashboardPalette` rows |
| **Organisation** | `Growyze` (4 swatches) | ✅ The `OrganisationDashboardPalette` row for this org |

Three conclusions:

1. **The FE consumes all three definition tiers correctly.** It calls the org `_Load` procedure, scopes it to the caller, and groups by tier in the UI. Nothing on the definition side needs fixing — the schema and the client agree.
2. **`Rainbow` is a hardcoded client-side default.** This answers the long-standing question of what governs card colours today: not the database. Until a palette is explicitly chosen, the 90-colour store in `DashboardPalette` is unused and the platform renders Rainbow. **The palette system is currently decorative by default.**
3. **Selection previews but does not persist.** With the picker open on Growyze, the cards already render in `#000055` / `#34DBD1` / `#FC3762` / `#F3F3FF` — so the client can apply a palette client-side. But **all three selection tables remain at 0 live and 0 audit rows** after the interaction. Not yet distinguished: whether `Apply` fails to persist, or was not pressed. Resolve by pressing Apply, hard-refreshing or re-logging in, then re-running the tripwire query in §3.

**Ordering note:** the picker lists Pink → Blueberry Twilight → Mango Fusion → Cheerful Fiesta, which matches no `ORDER BY` the database would produce (those four all share `SortOrder` 70). Consistent with the finding that no palette `_Load` procedure has an `ORDER BY` at all — the client is ordering them itself, on incidental row order. Adding a fifth palette at `SortOrder` 70 would land unpredictably.

## 4. The feature is half-built — backend shipped, FE never wired

This is the useful part for whoever picks it up: **the DB schema for default-palette selection already exists, is fully formed, and has never been used.** It was deployed by RoundhousE in April 2026 (scripts `060`–`068`, i.e. proper migrations, not hand-applied), so the backend side of the feature was completed and then apparently dropped before the FE work happened.

| Table | Deployed | Key | Grain it supports |
|---|---|---|---|
| `StaffDefaultPalette` | 2026-04-09 (`060`–`062`) | Org + Staff | a person's default everywhere |
| `StaffDashboardDefaultPalette` | 2026-04-09 (`063`–`065`) | Org + Staff + `DashboardGridId` | per-dashboard override |
| `StaffDashboardItemDefaultPalette` | 2026-04-29 (`066`–`068`) | Org + Staff + Grid + `DashboardGridItemId` | **per-card** override |

Each has a `_Load` and an `_Upsert` (`MERGE` on the natural key, so idempotent), a unique index on its business key, an `Audit` mirror and both triggers. Whoever implements the FE side has a ready-made, migration-tracked persistence layer with three levels of granularity — including per-card, which is finer than anyone has asked for.

Two design gaps to settle before using them, both consequences of the feature never being finished:

1. **There is no organisation-scoped selection table.** All three require `StaffId`. So "this org's default palette" cannot be expressed at all — only "this person's default". If an org-wide default is what's wanted (it is, for client branding), that needs either a new `OrganisationDefaultPalette` table or an FE convention that treats a sole org palette as the default.
2. **`PaletteId` is an untyped pointer** — bare `uniqueidentifier NOT NULL`, no FK, no discriminator, across three possible parent tables. Whoever implements this needs to define the resolution rule, and ideally add a discriminator or split the column.

## 5. Options

| # | Option | Assessment |
|---|---|---|
| **A** | **FE treats a sole `OrganisationDashboardPalette` as that org's default** when no explicit selection exists | **Preferred, and the smallest change.** No schema work, no per-user backfill, works for every future client automatically, and matches what "a bespoke palette for this organisation" plainly means. Needs only FE work |
| B | **Build the full selection feature** against the three existing tables, plus a new org-scoped table | The complete answer, and the schema is already 3/4 there. Bigger FE scope: a picker, persistence, and the `PaletteId` resolution rule. Worth it if per-user or per-card theming is actually wanted — otherwise it's more machinery than the requirement needs |
| C | **Backfill `StaffDefaultPalette` per staff member** | **Now known to be pointless** — Ian confirms nothing reads these tables, so rows would sit inert. Also breaks for each new user. Ruled out |
| D | Repoint a **system** palette's colours to the Growyze brand | **Do not.** `DashboardPalette` is global across all 18 orgs on UAT — it would restyle every client |

**Recommendation: option A**, unless per-user theming is a real product requirement. It is the only option that delivers client branding without building a feature nobody has asked for.

## 6. ~~Open question~~ — ANSWERED 2026-07-30

*Original question: if nothing applies a palette, what governs the colours cards render with today?*

**Answered by the UI: a hardcoded client-side default named `Rainbow`**, which does not exist in the database (§4a). So until a user explicitly picks a palette, the platform ignores the `DashboardPalette` store entirely.

This is good news for scoping. Option A is **not** "introduce palette-driven theming for the first time" — the client already knows how to render an arbitrary palette, and already shows the org's palette in the right group. The change is narrower: **pick the org palette instead of `Rainbow` as the starting default when the org has one.**

Remaining open question for the FE team: **does `Apply` persist a selection anywhere?** All three selection tables were still empty after a session in which the palette was previewed. If `Apply` is client-state only, then even a per-user choice is lost on next login, and the persistence layer (which exists in the DB, §4) has never been connected.

## 7. Pick-up notes

- **Write nothing to the three selection tables.** Confirmed 2026-07-30 that nothing consumes them, so rows would sit inert against an unconstrained pointer.
- Palette *definitions* need no repair — do not re-run `growyze_org_palette.sql`. It is **not idempotent** (it looks the parent up by name rather than using `OUTPUT`), and nothing enforces one palette per org — no unique key on `(OrganisationId, Name)` — so re-running it duplicates the palette and both copies appear in the picker.
- **Sizing note for when this works: the Growyze palette has only 4 colours**, against 6–10 for the system palettes. Cards with more than 4 series must wrap or generate, and that behaviour lives in the FE, not the DB. Decide the intended behaviour — and probably extend the palette — as part of the same change.
- The brand palette is **duplicated per-org, not shared**: the org tier has no shared-palette concept, so every additional Growyze client needs its own copy. If more are coming, factor that into whichever option is chosen.
- Related known defect in the same area: `OrganisationDashboardPalettes_Load` has a duplicated child `IsDeleted` predicate that displaced the parent check, so colours belonging to a *soft-deleted* org palette still reach the client. Latent today (all 3 palettes live). Mitigation until fixed: soft-delete the colour rows whenever you soft-delete an org palette. See `docs/microservice-report-database.md` §7.2.
- Report-DB writes are human-run — MCP `execute` is not enabled on any `microservice-*` server, so Claude cannot apply any of these options.
