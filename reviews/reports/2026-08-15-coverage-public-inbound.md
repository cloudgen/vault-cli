# Product review: folder-backup (coverage + public inbound)

**Date:** 2026-08-15  
**Reviewer:** council (coverage follow-up)  
**Product:** folder-backup `VERSION=1.7.1`  
**Ship unit:** `src/folder-backup`  
**Scope:** Requirement sufficient-check P0–P2 close-out; `submit-sudoer-request` public inbound; reviews/tests alignment  
**Method:** disk read + `sh tests/run.sh`  
**Baseline:** `tests/run.sh` PASS=175 FAIL=0 SKIP=2 (2026-08-15)

## Summary

C-full-product coverage was **Sufficient with Gaps**. Those Gaps are closed in law and ship unit: inbound detect matches AC-16, artifact samples exist, TTY/temp samples exist, help/about name `/var/sudoer-cli/sudoer-request`. This dest remains a Type 0 **submitter**, not the sudoer-cli approval machine.

## Strengths

| Area | Notes |
|------|--------|
| Domain ownership | Sole Active `requirement-domain-folder-backup`; every dispatcher verb has an owner |
| Install mode | Local-only; no silent online dual-path |
| Submit compose | Sibling allocates JSON; this CLI does not `mkdir` inbound or write `/etc` |
| Suite | Automated detect + env-override + no-mkdir cases (TP-21 / 21b) |

## Findings

### FB-INB-01 — Severity: P2 (medium)
- **Area:** TEST  
- **Status:** **fixed**  
- **Location:** `fb_detect_sudoer_inbound`; `tests/test_domain_folder_backup.sh`  
- **Description:** Detect probed only `sudoer-approving`; law required public inbound first.  
- **Impact:** Submit failed on a host that already had `/var/sudoer-cli/sudoer-request`.  
- **Suggestion:** AC-16 order + TP-21/21b (applied).  
- **Cross-ref:** `requirement-three-layer-privilege-model` §2.3.3c · L-INBOUND-01  

### FB-COV-01 — Severity: P2 (medium)
- **Area:** DOC  
- **Status:** **fixed**  
- **Location:** archive / privilege / interactive / storage REQs  
- **Description:** Missing worked archive basename, update JSON sample, TTY measure-outside-functions wording, `util_mktemp` sample.  
- **Impact:** Sufficient-check Step 3c/3d Gaps.  
- **Suggestion:** Samples and consume-`TTY` law (applied).  

### FB-VER-01 — Severity: P3 (low)
- **Area:** HYG  
- **Status:** **fixed**  
- **Location:** class residual / reviews stamps  
- **Description:** Class residual and review headers lagged ship `VERSION`.  
- **Impact:** Agent maps read stale version.  
- **Suggestion:** Align to **1.7.1** this change.

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| Type 0 mkdir inbound | Fail-closed; TP-21 |
| Deposit vs inbound | `/var/backup/folder-backup` is not inbound |
| Help ↔ dispatcher | Match; public path in help |
| LPU/LPA on this dest | N/A — compose only |
| Online install | Still intentionally absent |

## Priority remediation order

1. None open for this scope.  
2. Optional later: host-elevated TP-07/08 when production sudoers exists.  
3. Optional: pair live `print-sudoers` emit with the short JSON sample (law already pairs a reduced grant).

## Related

| Artifact | Role |
|----------|------|
| `reviews/test-plan.md` | TP map |
| `reviews/requirement-test-matrix.md` | REQ → TP |
| `reviews/lessons.md` | L-INBOUND-01 |
| `docs/requirements/requirement-three-layer-privilege-model.md` | Submit law 1.5.0 |

**Written by:** coverage follow-up  
**Review status:** Findings closed for this scope  
