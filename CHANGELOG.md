# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-09-30

### Changed

- **Name and version.** The program is `vault-cli` at version **1.0.0**.
- **Work commands.** `list`, `add`, and `update` store ssh-vault, github-vault, and cloudflare-vault under `~/.local/vaults`. `edit` is the same handler as `update` and is not a menu row. `self-update` still replaces the program.
- **Secrets.** A token or a private key is a regular file mode `0600` (`--token-file` or `--key-file`). `--token` and `--private-key` are refused and the value is not echoed. List, help, and about do not print secret bytes.
- **Boards.** Client rows are **11** list, **12** add, and **13** update. Grant verbs are not routed.
- **Backup and restore.** `backup <folder>` and `restore <archive>` are typed work commands (not numbered rows). The global backup folder is `/var/backups/vault-cli/` (`BACKUP_ROOT=/var/backups`, `BACKUP_NOTATION` is the app name). `sh tests/run.sh`: PASS=393 FAIL=0 SKIP=0.
- **Public repository.** https://github.com/cloudgen/vault-cli is public. The git remote is `git@github.com:cloudgen/vault-cli.git`. A push is accepted only when the forge probe is `Hi cloudgen!`.
- **Restore projects tree.** When `PROJECTS_ROOT` is unset, hard-disk restore uses a checkout under `prjs`, then `${HOME}/prjs`, then `/var/www/html/prjs`.
- **Suite.** `sh tests/run.sh`: PASS=367 FAIL=0 SKIP=0. Proof **TP-VAULT-01** through **TP-VAULT-06** and **TP-CLI-***.

## [1.20.0] - 2026-09-30

### Changed

- **Named menu off a terminal stops.** `menu`, `main`, and `self-management` with no terminal exit 1: `menu needs a terminal` (or `self-management needs a terminal`). Next step is `folder-backup help`. `--json` on that line is a JSON error. On a real terminal, `menu --json` still draws the boards.
- **Empty Enter on the front leaves.** An empty line, or `q`, is Exit. On a child board, an empty line or `q` is Back.
- **Row 82 is diagnostics.** On a numbered board, row **82** and a typed `version` run `about`. `folder-backup version` stays the thin version line.
- **A pipe with no command still places this program.** That 1.19.0 route is unchanged. Local `install` stays the mode `0755` copy.
- **Suite.** `sh tests/run.sh`: PASS=473 FAIL=0 SKIP=2. Proof **TP-CLI-15** · **TP-CLI-21**.
- Law: **requirement-shell-cli-default-interaction** **1.9.0**, **requirement-shell-cli-zero-arguments** **1.2.1**, **requirement-shell-cli-interface** **1.10.1**, **requirement-shell-interactive-vs-noninteractive** **1.1.3**.

## [1.19.0] - 2026-09-30

### Changed

- **A pipe with no command places this program.** On a real terminal, no command (and `--debug` or `--force` with no command) still opens the numbered boards. A pipe, no TTY, `--quiet`, or `--json` with no command calls `inst_self_install`: a checkout file is copied (mode `0700` for your login, `0755` for root) and a pipe downloads. Naming `menu` or `self-management` off a terminal still prints help. Local `install` stays the mode `0755` copy and is not this route.
- **Install lead.** README Quick Installation leads with `curl … | sh`. That line is the place. It does not print help.
- **Suite.** `sh tests/run.sh`: PASS=455 FAIL=0 SKIP=2. Proof **TP-CLI-07** · **TP-CLI-23**.
- Law: **requirement-shell-cli-zero-arguments** **Active 1.2.0** (owner of the split), **requirement-shell-cli-default-interaction** **1.8.0**, **requirement-shell-cli-interface** **1.10.0**, **requirement-bootstrap-chain** **2.3.0**, **requirement-shell-local-self-management** **1.3.2**, **requirement-shell-interactive-vs-noninteractive** **1.1.2**, **requirement-class-software-dev** **1.1.5**.

