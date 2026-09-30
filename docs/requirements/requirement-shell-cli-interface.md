**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 1.12.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-interface`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of vault-cli: command surface, privilege typing, global flags, dispatcher behavior, help/about contracts, and mode rules.

It defines a **normal-login** local self-managed shell CLI plus **domain vault** commands and typed folder `backup` / `restore`. Vault and archive behavior lives in `requirement-domain-vault-cli.md`. `list`, `add`, and `update` do not use an elevated deposit. The global backup folder is `/var/backups/${APP_NAME}/`.

### 1.1 Human-facing

**In one sentence:** Type `vault-cli help` to see every command; work commands are list, add, update, backup, and restore; `self-update` stays with the channel verbs; unknown words fail closed.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Type a listed verb | `vault-cli list` |
| Scripts / CI | `--json` / `--quiet` on a named verb; a pipe with no command places this program | `vault-cli --json version` |
| Not this file | Numbered board membership | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Dispatcher tokens, flags, help catalog, channel verbs | Treating local `install` as the pipe |
| `update` edits a vault | Treating `self-update` as that edit |

| Surface | What you open | What for |
|---------|---------------|----------|
| `vault-cli help` | command | listed verbs |
| `src/vault-cli` | ship file | `app_main` routes `list`, `add`, `update`, `edit`, `backup`, and `restore` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Edit a vault | `update` changes one existing ssh-vault, github-vault, or cloudflare-vault. `edit` is the same handler. | `vault-cli update github-vault --login LOGIN --token-id TOKENID --token-file ./token` |
| Replace this program | That is `self-update`, not `update`. | `vault-cli self-update` |
| Type an unknown word | Fail closed. | `vault-cli no-such-command` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every command **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning |
|----------|-----------|---------|
| **Type 0 – CLI lifecycle + diagnostics** | Invoking user | `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`, channel verbs including `self-update` |
| **Type 0 – Domain (user work)** | Invoking user | `list`, `add`, `update` (alias `edit`) on this login's vault root |
| **Type 1 – Admin privilege** | Controlled sudo | **Not used** by vault verbs |
| **Type 2 – Dedicated system user app ops** | Dedicated app user | **Not in scope** for this product |

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output |
| `--debug` | `DEBUG=1` | Extra diagnostics on stderr; must not break JSON purity on stdout |
| `--force` | `FORCE=1` / force policy | Skip safe confirms or force reinstall only where documented |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

### 2.3 Dispatcher and entry rules

1. **Single entry:** `app_main` **MUST** parse global flags and route commands.  
2. **Unknown command:** **MUST** fail loudly with pointer to `help` (via output SSOT).  
3. **Zero-cli-verb:** interactive → numbered boards (`requirement-shell-cli-default-interaction.md`); non-interactive → `inst_self_install` (`requirement-shell-cli-zero-arguments.md`). **MUST NOT** call `inst_local_install` on that line.  
4. **No raw user I/O:** User-facing messages **MUST** go through `out_*`.  
5. Script end **MUST** call `app_main "$@"` (no basename gate that blocks dispatch).

### 2.4 Help surface

`help` **MUST** list:

- Usage line  
- Every supported command with one-line purpose  
- Privilege category (this login vs not used)  
- Global flags  
- Honest note that `update` edits a vault and `self-update` replaces this program  

**Purpose split:** help **MUST** keep operational work apart from self-managed verbs. This product has **no** test-purpose domain verb.

| Purpose | Verbs |
|---------|-------|
| **Operational** | `list`, `add`, `update`; `edit` as an alias of `update` (not its own menu row); `backup` and `restore` (typed commands, not menu rows); `menu` / `main` when routed |
| **Self-managed** | `install`, `uninstall`, `where-is-me`, `self-install`, `self-update`, `self-uninstall`, `version-check`, `self-management` |
| **Diagnostics** | `version`, `about`, `help` |
| **Test-purpose** | none |

`app_help` **MUST** list vault work under **Work commands:** and channel verbs under the self-managed heading. `self-update` **MUST NOT** appear under Work commands.

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object.

### 2.5 Implementation Notes (this project)

| Item | Value for vault-cli |
|------|------------------------|
| **Product / binary name** | `vault-cli` (`APP_NAME`) |
| **Primary executable** | `src/vault-cli` (POSIX `/bin/sh`, single-file, version **1.0.0**) |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_text` + wrappers (`out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_json`, …) |
| **Version SSOT** | ship unit `VERSION=` (do not pin a stale number here) |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Primary install story** | User bin: `${HOME}/.local/bin/vault-cli` |
| **Online channel env** | **Product UX.** Help lists `SCRIPT_URL`. `install` does not download. A terminal with no command does not download. A pipe with no command does, via `inst_self_install`. |
| **Type 2 commands** | None |
| **Dedicated system user** | Not required |

