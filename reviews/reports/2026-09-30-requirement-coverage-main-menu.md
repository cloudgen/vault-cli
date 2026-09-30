# Requirement sufficient check — numbered boards

**Date:** 2026-09-30  
**Product:** folder-backup  
**Ship unit:** `src/folder-backup` **1.18.0**  
**Suite:** `sh tests/run.sh` — PASS=436 FAIL=0 SKIP=2

## Claim

- ID: **C-full-product**
- Text: Registered product law owns the live ship unit, including folder archive backup and the numbered boards that replaced the flat work list.

## SSOT preflight

- Identity: **aligned**. `APP_NAME` is `folder-backup`. `VERSION` is `1.18.0`. `REPO_USER` is `cloudgen`. The channel URL in the ship unit matches the README install line.
- Notes: No foreign product name was introduced by the menu law. Bootstrap parent remains selfmanaged.

## Registered law

- Registry rows: 20 Active + 1 Withdrawn (`requirement-shell-cli-zero-arguments`). No new requirement file.
- Domain requirements present: **yes** (`requirement-domain-folder-backup` **1.6.7**).

Menu law bumped in this pass:

| Key | Version | What it now says |
|-----|---------|------------------|
| `requirement-shell-cli-default-interaction` | 1.7.0 | Front **1** / hidden **2** / **8** / **9**. Client **11** / **12** / **17**. Self **81**–**87**. Back **0**. Finished leaf redisplays the front. |
| `requirement-shell-cli-sudoers-submenu` | 1.1.0 | Printed rows **172** and **175**. **171** / **173** / **174** reserved. |
| `requirement-shell-cli-interface` | 1.9.1 | Handlers `app_cmd_menu` and `app_cmd_menu_self`. |
| `requirement-domain-folder-backup` | 1.6.7 | Test-purpose verbs off every numbered board. |
| `requirement-shell-output-requirements` | 1.1.2 | TTY short name bold. Explain stays italic light gray. |
| `requirement-bootstrap-chain` | 2.2.1 | Self board is front row **8**. |
| `requirement-shell-local-self-management` | 1.3.1 | `install` is also row **81**. |

## Live surfaces (summary)

- Lifecycle: local `install` / `uninstall` / `where-is-me`, plus channel `self-install` / `version-check` / `self-update` / `self-uninstall` / `self-management`. Dual and explicit. Empty argv is not an install.
- Menu: `app_cmd_menu`, `app_cmd_menu_client`, `app_cmd_menu_self`, `app_cmd_menu_sudoers`. `app_main_menu` and `app_default_self_loop` are aliases. Off-TTY `menu`, empty argv, and `self-management` are help.
- Domain: `backup`, `restore`, and the five grant/draft verbs. Test-purpose names stay on help under their own heading and stay off numbered boards.
- Help-only: none found. `sudoers` is not a dispatcher token.

## Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| Empty argv / `menu` / `main` | lifecycle | `requirement-shell-cli-default-interaction` | ok — Implemented |
| Front, client, self boards | lifecycle | same | ok — Implemented |
| Sudoers board **172** / **175** and reserved **171** / **173** / **174** | lifecycle | `requirement-shell-cli-sudoers-submenu` | ok — Implemented |
| Channel verbs and local `install` | lifecycle | `requirement-shell-cli-interface` · `requirement-bootstrap-chain` · `requirement-shell-local-self-management` | ok |
| `backup` / `restore` | domain | `requirement-domain-folder-backup` · `requirement-folder-archive-backup` | ok |
| Grant/draft verbs | domain | domain + three-layer + sudoer-json | ok |
| Menu ink | output | `requirement-shell-output-requirements` | ok — Implemented |
| In-tool `sudo` wrap | privilege | `requirement-shell-sudo-command` | **Gap** (allow table present; wrap not live) |
| Normal-user-only class detect | shell | default-interaction · interface · domain | **Gap** (no detect helper) |
| Compact JSON `--json` twins inside the grant | domain | `requirement-sudoer-json-file` · three-layer AC-26 | **Gap** — **TP-FOLDER-BACKUP-27** todo |

## Artifact filename + content

No new file kind. Archive names and the sudoer grant stay on their existing owners. This pass did not reopen those samples.

| Kind | Filename grammar | Sample basename | Content structure | Sample body | Paired convert | Status |
|------|------------------|-----------------|-------------------|-------------|----------------|--------|
| Dated archive | yes (backup REQ) | yes | yes | yes | n/a | ok (not re-opened) |
| Sudoer grant text + JSON | yes | yes | yes | yes | yes for text dual | ok for text; compact `--json` twins **Gap-no-sample** in the compact body (**TP-FOLDER-BACKUP-27**) |
| Menu | n/a (no file) | n/a | n/a | n/a | n/a | ok |

## TTY measurement

- In scope: **yes**
- Measure outside functions: **yes** (default-interaction §2.2)
- Helpers consume `TTY`: **yes**
- Choice read is current-shell `prompt_line` → `_prompt_line`: **yes** (**TP-CLI-20**)
- Normal-user class detect: **Gap**

## Named workflow machine

- In scope: **yes** (submit a JSON grant; this program does not approve it)
- Submit-when and verify stay on `requirement-three-layer-privilege-model` (not rewritten here)
- Dest approval fencing: class residual **no dest fence** (approver is the sibling queue, not this CLI)
- `fence-test`: **N/A**
- Human-facing §1.1: present on the files edited in this pass. No requirement file was added or stripped.

## TTY approver path

- In scope: **N/A** (no login-review verb)

## LPU / LPA operator

- In scope: **N/A** (no least-privilege account in this product)

## Dual mention

- In scope: **yes**
- Menu leaves are on the CLI interface table and on a topic owner (domain, local self-management, or bootstrap)
- Invocation samples for the five grant verbs are on the sudoers-board requirement
- Help text is not counted as the second mention

## Coding-style related REQ

- In scope: **yes**
- `requirement-shell-script-coding` is Active. This pass did not rewrite it.

## In-tool sudo allow table

- In scope: **yes**
- Studied allow table: **yes** on `requirement-shell-sudo-command`
- Wrap body: **Gap**

## Honesty

The numbered boards match the ship unit and the suite. Short names are bold on a terminal. Test-purpose rows are not printed. A finished leaf redisplays the front. Off-TTY `self-management` is help (**TP-CLI-15**).

These stay open and must not be treated as done:

- In-tool sudo wrap
- Normal-user-only detect helper
- Compact JSON `--json` twins (**TP-FOLDER-BACKUP-27**)
- Companion SHA-256 is implemented on download; the suite does not stand up a companion file (test-plan row remains **todo**)
- Elevated deposit **TP-FOLDER-BACKUP-07** / **08** skip when this run is not root and has no deposit sudoers

## Verdict

- **Sufficient with Gaps**
- The menu claim is owned and implemented. Older law-ahead-of-code gaps remain.

## Recommendations

- P0: none for the numbered boards.
- P1: keep the sudo wrap, the class detect helper, and compact `--json` twins marked Gap until the ship unit matches those MUST lines.
- P2: a suite companion for the SHA-256 download check; root or allowlisted sudo when deposit **07** / **08** should run.