## [1.18.0] - 2026-09-30

### Changed

- **Numbered boards replace the flat work list.** On a terminal, no arguments (and `menu` / `main`) shows client-side (**1**), self-management (**8**), and Exit (**9**). Server-side is hidden and number **2** stays reserved. Client-side lists backup (**11**), restore (**12**), and sudoers (**17**). The sudoers board lists `submit-sudoer-request` (**172**) and `remove-project-sudoers` (**175**). Test commands stay typed; numbers **171**, **173**, and **174** stay reserved. Self-management lists local `install` (**81**) through `self-install` (**87**). Child boards use **0** Back. A finished command redisplays the front board. Off a terminal, no arguments and `self-management` still show help. `folder-backup sudoers` stays unknown.
- **Menu ink.** On a terminal the short name is bold. The description stays italic and light gray. The number, Exit, and Back stay plain.
- **Suite.** `sh tests/run.sh`: PASS=436 FAIL=0 SKIP=2. Proof **TP-CLI-13** · **TP-CLI-14** · **TP-CLI-15** · **TP-CLI-18** · **TP-CLI-19** · **TP-CLI-21**.
- Law: **requirement-shell-cli-default-interaction** **1.7.0**, **requirement-shell-cli-sudoers-submenu** **1.1.0**, **requirement-shell-cli-interface** **1.9.1**, **requirement-domain-folder-backup** **1.6.7**, **requirement-shell-output-requirements** **1.1.2**, **requirement-bootstrap-chain** **2.2.1**, **requirement-shell-local-self-management** **1.3.1**, **requirement-class-software-dev** **1.1.4**. Version cells point at the ship unit hard-assign.

## [1.17.0] - 2026-09-30

### Changed

- **Rebuilt from sibling selfmanaged.** The ship unit keeps that parent’s self-install, version-check, self-update, self-uninstall, and self-management board, and keeps folder-backup’s backup, restore, and sudoers verbs. Direction is selfmanaged → folder-backup. The parent tree was not edited.
- **Main menu is unchanged.** On a terminal, no arguments shows `1 backup`, `2 restore`, `3 sudoers`, `9 Exit`. Off a terminal, no arguments shows help. `install` still copies this file (mode 0755). `self-install` is the extra channel verb.
- **Cache leaf** stays the 1.16.5 contract: per login and per process. `about` prints Cache folder used, preferred, 1st fallback, and 2nd fallback. JSON keeps `cache_used`, `cache_fallback_2`, `persistence_storage`, and `effective_storage`. `SELFMANAGED_CACHE_HOST` still works beside `FOLDER_BACKUP_CACHE_HOST`.
- **Download integrity.** `self-install` and `self-update` fetch `src/folder-backup.sha256` beside the raw script when `CHECKSUM` is unset. Algorithm is SHA-256. A match continues. A mismatch aborts. A missing companion warns and continues. Local `install` does not download.
- **Suite.** Channel verbs stay off the main menu (TP-CLI-16). Cache about lines match 1.16.5 (TP-CLI-06, TP-CLI-12). `sh tests/run.sh`: PASS=418 FAIL=0 SKIP=2.
- Law: **requirement-bootstrap-chain** **2.2.0**, **requirement-shell-cli-interface** **1.9.0**, **requirement-shell-cli-storage** **1.4.1**, **requirement-shell-cli-default-interaction** **1.6.1**, **requirement-shell-interactive-vs-noninteractive** **1.1.1**.

## [1.16.5] - 2026-09-27

### Changed

