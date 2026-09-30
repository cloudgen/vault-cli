**file**: docs/requirements/requirement-shell-cli-storage.md  
**Status**: Active (Version 1.4.1)  
**Area**: shell  
**Key**: `requirement-shell-cli-storage`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for **shell CLI storage** of vault-cli. **Storage** means **two** classes:

| Class | Role | Survives reboot |
|-------|------|-----------------|
| **Cache folder** | Volatile scratch / backup staging | No (shm/tmp) or maybe (home fallback) |
| **Persistence storage** | Type 0 durable per-user app data | Yes (under this login’s `$HOME`) |

It owns path **shapes**, central resolvers, `app_main` wire, and about diagnostics for both classes.

Used for **volatile temps** (`mktemp`). Persistence is this login's durable app data under `${HOME}/.local/vault-cli`. Vault files live under `${HOME}/.local/vaults` and are not either of these folders.

The preferred cache is **not** a ram-drive **project** tree (`/dev/shm/vault-cli` or `/dev/shm/vault-cli-<login>`). It lives under `/dev/shm/cache/` (Linux) or `/tmp/cache/` (Git Bash and Mac). The leaf is **per login and per process** so two logins never share one cache directory.

---

### 1.1 Human-facing

**In one sentence:** `vault-cli about` names the cache folder this process is using, the preferred folder, each fallback, and the persistence folder under your home `.local/vault-cli`.

Scratch goes in a cache folder. Durable app data for this login goes under persistence storage. Vault files live under `${HOME}/.local/vaults`, not in this persistence folder.

| You | Another role | Not this |
|-----|--------------|----------|
| Let the CLI pick cache + persistence | Vault files under `${HOME}/.local/vaults` | Putting vault files in `/tmp` with a guessed name; treating `~/.local/bin` as data |
| Cache folder (preferred) on Linux: `/dev/shm/cache/cache-vault-cli-<login>-<pid>` | `/dev/shm/vault-cli` as cache (that looks like a project folder) | One shared `cache-vault-cli` leaf for every login |
| Cache folder (1st fallback) on Linux: `/tmp/cache/cache-vault-cli-<login>-<pid>` | Install binary `${HOME}/.local/bin/vault-cli` | A warning because a higher folder was skipped |
| Cache folder (2nd fallback) on Linux: `${HOME}/.cache/cache-vault-cli-<pid>` | Persistence `${HOME}/.local/vault-cli` used as scratch | A `$$` file name inside the cache folder |

**Includes:** cache resolver, persistence resolver, about fields. **Excludes:** deposit chown; install binary placement.

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Inspect storage | about shows Cache folder used, preferred, 1st fallback, 2nd fallback when this computer has one, and Persistence storage. A skipped tier prints nothing | `vault-cli about` / `vault-cli --json about` |

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Two storage classes (mandatory split)

Volatile leaf (shared parents `/dev/shm` and `/tmp`): `cache-${APP_NAME}-${login}-$$`.  
Home leaf (already per login): `cache-${APP_NAME}-$$`.  
`$$` is **this process id**. `${login}` is `id -un` as one path segment. **MUST NOT** hardcode either.

| Host | Preferred | 1st fallback | 2nd fallback |
|------|-----------|--------------|--------------|
| Linux (and Termux, and any host that is not Git Bash or Mac) | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/.cache/cache-${APP_NAME}-$$` |
| Git Bash (`MSYSTEM`, or `uname -s` `MINGW*` / `MSYS*`) | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` | none |
| Mac (`uname -s` `Darwin`) | `/tmp/cache/cache-${APP_NAME}-${login}-$$` | `${HOME}/Library/Caches/cache-${APP_NAME}-$$` | `${HOME}/cache/cache-${APP_NAME}-$$` |

| Class | Helper |
|-------|--------|
| Cache folder (preferred) | `util_preferred_cache_dir` |
| Cache folder (1st fallback) | `util_fallback_cache_dir` |
| Cache folder (2nd fallback) | `util_fallback2_cache_dir` (empty on Git Bash) |
| Persistence storage | `util_persistent_storage_dir` → `${HOME}/.local/${APP_NAME}` |

Live chosen **cache** root: `util_resolve_storage` (stdout).  
Live **persistence** root: `util_resolve_persistent_storage` (stdout; create-before-return).

