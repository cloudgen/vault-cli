# Requirement ↔ test matrix — vault-cli

**Updated:** 2026-09-30 (1.0.0)  
**Product VERSION:** 1.0.0  
**Suite:** `tests/run.sh` (1.0.0: PASS=367 FAIL=0 SKIP=0). Sources `tests/test_cli.sh`, `tests/test_local_lifecycle.sh`, and `tests/test_domain_vault.sh`. Does not source `tests/test_domain_folder_backup.sh`. Rows that cite **TP-FOLDER-BACKUP-*** describe that withdrawn file.

| Requirement key | Area | TP families | Coverage notes |
|-----------------|------|-------------|----------------|
| requirement-class-software-dev | class | TP-CLI-01, TP-CLI-11 | Syntax + stack residual; channel verbs kept |
| requirement-bootstrap-chain | architecture | TP-CLI-04, TP-CLI-07, TP-CLI-10, TP-CLI-23 | Channel verbs listed; offline version-check / self-update fail closed; a script with no command copies (`inst_self_install`) and does not fetch |
| requirement-project-folder | architecture | TP-LC-01, TP-FOLDER-BACKUP-06 | src ship unit; deposit path naming |
| requirement-three-layer-privilege-model | architecture | TP-FOLDER-BACKUP-01, **01b**, 01c, 02, 05, **14**, **15**, **15b**, **19**, **20**, **21**, **21b**, **22e**, **23**, **23b**, **23c**, **24**, **24b**, **24c**, **24d**, **26**, **26b**; **27 todo** | Trust tiers **S13**; submit workflow AC-16–22; independent generate AC-23/24; inbound fidelity; host-probe add/update; other-user dest ignored; **backup \*** emit AC-25; `--json` twins AC-26 (text have; compact JSON Gap) |
| requirement-sudoer-json-file | architecture | TP-FOLDER-BACKUP-**22**, **22b**, **22c**, **22d**, **22e**, **22f**, **24**, **24c**, **24d**, **26**, **26b**; **27 todo** | JSON grant is `folder-backup` backup/restore plus `*` **and** `--json` twins (AC-26); compact JSON emit **Gap**; pretty emit + inbound body keep both verbs; independent generate dest readable; OS-tool submit refuse |
| requirement-folder-archive-backup | backup | TP-FOLDER-BACKUP-03..08, 10..13, **16** | Source/name/deposit/verify/next-N/**restore** + dest whitelist W-ETC-USER (ops SSOT) |
| requirement-folder-archive-backup-retention-total | backup | TP-FOLDER-BACKUP-17, 17b, **17c** | Max **30** per basename; oldest-first prune; failed backup does not prune |
| requirement-folder-archive-backup-retention-daily | backup | TP-FOLDER-BACKUP-18, 18b, **18c** | Max **5** per basename per day; lowest-`N` same-day prune; failed backup does not prune |
| requirement-shell-cli-interface | shell | TP-CLI-* · **TP-VAULT-01..06** | Commands, flags, dispatch of `list` / `add` / `update` / `edit`; **menu/main** TP-CLI-13..16; Work commands heading (**TP-CLI-17 have**) |
| requirement-shell-script-coding | shell | (indirect) | Specialize-in home; own-or-point |
| requirement-shell-sudo-command | shell | TP-FOLDER-BACKUP-01, 01c, 26; **27 todo** | Studied allow table; wrap Gap |
| requirement-shell-cli-zero-arguments | shell | TP-CLI-07, **23** | **Active 1.2.1** — interactive boards; non-interactive `inst_self_install`; `--quiet` / `--json` / non-TTY `--debug` place; TTY `--debug` does not; named menu stop is default-interaction |
| requirement-shell-cli-default-interaction | shell | TP-CLI-07, **13**, **14**, **15**, **16**, **18**, **19**, **21**, **23** | **Active 1.10.0** — interactive zero-cli-verb = numbered boards; non-interactive place is zero-arguments; named `menu` / `self-management` off a terminal stop; empty front line leaves; row **82** and typed `version` run `about`; front **1**/**8**/**9**; client **11** list / **12** add / **13** update; self **81**–**87**; no sudoers board; bold short name; finished leaf redisplays the front |
| requirement-shell-cli-sudoers-submenu | shell | (withdrawn) | **Withdrawn.** Current client board has no row **17**. `vault-cli sudoers` is an unknown command (**TP-CLI-13**) |
| requirement-shell-local-self-management | shell | TP-LC-* (incl. **09/10** mode) | install/uninstall/where-is-me; **0755** multi-user; global preferred for elev |
| requirement-shell-output-requirements | shell | TP-CLI-03,05,08,09, **18** | JSON / quiet / errors; identity token + numbered-row ink |
| requirement-operator-readable-error | shell | TP-FOLDER-BACKUP-**25**, **25b**, **25c** | Operator-facing `[ERROR]` wording (what happened / next step / no jargon-only) |
| requirement-shell-modular-function-design | shell | (indirect) | `fb_print_sudoers*`, `fb_remove_project_sudoers`, deposit/restore |
| requirement-shell-idempotency | shell | TP-LC-03,07 · TP-FOLDER-BACKUP-06,08 | Re-install; next-N |
| requirement-shell-interactive-vs-noninteractive | shell | TP-LC-05 · TP-FOLDER-BACKUP-15 · **15b** | Uninstall / remove-project-sudoers confirm; multi-draft non-interactive path required |
| requirement-shell-cli-storage | shell | TP-CLI-06 · TP-CLI-12 | Per-login per-process cache (law **1.4.1**); silent tier miss; leaf mode 0700; persistence `${HOME}/.local/vault-cli` |
| requirement-domain-folder-backup | domain | (withdrawn file `tests/test_domain_folder_backup.sh`, not sourced) | **Withdrawn.** Superseded by `requirement-domain-vault-cli` |
| requirement-domain-vault-cli | domain | **TP-VAULT-01..06** · TP-CLI-13 · TP-CLI-17 | `list` / `add` / `update`; `edit` aliases `update`; no secret bytes; client rows **11**/**12**/**13** |

**Checklist / mold (harness, not product suite):** **S11–S12** elev tables (when claimed); **S13** trust tier; **S14** emit; **S15** convert/inbound; **S16** independent generate dest — agent path `SK-CREATE-SUDOERS-FILE` / `CL-CREATE-SUDOERS-SECURITY`. Operator errors: `SK-OPERATOR-READABLE-ERROR` / `CL-OPERATOR-READABLE-ERROR`.

**Kept (user order 2026-09-30):** channel verbs, automatic SHA-256 companion on download, terminal numbered boards, non-interactive zero-cli-verb as `inst_self_install`, local `install` as the 0755 copy. Do not drop those without an owner order.
