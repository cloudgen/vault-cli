# Product review: folder-backup (JSON re-encode / inbound fidelity)

**Date:** 2026-08-17  
**Reviewer:** session agent  
**Product:** folder-backup `VERSION=1.8.1`  
**Ship unit:** `src/folder-backup`  
**Scope:** JSON sudoer file re-encode; `submit-sudoer-request` inbound body; review-plan gate **JR-1..8**  
**Method:** disk law + `tests/run.sh` + `sudoer-cli json-to-sudoers` on pretty emit  
**Baseline:** PASS=198 FAIL=0 SKIP=2 (2026-08-17)

## Summary

The 2026-08-15 JSON grant review greened **emit** (TP-22*) and a stub submit (TP-20 file count). Live inbound after real `sudoer-cli` dropped `backup` (INC-20260817-001). Law, suite, checklist **S15**, and this review plan now require **pretty convert + inbound verb count**. Ship unit **1.8.1** fail-closes when a readable inbound lost a required verb.

## Strengths

| Area | Notes |
|------|--------|
| Law | `requirement-sudoer-json-file` **1.1.0** §2.7a; three-layer **1.7.0** AC-21 |
| Suite | TP-**22e** pretty emit through real sibling; TP-**22f** stub **body** (not count only) |
| Review plan | `what-to-review` **JR-1..8**; S14 ≠ S15 |
| Honesty | `[OK]` / purpose are not completeness |

## Findings

### FB-JR-01 — Severity: P2 (host residual)
- **Area:** OPS  
- **Status:** open (product/suite closed; host queue not)  
- **Location:** `/var/sudoer-cli/sudoer-request/sudoer-20260817-folder-backup-leolio-add-1.json`  
- **Description:** Live inbound remains restore-only from the 1.6.1 allocator. Installed `/usr/local/bin/sudoer-cli` may still be 1.6.1.  
- **Impact:** Approving that file installs restore-only elev.  
- **Suggestion:** Reject/leave pending; install sudoer-cli **1.6.2+**; re-submit; `sudo cat` inbound and count `commands`.  
- **Cross-ref:** INC-20260817-001 · JR-8  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| JR-1 emit both verbs | Pass (print-sudoers + `.json`) |
| JR-2/JR-3 pretty convert | Pass (TP-22e) |
| JR-4 real submit inbound | Pass (TP-22e queue-root) |
| JR-5 readable inbound verify | Pass (1.8.1 submit fail-closed) |
| JR-6 suite 22e/22f | have |
| JR-7 S15 vs S14 | S15 on checklist; 2026-08-15 filled run marked S15 not run |
| OS-tool JSON | still refused (TP-22d) |

## Priority remediation order

1. Do not approve the 2026-08-17 restore-only inbound.  
2. Admin-install sudoer-cli 1.6.2; re-submit; confirm inbound has `backup` and `restore`.  
3. Optional: global `folder-backup` 1.8.1 so host binary matches dest src.

## Related

| Artifact | Role |
|----------|------|
| `reviews/what-to-review.md` | JR-1..8 |
| `reviews/test-plan.md` | TP-22e/22f |
| `docs/incidents/incident-20260817-001-submit-sudoer-request-drops-backup-verb.md` | Postmortem |
| `requirement-sudoer-json-file` 1.1.0 | §2.7a |

**Written by:** session agent  
**Review status:** Plan + suite Pass; host inbound residual **FB-JR-01** open
