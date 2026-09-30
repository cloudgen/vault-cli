# Report: human readability + requirement coverage — folder-backup 1.16.3

**Date:** 2026-09-06  
**Mode:** C-full-product coverage (SK-REQUIREMENT-SUFFICIENT-CHECK) + SK-WRITE-README / SK-WRITE-HUMAN-INTRO + tests  
**Status:** Gaps remain (documented)  
**Suite:** PASS=375 FAIL=0 SKIP=2

## Summary

Claim **C-full-product**. README Description now uses the voice pack (one sentence, three boxes, includes/excludes, practice). Every registered requirement has **§1.1 Human-facing**. Related shell files have a section **Under command line for normal user only**. Help lists grant-emit testers apart (**TP-CLI-17 have**). New Active law: `requirement-shell-script-coding` (specialize-in home) and `requirement-shell-sudo-command` (studied allow table; wrap Gap). Compact JSON `--json` twins remain Gap (**TP-FOLDER-BACKUP-27**). Detect of Termux / Git Bash / Windows cmd is not in the ship unit yet (honest Gap).

Lessons re-checked: **L-TYPE-N-01** · **L-CASE2-01** · **L-INBOUND-02** · **L-OUTPUT-01** · **L-MENU-SUDOERS-01**.

## Requirement sufficient check

### Claim
- ID: C-full-product
- Text: Full specialized folder-backup including domain backup/restore, sudoer JSON, case 2 default interaction, coding-style, and in-tool sudo law.

### SSOT preflight
- Identity: aligned (`APP_NAME=folder-backup`, `VERSION=1.16.3`, `REPO_USER=cloudgen`, empty `SCRIPT_URL`)
- Notes: README badge and CHANGELOG 1.16.3 match ship unit.

### Registered law
- Registry rows: 21 (20 Active + 1 Withdrawn)
- Domain requirements present: yes (`requirement-domain-folder-backup`)
- Coding-style related REQ: yes (`requirement-shell-script-coding`)
- In-tool sudo REQ: yes (`requirement-shell-sudo-command`) — wrap **Gap**
- Install mode: local-only (not dual-mode)

### Live surfaces (summary)
- Lifecycle: install, uninstall, where-is-me, version, about, help, empty argv, menu, main
- Domain: backup, restore, print-sudoers, print-sudoers-install-script, remove-project-sudoers, generate-sudoer-request, submit-sudoer-request
- Help-only: none

### Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| Empty argv TTY list / off-TTY help | lifecycle | default-interaction | ok |
| `menu` / `main` | lifecycle | CLI-interface + default-interaction | ok |
| Help grant-emit heading split | help | CLI-interface AC-9 | ok (TP-CLI-17 have) |
| install / uninstall / where-is-me | lifecycle | local-self-management | ok |
| backup / restore | domain | domain + folder-archive-backup | ok |
| print/generate/submit/remove sudoers | domain | domain + three-layer + sudoer-json | ok |
| Compact JSON `--json` twins | privilege | sudoer-json AC-26 | Gap (text have; compact todo TP-27) |
| Coding-style related REQ | class | `requirement-shell-script-coding` | ok |
| In-tool sudo wrap | privilege | `requirement-shell-sudo-command` | Gap (`util_sudo` missing; OS-tool `sudo -n`) |
| Termux / Git Bash / Windows cmd detect | privilege | Under command line sections | Gap (no helper) |
| §1.1 Human-facing on every REQ | law quality | all registered files | ok |

### Artifact filename + content
JSON sudoer + text dual + per-user fragment: grammar and samples live on sudoer-json / three-layer. Compact `--json` twin sample is Gap until emit matches law.

### TTY measurement (Step 3d)
- In scope: yes
- Measure outside functions: yes
- Helpers consume TTY: yes

### Named workflow machine (Step 3e)
- In scope: yes (file-based JSON submit; dest approve is sibling)
- Class residual: considered — no dest approver / no dest fence
- Type 0 fence-test: N/A

### TTY approver path (Step 3f)
- In scope: N/A

### LPU / LPA operator (Step 3g)
- In scope: N/A

### Dual mention (Step 3h)
- In scope: yes
- Routed verbs on CLI-interface + topic-owner
- Help code not counted as second mention: yes

### Coding-style related REQ (Step 3i)
- In scope: yes
- Language-matched Active file: **yes** (`requirement-shell-script-coding`)
- Specialize-in intention: yes
- Own-or-point: yes

### In-tool sudo allow table (Step 3j)
- In scope: yes
- Studied dest + argv table: **yes** on `requirement-shell-sudo-command`
- Wrap Implemented: **Gap**

### Human-intro standard
- Every registered REQ has §1.1
- Class §1.1 says **project nature** (not project class as the people-facing word)
- README Description: one sentence + boxes + includes/excludes + practice

### Honesty / consistency
- Compact JSON `--json` twins still Gap (law > code)
- Sudo wrap / class detect still Gap (law > code)
- TP-CLI-17 closed in code + suite

### Verdict
- **Sufficient with Gaps**
- One-line rationale: Domain and lifecycle owned; coding-style and sudo allow table registered; wrap, class detect, and compact `--json` twins remain honest Gaps.

### Recommendations
- P0: none for this claim (unowned surfaces closed)
- P1: `util_sudo` + re-exec `backup <folder>`; compact JSON `--json` twins (TP-27); Termux/Git Bash/Windows cmd detect helper
- P2: isolate TP-FOLDER-BACKUP-07/08 from live `/var/backup` when possible

## Issues closed this turn

| ID | Was | Now |
|----|-----|-----|
| Help AC-9 / TP-CLI-17 | todo / Gap | have |
| §1.1 missing on older REQs | Gap | have |
| coding-style REQ | missing | Active 1.0.0 |
| sudo allow table | missing | Active 1.0.0 (wrap Gap) |
| README Type-0 / no practice | Fail voice pack | Pass |
| CLI tests mkdir live HOME | isolation hole | `ci_isolated_env` at CLI suite start |

## Issues still open

| ID | Severity | Status |
|----|----------|--------|
| TP-FOLDER-BACKUP-27 compact `--json` twins | P2 | open |
| `util_sudo` wrap + re-exec | P1 | open (Gap) |
| Command-line-for-normal-user-only detect | P2 | open (Gap) |
