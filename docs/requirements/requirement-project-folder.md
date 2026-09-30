**file**: docs/requirements/requirement-project-folder.md  
**Status**: Active (Version 1.0.2)  
**Area**: architecture  
**Key**: `requirement-project-folder`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Define **project folder structure** and path ownership for vault-cli: source layout, install locations, staging/scratch, and the durable backup deposit root.

**Critical distinction:** CLI tool own paths vs target folders being archived vs host durable backup deposit.

### 1.1 Human-facing

**In one sentence:** The program you install lives at `src/vault-cli`; archives you keep live under `/var/backups/vault-cli/`; those are different folders from the project you pack.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Install to `~/.local/bin`; pack a named project folder | `sh src/vault-cli install` |
| Admin | Global binary under `/usr/local/bin`; deposit tree under `/var/backups/vault-cli` | `sudo sh src/vault-cli install` |
| Not this file | How backup names and retention work | `requirement-folder-archive-backup` |

| Includes | Excludes |
|----------|----------|
| `src/` ship unit; user vs global bin | Online companion digest as a required install file |
| Deposit root `/var/backups/${APP_NAME}/` (`/var/backups/vault-cli/`) | Treating the project being packed as this program’s home |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/vault-cli` | program file | install source |
| `/var/backups/vault-cli/` | deposit tree | kept archives |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install for yourself | Copy into `~/.local/bin`. | `sh src/vault-cli install` |
| Name the deposit tree | Host archives, not your checkout. | `vault-cli about` |

---

## 2. Core Rules (Mandatory)

### 2.1 Workspace source layout (developer tree)

| Path | Role |
|------|------|
| `src/vault-cli` | **Ship unit** — single POSIX shell executable source |
| `tests/` | CLI tests when present |
| `docs/requirements/` | Product law (this surface) |
| Product root README / CHANGELOG / LICENSE / SECURITY | Product user docs when specialized |

1. **MUST** keep the installable CLI under **`src/`** (not only repo root).  
2. **MUST** install the binary under a privilege-correct bin path (see §2.2).  
3. **MUST NOT** require online channel files (companion digest) for local install.

### 2.2 CLI tool install locations (Type 1a / 1b)

| Mode | Binary path | Default |
|------|-------------|---------|
| **Per-user (normal)** | `${USER_BIN}/${APP_NAME}` | `${HOME}/.local/bin/vault-cli` |
| **Global (root)** | `${GLOBAL_BIN}/${APP_NAME}` | `/usr/local/bin/vault-cli` |

Rules:

1. Non-root **install** **MUST** target user bin.  
2. Root **install** **MAY** (and for production elevation **SHOULD**) target global bin.  
3. **Primary product story** for this project: **user bin** (`~/.local/bin`) for Type 0 day-to-day; **global bin** for multi-user / durable sudoers trust.  
4. Uninstall **MUST** remove only the managed binary path for the install mode used.  
5. Managed binary mode **MUST** be **`0755`** after install (shell ship unit: non-owners need **read+execute**; see `requirement-shell-local-self-management` §2.3.1). Global install **MUST** leave a path runnable by normal users and root, not owner-only (`0700`) or execute-without-read (`0711`).

### 2.3 Scratch / cache (CLI own volatile)

| Purpose | Pattern |
|---------|---------|
| Cache / staging root | From `util_resolve_storage` (see `requirement-shell-cli-storage`); Linux preferred `/dev/shm/cache/cache-${APP_NAME}-<login>-<pid>` |
| Persistence storage | `${HOME}/.local/${APP_NAME}/` (`util_resolve_persistent_storage`) — **not** `${HOME}/.local/bin` |
| Archive staging | under `${EFFECTIVE_STORAGE_DIR}` (or `mktemp` under that root) |
| Sudoers fragment draft | User-writable path under config: `…/sudoers.fragment-<user>` (legacy un-suffixed still discoverable; never auto-write `/etc/sudoers.d`) |

Rules:

1. Scratch **MUST** use the cache resolver (`requirement-shell-cli-storage`): Linux preferred `/dev/shm/cache/cache-${APP_NAME}-${login}-$$`, then `/tmp/cache/...`, then `${HOME}/.cache/cache-${APP_NAME}-$$`. Git Bash and Mac preferred `/tmp/cache/cache-${APP_NAME}-${login}-$$`. **MUST NOT** use `/dev/shm/${APP_NAME}` as cache. Persistence **MUST** be `${HOME}/.local/${APP_NAME}/` — **MUST NOT** use `${HOME}/.local/bin` as persistence.  
2. Temps **MUST** clean up (`trap`) after success/failure of a backup run.  
3. Staging archives are **EPHEMERAL** until successfully deposited; do not leave world-writable archives.

### 2.4 Durable host backup deposit (not CLI config)

| Item | Value |
|------|--------|
| **Backup root** | `/var/backups` |
| **Backup notation directory** | `/var/backups/${BACKUP_NOTATION}/` |
| **Default notation** | `${APP_NAME}` (`vault-cli` unless overridden by env) |
| **Global backup folder** | `/var/backups/${APP_NAME}/` |
| **Archive basename pattern** | `${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz` |

Rules:

1. Writing into `/var/backups/${APP_NAME}/` **MUST** use this login when that folder is writable, and **MUST** fail closed when it is not — not an unrestricted root shell.  
2. Normal users **MUST NOT** be granted write to all of `/var` — only the allowlisted deposit.  
3. Archive **creation** (tar gzip) **MUST** run as the invoking user into staging; only the **deposit copy** is elevated.

### 2.5 Target folders being backed up

1. Source folder is a **user-supplied path** (domain operand), not an app system-user tree.  
2. The tool **MUST** validate the source is a readable directory before archiving.  
3. The tool **MUST NOT** follow uncontrolled recursion into dangerous system roots without explicit user path input and validation.

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **APP_NAME** | `vault-cli` |
| **Ship unit path** | `src/vault-cli` |
| **USER_BIN default** | `${HOME}/.local/bin` |
| **GLOBAL_BIN default** | `/usr/local/bin` |
| **BACKUP_ROOT** | `/var/backups` |
| **BACKUP_NOTATION default** | `vault-cli` (`${APP_NAME}`) |
| **Global backup folder** | `/var/backups/vault-cli/` |
| **Config dir (optional)** | `${HOME}/.config/${APP_NAME}/` for generated sudoers drafts |
| **No Type 2 app data tree** | No dedicated system app user for routine ops |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Separate staging, install, and privileged deposit.  
- **Principle 10 – Least privilege**: User creates archive; elevation only for deposit.  
- **Principle 11 – Temps**: Staging is cleanup, not museum.  
- **Principle 17 – Defensive storage**: No assumed writable paths without resolve.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Fail loud if deposit root or staging is not usable under policy.  
- **Intentional**: Path classes are documented and not mixed.  
- **Anti-fragile**: Per-user isolation under multi-user hosts.  
- **Over-protect**: Do not “simplify” by writing archives straight into `/var/backups` as a world-writable tree or by running the whole CLI as root.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Move the ship unit out of `src/` without updating this requirement and install paths.  
2. Make online channel paths required for install.  
3. Grant the product unrestricted write under `/var` or `/etc`.  
4. Collapse staging and durable deposit into one world-writable directory.  
5. Collapse cache into a ram-drive-shaped `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` leaf.

**Violating this rule is a critical path/privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Ship unit lives at `src/vault-cli` |
| AC-2 | Default user install path is `~/.local/bin/vault-cli` |
| AC-3 | Durable deposit is under `/var/backups/${APP_NAME}/` |
| AC-4 | Archive naming pattern documented and owned with domain law |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-local-self-management` | Place/remove binary |
| `requirement-shell-cli-storage` | Scratch resolve |
| `requirement-domain-folder-backup` | Archive + deposit behavior |
| `requirement-three-layer-privilege-model` | Elevation boundary |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Specialized project folder law for folder-backup |
| 2026-09-27 | Active 1.0.1 | Scratch leaf follows storage 1.4.0 (per login, per process) |
| 2026-09-30 | Active 1.0.2 | Global backup folder is `/var/backups/${APP_NAME}/` (`/var/backups/vault-cli/`). Ship unit and install paths are `vault-cli`. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
