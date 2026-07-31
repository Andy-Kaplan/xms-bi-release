# O39 — O23's fix is live on UAT but exists only on an unmerged branch, so `main` lacks it

> Detail file for ledger item **O39**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | OPEN — the divergence is confirmed; the merge has not been done |
| **Priority** | 2 — blocks cutting `releases/v1.1` correctly |
| **Area** | Repo hygiene / release integrity |
| **Owner / decides** | Andy |
| **Next action** | Merge `worktree-margebrut-live` into `main` (or open a PR), **before** [O5](O5-growyze-default-dashboards.md)'s release-prep cuts `releases/v1.1`. Then re-check that no other worktree branch holds deployed-but-unmerged work — the same check that found this one |
| **Found by** | [O5](O5-growyze-default-dashboards.md) Plan 3, 2026-07-31, while checking whether a script number was free |
| **Related** | [O23](O23-growyze-supplier-bottom-level.md) (the fix in question), [O8](O8-marge-brut-dashboard.md) (the branch's main payload), [O5](O5-growyze-default-dashboards.md) (release-prep is blocked on this) |

## What's wrong

[O23](O23-growyze-supplier-bottom-level.md)'s Growyze supplier `BOTTOM_LEVEL` fix — `ClaudeDevelopment/integrations/Growyze/22_supplier_bottom_level.sql`, `23_verify_supplier_bottom_level.sql` and runner `94_deploy_supplier_bottom_level.ps1` — was **deployed to UAT on 2026-07-30 and is live there**. Those three files exist **only on the `worktree-margebrut-live` branch**. They are not on `main`, and not on `worktree-growyze-dashboards-o5`.

Confirmed by:

```
git log --all --diff-filter=A --name-only -- "ClaudeDevelopment/integrations/Growyze/*"
git branch -a --contains 99f0a14        # -> worktree-margebrut-live only
```

So **the repository's main line does not contain a fix that is running in UAT.**

## Why it matters

Three distinct consequences, in rough order of severity:

1. **A release cut from `main` would silently omit it.** [O5](O5-growyze-default-dashboards.md)'s release-prep is about to create `releases/v1.1`. Cut from `main` as it stands, v1.1 would ship *without* the supplier fix — and because the fix is already live on UAT, UAT would keep passing while Prod received a version missing it. That is the worst shape of this problem: the environment you test in is *ahead* of the artefact you ship.
2. **Script numbers 22, 23 and 94 are invisibly taken.** `git ls-tree` on any other branch shows the Growyze folder ending at `21` and `93`, so the next author naturally reaches for `22`. O5's Plan 3 Task 1c hit exactly this and was moved to `24`. Anyone else will hit it too.
3. **O8's Marge Brut work is on the same branch.** Marge Brut is *live and verified* on two UAT orgs, so whatever else that branch carries is in the same position — deployed, working, and absent from `main`. The merge is not just about three Growyze files.

## Notes for whoever fixes it

- **Check what else is on that branch before merging** — `git log main..worktree-margebrut-live --oneline` and `--name-only`. Treat it as a real merge to review, not a formality; it carries at least O8's dashboard and O23's fix.
- **`main` was last advanced by a fast-forward** from `worktree-growyze-dashboards-o5` (2026-07-31), and `origin/main` is still behind local `main`. Sort out the push/PR story at the same time.
- **Then sweep for the same problem elsewhere.** This was found by accident. A cheap check: for each worktree branch, `git log main..<branch> --oneline` — anything non-empty on a branch whose ledger item says "deployed" is the same defect. Worktrees in play have included `worktree-margebrut-live`, `worktree-growyze-uom-cost` (believed merged as `fb52ab3..3096646`) and `worktree-growyze-dashboards-o5`.
- **The general lesson worth keeping:** "deployed to UAT" and "in the repo" are independent facts, and the ledger records the first while `git` records the second. When an item says *deployed*, confirm the code is on `main` before treating a release as complete.
- Don't mark Closed until the user confirms.
