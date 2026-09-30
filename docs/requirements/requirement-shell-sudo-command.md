**file**: docs/requirements/requirement-shell-sudo-command.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-sudo-command`  
**Optional RQ-ID**: `RQ-SHELL-SUDO-COMMAND`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **in-tool sudo**: one wrapping function, check before sudo, and a **studied sudo allow table** (dest + argv — no guessing).

JSON grant **body** stays on `requirement-sudoer-json-file`. Emit / install **workflow** stays on `requirement-three-layer-privilege-model`. Coding-style **points** here.

### 1.1 Human-facing

**In one sentence:** After an admin installs the grant, this program may run `folder-backup backup <folder>` (and restore) via passwordless sudo of **that** argv — it must not scatter extra `sudo mkdir` / `sudo cp` as a second grant.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Run backup after the grant exists | `folder-backup backup /path/to/project` |
| Admin | Install the fragment under `/etc/sudoers.d/` | `visudo -c` then mode `0440` |
| Not this file | JSON `commands[]` shape | `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| Studied dest `/etc/sudoers.d/folder-backup-<user>` | Guessing `/etc/<user>/folder-backup` |
| Studied argv `backup *` / `restore *` / `--json` twins | Verb-only `backup` |
| One wrap function | Probe with `sudo true` / `sudo mkdir` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `folder-backup print-sudoers` | command | studied Cmnd text |
| `src/folder-backup` | ship unit | live wrap (Gap) |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Print the draft | Text dual includes `backup *` and `--json backup *`. | `folder-backup print-sudoers` |
| Pack a folder after install | Matching NOPASSWD argv; no extra OS-tool grant. | `folder-backup backup /path/to/project` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Wrap + check before sudo

1. In-tool `sudo` **MUST** go through one wrapping function (typical `util_sudo`).  
2. Already-root **MUST** run the argv without `sudo`.  
3. Probe with a **non-sudo** command first. If this login already can, **MUST NOT** `sudo`.  
4. **MUST NOT** probe with `sudo true` / `sudo ls` / `sudo mkdir` / `sudo cp`.  
5. `sudo -n` **MAY** run only when the allow table row is NOPASSWD and matches the **full argv**. Off-TTY / `--json` without that row **MUST** fail closed (no hang).

### 2.2 Studied sudo allow table (this product)

Study evidence: `print-sudoers` stdout (ship unit `fb_print_sudoers` / `fb_sudoers_text`). Installed `/etc/sudoers.d/folder-backup-<user>` wins when readable. **MUST NOT** guess dest.

| Binary | Verb | Operand | Fragment dest | NOPASSWD? | This wrap? | Study evidence |
|--------|------|---------|---------------|-----------|------------|----------------|
| `${GLOBAL_BIN}/folder-backup` (default `/usr/local/bin/folder-backup`) | `backup` | `*` | `/etc/sudoers.d/folder-backup-<username>` (`id -un`) | yes | **intended yes** after re-exec (Gap) | `print-sudoers` line `… backup *` |
| same | `restore` | `*` | same | yes | **intended yes** after re-exec (Gap) | `print-sudoers` line `… restore *` |
| same | `--json backup` | `*` | same | yes | **intended yes** after re-exec (Gap) | `print-sudoers` line `… --json backup *` |
| same | `--json restore` | `*` | same | yes | **intended yes** after re-exec (Gap) | `print-sudoers` line `… --json restore *` |
| `/usr/bin/tar` or `/bin/tar` | `-tzf` | archive path | **not** on the JSON grant | residual | **no** (inner OS-tool — Gap) | live deposit/verify |
| `/bin/mkdir` / `install` / `cp` / `chmod` / `rm` | (various) | deposit paths | **not** on the JSON grant | residual | **no** (inner OS-tool — Gap) | live `sudo -n mkdir` / `cp` |

`<username>` is `id -un` at generate time — **MUST NOT** freeze a session login in this file.

### 2.3 Honesty (Gaps)

| Item | Status |
|------|--------|
| `util_sudo` wrap | **Gap** — ship unit has no wrap; deposit/verify/restore-stage scatter `sudo -n` |
| Re-exec `sudo -n ${GLOBAL_BIN}/folder-backup backup <folder>` | **Gap** — three-layer already records this; inner OS-tool sudo remains |
| Compact JSON `--json` twins | **Gap** vs `requirement-sudoer-json-file` AC-26 (text dual **has** twins; compact emit does not) — **TP-FOLDER-BACKUP-27** |

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Fragment dest family** | `/etc/sudoers.d/folder-backup-<username>` |
| **Emit checklists** | Product **does** emit fragments (`print-sudoers`) — security review of emit stays on three-layer |
| **This CLI writes `/etc`?** | **No** (Type 0 print/submit only) |

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** in-tool `sudo` **MUST NOT** run on that class — fail closed with an operator-readable next step.

| MUST | MUST NOT |
|------|----------|
| Detect the class; skip the wrap | Password-sudo ladder on Termux / Git Bash / Windows cmd |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

**Implementation Notes:** ship unit has **no detect helper yet** (Gap).

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Study dest/argv; never guess.  
- **Intentional:** One wrap; JSON grant is backup/restore of this binary.  
- **Anti-fragile:** Fail closed off-TTY without a matching NOPASSWD row.  
- **Over-protect:** Do not probe with `sudo true`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Guess dest as `/etc/<user>/folder-backup` when emit installs `/etc/sudoers.d/folder-backup-<user>`.  
2. Write verb-only `backup` as the matching argv.  
3. Mark OS-tool `mkdir`/`cp` as **This wrap? = yes**.  
4. Probe with `sudo true` / `sudo mkdir`.  
5. Enable the wrap on Termux / Git Bash / Windows cmd.  
6. Claim the wrap Implemented while `util_sudo` is missing.

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Allow table dest + argv match `print-sudoers` |
| AC-2 | Wrap is one function; already-root skips sudo |
| AC-3 | Honest Gap until `util_sudo` + re-exec exist |
| AC-4 | Compact JSON `--json` twins remain Gap until TP-27 |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Emit / install workflow |
| `requirement-sudoer-json-file` | JSON body |
| `requirement-shell-script-coding` | Points here |
| `requirement-folder-archive-backup` | Deposit callers |
| `docs/requirements/index.md` | Registry |

**Design-time verification:** TP-FOLDER-BACKUP-01 / 01c / 26 (text dual); **TP-FOLDER-BACKUP-27** todo (compact `--json` twins). Inner OS-tool sudo is residual Gap (no TP claiming wrap complete).

**Last Updated**: 2026-09-06  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
