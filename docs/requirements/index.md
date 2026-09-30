# Requirements index

**Product:** vault-cli (POSIX `/bin/sh` self-managed CLI — list, add, and update ssh-vault, github-vault, and cloudflare-vault on this login)  
**Workspace state:** Specialized product law (left genesis); **software-development** class; bootstrap **selfmanaged → vault-cli** (domain extend; channel verbs **kept**; a terminal with no command is the numbered boards; a pipe with no command is `self-install`).  
**Updated:** 2026-09-30  
**Counts:** **23** requirement files — **18** Active + **5** Withdrawn. Exactly one Active `requirement-domain-*`.

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack (posix-sh); channel verbs kept from selfmanaged; residual no dest approver / no dest fence; §1.1; coding-style + sudo-command pointers | class | Active (1.1.5) | `requirement-class-software-dev.md` | 2026-09-30 |
| requirement-bootstrap-chain | Bootstrap chain A=selfmanaged → B=vault-cli (domain extend: list/add/update; channel kept; interactive boards / non-interactive self-install; self board is front row 8; ship unit `src/vault-cli` **1.0.0**) | architecture | Active (2.4.0) | `requirement-bootstrap-chain.md` | 2026-09-30 |
| requirement-project-folder | Project layout (`src/`), install bins, global backup folder `/var/backups/${APP_NAME}`; scratch leaf per login and per process | architecture | Active (1.0.2) | `requirement-project-folder.md` | 2026-09-30 |
| requirement-three-layer-privilege-model | Type 0 + narrow Type 1 deposit; sudoers emit + **install-script** handoff; **per-user** fragment names; **trust tiers** (S13); submit workflow + inbound fidelity + **host-probe add/update** + **independent generate** (readable dest); fragment **MUST** be `backup *` / `restore *` **and** `--json` twins; privilege paths do not download; staging cache is per login and per process | architecture | Active (1.12.1) | `requirement-three-layer-privilege-model.md` | 2026-09-30 |
| requirement-sudoer-json-file | **JSON sudoer file** SSOT: `{{PRJ_NAME}}` only; `args` **MUST** be verb plus `*` **and** `--json` twins; pretty/compact legal; re-encode **MUST** keep every `commands[]` object; **independent generate** dest readable | architecture | Active (1.4.0) | `requirement-sudoer-json-file.md` | 2026-08-23 |
| requirement-folder-archive-backup | **Backup/restore ops SSOT** (history). Superseded when the product became vault-cli | backup | Withdrawn (1.2.2) | `requirement-folder-archive-backup.md` | 2026-09-30 |
| requirement-folder-archive-backup-retention-total | **Total retention** (history). Superseded when the product became vault-cli | backup | Withdrawn (1.0.1) | `requirement-folder-archive-backup-retention-total.md` | 2026-09-30 |
| requirement-folder-archive-backup-retention-daily | **Daily retention** (history). Superseded when the product became vault-cli | backup | Withdrawn (1.0.1) | `requirement-folder-archive-backup-retention-daily.md` | 2026-09-30 |
| requirement-shell-cli-interface | Shell CLI interface for vault-cli; channel verbs kept, including `self-update`; local `install` mode 0755; non-interactive zero-cli-verb is `inst_self_install`; named `menu` off a terminal stops; `menu`/`main` routed; interactive zero-cli-verb = numbered boards; domain verbs `list`/`add`/`update` (`edit` aliases `update`) plus typed `backup`/`restore` are routed; grant tokens are not the catalog; about prints vault root, counts, and `/var/backups/${APP_NAME}` | shell | Active (1.12.0) | `requirement-shell-cli-interface.md` | 2026-09-30 |
| requirement-shell-cli-zero-arguments | Interactive zero-cli-verb = numbered boards; non-interactive zero-cli-verb = `inst_self_install` (not help, not local `install`); named menu stop is default-interaction | shell | Active (1.2.1) | `requirement-shell-cli-zero-arguments.md` | 2026-09-30 |
| requirement-shell-cli-default-interaction | Claimed TTY numbered boards on an **interactive** zero-cli-verb and `menu`/`main`; front **1** / hidden **2** / **8** / **9**; client **11** list / **12** add / **13** update / **0** Back; self **81**–**87** (row **82** runs about; row **85** is `self-update`); `edit` aliases `update` and is not a row; no sudoers board; named menu off a terminal stops; client rows are on `src/vault-cli` | shell | Active (1.10.0) | `requirement-shell-cli-default-interaction.md` | 2026-09-30 |
| requirement-shell-cli-sudoers-submenu | Client **17** sudoers board (history). Superseded when the client board became list/add/update | shell | Withdrawn (1.1.1) | `requirement-shell-cli-sudoers-submenu.md` | 2026-09-30 |
| requirement-shell-local-self-management | Local install / uninstall / where-is-me; **mode 0755** multi-user; channel verbs live beside this pair; `install` is also self-board row **81**; a pipe is not this `install` | shell | Active (1.3.2) | `requirement-shell-local-self-management.md` | 2026-09-30 |
| requirement-shell-output-requirements | Central `out_*` output SSOT; identity token + numbered-row ink (bold short name); parent selfmanaged | shell | Active (1.1.2) | `requirement-shell-output-requirements.md` | 2026-09-30 |
| requirement-operator-readable-error | Operator-facing error **wording** (human-intro style: what happened / next step) | shell | Active (1.0.0) | `requirement-operator-readable-error.md` | 2026-08-17 |
| requirement-shell-script-coding | POSIX `/bin/sh` coding-style specialize-in home (without it, portable lessons arrive raw); own-or-point | shell | Active (1.0.0) | `requirement-shell-script-coding.md` | 2026-09-06 |
| requirement-shell-sudo-command | In-tool sudo wrap + studied allow table (`backup *` / `restore *` / `--json` twins); wrap **Gap**. Vault verbs do not use this wrap | shell | Active (1.0.0) | `requirement-shell-sudo-command.md` | 2026-09-06 |
| requirement-shell-modular-function-design | Single-file modular prefixes (`out_`/`inst_`/`app_`/`fb_`); parent selfmanaged. Domain handlers for vault-cli are `vc_*` in `requirement-domain-vault-cli` | shell | Active (1.0.1) | `requirement-shell-modular-function-design.md` | 2026-09-30 |
| requirement-shell-idempotency | Re-run safety; archive next-N no overwrite | shell | Active (1.0.0) | `requirement-shell-idempotency.md` | 2026-08-03 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / confirm policy; `prompt_ask` → `PROMPT_ASK_VALUE`; off-TTY zero-cli-verb is self-install; named menu off a terminal stops | shell | Active (1.1.3) | `requirement-shell-interactive-vs-noninteractive.md` | 2026-09-30 |
| requirement-shell-cli-storage | Per-login per-process cache folder **and** persistence `${HOME}/.local/vault-cli` (`${HOME}/.local/${APP_NAME}`); leaf mode 0700; silent tier miss; about Cache folder used / preferred / 1st / 2nd + Persistence storage; both cache env pairs accepted. Vault root `${HOME}/.local/vaults` is owned by `requirement-domain-vault-cli` | shell | Active (1.4.1) | `requirement-shell-cli-storage.md` | 2026-09-30 |
| requirement-domain-folder-backup | Withdrawn domain surface (folder backup + sudoers). Superseded by `requirement-domain-vault-cli` | domain | Withdrawn (1.6.8) | `requirement-domain-folder-backup.md` | 2026-09-30 |
| requirement-domain-vault-cli | Domain surface SSOT: `list` / `add` / `update` (`edit` aliases `update`) plus typed `backup` / `restore`; kinds ssh-vault, github-vault, cloudflare-vault; global backup folder `/var/backups/${APP_NAME}`; `self-update` is not the vault edit verb; secrets stay off argv and off list output; grant verbs are not routed | domain | Active (1.1.0) | `requirement-domain-vault-cli.md` | 2026-09-30 |