- **Scratch is one folder per login and per process.** On Linux the preferred folder is `/dev/shm/cache/cache-folder-backup-<login>-<pid>`, then `/tmp/cache/cache-folder-backup-<login>-<pid>`, then `${HOME}/.cache/cache-folder-backup-<pid>`. Git Bash prefers `/tmp/cache/...` then `${HOME}/AppData/Local/Temp/cache-folder-backup-<pid>` (no second fallback). Mac prefers `/tmp/cache/...`, then `${HOME}/Library/Caches/cache-folder-backup-<pid>`, then `${HOME}/cache/cache-folder-backup-<pid>`. A skipped folder is silent. An error is only when every folder on this host fails. Files inside the folder stay `mktemp` names. Durable data stays `${HOME}/.local/folder-backup` (no login suffix, no process id). Human `about` prints **Cache folder used**, **Cache folder (preferred)**, **Cache folder (1st fallback)**, **Cache folder (2nd fallback)** when that host has one, and **Persistence storage**. JSON uses `cache_used`, `cache_preferred`, `cache_fallback`, `cache_fallback_2`, and `persistence_storage`. Law: **requirement-shell-cli-storage** **1.4.0**. Suite **TP-CLI-06** · **TP-CLI-12** (PASS=410 FAIL=0 SKIP=2).

## [1.16.4] - 2026-09-23

### Fixed

- **Cache leaf is private to this login.** `util_resolve_storage` keeps `/dev/shm/cache/cache-folder-backup` (then `/tmp/cache/…`, then the home cache) only when this login owns a real directory and `chmod 0700` sticks. Another login’s writable leaf, a symlink, or a group/world-open directory falls through. Human `about` prints **Cache folder (live)** next to preferred and fallback. Law: **requirement-shell-cli-storage** **1.3.0**. Suite **TP-CLI-06** · **TP-CLI-12**.
- **Draft picker no longer captures `read`.** Multi-draft `remove-project-sudoers` calls `prompt_ask` in the current shell and reads `PROMPT_ASK_VALUE`. The question is no longer glued onto the number (`Choose draft number to remove: 2`). Law: **requirement-shell-interactive-vs-noninteractive** **1.1.0**. Suite **TP-FOLDER-BACKUP-15c** · **TP-CLI-20**.

## [1.16.3] - 2026-09-06

### Changed

- **Help lists grant-emit testers apart from work commands.** Human help now has **Work commands:** (`backup` / `restore` / `remove-project-sudoers` / `submit-sudoer-request`) then **Grant and draft setup (tests and review):** (`print-sudoers` / `print-sudoers-install-script` / `generate-sudoer-request`). Closes AC-9 / **TP-CLI-17**. Lifecycle heading is people-facing (no Type-N lead).
- **Product README** Description uses one sentence, three boxes, includes/excludes, and a practice table of what you type. Features are outcomes, not a verb catalog. Related Projects no longer leads with Type 0.
- **Requirements:** every registered `requirement-*.md` has **§1.1 Human-facing**; related shell files have a section **Under command line for normal user only**. New **`requirement-shell-script-coding`** (specialize-in home) and **`requirement-shell-sudo-command`** (studied allow table; wrap still Gap). Compact JSON `--json` twins remain Gap (**TP-FOLDER-BACKUP-27**).

### Fixed

- CLI suite isolates HOME before `about`/`version` so those paths do not mkdir on the live login. **TP-CLI-10** also rejects `self-uninstall`. **TP-CLI-13** covers TTY `main`.

## [1.16.2] - 2026-09-03

### Fixed

- **Suite no longer queues live sudoer inbound.** TP-CLI-13 proved the five grant/draft verbs by actually running `submit-sudoer-request` against the host (`sudoer-cli` 1.17.1 → `/var/sudoer-cli/sudoer-request`). Isolation now defaults to a missing `SUDOER_CLI` plus a temp queue trio; submit with `SUDOER_QUEUE_INBOUND` passes `--queue-root` to sudoer-cli; the runner asserts this user’s live inbound files did not grow. Lesson **L-INBOUND-02**.

## [1.16.1] - 2026-09-03

### Changed