On Termux/Android, the chosen cache root (including `/tmp` and `/dev/shm`) **MAY** be **`noexec`**. Termux uses the **Linux** chain. Cache remains scratch **only**. **MUST NOT** run a program from the cache root.

**Silent fallback.** Choosing a later tier **MUST NOT** print a warning or an error. **MUST NOT** say that a fallback happened. An error is allowed only when **every** tier for this host failed to be created.

**MUST NOT** mix these with:

| Forbidden as this product’s storage | Why |
|-------------------------------------|-----|
| `${HOME}/.local/bin` / `USER_BIN` | Install binary dir |
| `/var/backup` / deposit directory | Type 1 durable deposit (privilege law) |
| `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` | Looks like a ram-drive project folder |
| `${HOME}/.local/share/${APP_NAME}` | Not this product’s persistence shape |
| One shared `cache-${APP_NAME}` leaf | Two logins would share scratch |
| `XDG_CACHE_HOME` as the chain | Home cache is the Linux 2nd fallback path above, not an override of the chain |

Config drafts stay under `${HOME}/.config/${APP_NAME}/` (sudoers fragment / JSON grant). That is **config**, not cache and not persistence.

### 2.2 Single cache resolver SSOT

1. **MUST** keep **one** authoritative cache-resolve helper: **`util_resolve_storage`**.  
2. New code that needs a product scratch/cache **root** **MUST** call `util_resolve_storage` (or `mktemp` under a path it returned).  
3. Resolver **MUST** print the chosen directory path on **stdout** for `$(util_resolve_storage)` capture.  
4. User-visible failure about cache **MUST** use Output SSOT.  
5. Tests may force the host chain with `FOLDER_BACKUP_CACHE_HOST` (`linux`, `gitbash`, `mac`) and skip the preferred tier with `FOLDER_BACKUP_CACHE_SKIP=preferred`. `SELFMANAGED_CACHE_HOST` and `SELFMANAGED_CACHE_SKIP` remain accepted. **Do not rename** `SELFMANAGED_CACHE_HOST`.  
5. **MUST** expose policy helpers **`util_preferred_cache_dir`**, **`util_fallback_cache_dir`**, and **`util_fallback2_cache_dir`** (class B stdout) so about does not invent a second cache path family.

### 2.3 Live cache resolve priority

Walk this host’s chain in order. First directory that can be created **and** is writable wins. The chain is the table in §2.1. **MUST NOT** replace that chain with one shared `cache-${APP_NAME}` leaf or with `XDG_CACHE_HOME`.

**Parent:** for `/dev/shm/cache` and `/tmp/cache` the resolver **MUST** create that parent (prefer mode **1777** when creating) so each login can add its own `cache-${APP_NAME}-${login}-$$` leaf. The **leaf** **MUST** be mode **0700**, a real directory, and owned by this login. A symlink, another owner, or a mode that is not owner-only **MUST** fall through to the next tier with no message.

**Create before return:** for the **chosen** leaf, the resolver **MUST** create it, confirm it is **writable**, then print the path. If create/write fails → try the next tier **with no message**. If none work → **MUST** fail closed. **MUST NOT** return a path without creating it.

**MUST NOT** use these as cache:

| Forbidden cache path | Why |
|----------------------|-----|
| `/dev/shm/${APP_NAME}` | Looks like a ram-drive project folder |
| `/dev/shm/${APP_NAME}-${USERNAME}` | Same confusion. Login belongs in the leaf **under** `cache/`, as `cache-${APP_NAME}-${login}-$$` |
| `/dev/shm` or `/tmp` as a dump | No app-named cache leaf |
| Persistence storage | Durable data is not scratch |

### 2.4 Cache isolation

1. Cache leaves **MUST** include **`cache-${APP_NAME}`** (app identity).  
2. Volatile leaves (`/dev/shm/cache` and `/tmp/cache`) **MUST** be `cache-${APP_NAME}-${login}-$$`. Home leaves **MUST** be `cache-${APP_NAME}-$$` (no login segment). Isolation is the login segment plus this process id, not one shared directory that the second login falls out of.  
3. **MUST NOT** use a single shared world-writable directory for all logins or all apps.  
4. Live product **MUST** export `TMPDIR=${EFFECTIVE_STORAGE_DIR}` so `mktemp` inherits the isolated **cache** root.  
5. New scratch files **MUST** be created via **`util_mktemp`** (or `mktemp` under a path `util_resolve_storage` returned).  
6. The **cache directory** name includes `$$` (this process). Scratch **files** inside it **MUST NOT** use a predictable `$$` file name (forbidden: `/tmp/${APP_NAME}.$$`, `${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.$$`).

