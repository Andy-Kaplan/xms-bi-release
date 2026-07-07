# O17 — Rotate credentials exposed in ChickenShop Matillion exports

> Detail file for ledger item **O17**. Read only when picking up this item. Back to the [ledger](../OUTSTANDING.md).

| | |
|---|---|
| **Status** | BLOCKED |
| **Area** | Security / integrations |
| **Owner / decides** | Andy (with whoever owns the ChickenShop/Yooz accounts) |
| **Next action** | Regenerate the `chiknstorageaccount` Azure Storage access key and reset the Yooz API password for `support@sixsevens.co.uk`; update whatever live Matillion/fetch config uses them. |
| **Sources** | `ClaudeDevelopment/integrations/ChickenShop/matillion-export/*.json` (now redacted) · PR #1 description |

## Context

During the 2026-07-06 branch tidy-up, GitHub push protection blocked the first push: the ChickenShop Matillion export JSONs contained two live secrets — an **Azure Storage account key** for `chiknstorageaccount` (in all 3 files, inside connection strings) and a **Yooz API password** for `support@sixsevens.co.uk` (embedded Python in 2 files). Both were redacted and git history rewritten *before* anything reached the remote, so the repo is clean — but the credentials sat in plaintext on disk since ~May 2026 and must be treated as exposed. Redacting the repo copy does not un-expose them.

Marked BLOCKED because rotation happens in Azure Portal / Yooz admin, outside this repo; Andy confirmed 2026-07-06 he'll do it "at a later stage".

## Progress log
- **2026-07-06** — Secrets found by GitHub push protection, redacted (`REDACTED-ROTATE-ME` markers), commit rewritten, full branch history verified clean before push. Rotation pending.

## Pick-up notes
- After rotation, nothing in this repo needs updating (values are already redacted); the live Matillion jobs / fetch configs that used these credentials are in the integrations project, not here.