- **Sudoers submenu is its own product law** (`requirement-shell-cli-sudoers-submenu` **1.0.0**). The start list still hosts family row **3** (`requirement-shell-cli-default-interaction` **1.6.0**). Menu behavior is unchanged: five grant/draft setup verbs stay live CLI commands; `folder-backup sudoers` stays unknown. Portable pack (H1 include): **`LM-CLI-SUDOERS-SUBMENU`** · **`SK-CLI-SUDOERS-SUBMENU`** · term `cli-sudoers-submenu`. Proof still **TP-CLI-13** / **TP-CLI-16** / **TP-CLI-18**.

## [1.16.0] - 2026-09-03

### Changed

- **Sudoers family submenu** (copied from sibling grok-cli). The numbered start list is **backup**, **restore**, family **sudoers**, then **9. Exit**. Pick **3** / `sudoers` opens grant/draft setup: `generate-sudoer-request` (JSON grant), `submit-sudoer-request` (inbound queue), `print-sudoers` (sudoers text), `print-sudoers-install-script` (admin script), `remove-project-sudoers` (remove draft). **Back 8** / **Exit 9**. Each of those five remains a live CLI verb. `folder-backup sudoers` stays unknown. Law: **requirement-shell-cli-default-interaction** **1.5.0** · CLI-interface **1.8.0** · domain **1.6.3**. Suite **TP-CLI-13** · **TP-CLI-16** · **TP-CLI-18**.

## [1.15.0] - 2026-09-03

### Changed

- **Numbered work list uses the default CLI main menu style.** On a real terminal the header is **folder-backup**(*live version*) (bold name, italic version). Each command description after the colon is italic and light gray. Scripts and pipes stay plain (no color codes). Law: **requirement-shell-cli-default-interaction** **1.4.0** · **requirement-shell-output-requirements** **1.1.0**. Suite **TP-CLI-18** (portable look family **TP-CLI-17**; this product already used 17 for the help heading split).

## [1.14.0] - 2026-08-30

### Changed

- **Storage means cache folder and persistence.** Persistence is `${HOME}/.local/folder-backup/` (created; shown as **Persistence storage** / JSON `persistent_storage`). Cache family is unchanged (preferred `/dev/shm/cache/cache-folder-backup`). Persistence is **not** `${HOME}/.local/bin`. Sudoers drafts stay under `${HOME}/.config/folder-backup/` until a later dest re-home. Law: **requirement-shell-cli-storage** **1.2.0**. Suite **TP-CLI-06** · **TP-CLI-12**.

## [1.13.0] - 2026-08-30

### Changed

- **About names cache folders, not “storage effective.”** Human `about` prints **Cache folder (preferred)** `/dev/shm/cache/cache-folder-backup` and **Cache folder (fallback)** `${XDG_CACHE_HOME}/cache-folder-backup`. JSON adds `cache_preferred` / `cache_fallback` (live chosen root remains `effective_storage`). Preferred cache is no longer `/dev/shm/folder-backup-<user>` (that looks like a ram-drive project folder). Law: **requirement-shell-cli-storage** **1.1.0**. Suite **TP-CLI-06** · **TP-CLI-12**.

## [1.12.0] - 2026-08-28

### Changed

- **Bare `folder-backup` on a real terminal opens the numbered work list.** Off-TTY (scripts, pipes, CI) a bare run still prints help and does not install. Named `menu` / `main` still open the same list. Flags-only `--json` is JSON help (not the list). Law: **requirement-shell-cli-default-interaction** **1.3.0** (case 2); CLI-interface **1.7.0**. **requirement-shell-cli-zero-arguments** is **Withdrawn**. Suite **TP-CLI-07** (off-TTY help) · **TP-CLI-13** (TTY empty argv + `menu`) · **TP-CLI-15** (flags-only `--json`).

