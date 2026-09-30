# Report: review-plan + test-plan revision — folder-backup 1.9.0

**Date:** 2026-08-17  
**Ship unit:** `src/folder-backup` **1.9.0**  
**Scope:** Align `reviews/what-to-review.md`, `reviews/test-plan.md`, `reviews/requirement-test-matrix.md`, and `reviews/lessons.md` to living law (independent generate, inbound fidelity, operator-readable errors). Run suite and fix.  
**Verdict:** **PASS**

## What was stale

| Plan | Gap |
|------|-----|
| `what-to-review` | Suite baseline still 235; P6 stopped at three-layer 1.8.0 / AC-22; no P10/P11; generate dest and operator-readable errors not on law/high-risk/gate tables; JR-6 omitted TP-24/25; harness S16 missing |
| `test-plan` | Last-run still “TP-24 generate” only; baseline coverage omitted generate dest and TP-25*; privilege map JR-1..8 |
| `requirement-test-matrix` | Operator-readable row existed; checklist note still S11–S13 only |
| `lessons` | L-OUTPUT-01 did not point at `requirement-operator-readable-error` / TP-25* |

## What changed in the plans

- Pre-flight **P6** → three-layer **≥1.10.0** + sudoer-json **≥1.2.0** + operator-readable-error **1.0.0**  
- **P10** independent generate dest (TP-24/24d · S16 · AC-24)  
- **P11** operator-readable errors (TP-25*)  
- High-risk: `fb_generate_sudoer_request`, inbound `out_die` jargon  
- JR-6/JR-9 + privilege map include generate and operator-readable TPs  
- Suite baseline **PASS=242 FAIL=0 SKIP=2**

## Suite

Ran `./tests/run.sh` after plan edits.

| Result | Count |
|--------|-------|
| PASS | 242 |
| FAIL | 0 |
| SKIP | 2 (TP-07/08 host deposit; not root / no allowlisted `sudo -n`) |

No product fix required this pass. TP-25/25b/25c remain **have**.

## Residual (not blockers)

| ID | Note |
|----|------|
| INC-20260817-001 | Live host inbound may still be restore-only until reject + sudoer-cli **1.6.2+** + re-submit. Do not approve collapsed files. |
| L-SUDOERS-06 / L-OUTPUT-01 | Open watch — re-check on next privilege review. |

## Non-goals

Online install, companion channel checksum, Type 0 `/etc` write.
