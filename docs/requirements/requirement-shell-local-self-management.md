**file**: docs/requirements/requirement-shell-local-self-management.md  
**Status**: Active (Version 1.3.2)  
**Area**: shell  
**Key**: `requirement-shell-local-self-management`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **local self-managed lifecycle** of the folder-backup POSIX shell CLI: **`install`**, **`uninstall`**, and **`where-is-me`**, plus the local diagnostics package contract for **`version`**, **`about`**, and **`help`** (wiring owned with CLI interface).

**This file owns the local copy pair.** `install` copies the running file (mode **0755**). `uninstall` removes that managed binary. `where-is-me` reports paths. The channel verbs `self-install`, `version-check`, `self-update`, `self-uninstall`, and `self-management` are live and are owned by `requirement-shell-cli-interface` and `requirement-bootstrap-chain`. Do not alias `install` to `self-install`. A terminal with no command is the numbered boards. A pipe with no command is `self-install`, not this file’s `install`. On a terminal, `install` is also self-board row **81** (`requirement-shell-cli-default-interaction`). `uninstall` and `where-is-me` stay typed commands.

### 1.1 Human-facing

**In one sentence:** Copy this program onto your PATH with `folder-backup install`; remove it with `uninstall`; ask where it lives with `where-is-me`. Downloading a new copy is the separate verb `self-install`.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Install to `~/.local/bin` | `sh src/folder-backup install` |
| Admin | Install to `/usr/local/bin` before a durable sudoers grant | `sudo sh src/folder-backup install` |
| Not this file | Backup/restore verbs | `requirement-domain-folder-backup` |