- **Sudoers `--json` twins are now MUST in law.** Text `print-sudoers` already emits `--json backup *` / `--json restore *`. Compact JSON emit is an honest **Gap** until `fb_sudoers_json_text` includes those `commands[]` objects (AC-26). Suite **TP-FOLDER-BACKUP-27** remains **todo**. Law: sudoer-json **1.4.0** · three-layer **1.12.0**.

## [1.11.0] - 2026-08-23

### Added

- **`menu` / `main` numbered work list.** On a real terminal, `folder-backup menu` (or `main`) prints four operational rows plus **9. Exit** (`backup` / `restore` / `remove-project-sudoers` / `submit-sudoer-request`). Labels are `verb: explain`. Off-TTY, `menu` is help (JSON help with `--json`); `--quiet` does not swallow that help. Empty argv stays help. Self-managed, `version`/`about`, and test-purpose grant-emit verbs stay off the list. Law: **requirement-shell-cli-default-interaction** (Gap closed) · CLI-interface **1.6.0**. Suite **TP-CLI-13..16**.

## [1.10.0] - 2026-08-23

### Changed

- **Sudoers emit matches `backup <folder>`.** `print-sudoers` / JSON grant now use sudoers `*` (one extra operand): text `… folder-backup backup *` and `restore *` (plus `--json` argv lines); JSON `args: ["backup", "*"]` / `["restore", "*"]`. Verb-only exact-argv is withdrawn (INC-20260823-001). Law: three-layer **1.11.0** AC-25 · sudoer-json **1.3.0**. Suite **TP-FOLDER-BACKUP-26 / 26b**.
- Host fragment is still admin-installed. Type 0 does not write `/etc`. Deposit internals may still use `sudo -n mkdir`/`cp` when not already root.

## [1.9.0] - 2026-08-17

### Added

- Law **`requirement-operator-readable-error`**: blocking errors must be understandable (what happened / next step). Suite **TP-FOLDER-BACKUP-25 / 25b / 25c**. Portable: **`LM-OPERATOR-READABLE-ERROR`** · **`SK-OPERATOR-READABLE-ERROR`** · **`CL-OPERATOR-READABLE-ERROR`**.
- **`generate-sudoer-request [path]`** writes a local JSON sudoer file (compact; `backup` and `restore`) and verifies it. Default: `~/.config/folder-backup/sudoer-request-<user>.json`. Does not write `/etc` or inbound. When `sudoer-cli` is present, `json-to-sudoers` must still list both verbs. Next step is `submit-sudoer-request <path>`.
- Suite **TP-FOLDER-BACKUP-24 / 24b / 24c / 24d**. Law: three-layer **1.10.0** AC-23/24 · domain **1.6.1** · CLI **1.3.1** · sudoer-json **1.2.0**. Incident **INC-20260817-002**.

### Changed

- **`submit-sudoer-request` default handoff is compact JSON** (same grant as pretty `print-sudoers` dual) so sibling convert keeps both verbs. Inbound fail-closed copy names the missing grant, the request id, and `generate-sudoer-request`.
- **Independent generate (sacred):** any sudoer generate is a Type 0 subcommand that writes a dest tests and review can read without sudo. Submit temp / inbound / `/etc` are not that dest.

## [1.8.2] - 2026-08-17

### Added

- **`submit-sudoer-request` defaults to `update`** when this user’s host fragment exists under `/etc/sudoers.d/folder-backup-<user>` (or legacy `folder-backup`). Otherwise **add**. `--update` / `--add` override. Other users’ fragments do not count. `about --json` reports `host_sudoers_present`.
- Suite **TP-FOLDER-BACKUP-23 / 23b** (`SUDOERS_D_DIR` isolate). Law: three-layer **1.8.0** AC-22.

## [1.8.1] - 2026-08-17

### Added