**Complete `util_mktemp` sample:**

```sh
util_mktemp() {
    : "${APP_NAME:=vault-cli}"
    : "${EFFECTIVE_STORAGE_DIR:=}"
    _suffix="${1:-tmp}"
    case "${_suffix}" in
        *'$$'*)
            out_die "util_mktemp: refuse predictable \$\$ name template"
            ;;
    esac
    if [ -z "${EFFECTIVE_STORAGE_DIR}" ]; then
        EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)
        export EFFECTIVE_STORAGE_DIR
    fi
    mktemp "${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.${_suffix}.XXXXXX" \
        || mktemp "${TMPDIR:-/tmp}/${APP_NAME}.${_suffix}.XXXXXX" \
        || mktemp
}
```

**Forbidden:**

```sh
tmp="/tmp/${APP_NAME}.$$"
tmp="${EFFECTIVE_STORAGE_DIR}/${APP_NAME}.$$"
```

### 2.5 Persistence storage

1. Persistence **MUST** be **`${HOME}/.local/${APP_NAME}`** (this login’s home + app name). No login suffix and no `$$`.  
2. Helper **`util_persistent_storage_dir`** **MUST** print that path. **`util_resolve_persistent_storage`** **MUST** `mkdir -p` it, confirm it is writable, then print it (fail closed).  
3. **MUST NOT** use `${HOME}/.local/bin` as persistence (that is `USER_BIN`).  
4. **MUST NOT** use `/var/backup` as Type 0 persistence.  
5. **MUST NOT** store scratch/temps in persistence when a cache root is available.  
6. Persistence **MUST** be under the invoking login’s `$HOME` (per-user). **MUST** include `${APP_NAME}`.

### 2.6 Wire and diagnostics

| Surface | Requirement |
|---------|-------------|
| `app_main` | Resolve once early: `EFFECTIVE_STORAGE_DIR=$(util_resolve_storage)`; `PERSISTENT_STORAGE_DIR=$(util_resolve_persistent_storage)`; export `EFFECTIVE_STORAGE_DIR`, `STORAGE_DIR`, `PERSISTENT_STORAGE_DIR`, `TMPDIR` (`TMPDIR` = cache root; `STORAGE_DIR` = 1st fallback) |
| `app_about` human | **MUST** print **`Cache folder used:`** then the live directory; **`Cache folder (preferred):`** then this host’s preferred path; **`Cache folder (1st fallback):`** then the 1st fallback; **`Cache folder (2nd fallback):`** only when this host has a 2nd fallback; **`Persistence storage:`** then `${HOME}/.local/${APP_NAME}`. Linux sample below. **MUST NOT** label cache lines **Storage (effective)**, **Storage (fallback)**, or **Cache folder (live)**. **MUST NOT** warn or error when the used directory is a fallback |
| `app_about` JSON | **MUST** include `cache_used`, `cache_preferred`, `cache_fallback` (1st), `cache_fallback_2` (2nd, empty string when the host has none), `persistence_storage`, and the live chosen cache root as `effective_storage` (same value as `cache_used`; `storage_dir` = 1st fallback). **MUST NOT** include `CHECKSUM` |
| Domain `backup` | Stage archives under the live **cache** root; clean up on exit |

Linux `about` lines (placeholders, not a fixed process id). `Cache folder used` is the tier that was created:

```
[INFO] Cache folder used: /dev/shm/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (preferred): /dev/shm/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (1st fallback): /tmp/cache/cache-${APP_NAME}-${login}-$$
[INFO] Cache folder (2nd fallback): ${HOME}/.cache/cache-${APP_NAME}-$$
[INFO] Persistence storage: ${HOME}/.local/${APP_NAME}
```

Git Bash omits the 2nd fallback line. Mac prints preferred under `/tmp/cache/`, 1st fallback under `${HOME}/Library/Caches/`, and 2nd fallback under `${HOME}/cache/`.

When the preferred tier is the one used, the used line and the preferred line are the same path. When a fallback is used, the used line is that fallback path and the preferred line still shows the preferred path.