#### Supported commands (normative for this project)

| Command | Type | Handler family | Required behavior |
|---------|------|----------------|-------------------|
| *(no command — zero-cli-verb)* | Type 0 | interactive `app_cmd_menu`; else `inst_self_install` | Terminal, not quiet, not json: numbered boards. Otherwise CLI self-install. Not local `install`. |
| `install` | Type 0 | `inst_local_install` | Copy running ship unit to privilege-correct bin; mode **0755**; idempotent unless `--force`. **Not** `inst_self_install`. |
| `uninstall` | Type 0 | `inst_local_uninstall` | Remove managed binary; confirm unless `--force` |
| `where-is-me` | Type 0 | `app_where_is_me` | Running + install paths + installed flag |
| `self-install` | Type 0 | `inst_self_install` | Copy when `$0` is a file; download when piped. Local dest mode **0700**, global **0755**. |
| `version-check` | Type 0 | `ver_check` | Compare local `VERSION` with the channel. Needs a reachable `SCRIPT_URL`. |
| `self-update` | Type 0 | `inst_self_update` | Replace the managed binary from the channel. |
| `self-uninstall` | Type 0 | `inst_self_uninstall` | Remove the channel-managed binary. Off-TTY without `--force` fails closed when a binary exists. |
| `self-management` | Type 0 | `app_default_self_loop` → `app_cmd_menu_self` | TTY opens the self board (**81**–**87**). Off a terminal, stops: `self-management needs a terminal`. Front row **8** opens the same board and returns to the front. The argv verb ends after a leaf or Back. |
| `version` | Type 0 | `app_version` | Local `VERSION` only; no network |
| `about` | Type 0 | `app_about` | Diagnostics: install presence, paths, user, shell, TTY, cache lines from `requirement-shell-cli-storage`, channel `script_url`, **Vault root**, ssh-vault count, github-vault count, cloudflare-vault count, backup root `/var/backups`, notation `${APP_NAME}`, deposit directory `/var/backups/${APP_NAME}/`. No secret bytes. |
| `help` | Type 0 | `app_help` | Full usage in human mode; short JSON note in JSON mode |
| `list` | Type 0 | `vc_list` (domain) | **Operational.** Names only. Optional kind `ssh-vault`, `github-vault`, or `cloudflare-vault`. |
| `add` | Type 0 | `vc_add` (domain) | **Operational.** Create one vault. On a terminal, one field at a time. Off a terminal, flags only. |
| `update` | Type 0 | `vc_update` (domain) | **Operational.** Edit one existing vault. This is the vault edit verb. Not `self-update`. |
| `edit` | Type 0 | `vc_update` (domain) | **Operational alias of `update`.** **MUST NOT** be its own menu row. |
| `backup` | Type 0 | `fb_backup` | **Operational.** Pack `<source-folder>` into `/var/backups/${APP_NAME}/`. **MUST NOT** be a numbered-board row. |
| `restore` | Type 0 | `fb_restore` | **Operational.** Restore `<archive\|prefix>` with optional dest. Flags `--force`, `--disk`, `--ram`. Default dest is the hard-disk projects tree. **MUST NOT** be a numbered-board row. |
| `menu` | Type 0 | `app_cmd_menu` | Numbered boards: front **1** client-side, hidden **2**, **8** self-management, **9** Exit (`requirement-shell-cli-default-interaction`). Client rows **11** `list`, **12** `add`, **13** `update`. Same boards as interactive empty argv. Off a terminal, stops: `menu needs a terminal`. |
| `main` | Type 0 | `app_cmd_menu` | Alias of `menu`. **MUST NOT** appear as a choice on its own board. |

#### Global flags (normative wiring)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | `QUIET=1` in `app_main` |
| `--json` | `JSON=1` and `QUIET=1` in `app_main` |
| `--debug` | `DEBUG=1` in `app_main` |
| `--force` | `FORCE=1` (and install reinstall policy when applicable; restore into a non-empty dest) |
| `--disk`, `--hard-disk` | `RESTORE_HOST=hard-disk` |
| `--ram`, `--ram-drive` | `RESTORE_HOST=ram-drive` |

