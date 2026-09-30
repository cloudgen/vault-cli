# Reviews — vault-cli

Public product review surface (peer of `tests/`).

| File | Role |
|------|------|
| `what-to-review.md` | Living review plan / checklist |
| `test-plan.md` | TP-* status map |
| `requirement-test-matrix.md` | Requirement → TP families |
| `lessons.md` | Durable failure modes to re-check |
| `index.md` | Report index |
| `reports/` | Dated review run reports |

**Ship unit:** `src/vault-cli` (**VERSION 1.0.0**)  
**Suite:** `./tests/run.sh`  
**Last suite baseline:** see `test-plan.md` (1.0.0: PASS=367 FAIL=0 SKIP=0)  

**Current command surface:** `list`, `add`, and `update` (`edit` aliases `update`). Client rows **11** / **12** / **13**. Secrets stay in mode `0600` files. `backup`, `restore`, and the grant verbs are not routed.
