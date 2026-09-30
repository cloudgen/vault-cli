# Requirement sufficient check — zero-cli-verb self-install

**Date:** 2026-09-30  
**Product:** folder-backup  
**Ship unit:** `src/folder-backup` **1.19.0**  
**Suite:** `sh tests/run.sh` — PASS=455 FAIL=0 SKIP=2

## Claim

- ID: **C-full-product**
- Text: Registered product law owns the live ship unit. A terminal with no command opens the numbered boards. A pipe, no TTY, `--quiet`, or `--json` with no command places this program through `inst_self_install`.

## SSOT preflight

- Identity: **aligned**. `APP_NAME` is `folder-backup`. `VERSION` is `1.19.0`. `REPO_USER` is `cloudgen`. README Quick Installation leads with the raw-script pipe. That line is the place.
- Notes: Bootstrap parent remains selfmanaged. No new requirement file. `requirement-shell-cli-zero-arguments` is Active again and owns this split.

## Registered law

- Registry rows: 21 Active + 0 Withdrawn. No new requirement file.

Law bumped for this route:

| Key | Version | What it now says |
|-----|---------|------------------|
| `requirement-shell-cli-zero-arguments` | 1.2.0 | Interactive zero-cli-verb is the boards. Non-interactive zero-cli-verb calls `inst_self_install`. It does not print help and it does not call `inst_local_install`. |
| `requirement-shell-cli-default-interaction` | 1.8.0 | The boards stay the interactive tree. Named `menu` and `self-management` off a terminal stay help. |
| `requirement-shell-cli-interface` | 1.10.0 | No command is the zero-cli-verb split. `install` stays the local copy, mode 0755. |
| `requirement-bootstrap-chain` | 2.3.0 | A non-interactive line with no command is CLI self-install. |
| `requirement-shell-local-self-management` | 1.3.2 | A pipe is not this file’s `install`. |
| `requirement-shell-interactive-vs-noninteractive` | 1.1.2 | Off-TTY zero-cli-verb is self-install. |
| `requirement-class-software-dev` | 1.1.5 | Ship-unit install row matches the split. |

The numbered-board law from 1.18.0 stays. This pass did not reopen the menu shape.

## Live surfaces (summary)

- Zero-cli-verb: `app_main` clears `COMMAND`, then both the no-token gate and the post-parse empty-command gate do the same thing. Interactive (`TTY` and not JSON and not quiet) calls `app_cmd_menu`. Every other no-command line calls `inst_self_install`.
- Place: script `$0` copies (no download). Interpreter `$0` (a pipe) downloads. Your login lands at mode 0700. Root lands at mode 0755. A second run with force off says already installed.
- Named `menu` / `main` off a terminal stay help, including JSON help. Interactive `menu --json` still draws the boards.
- Off-TTY `self-management` stays help.
- Local `install` stays `inst_local_install`, mode 0755, and is self-board row **81**.

## Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| Interactive zero-cli-verb (boards) | lifecycle | `requirement-shell-cli-zero-arguments` · `requirement-shell-cli-default-interaction` | ok — Implemented (**TP-CLI-13**, **TP-CLI-23**) |
| Non-interactive zero-cli-verb (`inst_self_install`) | lifecycle | `requirement-shell-cli-zero-arguments` | ok — Implemented (**TP-CLI-07**, **TP-CLI-23**) |
| Named `menu` / `self-management` off a terminal | lifecycle | `requirement-shell-cli-default-interaction` | ok — Implemented (**TP-CLI-15**) |
| Local `install` mode 0755 | lifecycle | `requirement-shell-local-self-management` | ok — Implemented (**TP-LC-09**) |
| Numbered boards | lifecycle | `requirement-shell-cli-default-interaction` · sudoers-submenu | ok — unchanged from 1.18.0 |
| In-tool `sudo` wrap | privilege | `requirement-shell-sudo-command` | **Gap** (allow table present; wrap not live) |
| Normal-user-only class detect | shell | default-interaction · interface · domain | **Gap** (no detect helper) |
| Compact JSON `--json` twins inside the grant | domain | `requirement-sudoer-json-file` · three-layer AC-26 | **Gap** — **TP-FOLDER-BACKUP-27** todo |