| Includes | Excludes |
|----------|----------|
| `install` / `uninstall` / `where-is-me`; mode **0755** | Treating `install` as a download |
| Local `version` / `about` / `help` | The channel verbs (they have their own rows on the interface) |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/folder-backup` | ship unit | install source |
| `~/.local/bin/folder-backup` | user bin | day-to-day |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install for yourself | No root. Mode is `0755` so others can run it. | `sh src/folder-backup install` |
| Remove it | Confirm, or `--force` in a script. | `folder-backup uninstall --force` |

---

## 2. Core Rules (Mandatory)

### 2.1 Local lifecycle command pair

| Feature | Command | Meaning |
|---------|---------|---------|
| Local install | **`install`** | Copy **running** ship unit → privilege-correct bin; **no** network |
| Local uninstall | **`uninstall`** | Remove **managed** binary only; confirm / `--force` |
| Local refresh | **`install --force`** | Replace managed binary from **this** running ship unit |
| Where-is-me | **`where-is-me`** | Report running path + managed install path + installed flag |

**Not this file’s verbs:** `self-install`, `self-uninstall`, `self-update`, `version-check`, `self-management`. They are live on the dispatcher. This file does not define them and must not delete them.

### 2.2 Local diagnostics (required companions)

| Feature | Command | Network |
|---------|---------|---------|
| **Local version** | `version` | **MUST NOT** fetch remote |
| About | `about` | Diagnostics, including channel `script_url` and domain fields |
| Help | `help` | Lists local lifecycle, channel verbs, and domain commands |

### 2.3 Local install rules

1. Source **MUST** be the currently executing ship unit when resolvable — **not** a URL.  
2. Target **MUST** be root → `${GLOBAL_BIN}/${APP_NAME}`; non-root → `${USER_BIN}/${APP_NAME}` unless **`--global`** / `FORCE_GLOBAL=1` is set.  
3. Defaults: `GLOBAL_BIN=/usr/local/bin`; `USER_BIN=${HOME}/.local/bin`.  
4. Create target bin dir when missing; fail loud if not writable.  
5. Atomic place: stage → set mode → `mv` onto final path (or equivalent `install -m`).  
6. Idempotent: already installed + force off → success no-op **for content**; mode **MUST** still be healed to the required mode when the installer can write the target (see §2.3.1).  
7. **MUST NOT** require network for install.  
8. **`install --global`** (or `FORCE_GLOBAL=1`): target **`${GLOBAL_BIN}/${APP_NAME}`**; if not writable, fail with clear root/sudo guidance.  
9. For hosts that will admin-install **sudoers**, operators **SHOULD** use global install (root). Local install alone is **not** production-secure for elevation (see `requirement-three-layer-privilege-model` §2.3.1a).

### 2.3.1 Installed binary mode (multi-user runnable) — mandatory

This product ships as a **POSIX shell script** (interpreted). Execution by any non-owner requires the **read** bit for that class, not execute alone.

| Rule | Requirement |
|------|-------------|
| **Final mode** | Managed install **MUST** set absolute mode **`0755`** (`rwxr-xr-x`) on the installed binary |
| **Forbidden weak form** | **MUST NOT** rely on `chmod +x` alone after `mktemp`/`cp` — `0600 \| 0111 = 0711` yields `rwx--x--x`, which **breaks** non-owner runs of shell scripts |
| **Global multi-user** | After root/global install to `${GLOBAL_BIN}`, **any** host user (including root and unprivileged accounts) **MUST** be able to execute `${GLOBAL_BIN}/${APP_NAME}` (subject only to path/exec mount policy) |
| **User-bin** | Local install **MUST** also use **`0755`** so the owner always has a normal runnable script (and heal survives umask / prior bad modes) |
| **Not world-writable** | Mode **MUST NOT** grant group/other write (`o+w` / `g+w` forbidden for the managed binary) |
| **Mode heal** | If the managed path already exists and force is off, install **MUST** still attempt `chmod 0755` on that path when permitted (fix broken `0700`/`0711` installs without requiring `--force`) |
| **Verify** | After place (and after heal), the installer **SHOULD** confirm the path is readable and executable by the installing process; fail loud if place left a non-executable file |

**Rationale (CIAO):** Global install is the production trust path for elevation. A root-owned `0711` ship unit looks “installed” (`-x`) but denies normal users — anti-fragile install must leave a **usable multi-user CLI**, not merely an owner-only script.

### 2.4 Local uninstall rules

1. The local remove command name **MUST** be **`uninstall`**. `self-uninstall` is the separate channel remove.  
2. Target **MUST** be the managed binary only.  
3. Absent → success no-op.  
4. Interactive confirm unless `--force`; non-interactive/json/quiet without force → **fail closed** (`confirm_required`).  
5. **MUST NOT** delete domain data, `/var/backup` archives, home trees, or unrelated binaries.  
6. After remove, human mode **SHOULD** warn that host sudoers fragments under **`/etc/sudoers.d/folder-backup-<user>`** (and any legacy `/etc/sudoers.d/folder-backup`) are **not** removed by uninstall; admin must remove or reinstall fragment separately when leaving test elevation.

### 2.5 Where-is-me rules

1. Report absolute running path when resolvable.  
2. Report expected managed install path and whether installed.  
3. Honest degradation when `$0` is not a file path.  
4. JSON at least: `running_path`, `install_path`, `installed`.  
5. Output via `out_*` / `out_json` only.

### 2.6 Config variables (local)

| Variable | Role | Default / note |
|----------|------|----------------|
| `APP_NAME` | Binary basename SSOT | hard-assign `folder-backup` |
| `VERSION` | Local version SSOT | hard-assign in the ship unit (see `src/folder-backup`; do not pin a stale number here) |
| `GLOBAL_BIN` | System-wide bin | `/usr/local/bin` |
| `USER_BIN` | Per-user bin | `${HOME}/.local/bin` |
| `FORCE` | Replace / skip confirm | `0` |
| `FORCE_GLOBAL` | Force install/operate on global path | `0` (`install --global`) |
| `ALLOW_TEST_LOCAL_SUDOERS` | Allow `print-sudoers` under test_local tier | `0` (see three-layer privilege) |
| `SCRIPT_URL` / `REPO_*` / `CHECKSUM` | Channel for `self-install` / `version-check` / `self-update` | **Not** required for `install` |

### 2.7 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / binary** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Primary install path story** | Type 0 day-to-day: `${HOME}/.local/bin/folder-backup`; production elevation: `/usr/local/bin/folder-backup` |
| **Handlers** | `inst_local_install`, `inst_local_uninstall`, `app_where_is_me`, `app_version` |
| **Detect** | `inst_is_installed` / privilege-correct path helpers |
| **Channel verbs** | Live beside this pair. Owned by the CLI interface and the bootstrap chain. |

### 2.8 Why This Requirement Exists (CIAO)

- **Principle 9 – Command types**: Type 0 local lifecycle only for place/remove.  
- **Principle 10 – Least privilege**: User bin without root when possible.  
- **Principle 3 – Anti-fragile**: Works offline / air-gapped.  
- **Principle 16 – Interactive**: Uninstall confirm contract.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** `install` / `uninstall` / `where-is-me` stay your-own-login copies into user bin — **MUST NOT** wrap `sudo` or write `/etc` on that class.

| MUST | MUST NOT |
|------|----------|
| Local install as this login | Global install via `sudo` on this class |
| Help / version / about | Recommend `sudo curl \| sh` |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

**Implementation Notes:** ship unit has **no detect helper yet** (Gap). User-bin install already needs no sudo.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: `install` does not use the network.  
- **Intentional**: This file’s verbs are `install` / `uninstall` / `where-is-me`.  
- **Anti-fragile**: Idempotent place/remove.  
- **Over-protect**: Do not alias `install` to `self-install`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Replace local `uninstall` with `self-uninstall` as the only remove verb.  
2. Require `SCRIPT_URL` for `install`.  
3. Route a zero-cli-verb line to `inst_local_install`. Non-interactive place is `inst_self_install` (`requirement-shell-cli-zero-arguments`).  
4. Delete user data or `/var/backup` content during uninstall.  
5. Fetch remote version inside `version`.  
6. Install the managed binary with execute-only group/other bits (`0711` / `chmod +x` after `0600` stage) — **must** keep absolute **`0755`** so global install remains multi-user runnable for a shell ship unit.

**Violating this rule is a critical install-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | `install` copies ship unit to user or global bin without network |
| AC-2 | `uninstall` removes managed binary only with confirm/`--force` contract |
| AC-3 | `where-is-me` reports paths + installed flag |
| AC-4 | `version` prints the ship-unit VERSION and does not fetch a remote version |
| AC-5 | `install` does not download; channel verbs stay routed under the CLI interface |
| AC-6 | Installed managed binary mode is **`0755`** (not `0711` / owner-only) after install |
| AC-7 | Global install is executable by a non-owner account (shell script remains readable) |
| AC-8 | Re-running `install` without `--force` heals a broken mode (`0700`/`0711` → `0755`) when writable |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Command table + flags |
| `requirement-shell-cli-default-interaction` | Interactive zero-cli-verb boards |
| `requirement-shell-cli-zero-arguments` | Non-interactive zero-cli-verb is `inst_self_install`, not local `install` |
| `requirement-project-folder` | Path defaults |
| `requirement-shell-idempotency` | Already installed / uninstalled |
| `requirement-bootstrap-chain` | Why the channel verbs exist beside this local pair |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-LC-01..08** | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-09** mode `0755` after install | `tests/test_local_lifecycle.sh` | have |
| **TP-LC-10** mode heal without `--force` | `tests/test_local_lifecycle.sh` | have |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Local-only lifecycle for folder-backup |
| 2026-08-09 | Active 1.2.0 | §2.3.1 mode **0755** multi-user; ban `chmod +x`→`0711` trap; AC-6..8; TP-LC-09/10 |
| 2026-08-28 | Active 1.2.1 | Empty-argv owner is default-interaction case 2; Type O fence unchanged |
| 2026-09-30 | Active 1.3.0 | Channel verbs are live beside this pair. `install` stays the local copy. |
| 2026-09-30 | Active 1.3.1 | Empty argv is the numbered boards. `install` is also self-board row **81**. `uninstall` and `where-is-me` stay typed. Version cell points at the ship unit. |
| 2026-09-30 | Active 1.3.2 | A pipe with no command is `self-install`, not this file’s `install`. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