#### Dispatcher acceptance criteria

1. Unknown token after flag parse → `out_die` with pointer to `vault-cli help`.  
2. Zero-cli-verb → interactive numbered boards; non-interactive `inst_self_install` (not local `install`, not help, not `update`).  
3. Command routing table in `app_main` **must** include every **Implemented** row above. Rows marked **Gap** stay unrouted until the ship unit gains `vc_list`, `vc_add`, and `vc_update`.  
4. Help text **must** stay aligned with that table. `self-update` **MUST** stay out of **Work commands:**.  
5. Domain operands and error tokens are owned by `requirement-domain-vault-cli.md` — this file owns the **listed verbs** and routing.

#### Explicitly out of scope

- Calling `inst_local_install` from a zero-cli-verb line
- Using `update` to replace the program (`self-update` does that)
- Passing a token or a private key as an argv value
- The five grant/draft verbs (withdrawn with `requirement-domain-folder-backup`)
- Type 1 deposit and Type 2 app runtime  

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution**: Unknown commands fail loud; force gates destructive ops.  
- **CIAO Principle 2 – Intentional**: Every command has one privilege type and one handler family.  
- **CIAO Principle 5 – Single Source of Output**: Central `out_*`.  
- **CIAO Principle 6 – Single Point of Entry**: `app_main` is the dispatcher SSOT.  
- **CIAO Principle 9 – Three Types of Commands**: Type 0 lifecycle and vault work. Vault verbs do not use admin privilege.  
- **CIAO Principle 10 – Least-Privilege User**: No invented system-user requirement for binary lifecycle.  
- **CIAO Principle 16 – Interactive vs Non-Interactive**: No hang in non-interactive mode.  
- **CIAO Principle 4 / 20 – Over-protect**: Protection Rule blocks privilege and UX regressions.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** `list`, `add`, and `update` stay this-login verbs and **MUST NOT** wrap `sudo`. Detect lives with privilege/sudo law.

| MUST | MUST NOT |
|------|----------|
| Keep your own login only | Enable in-tool `sudo` because a verb is listed |
| Help remains available | Recommend `sudo curl \| sh` |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