- Submit **inbound fidelity** (AC-9 / three-layer AC-21): when the queued request file is readable, `submit-sudoer-request` **fails closed** if sibling re-encode dropped `backup` or `restore`. Purpose text is not completeness.
- Suite **TP-FOLDER-BACKUP-22e / 22f**: pretty emit through real `sudoer-cli` keeps both verbs; stub inbound body is read (not only file count).
- Law: `requirement-sudoer-json-file` **1.1.0** · three-layer **1.7.0**. Incident **INC-20260817-001**.

## [1.8.0] - 2026-08-15

### Changed

- **Sudoers grant is the project command only.** `print-sudoers` / submit emit `${GLOBAL_BIN}/folder-backup backup` and `restore` (JSON dual written as `<draft>.json`). No `mkdir`/`cp`/`tar`/`rm`/`install`/`chmod` Cmnds — those extra tools increased complexity and weakened security.
- **Warning:** Runtime deposit/restore/retention still call `sudo -n mkdir`/`cp`/`tar`/`rm`. **Do not replace** a working OS-tool host fragment with this grant until `backup`/`restore` re-exec via the project command. Submit **refuses** leftover OS-tool files (AC-7).
- Law: `requirement-sudoer-json-file` **1.0.1** · three-layer **1.6.0** (JSON body deferred) · domain **1.4.1**
- Suite **TP-FOLDER-BACKUP-22 / 22b / 22c**; 01/01c/01d/02 assert the new grant shape.

## [1.7.1] - 2026-08-15

### Changed

- **`submit-sudoer-request`** targets sudoer-cli’s **public inbound** `/var/sudoer-cli/sudoer-request` (mode 3773). Sibling CLI allocates the JSON request. This CLI does **not** write `/etc` and does **not** `mkdir` inbound.
- Detect order: `SUDOER_QUEUE_INBOUND` → `${SUDOER_PUBLIC_ROOT}/sudoer-request` → F4 `…/sudoer-request` → legacy `sudoer-approving` last.
- Help/about name the public inbound; `prompt_*` consume `TTY`; submit scratch uses `util_mktemp`.
- Law: three-layer **1.5.0** (AC-16–19) · domain **1.4.0** · CLI interface **1.1.0**
- Suite **TP-FOLDER-BACKUP-21 / 21b** (public preferred; env override wins; no Type 0 mkdir)

## [1.7.0] - 2026-08-14

### Added

- **Detect sudoer-cli and sudoer-adm** on `about` (human + `--json`): path / absent / inbound writable.
- **`submit-sudoer-request`** (Type 0): queue this product's sudoers fragment into the inbound approval folder via sudoer-cli. Does **not** write `/etc`. Requires sudoer-cli + sudoer-adm + writable `sudoer-approving`. Flags: `--purpose`, `--update`, optional file operand, same `--allow-test-local` gate as `print-sudoers`.
- Law: `requirement-domain-folder-backup` 1.3.0 · `requirement-three-layer-privilege-model` 1.4.0 §2.3.3c
- Suite **TP-FOLDER-BACKUP-19 / 20** · help/about **TP-CLI-04 / 06** fields

### Changed

- Version SSOT **1.7.0**
- `print-sudoers` fragment now starts with `# Purpose:` (shared helper for submit)

## [1.6.1] - 2026-08-13

### Changed

- **Bootstrap origin** is now sibling **cli-template** (Type 0 local-only template). Direction **A → B only**. `selfmanaged` is retired history, not a live hop.
- Ship unit Type 0 body rebuilt from `cli-template`, then domain (`fb_*`) re-extended. Online / Type O remain absent (already absent on A).
- Law: `requirement-bootstrap-chain` **2.0.0**; class / domain / shell notes retargeted.

## [1.6.0] - 2026-08-12

### Added

- **Retention after successful backup** (per project basename under deposit):
  - **`MAX_DAILY_BACKUPS`** default **5** — prune oldest same-day `N` until ≤5
  - **`MAX_TOTAL_BACKUPS`** default **30** — prune oldest (day then `N`) until ≤30
  - Order: daily prune, then total prune
