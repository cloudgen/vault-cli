# Report: requirement coverage + test plan — folder-backup 1.12.0

**Date:** 2026-08-28  
**Mode:** C-full-product coverage (SK-REQUIREMENT-SUFFICIENT-CHECK) + shell CLI test-plan review (SK-SHELL-CLI-TEST)  
**Status:** open items (documented Gaps)

## Summary

Claim **C-full-product**. Case 2 empty argv is owned and implemented: TTY numbered list, off-TTY help, never install-ensure. `requirement-shell-cli-zero-arguments` is Withdrawn and is not a second live owner. Dual mention for `menu`/`main` holds (CLI-interface + default-interaction). Tests lock the new path (TP-CLI-07 / 13 / 15). Remaining Gaps are pre-existing or documented: TP-CLI-17 (help heading split), TP-FOLDER-BACKUP-27 (compact JSON `--json` twins), missing coding-style REQ, missing §1.1 on many older REQs.

Lessons re-checked: **L-TYPE-N-01** (off-TTY still not ensure) · **L-CASE2-01** (TTY empty argv is the list).

## Requirement sufficient check

### Claim
- ID: C-full-product
- Text: Full specialized folder-backup including domain backup/restore, sudoer JSON, and case 2 default interaction.

### SSOT preflight
- Identity: aligned (`APP_NAME=folder-backup`, `VERSION=1.12.0`, `REPO_USER=cloudgen`, empty `SCRIPT_URL`)
- Notes: README badge and CHANGELOG 1.12.0 match ship unit.

### Registered law
- Registry rows: 19 (18 Active + 1 Withdrawn)
- Domain requirements present: yes (`requirement-domain-folder-backup`)
- Install mode: local-only (not dual-mode)

### Live surfaces (summary)
- Lifecycle: install, uninstall, where-is-me, version, about, help, empty argv, menu, main
- Domain: backup, restore, print-sudoers, print-sudoers-install-script, remove-project-sudoers, generate-sudoer-request, submit-sudoer-request
- Help-only: none (setup remains forbidden / not-yet-wired)

### Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| Empty argv TTY list / off-TTY help | lifecycle | `requirement-shell-cli-default-interaction` | ok |
| `menu` / `main` | lifecycle | CLI-interface + default-interaction | ok |
| Flags-only `--json` → JSON help | lifecycle | default-interaction §2.2 | ok (tested TP-CLI-15) |
| Type O empty-argv install-ensure | lifecycle | Absent by design | ok (forbidden) |
| `requirement-shell-cli-zero-arguments` | lifecycle | Withdrawn | ok (not live owner) |
| install / uninstall / where-is-me | lifecycle | local-self-management | ok |
| backup / restore | domain | domain + folder-archive-backup | ok |
| print/generate/submit/remove sudoers | domain | domain + three-layer + sudoer-json | ok |
| Compact JSON `--json` twins | privilege | sudoer-json 1.4.0 AC-26 | Gap (text have; compact todo TP-27) |
| Help test-purpose heading apart | help | CLI-interface AC-9 | Gap (TP-CLI-17 todo) |
| Coding-style related REQ | class | none on disk | Gap (pre-existing) |
| §1.1 Human-facing on every REQ | law quality | mixed | Gap (older REQs lack it) |

### Artifact filename + content
JSON sudoer + text dual + per-user fragment: grammar and samples live on sudoer-json / three-layer. Compact `--json` twin sample is Gap until emit matches law.

### TTY measurement (Step 3d)
- In scope: yes
- Measure outside functions: yes (`TTY=0` then `[ -t 0 ] && [ -t 1 ] && TTY=1` at ship-unit top)
- Helpers consume TTY: yes (`app_main_menu` reads `TTY`)

### Named workflow machine (Step 3e)
- In scope: yes (file-based JSON submit; dest approve is sibling)
- Class residual: considered — no dest approver / no dest fence on this product
- Type 0 fence-test: N/A (no dest Fence on this CLI)

### TTY approver path (Step 3f)
- In scope: N/A (no login-hook review verb)

### LPU / LPA operator (Step 3g)
- In scope: N/A (no dedicated LPU on this product)

### Dual mention (Step 3h)
- In scope: yes
- `menu` / `main`: CLI-interface + default-interaction + invocation samples
- Empty argv is not a routed-verb; owned on default-interaction
- Help code not counted as second mention: yes

### Coding-style related REQ (Step 3i)
- In scope: yes (software-development)
- Language-matched Active file: **Gap** (`requirement-shell-script-coding` absent)
- Pre-existing; not introduced by case 2

### Honesty / consistency
- Case 2 Implementation Notes match `app_main` (`$# -eq 0` → `app_main_menu`)
- Zero-arguments Withdrawn; registry matches
- Compact JSON `--json` twins honestly Gap
- Help examples now lead with bare `folder-backup`

### Verdict
- **Sufficient with Gaps**
- One-line rationale: Case 2 empty argv and domain ops are owned; compact JSON twins, help heading split, coding-style REQ, and older §1.1 gaps remain documented.

### Recommendations
- P0: none for case 2 (ship + tests match law)
- P1: emit compact JSON `--json` twins (close TP-FOLDER-BACKUP-27); split help test-purpose heading (TP-CLI-17)
- P2: specialize `requirement-shell-script-coding`; add §1.1 to remaining Active REQs

## Test plan review (SK-SHELL-CLI-TEST)

| Area | Verdict |
|------|---------|
| Isolated HOME / USER_BIN | keep |
| Case 2 empty argv | TP-CLI-07 off-TTY help; TP-CLI-13 TTY four labels; TP-CLI-15 flags-only `--json` |
| Type O empty-argv install | n/a (local-only) |
| Type 1 TTY privilege traps | n/a for package-ensure; deposit uses allowlisted `sudo -n` (TP-07/08 skip without sudoers) |
| JSON re-encode | TP-22e/22f have |
| TP-CLI-17 | todo (honest) |
| TP-FOLDER-BACKUP-27 | todo (honest Gap) |

## Issues
### Issue 1 -- Severity: suggestion
- File: tests/test_cli.sh (fixed this run)
- Description: TP-CLI-13 empty argv only asserted backup + Exit 9
- Suggestion: Mirror four labels — applied
- Lesson: L-CASE2-01
- Test: TP-CLI-13
- Status: closed

### Issue 2 -- Severity: suggestion
- File: tests/test_cli.sh (fixed this run)
- Description: flags-only `--json` untested
- Suggestion: TP-CLI-15 asserts — applied
- Test: TP-CLI-15
- Status: closed

### Issue 3 -- Severity: suggestion
- File: src/folder-backup app_help (fixed this run)
- Description: examples led with `menu`
- Status: closed

### Issue 4 -- Severity: suggestion
- File: reviews/test-plan.md TP-FOLDER-BACKUP-27
- Description: `--json` twins MUST/Gap missing from plan
- Status: closed (row **todo**)

### Issue 5 -- Severity: suggestion
- File: reviews/requirement-test-matrix.md suite counts
- Description: stale PASS=242
- Status: closed