**Implementation Notes:** ship unit has **no detect helper yet** (Gap).

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail loud on bad input; never silent wrong privilege context.  
- **Intentional:** Command table + help + dispatcher stay synchronized.  
- **Anti-fragile:** Works under TTY, quiet, JSON, offline local install.  
- **Over-protect:** Do not collapse Type 0/1, hide the channel verbs, or raw-print user messages.  
- **SSOT:** `APP_NAME` / `VERSION` / flags at config defaults; output via `out_*`; dispatch via `app_main`.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Drop the channel verbs, or point a zero-cli-verb line at `inst_local_install`, without a registry update.  
2. Alias `install` to `self-install`.  
3. List commands in help that are not routed (or route commands not listed).  
4. Bypass `out_*` for product user messages.  
5. Run the entire CLI as root by default.  
6. Put vault field walks and error tokens only here and omit `requirement-domain-vault-cli`.  
7. Treat `self-update` as the vault edit verb, or accept secret bytes on argv.  
8. Route a non-interactive zero-cli-verb to help, or drop `menu`/`main` routing.  
9. Put `self-update` under **Work commands:**, or give `edit` its own menu row.  
10. Route a grant/draft verb (`print-sudoers`, `print-sudoers-install-script`, `generate-sudoer-request`, `submit-sudoer-request`, `remove-project-sudoers`) as vault-cli work. `backup` and `restore` are routed typed commands and are not numbered-board rows.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | All **Implemented** commands in the table are routed and listed in help |
| AC-2 | Global flags wire QUIET/JSON/DEBUG/FORCE as specified |
| AC-3 | Interactive zero-cli-verb is the numbered boards; non-interactive zero-cli-verb is `inst_self_install`; never local `install` |
| AC-4 | Channel verbs are routed and listed in help; they are self-board rows **84**–**87** (and `self-management` opens that board), not front rows |
| AC-5 | Domain verbs point to `requirement-domain-vault-cli` for operands and error tokens |
| AC-6 | `list`, `add`, and `update` are Type 0 operational verbs; `edit` aliases `update`; `app_main` routes all four |
| AC-7 | `update` does not replace the program; `self-update` does; help keeps them under different headings |
| AC-8 | `menu` and `main` are routed and listed in help; interactive empty argv opens the same boards (`requirement-shell-cli-default-interaction`) |
| AC-9 | Help **Work commands** lists `list`, `add`, `update`, the `edit` alias, `backup`, and `restore`. No secret bytes appear in help. |
| AC-10 | Grant/draft tokens are not vault-cli commands. `backup` and `restore` are routed. The global backup folder is `/var/backups/${APP_NAME}/` |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | **Active** — non-interactive zero-cli-verb is `inst_self_install` |
| `requirement-shell-cli-default-interaction` | Case 2 empty argv + claimed `menu`/`main` numbered boards |
| `requirement-shell-local-self-management` | install/uninstall/where-is-me |
| `requirement-shell-output-requirements` | `out_*` catalog |
| `requirement-domain-vault-cli` | Domain vault verbs; `list` / `add` / `update` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-01..12** | `tests/test_cli.sh` | have |
| **TP-CLI-13..16** | same | **have** — `menu`/`main` (`requirement-shell-cli-default-interaction`) |
| **TP-CLI-17** | same | **have** — help **Work commands** lists `list` / `add` / `update` / `edit` and keeps `self-update` off that heading (AC-9) |
| **TP-VAULT-01..06** | `tests/test_domain_vault.sh` | **have** — vault verbs (`requirement-domain-vault-cli`) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | CLI surface for local-only folder-backup + domain backup |
| 2026-08-15 | Active 1.1.0 | `submit-sudoer-request` listed as Type 0 JSON submit into sibling public inbound |
| 2026-08-17 | Active 1.2.0 | `--add` / `--update`; default submit action from host `/etc/sudoers.d` probe |
| 2026-08-17 | Active 1.3.0 | `generate-sudoer-request` Type 0; AC-7 |
| 2026-08-17 | Active 1.3.1 | Generate dest must be readable for tests/review; independent of submit |
| 2026-08-23 | Active 1.4.0 | `menu` / `main` listed (Gap); empty argv stays help |
| 2026-08-23 | Active 1.5.0 | Restore / print-sudoers-install-script / remove-project-sudoers listed; test-purpose grant-emit verbs apart in help (AC-9) |
| 2026-08-23 | Active 1.6.0 | `menu` / `main` routed (`app_main_menu`); empty argv stays help |
| 2026-08-28 | Active 1.7.0 | Case 2: TTY empty argv = numbered list; off-TTY help; zero-arguments Withdrawn |
| 2026-09-03 | Active 1.8.0 | Grant/draft setup verbs stay live CLI commands; numbered **main** list uses family **sudoers** (submenu); `sudoers` not dispatched; AC-10 |
| 2026-09-03 | Active 1.8.1 | Submenu SSOT **`requirement-shell-cli-sudoers-submenu`** |
| 2026-09-06 | Active 1.8.2 | §1.1 Human-facing; help **Work commands** vs **Grant and draft setup** (AC-9 / TP-CLI-17 have); Under command line section |
| 2026-09-27 | Active 1.8.3 | About cache lines: used, preferred, 1st fallback, 2nd fallback when this host has one (`requirement-shell-cli-storage` 1.4.0) |
| 2026-09-30 | Active 1.9.0 | Channel verbs from selfmanaged are routed. `install` stays the local copy. Main menu unchanged. |
| 2026-09-30 | Active 1.9.1 | Handlers `app_cmd_menu` / `app_cmd_menu_self`. Self board **81**–**87**. Test-purpose verbs off every numbered board. Sudoers rows **172** and **175**. |
| 2026-09-30 | Active 1.10.0 | Non-interactive zero-cli-verb is `inst_self_install`. Interactive zero-cli-verb stays the boards. Local `install` stays `inst_local_install`. |
| 2026-09-30 | Active 1.10.1 | Named `menu` and `self-management` off a terminal stop. They do not print help. |
| 2026-09-30 | Active 1.11.0 | Product is vault-cli. Operational verbs are `list`, `add`, `update` (alias `edit`). `self-update` stays the channel refresh. Backup and grant verbs leave the catalog. `vc_*` handlers are Gap. |
| 2026-09-30 | Active 1.11.0 | `src/vault-cli` **1.0.0** routes `vc_list`, `vc_add`, and `vc_update`. **TP-CLI-17** and **TP-VAULT-01..06** have. `sh tests/run.sh`: PASS=367 FAIL=0 SKIP=0. |
| 2026-09-30 | Active 1.12.0 | `backup` and `restore` are routed typed commands. Deposit directory is `/var/backups/${APP_NAME}/`. Grant verbs stay unrouted and off the boards. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