## Artifact filename + content

No new file kind. The companion digest `src/folder-backup.sha256` stays the download check for a pipe. This suite still does not stand up that companion.

| Kind | Filename grammar | Sample basename | Content structure | Sample body | Paired convert | Status |
|------|------------------|-----------------|-------------------|-------------|----------------|--------|
| Dated archive | yes (backup REQ) | yes | yes | yes | n/a | ok (not re-opened) |
| Sudoer grant text + JSON | yes | yes | yes | yes | yes for text dual | ok for text; compact `--json` twins **Gap-no-sample** (**TP-FOLDER-BACKUP-27**) |
| Placed CLI | the program name | `folder-backup` | copy of this file, or a channel download | n/a | SHA-256 companion on download | place path Implemented; companion suite row remains **todo** |

## TTY measurement

- In scope: **yes**
- Measure outside functions: **yes** (startup `TTY`)
- Interactive gate reads that flag plus `JSON` and `QUIET`: **yes**
- Choice read is current-shell `prompt_line` → `_prompt_line`: **yes** (**TP-CLI-20**)
- Normal-user class detect: **Gap**

## Named workflow machine

- In scope: **yes** (submit a JSON grant; this program does not approve it)
- Submit-when and verify stay on `requirement-three-layer-privilege-model`
- Dest approval fencing: class residual **no dest fence**
- `fence-test`: **N/A**
- Human-facing §1.1: present on the route owners edited in this pass. No requirement file was added or stripped.

## TTY approver path

- In scope: **N/A** (no login-review verb)

## LPU / LPA operator

- In scope: **N/A** (no least-privilege account in this product)

## Dual mention

- In scope: **yes**
- The no-command route is on `requirement-shell-cli-interface` and on `requirement-shell-cli-zero-arguments`
- Local `install` stays on the interface table and on local self-management
- Help text is not counted as the second mention

## Coding-style related REQ

- In scope: **yes**
- `requirement-shell-script-coding` is Active. This pass did not rewrite it.

## In-tool sudo allow table

- In scope: **yes**
- Studied allow table: **yes** on `requirement-shell-sudo-command`
- Wrap body: **Gap**

## Honesty

`sh tests/run.sh` reported PASS=455 FAIL=0 SKIP=2. **TP-CLI-07** copies on an empty off-TTY line, checks mode 0700, and checks the second run. **TP-CLI-23** places for `--quiet`, `--json`, non-TTY `--debug`, and TTY `--json`, and keeps TTY `--debug` on the boards. Named `menu` off a terminal is still help (**TP-CLI-15**). Interactive `menu --json` still draws (**TP-CLI-14**).

The 1.18.0 menu report’s sentence that an off-TTY empty line is help describes that release. It is not the 1.19.0 route.

**1.20.0 note:** the place route in this report is unchanged. Named `menu` / `self-management` off a terminal now stop. That contract is `reviews/reports/2026-09-30-requirement-coverage-menu-contract.md`. The sentence above that names **TP-CLI-15** as help describes 1.19.0.

These stay open and must not be treated as done:

- In-tool sudo wrap
- Normal-user-only detect helper
- Compact JSON `--json` twins (**TP-FOLDER-BACKUP-27**)
- Companion SHA-256 is implemented on download; the suite does not stand up a companion file (test-plan row remains **todo**)
- Elevated deposit **TP-FOLDER-BACKUP-07** / **08** skip when this run is not root and has no deposit sudoers

## Verdict

- **Sufficient with Gaps**
- The zero-cli-verb claim is owned and implemented. The gaps above remain.

## Recommendations

- P0: none for this route.
- P1: keep the sudo wrap, the class detect helper, and compact `--json` twins marked Gap until the ship unit matches those MUST lines.
- P2: a suite companion for the SHA-256 download check; root or allowlisted sudo when deposit **07** / **08** should run.
