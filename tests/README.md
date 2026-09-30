# Tests — vault-cli

## Run

```sh
./tests/run.sh
# or
sh tests/run.sh
```

Exit **0** when all assertions pass; **1** on failure; **2** if ship unit missing.

## Layout

| File | Focus | TP families |
|------|--------|-------------|
| `run.sh` | Entrypoint | — |
| `helpers.sh` | Asserts + isolated HOME | — |
| `test_cli.sh` | CLI surface, case 2 empty argv, numbered boards, Work commands heading, offline online-reject | **TP-CLI-*** (incl. **TP-CLI-17** heading · **TP-CLI-18** look) |
| `test_local_lifecycle.sh` | install / uninstall / where-is-me | **TP-LC-*** |
| `test_domain_vault.sh` | list / add / update for ssh-vault, github-vault, and cloudflare-vault | **TP-VAULT-*** |
| `test_backup_restore.sh` | Typed `backup` / `restore`; deposit under `BACKUP_ROOT/APP_NAME`; default folder `/var/backups/vault-cli` | **TP-BACKUP-01..05** |
| `test_domain_folder_backup.sh` | Withdrawn backup suite. `tests/run.sh` does not source it | **TP-FOLDER-BACKUP-*** (not this run) |

## Isolation

- Temp `HOME` + `USER_BIN` for CLI and install tests (`ci_isolated_env` at the start of the CLI suite)  
- **No** public network  
- **No** write to `/etc/sudoers.d` (suite never installs sudoers)  
- **No** enqueue into live `/var/sudoer-cli/sudoer-request` (runner snapshot). If that inbound dir is **absent**, the fence records SKIP rather than a proof.  
- The current suite does not deposit archives and does not call `sudo`.  

PASS/FAIL/SKIP counts are **per assertion**, not per TP-ID. TTY menu cases (TP-CLI-13/14/16/18) SKIP without `python3`.

## Ship unit under test

`src/vault-cli` (**1.0.0**)

Last run: `sh tests/run.sh` — PASS=367 FAIL=0 SKIP=0.

## Maps

Product TP map: `reviews/test-plan.md`  
RTM: `reviews/requirement-test-matrix.md`