## Channel (kept from selfmanaged — user order 2026-09-30)

| Surface | Status on vault-cli |
|---------|---------------------|
| `self-install` / `version-check` / `self-update` / `self-uninstall` / `self-management` | **Present.** On the self-management board (front row **8**, rows **84**–**87**). Row **85** `self-update` replaces this program. It is not the vault edit verb. A non-interactive zero-cli-verb calls `inst_self_install`. Not front-board rows. |
| `SCRIPT_URL` | **Present.** Composed from `REPO_USER` / `REPO_NAME` / `SCRIPT_RELPATH`. Help prints it. |
| Non-interactive zero-cli-verb | **CLI self-install** (`inst_self_install`). Not local `install`. Not help. |
| `install` | **Local copy** (`inst_local_install`, mode 0755). Not an alias of `self-install`. Also self-board row **81**. |
| Separate `.sha256` requirement file | **No file.** The ship unit still honors optional `CHECKSUM` on download. |

**Install mode:** **dual.** Checkout copy is `install` (mode 0755). Online place is the pipe one-liner (`self-install`: local 0700, global 0755). A terminal with no command is the numbered boards.

**Rules for agents:**

1. Treat **Active** rows above as the **live product-law inventory** for vault-cli. Withdrawn rows stay in this registry as history.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change when creating one.  
3. Product source comments cite **only** these live requirement files — never templates/skills as behavioral authority.  
4. This versioned surface lists **requirement rows only** — do not dump templates / skills / terminologies / incidents path inventories here.  
5. Keep Status and Path in sync with each file’s header when status changes.  
6. **Class gate:** software-development requires exactly one Active `requirement-class-software-dev.md` (this registry includes it).  
7. **Domain SSOT:** exactly one Active `requirement-domain-*` (`requirement-domain-vault-cli`).  
8. **Do not drop** the channel verbs, and **do not** route a non-interactive zero-cli-verb to help or to local `install`, without an explicit user order and a registry update.  
9. **`update`** edits one existing vault. **`self-update`** replaces this program. Do not merge those verbs.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