- **Sudoers** allowlisted `rm -f` of deposit `*.tar.gz` for root-owned prune
- Law: `requirement-folder-archive-backup-retention-daily` · `requirement-folder-archive-backup-retention-total` (molds LM-*-RETENTION-*)
- Suite **TP-FOLDER-BACKUP-17 / 17b / 18 / 18b**

### Changed

- Version SSOT **1.6.0**
- Type 0 deposit when `BACKUP_ROOT` notation dir is user-writable (tests / custom roots)
- `about` / help report retention caps; backup JSON includes retention_* fields

## [1.5.0] - 2026-08-12

### Fixed

- **Restore dest gate (INC-20260812-001)** — pure ban on all `/etc/*` blocked legitimate homes such as `/etc/sudo-adm`. Gate is now **whitelist-oriented**:
  - **W-ETC-USER:** allow `/etc/{{username}}` and children for the **invoking** user only
  - **Hard deny:** exact `/etc`, **`/etc/passwd`**, deposit tree, other FHS under-prefixes not on whitelist
  - **W-HOME:** invoking passwd home (and under) still allowed when not already covered

### Changed

- Version SSOT **1.5.0**
- `requirement-folder-archive-backup` **1.2.0** §2.6b.2a (AC-15..18)
- Mold **`LM-FOLDER-ARCHIVE-BACKUP`** **1.2.0** §2.8b
- Suite **TP-FOLDER-BACKUP-16**

## [1.4.4] - 2026-08-09

### Fixed

- **Multi-user project-sudoers-file overwrite** — draft and installed basenames now include the **user suffix** so admin install for user A does not overwrite user B:
  - Draft: `~/.config/folder-backup/sudoers.fragment-<user>` (legacy `sudoers.fragment` still discoverable)
  - Host: `/etc/sudoers.d/folder-backup-<user>` (legacy `/etc/sudoers.d/folder-backup` still probed)
- **`remove-project-sudoers` multi-draft** — lists drafts under config and lets the user choose interactively; non-interactive requires an explicit path. Suite **TP-FOLDER-BACKUP-15b**.

### Changed

- Version SSOT **1.4.4**; three-layer REQ **1.3.0** (AC-14/AC-15); term `project-sudoers-file` portable paths.

## [1.4.3] - 2026-08-09

### Fixed

- **Global/local install mode** — managed binary now uses absolute mode **`0755`**. Prior `chmod +x` after `mktemp` (`0600`) produced **`0711`** (`rwx--x--x`): shell ship unit was not readable by non-owners, so normal users could not run a root global install. Re-running `install` without `--force` also **heals** broken `0700`/`0711` modes. Suites **TP-LC-09**, **TP-LC-10**.

### Changed

- Version SSOT **1.4.3**; `requirement-shell-local-self-management` **1.2.0** §2.3.1 multi-user mode law; project-folder install mode note.

## [1.4.2] - 2026-08-09

### Fixed

- **`remove-project-sudoers` honesty** — probe `/etc/sudoers.d/folder-backup` instead of hedging “if any”; when host elev is present, warn **STILL ACTIVE** and give admin leave-elev (`sudo rm` and/or install-script `uninstall`); when absent, say host fragment also absent. JSON includes `host_fragment_present`. Suite **TP-FOLDER-BACKUP-15**.

### Changed

- Version SSOT **1.4.2**; three-layer REQ §2.3.3b / AC-13 probe wording.

## [1.4.1] - 2026-08-09

### Added

- **`remove-project-sudoers [path]`** — Type 0 removes the **project-sudoers-file** draft only (default `~/.config/folder-backup/sudoers.fragment`); confirm or `--force`; refuses `/etc`; warns installed host fragment is separate (admin script `uninstall`). Suite **TP-FOLDER-BACKUP-15**.

### Changed

- Version SSOT **1.4.1**; domain + three-layer REQs §2.3.3b; mold portable §2.3.3b.

## [1.4.0] - 2026-08-09

