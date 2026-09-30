**file**: docs/requirements/requirement-shell-script-coding.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-script-coding`  
**Optional RQ-ID**: `RQ-SHELL-SCRIPT-CODING`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **POSIX `/bin/sh` coding style** of folder-backup.

**Without this file, portable learned lessons arrive raw** (agents would treat coding skills as product law). This file is the specialize-in home. Slices already owned by peer requirements are **pointers**, not a second copy.

### 1.1 Human-facing

**In one sentence:** The installed program is one POSIX `/bin/sh` file with prefixes, one printer family, and no hidden `set -e` exits — new helpers follow that shape.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Run the one program | `src/folder-backup` |
| Maintainers / agents | Add helpers with prefixes and CIAO headers | `fb_*` / `out_*` |
| Not this file | Which commands exist; sudo allow table | `requirement-shell-cli-interface` · `requirement-shell-sudo-command` |

| Includes | Excludes |
|----------|----------|
| Shebang `#!/bin/sh`; prefixes; `out_*`; no bashisms | Dumping a second copy of output / TTY / storage / sudo tables |
| Specialize-in home for shell coding lessons | Treating a coding skill as product law |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/folder-backup` | ship unit | live style |
| `docs/requirements/index.md` | registry | this row |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Add a helper | Prefix + header + `out_*`. Do not invent a second shipped file. | edit `src/folder-backup` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Specialize-in intention

1. **MUST** treat this file as the coding-style related requirement for this software-development product.  
2. **MUST NOT** tell agents to follow a coding skill as product law.  
3. **MUST** own-or-point: do not duplicate full peer bodies.

### 2.2 Own (this file)

| Rule | MUST |
|------|------|
| Shebang | `#!/bin/sh` |
| Interpreter | POSIX `/bin/sh` (dash/bash-as-sh subset); **MUST NOT** bashisms (`[[`, `source`, arrays) |
| `set` | **MUST NOT** `set -e` / `set -u` / `set -eu` as the script-wide policy (explicit checks; `set -u` helpers already use defaults) |
| Function names | Prefix table on `requirement-shell-modular-function-design` — **MUST** obey it |
| Public helpers | CIAO header (General Purpose / ALIGNMENT / last updated) |
| Sourcing | `.` not `source` |
| Command lookup | `command -v` not bare `which` |
| Capture of `read` helpers | **MUST NOT** `$()` / backticks of `prompt_ask` / `prompt_yes_no` / menu `read` |

### 2.3 Point (peers own the body)

| Slice | Owner |
|-------|--------|
| `out_*` printers / JSON / quiet | `requirement-shell-output-requirements` |
| Operator `[ERROR]` wording | `requirement-operator-readable-error` |
| Prefix table / single-file | `requirement-shell-modular-function-design` |
| TTY measure outside functions; helpers consume `TTY` | `requirement-shell-interactive-vs-noninteractive` |
| Cache / persistence roots | `requirement-shell-cli-storage` |
| In-tool sudo wrap + studied allow table | `requirement-shell-sudo-command` |
| Dispatcher / flags | `requirement-shell-cli-interface` |

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Language** | posix-sh |
| **Sudo wrap** | **Gap** — no `util_sudo`; deposit uses scattered `sudo -n` (peer sudo-command) |
| **Detect Termux / Git Bash / Windows cmd** | **Gap** — no helper yet |

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** new helpers **MUST NOT** implement a password-sudo ladder or wrap `apt` on that class.

| MUST | MUST NOT |
|------|----------|
| POSIX `/bin/sh` as this login | In-tool `sudo` added “because Linux has it” |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

**Implementation Notes:** ship unit has **no detect helper yet** (Gap).

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Explicit checks; no script-wide `set -e`.  
- **Intentional:** Prefixes and headers encode why.  
- **Anti-fragile:** POSIX `/bin/sh` on dash and Git Bash.  
- **Over-protect:** Do not strip CIAO headers “for brevity.”

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Change the shebang from `#!/bin/sh`.  
2. Treat a coding skill as this product’s law.  
3. Duplicate output / TTY / storage / sudo tables here.  
4. Capture `prompt_*` / menu `read` with `$()`.  
5. Enable admin privilege on Termux / Git Bash / Windows cmd.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Shebang `#!/bin/sh`; no script-wide `set -e`/`set -u` |
| AC-2 | Peers own output / TTY / storage / sudo; this file points |
| AC-3 | No `$()` of `read` helpers in the ship unit |
| AC-4 | Purpose states specialize-in intention |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-modular-function-design` | Prefixes |
| `requirement-shell-output-requirements` | Printers |
| `requirement-shell-sudo-command` | In-tool sudo |
| `requirement-shell-interactive-vs-noninteractive` | TTY |
| `requirement-class-software-dev` | Class residual pointer |
| `docs/requirements/index.md` | Registry |

**Last Updated**: 2026-09-06  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
