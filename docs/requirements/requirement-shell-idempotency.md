**file**: docs/requirements/requirement-shell-idempotency.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-shell-idempotency`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **idempotency (re-run safety)** of state-changing operations in the folder-backup POSIX shell CLI.

**Informal formula:** for ensure-style operation *f* and system state *x*, **f(f(x)) ≈ f(x)** for the **desired outcome** (logs and timestamps may differ).

### 1.1 Human-facing

**In one sentence:** Running `install` or `backup` a second time must not smash a good install or overwrite today’s archive slot — it skips or numbers the next file.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Re-run install or backup | `folder-backup install` |
| The other role | Scripts must get success when the desired state already holds | CI re-run |
| Not this file | Confirm prompts | `requirement-shell-interactive-vs-noninteractive` |

| Includes | Excludes |
|----------|----------|
| Re-install no-op unless `--force` | Failing because “already installed” |
| Same-day archive `N+1` | Overwriting `NAME-YYYYMMDD-1.tar.gz` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/folder-backup` | ship unit | install + next-N |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install twice | Second run succeeds without clobber unless you pass `--force`. | `folder-backup install` |
| Backup twice the same day | Second archive is `…-2.tar.gz`. | `folder-backup backup /path/to/project` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What must be idempotent

Every **state-changing** shell operation that **ensures** a desired configuration **MUST**:

1. **Detect** whether the desired state already holds.  
2. **Skip or no-op** unsafe work when it does.  
3. **Succeed** when already achieved — **MUST NOT** fail solely because state “already exists.”  
4. **Avoid duplicates** (binary installs, PATH lines, identical archive slot collisions handled by numbering).  
5. **Leave the system consistent** on every run (including partial prior installs).  
6. **Communicate** clearly when already done in human mode; respect quiet/json via output SSOT.

### 2.2 What a second run must not do

| Forbidden when desired state already holds | Prefer |
|--------------------------------------------|--------|
| Fail solely because state exists | Success + “already installed / nothing to uninstall” |
| Create duplicate managed binaries | Existence check first |
| Overwrite a correct install without force | No-op unless force |
| Leave half-applied worse state | Atomic steps; cleanup temps; fail loud |

### 2.3 Force override

Force policy (`--force` / `FORCE=1`) **MAY** re-apply ensure steps that would otherwise no-op **only** when documented. Force **MUST NOT** silently skip integrity or path validation for domain deposit.

### 2.4 Implementation Notes — command matrix (this project)

| Command / path | Desired state | Re-run when already good | Force / special |
|----------------|---------------|--------------------------|-----------------|
| `install` | Managed binary present at privilege-correct path | Success no-op | `--force` replaces from running ship unit |
| `uninstall` | Managed binary absent | Success no-op | `--force` skips confirm |
| `where-is-me` / `version` / `about` / `help` | Read-only | Always safe | N/A |
| `print-sudoers` | Emit fragment text | Safe re-print (same content for same user/host defaults) | Does not install into `/etc` |
| `generate-sudoer-request` | Local verified JSON grant at dest path | Overwrite same dest (draft) | Does not write `/etc` or inbound |
| `submit-sudoer-request` | Queue a **new** JSON request (sibling allocates next `n`) | Each success is a new `request_id`; not a no-op | Does not write `/etc`; does not `mkdir` inbound; missing inbound fails closed |
| `backup` | New archive deposit for this run | **Not** “skip backup”; each run **SHOULD** create next `N` or fail if naming cannot progress | Must not overwrite existing archive without explicit force policy (default: **never overwrite** — allocate next `N`) |

### 2.5 Domain numbering idempotency

Archive names use `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz`. For the same calendar day and same source basename:

1. **MUST** scan destination (or staging policy) for existing `N` values.  
2. **MUST** choose the next free positive integer `N` (1, 2, 3, …).  
3. **MUST NOT** overwrite an existing archive file by default.

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Re-runs must not corrupt installs or archives.  
- **Principle 3 – Anti-fragile**: Safe to re-invoke.  
- **Principle 12 – Backup**: New archives do not clobber prior ones.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** re-run safety still applies to user-bin install and user-writable dests; it **MUST NOT** invent `sudo` to “heal” a host deposit.

| MUST | MUST NOT |
|------|----------|
| Idempotent user-bin install | Wrap `sudo` to force a `/var/backup` write |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

## 3. Design Principles (CIAO / CIAO-Lite)

- Detect → ensure → success-if-done for lifecycle.  
- Domain backup is **additive** (new N), not “ensure same file.”  
- Fail closed on permission and path errors (idempotency ≠ never error).

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Make `install` fail when already installed (force off).  
2. Overwrite existing dated archives by default.  
3. Treat idempotency as permission to ignore validation failures.  
4. Remove atomic install/stage patterns for “speed.”

**Violating this rule is a critical re-run safety regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Second `install` without force is success no-op |
| AC-2 | Second `uninstall` when absent is success no-op |
| AC-3 | Second `backup` same day allocates next `N` without overwrite |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Install/uninstall ensure |
| `requirement-domain-folder-backup` | Archive numbering |
| `requirement-shell-cli-interface` | Force flag wiring |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-LC-03,07** | `tests/test_local_lifecycle.sh` | have |
| **TP-FOLDER-BACKUP-06** | `tests/test_domain_folder_backup.sh` | have |
| **TP-FOLDER-BACKUP-08** | `tests/test_domain_folder_backup.sh` | skip (non-root CI) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Idempotency for local lifecycle + archive numbering |

---

**Last Updated**: 2026-08-03  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