### Added

- **`print-sudoers-install-script [path]`** — Type 0 generates an admin shell script (prefer `/dev/shm/{{APP_NAME}}-<user>-sudoers-admin.sh`) with `install` / `uninstall` / `replace` / `status` so a sudo-capable account can install or remove the **project-sudoers-file** under `/etc/sudoers.d/` without the CLI writing `/etc`.
- Terminology **`project-sudoers-file`** (draft path + handoff); suite **TP-FOLDER-BACKUP-14**.
- Harness aligned from RAM genesis (S11–S12 elev tables + **S13** trust tier) then pushed portable deltas back to RAM/HD genesis.

### Changed

- Version SSOT **1.4.0**; domain/three-layer REQs document admin-script workflow.
- Help/examples include install-script handoff for leaving test elevation (`uninstall`).

## [1.3.0] - 2026-08-09

### Security

- **Sudoers trust tiers:** global managed binary = production; local-only = **test mode only** (user can rewrite `~/.local/bin` and stage content).
- `print-sudoers` refuses non-production tier unless `--allow-test-local` or `ALLOW_TEST_LOCAL_SUDOERS=1`.
- Fragment headers and human output warn **TEST MODE ONLY / uninstall soon** for test_local.
- Stage allowlists tightened to **per-user** roots (`folder-backup-<user>/`), not broad `folder-backup-*`.
- Harness: `SK-CREATE-SUDOERS-FILE` v1.1, checklist **S11**, `LM-THREE-LAYER-PRIVILEGE-MODEL` v2.1, product three-layer requirement v1.2.
- Re-review: `reviews/reports/2026-08-09-sudoers-security-folder-backup.md` (Pass test only). WS record marked **test / to-uninstall**.

### Added

- `install --global` / `FORCE_GLOBAL=1` to target `/usr/local/bin` when writable.
- `about` reports `sudoers_trust_tier`.
- Uninstall warns that `/etc/sudoers.d/folder-backup` is not removed.
- Suite: TP-FOLDER-BACKUP-01b refuse without allow flag; 01c restore stage with allow flag.

### Changed

- Version SSOT **1.3.0** on ship unit.
- README / SECURITY.md document production vs test elevation paths.

## [1.2.1] - 2026-08-03

### Added

- Config repository identity: `REPO_USER=cloudgen`, `REPO_NAME=folder-backup` (project-repository alignment; `SCRIPT_URL` remains empty for local-only install).
- `about` / `--json about` report `repository` / `repo_user` / `repo_name` / `script_url`.
- Product README documents source repository and `REPO_*` env vars.

## [1.2.0] - 2026-08-03

### Added

- `restore <archive|prefix> [dest]` with count verification after extract.
- Default restore destination host is **hard-disk** (`PROJECTS_ROOT/<project>`) — reverse of ram-drive-first; override with `--ram`, `--disk`, or an explicit path.
- Sudoers fragment lines for restore: allowlisted `cp` from deposit into per-user stage (Type 0 `tar -xzf` after).
- Domain surface and ops requirement coverage for restore; suite cases TP-FOLDER-BACKUP-11..13.
- Product harness skill `SK-FOLDER-ARCHIVE-BACKUP` and related sudoers create skill.

### Changed

- Backup flow reports source/archive file and member counts; deposit size verification.
- `print-sudoers` includes `tar -tzf` list allowlist and restore stage fetch.
- Version SSOT **1.2.0** on ship unit.

## [1.1.0] - 2026-08-03

### Added

- Post-deposit verification (stage counts + deposit size; optional elevated `tar -tzf` re-list).
- `print-sudoers` allowlist for deposit listing.

### Fixed

- Fail-closed deposit path retained when sudoers missing.

## [1.0.0] - 2026-08-03

### Added

- Initial specialized product **folder-backup**: local install/uninstall, backup with elevated deposit, print-sudoers, isolated test suite.
