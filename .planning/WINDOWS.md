---
schema_version: 1
open_count: 1
waived_count: 0
fixed_count: 0
total_count: 1
last_updated: 2026-08-08T06:07:48.089Z
---

# Broken Windows Ledger

> Cross-phase defect register. `/gsd-ship` blocks while `open_count > 0`.
> Waive with `gsd-tools windows waive <id> "<reason>"` (reason required).
> Mark fixed with `gsd-tools windows fixed <id>`.

| id | phase | kind | file | line | description | status | reason | recorded_at | resolved_at |
|----|-------|------|------|------|-------------|--------|--------|-------------|-------------|
| 1 | 07 | unrun-verify | apps/web/public/.well-known/assetlinks.json |  | Vercel production deploy pending — live assetlinks.json still has empty fingerprints | open |  | 2026-08-08T06:07:48.089Z |  |

````json
[
  {
    "id": 1,
    "kind": "unrun-verify",
    "phase": "07",
    "file": "apps/web/public/.well-known/assetlinks.json",
    "line": null,
    "description": "Vercel production deploy pending — live assetlinks.json still has empty fingerprints",
    "status": "open",
    "reason": "",
    "recorded_at": "2026-08-08T06:07:48.089Z",
    "resolved_at": null
  }
]
````
