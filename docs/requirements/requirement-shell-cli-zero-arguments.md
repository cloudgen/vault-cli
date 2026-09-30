**file**: docs/requirements/requirement-shell-cli-zero-arguments.md  
**Status**: Active (Version 1.2.1)  
**Area**: shell  
**Key**: `requirement-shell-cli-zero-arguments`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This file owns a **zero-cli-verb** line: no command after switches. A switch is not a command.

On a real terminal, with quiet and json off, that line opens the numbered boards (`requirement-shell-cli-default-interaction`). A pipe (`curl … | sh`), or `--quiet` / `--json` with no command, or the same line with no terminal, **places this program** (`inst_self_install`). It must not print help. It must not run local `install`.

Sibling shape: `sshd-cli` uses the same split (terminal → menu, non-interactive → CLI self-install). This product’s place target is folder-backup, not an OpenSSH payload.

### 1.1 Human-facing

**In one sentence:** On a terminal, `folder-backup` with no command opens the numbered boards; a pipe, or `--quiet` / `--json` with no command, places this program (or says it is already installed).

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | A terminal with no command, or a pipe with nobody to answer | `folder-backup` on a TTY · `curl -fsSL …/src/folder-backup \| sh` |
| The other role | Named verbs stay named | `folder-backup help` · `folder-backup install` · `folder-backup menu` |
| Not this file | Board membership; local copy mode 0755 | `requirement-shell-cli-default-interaction` · `requirement-shell-local-self-management` |

| Includes | Excludes |
|----------|----------|
| Zero-cli-verb: bare name, pipe, and switches with no verb (`--debug`, `--force`, `--quiet`, `--json`) | A line that still has a verb (`folder-backup --json version`, `folder-backup help`, `folder-backup menu`) |
| Interactive → numbered boards; non-interactive → `inst_self_install` | Help as the pipe default; aliasing `install` to `self-install` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| First place from the internet | The pipe has no human. The tool places itself. A normal login lands in `~/.local/bin` (mode `0700`). Root lands in `/usr/local/bin` (mode `0755`). | `curl -fsSL https://raw.githubusercontent.com/cloudgen/folder-backup/main/src/folder-backup \| sh` |
| Run it on a terminal with no command | Numbered boards. A switch such as `--debug` is still no command. It must not place and must not dump help. | `folder-backup` or `folder-backup --debug` |
| Quiet or JSON with no command | No menu and no help. The tool places the program, or says it is already installed. | `folder-backup --quiet` · `folder-backup --json` |

**Zero-cli-verb** means no command after switches. It is not `$# -eq 0` before flag parse. **Local `install`** copies the running file at mode `0755` and is a different verb.

---

## 2. Core Rules (Mandatory)

### 2.1 Definitions

| Term | Definition for folder-backup |
|------|-------------------------------|
| **Zero-cli-verb** | No routed verb after global switches are parsed. Switches are allowed. `folder-backup`, `folder-backup --debug`, `folder-backup --quiet`, and `folder-backup --json` are this shape. `folder-backup --json version` is not. |
| **Interactive zero-cli-verb** | Zero-cli-verb and `TTY=1` and `JSON=0` and `QUIET=0`. Route to `app_cmd_menu`. |
| **Non-interactive zero-cli-verb** | Zero-cli-verb and (no TTY, or `JSON=1`, or `QUIET=1`). Call `inst_self_install`. |
| **CLI self-install** | `inst_self_install`: copy when `$0` is this file; download when `$0` is the shell. Local dest mode **0700**. Global dest mode **0755**. Already installed and force off → success no-op. |
| **Local install** | Verb `install` → `inst_local_install`, mode **0755**. Not this file’s route. |

### 2.2 Split

