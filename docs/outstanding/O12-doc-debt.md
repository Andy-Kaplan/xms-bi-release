# O12 — Doc debt: DV diagram stat + documentation-audit-findings

> Detail file for ledger item **O12**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | DOC-DEBT |
| **Area** | Documentation |
| **Owner / decides** | Andy |
| **Next action** | Fix the DV diagram Live Links header stat and address the audit findings §8-10 |
| **Sources** | `docs/data-vault-diagram.html`, `docs/documentation-audit-findings.md` |

## Context
Two known documentation gaps carried in memory:
1. **`docs/data-vault-diagram.html`** — Live Links header stat reads **39**, should be **40**.
2. **`docs/documentation-audit-findings.md`** §8-10 — index.html omissions and stale HTML counts — not addressed.

## Progress log
- **(various)** — Identified during doc audits; not actioned.
- **2026-07-02** — Logged to ledger from memory.

## Pick-up notes (resume here)
- The DV diagram stat is a one-line JS edit (header stat counts, ~lines 131-134 of the `<script>` block).
- For §8-10, read `docs/documentation-audit-findings.md` for the specific omissions.
- Per CLAUDE.md, DV entity changes must sync across .md + all interactive HTML docs — check nothing else drifted.
- Don't mark Closed until the user confirms.