### 2.7 Staging rules for backups (cache family)

These steps describe the withdrawn folder-backup deposit. `vault-cli` does not create archives and does not write `/var/backup`. Cache and persistence rules above still apply.

1. Create archives in a stage directory under `EFFECTIVE_STORAGE_DIR` (the live chosen **cache** root), one path segment so elevation wildcards can match.  
2. Use restrictive modes appropriate for user data (prefer not world-readable when content may be sensitive).  
3. **MUST** remove staging artifacts via `trap` on success and failure after deposit attempt completes (or fails closed with path logged).  
4. Durable deposit path `/var/backup/...` is **not** the storage resolver’s job (privilege + domain law).

### 2.8 Implementation Notes (this project)

| Item | Live value |
|------|------------|
| **Product / binary** | `vault-cli` |
| **Cache resolver** | `util_resolve_storage` in `src/vault-cli` |
| **Linux preferred** | `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` |
| **Linux 1st / 2nd** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/.cache/cache-${APP_NAME}-$$` |
| **Git Bash** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$` |
| **Mac** | `/tmp/cache/cache-${APP_NAME}-${login}-$$` then `${HOME}/Library/Caches/cache-${APP_NAME}-$$` then `${HOME}/cache/cache-${APP_NAME}-$$` |
| **Live chosen cache** | `EFFECTIVE_STORAGE_DIR` (JSON `cache_used` and `effective_storage`) |
| **Persistence helper** | `util_resolve_persistent_storage` |
| **Persistence path** | `${HOME}/.local/vault-cli` (`${HOME}/.local/${APP_NAME}`; JSON `persistence_storage`) |
| **Call sites** | `app_main`, `app_about`; cache used by domain staging |
| **Sudoers drafts / generate JSON** | Still under `${HOME}/.config/folder-backup/` (privilege/domain dest law). Persistence folder is created and shown; those dests are **not** silently re-homed |
| **Not used for** | Install binary; ram-drive project trees; `/var/backup` deposit |

### 2.9 Why This Requirement Exists (CIAO)

- **Caution:** Cache vs persistence vs install bin vs host deposit must not collapse. The leaf is private to this login.  
- **Intentional:** Storage means both families. About says which tier was used and which tiers exist.  
- **Anti-fragile:** Missing `/dev/shm` still works, and the miss is silent.  
- **Principle 11 – Temps:** Cache cleanup, not museum copies of staging.  
- **Principle 12 – Backup/durability:** Persistence is the keep-files folder.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** cache and persistence stay under this login’s folders — **MUST NOT** create `/var/backup` via `sudo` from storage helpers.

| MUST | MUST NOT |
|------|----------|
| User cache / `${HOME}/.local/folder-backup` | Host deposit as a storage-resolver job |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |
| Termux: Linux cache chain, scratch only | Run a downloaded program from the cache folder |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

## 3. Design Principles (CIAO / CIAO-Lite)

- Volatile first, user cache last for **scratch**.  
- Persistence is a different folder from cache.  
- Isolation before convenience.  
- Create fail-closed only when every tier failed.  
- About labels name **Cache folder used**, **preferred**, **1st fallback**, **2nd fallback** when that host has one, and **Persistence storage**.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Restore `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` as the preferred cache.  
2. Label about cache lines **Storage (effective)** / **Storage (fallback)** / **Cache folder (live)**. The labels are **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, **Cache folder (2nd fallback)** when that host has one.  
3. Drop persistence storage from this requirement or from `about`.  
4. Use `${HOME}/.local/bin` or `/var/backup` as Type 0 persistence.  
5. Replace the cache fallback chain with a shared world-writable dump, or with one `cache-${APP_NAME}` leaf shared by every login.  
6. Scatter hard-coded `/tmp/folder-backup` roots outside the cache resolver.  
7. Leave the resolvers dead with no call sites while claiming storage is product law.  
8. Echo a tier path without creating it.  
9. Stage durable deposits only in world-writable shared paths by design.  
10. Use predictable `$$` scratch **file** names instead of `util_mktemp` / `mktemp` XXXXXX. The cache **directory** itself includes `$$`.  
11. Warn or error only because a higher cache tier was skipped.  
12. Drop `${login}` or `$$` from a volatile cache leaf, or put the login on a home leaf, or put the login back on `/dev/shm/${APP_NAME}-${login}` outside `cache/`.  
13. Accept a cache leaf this login does not own, or leave a chosen leaf group- or world-accessible.  
14. Put backup staging in persistence by default.  
15. Strip the **Under command line for normal user only** section, or enable admin privilege / a dedicated system user from the storage helpers.