1. An **interactive** zero-cli-verb **MUST** call `app_cmd_menu`. It **MUST NOT** call `inst_self_install`, `inst_local_install`, or `app_help`. `--debug` and `--force` do not change this route.  
2. A **non-interactive** zero-cli-verb **MUST** call `inst_self_install` and return its status. It **MUST NOT** open the boards, **MUST NOT** call `app_help`, and **MUST NOT** call `inst_local_install`. This includes `--quiet` and `--json` with no verb, including on a terminal.  
3. `folder-backup help` is the usage path. `folder-backup menu` and `folder-backup main` are named menu verbs. Those lines are not zero-cli-verb. Off a terminal, those named verbs stop (`requirement-shell-cli-default-interaction`). This file does not own that stop.  
4. Bootstrap **MUST** call `app_main "$@"`. No basename gate.  
5. A second non-interactive zero-cli-verb **MUST** succeed without `--force` when the managed binary is already present. The human line **MUST** say already installed. JSON **MUST** be a success object, not help JSON.  
6. When no managed binary is present, non-interactive zero-cli-verb **MUST** place one or fail closed. A missing network on a **copy** (`$0` is the script) **MUST** still place. A download failure **MUST** be non-zero.  
7. `COMMAND` **MUST** start empty. An inherited or default `help` **MUST NOT** turn a zero-cli-verb line into help.

### 2.3 Detect

| Case | Condition | Non-interactive, force off |
|------|-----------|----------------------------|
| **Not installed** | `inst_is_installed` false | Place into the privilege-correct path |
| **Installed** | Managed binary present | Exit 0. Human: already installed. JSON: success. No help. No menu. No second download. |

| Invoker | Target |
|---------|--------|
| root (`id -u` 0) | `${GLOBAL_BIN}/folder-backup` (default `/usr/local/bin/folder-backup`), mode **0755** |
| non-root | `${USER_BIN}/folder-backup` (default `${HOME}/.local/bin/folder-backup`), mode **0700** |

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** A pipe must not hang and must not pretend to succeed without placing.  
- **Intentional:** One split. Terminal boards. Non-interactive place. Local `install` stays its own verb.  
- **Anti-fragile:** Copy from the file you already have when `$0` is that file, even if `SCRIPT_URL` is dead.  
- **Over-protect:** Do not treat `--json` with no verb as JSON help.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route a non-interactive zero-cli-verb line to `app_help`.  
2. Route an interactive zero-cli-verb line to `inst_self_install` or `inst_local_install`.  
3. Alias `install` to `inst_self_install`.  
4. Withdraw this file while the pipe one-liner is the install path.  
5. Default `COMMAND` to `help` so a line with only switches becomes help.  
6. Hang a menu under `curl | sh`.

**Violating this rule is a critical empty-argv regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Off-TTY empty argv places the CLI (copy when `$0` is the script), exit 0, not help, not the boards |
| AC-2 | A second off-TTY empty argv says already installed and exits 0 |
| AC-3 | Interactive empty argv and interactive `--debug` with no verb open the boards and do not place |
| AC-4 | `--quiet`, `--json`, and off-TTY `--debug` with no verb place the CLI. `--json version` stays version |
| AC-5 | Local dest mode after a non-root place is **0700**. `install` remains mode **0755** and is not this route |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-default-interaction` | Interactive zero-cli-verb boards; named `menu` / `main` |
| `requirement-shell-cli-interface` | Command table; `self-install` copy/download and dest modes |
| `requirement-shell-local-self-management` | Local `install` is not this route |
| `requirement-bootstrap-chain` | Channel kept; this split is the empty-argv extend |
| `requirement-shell-interactive-vs-noninteractive` | TTY vs pipe; no hang |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY empty argv copies, mode 0700, second run already installed |
| **TP-CLI-13** | same | **have** — interactive empty argv is the front board |
| **TP-CLI-23** | same | **have** — `--quiet` / `--json` / off-TTY `--debug` place; TTY `--debug` is the front and does not place; `--debug version` stays version |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Type N: empty argv always help |
| 2026-08-28 | **Withdrawn** 1.1.0 | Superseded by default-interaction case 2 (TTY boards; off-TTY help) |
| 2026-09-30 | **Withdrawn** 1.1.1 | Residual fence: empty argv must not install-ensure |
| 2026-09-30 | **Active** 1.2.0 | User order: match sibling sshd-cli. Interactive zero-cli-verb is the boards. Non-interactive zero-cli-verb is `inst_self_install`, not help. Local `install` stays a different verb. |
| 2026-09-30 | **Active** 1.2.1 | Portable empty-argv law no longer treats flags-only `--json` as JSON help. Named `menu` off a terminal is owned by default-interaction (stop, not this file). The place route is unchanged. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
