# CLI routed-verb table — vault-cli

**Product:** vault-cli  
**Ship unit on disk:** `src/vault-cli`  
**Dispatcher:** `app_main`  
**Scan date:** 2026-09-30  
**Mode:** law matches the dispatcher case  

Inventory from the dispatcher case, not help. Human-readable form is `short-descript: explain` (short-descript = routed-verb).

## Live

| verb | handler | privilege | last modified date | purpose | human-readable |
|------|---------|-----------|--------------------|---------|----------------|
| version | `app_version` | you | 2026-09-30 | diagnostics | version: Show the local version |
| about | `app_about` | you | 2026-09-30 | diagnostics | about: Show diagnostics including vault root and vault counts |
| help | `app_help` | you | 2026-09-30 | diagnostics | help: Show this help |
| install | `inst_local_install` | you | 2026-09-30 | self-managed | install: Copy this program into your bin or /usr/local/bin |
| uninstall | `inst_local_uninstall` | you | 2026-09-30 | self-managed | uninstall: Remove the managed binary (not the vault root) |
| where-is-me | `app_where_is_me` | you | 2026-09-30 | self-managed | where-is-me: Show running and install paths |
| self-install | `inst_self_install` | you | 2026-09-30 | self-managed | self-install: Copy this file, or download it when the shell is a pipe |
| version-check | `ver_check` | you | 2026-09-30 | self-managed | version-check: Compare this version with the channel |
| self-update | `inst_self_update` | you | 2026-09-30 | self-managed | self-update: Replace the placed binary from the channel |
| self-uninstall | `inst_self_uninstall` | you | 2026-09-30 | self-managed | self-uninstall: Remove the channel-placed binary |
| self-management | `app_default_self_loop` → `app_cmd_menu_self` | you | 2026-09-30 | self-managed | self-management: On a terminal, numbered self-management board (81-87). Off a terminal, stops: self-management needs a terminal |
| list | `vc_list` | you | 2026-09-30 | operational | list: Show ssh-vault, github-vault, and cloudflare-vault names without secrets |
| add | `vc_add` | you | 2026-09-30 | operational | add: Add one ssh-vault, github-vault, or cloudflare-vault |
| update | `vc_update` | you | 2026-09-30 | operational | update: Edit one existing ssh-vault, github-vault, or cloudflare-vault |
| edit | `vc_update` | you | 2026-09-30 | operational | edit: Alias of update (not a second menu row) |
| menu | `app_cmd_menu` (`app_main_menu` aliases it) | you | 2026-09-30 | operational | menu: Numbered boards: client-side, self-management, and Exit (same boards as a TTY empty run; a script stops: menu needs a terminal) |
| main | `app_cmd_menu` | you | 2026-09-30 | operational | main: Same as menu |

## Not routed

| verb | status |
|------|--------|
| backup, restore, print-sudoers, print-sudoers-install-script, remove-project-sudoers, generate-sudoer-request, submit-sudoer-request | unknown command |
| sudoers | unknown command |
| setup | forbidden (not this CLI) |

Do not list `menu` / `main` as choices on their own menu.

A TTY **front** board prints category rows, not the flat work list. vault-cli is **case 2**. Front rows are **1** client-side, **8** self-management, **9** Exit. Number **2** stays reserved (no host service).

**Law** (`requirement-shell-cli-default-interaction` 1.10.0): client rows are **11** list, **12** add, **13** update, **0** Back. `edit` runs `update` and is not a numbered row. There is no sudoers board. Row **85** stays `self-update` (channel replace), not `vc_update`.

**Disk** (`src/vault-cli` on 2026-09-30): `app_main` routes `list`, `add`, `update`, and `edit`. It does not route backup, restore, or the grant verbs. The printed client board is **11** list, **12** add, **13** update.

The self board prints **81**–**87**. Row **82** and a typed `version` on a board run `about`. Argv `version` stays `app_version`. `uninstall` and `where-is-me` stay typed. A finished leaf redisplays the front. An empty line on the front leaves. Child Back is **0**. Off a terminal, `menu` and `self-management` stop. Typing `self-update` on the front is invalid. Open **8**, then **85**.

**Front:** client-side, self-management, Exit. **Client:** list, add, update. **Self board:** install, version, about, version-check, self-update, self-uninstall, self-install.

## Honesty

Dispatcher tokens on 2026-09-30: version, about, help, install, uninstall, where-is-me, self-install, version-check, self-update, self-uninstall, self-management, list, add, update, edit, menu, main. Empty argv is **not** a token: on a real terminal it calls `app_cmd_menu`; a pipe, `--quiet`, or `--json` with no command calls `inst_self_install`. Named `menu` and `self-management` off a terminal stop (`needs a terminal`). Channel verbs are live and sit on the self board (front row **8**), not as front rows. `install` is the local copy and self row **81**. `self-update` replaces the program. `update` edits a vault.