**Violating this rule is a critical storage isolation regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Exactly one authoritative cache resolver creates and returns the cache root |
| AC-2 | Linux preferred leaf is `/dev/shm/cache/cache-${APP_NAME}-${login}-$$` when that directory is usable. Git Bash and Mac preferred leaf is `/tmp/cache/cache-${APP_NAME}-${login}-$$` |
| AC-3 | `app_main` sets `EFFECTIVE_STORAGE_DIR` / `TMPDIR` and `PERSISTENT_STORAGE_DIR` early |
| AC-4 | `about` human prints Cache folder used, preferred, 1st fallback, 2nd fallback when present, and Persistence storage; JSON has `cache_used` / `cache_preferred` / `cache_fallback` / `cache_fallback_2` / `persistence_storage` |
| AC-5 | Scratch files use `util_mktemp` / `mktemp` XXXXXX; the cache directory name may include `$$`; scratch file names must not |
| AC-6 | Live cache path is not `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${USERNAME}` |
| AC-7 | Persistence path is `${HOME}/.local/${APP_NAME}` and the directory exists after resolve; it is not `${HOME}/.local/bin` |
| AC-8 | The live cache leaf is a directory this login owns, mode **0700** (`drwx------`) |
| AC-9 | Skipping a cache tier prints no warning and no error. Git Bash has no 2nd fallback. Mac 2nd fallback is `${HOME}/cache/cache-${APP_NAME}-$$` |
| AC-10 | Backup staging uses the cache resolver root and cleans up |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-project-folder` | Path classes |
| `requirement-domain-folder-backup` | Staging use; host deposit |
| `requirement-folder-archive-backup` | Stage one path segment under the cache root |
| `requirement-shell-cli-interface` | About fields |
| `requirement-shell-local-self-management` | Install binary `${HOME}/.local/bin` — not persistence |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-06** | `tests/test_cli.sh` | have — JSON `cache_used` / `cache_preferred` / `cache_fallback` / `cache_fallback_2` / `persistence_storage`; human Cache folder used, preferred, 1st, 2nd + Persistence storage |
| **TP-CLI-12** | same | have — Linux preferred `/dev/shm/cache/cache-${APP_NAME}-${login}-$$`; 1st `/tmp/cache/...`; 2nd `${HOME}/.cache/cache-${APP_NAME}-$$`; Git Bash and Mac chains; silent skip of preferred; leaf mode 0700 owned by this login; persistence `${HOME}/.local/${APP_NAME}`; live dir exists; not `/dev/shm/${APP_NAME}-${login}` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Storage resolve for folder-backup staging |
| 2026-08-15 | Active 1.0.0 | `util_mktemp` sample; forbid `$$` scratch names |
| 2026-08-30 | Active 1.1.0 | Preferred `/dev/shm/cache/cache-folder-backup`; about Cache folder (preferred)/(fallback) |
| 2026-08-30 | Active 1.2.0 | Storage = cache folder **and** persistence `${HOME}/.local/folder-backup/` |
| 2026-09-23 | Active 1.3.0 | Chosen cache leaf is this login’s mode 0700 directory; human about prints **Cache folder (live)** |
| 2026-09-27 | Active 1.4.0 | Per-login per-process cache leaves. Linux shm → tmp → `${HOME}/.cache`. Git Bash tmp → AppData Local Temp. Mac tmp → Library/Caches → `${HOME}/cache`. Silent tier miss. `about` prints used / preferred / 1st / 2nd. JSON `persistence_storage` |
| 2026-09-30 | Active 1.4.1 | Same leaves and about lines. `FOLDER_BACKUP_CACHE_HOST` / `FOLDER_BACKUP_CACHE_SKIP` and `SELFMANAGED_CACHE_HOST` / `SELFMANAGED_CACHE_SKIP` are both accepted. |
| 2026-09-30 | Active 1.4.1 | Persistence is `${HOME}/.local/vault-cli`. Cache leaves stay `cache-${APP_NAME}-…`. Ship unit is `src/vault-cli`. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
