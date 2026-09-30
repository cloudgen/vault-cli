# Requirement sufficient check — menu contract

**Date:** 2026-09-30  
**Product:** folder-backup  
**Ship unit:** `src/folder-backup` **1.20.0**  
**Suite:** `sh tests/run.sh` — PASS=473 FAIL=0 SKIP=2

## Claim

- ID: **C-menu**
- Text: Named `menu`, `main`, and `self-management` off a terminal stop. An empty line on the front leaves. On a numbered board, row **82** and a typed `version` run `about`. Argv `version` stays the thin version line. A pipe with no command still places this program.

## SSOT preflight

- Identity: **aligned**. `APP_NAME` is `folder-backup`. `VERSION` is `1.20.0`. README Quick Installation still leads with the raw-script pipe.
- Notes: No new requirement file. Registry stays 21 Active + 0 Withdrawn. The 1.19.0 place route is unchanged. Interactive `menu --json` still draws.

## Registered law

| Key | Version | What it now says |
|-----|---------|------------------|
| `requirement-shell-cli-default-interaction` | 1.9.0 | Off a terminal, named menu stops. Empty front line leaves. Row **82** and a typed `version` on a board run `about`. |
| `requirement-shell-cli-zero-arguments` | 1.2.1 | Place route unchanged. Named menu stop is owned next door. Flags-only `--json` stays self-install. |
| `requirement-shell-cli-interface` | 1.10.1 | `menu` and `self-management` off a terminal stop. |
| `requirement-shell-interactive-vs-noninteractive` | 1.1.3 | `menu` / `main` off a terminal stop. They do not print help. |

## Live surfaces

- `app_cmd_menu` off a terminal calls `out_die` (`menu needs a terminal. Next: folder-backup help`, exit 1). On a terminal it still forces JSON and quiet off while drawing.
- `app_default_self_loop` off a terminal stops with `self-management needs a terminal`. The dispatcher calls that function for the verb.
- Front Exit accepts **9**, **99**, `exit`, `quit`, `q`, and an empty line. Child boards treat `q` and an empty line as Back.
- `app_menu_run_leaf` for `version` calls `app_about`. Dispatcher `version` still calls `app_version`.
- Row **2** stays hidden. Sudoers stays client **17** with **172** and **175**. There is no language board.

## Proof

`sh tests/run.sh` reported PASS=473 FAIL=0 SKIP=2. **TP-CLI-15** checks the off-terminal stop, including `--json` error and `--quiet`. **TP-CLI-21** checks empty Enter, row **82**, and a typed `version`. **TP-CLI-14** still checks that interactive `menu --json` draws. **TP-CLI-07** and **TP-CLI-23** still check the place route. Argv `version` still prints `folder-backup version 1.20.0`.

The 1.18.0 menu report and the 1.19.0 zero-cli-verb report describe those releases. Named menu as help in those reports is not the 1.20.0 contract.

## Honesty

These stay open and must not be treated as done:

- In-tool sudo wrap
- Normal-user-only detect helper
- Compact JSON `--json` twins (**TP-FOLDER-BACKUP-27**)
- Companion SHA-256 is implemented on download; the suite does not stand up a companion file
- Elevated deposit **TP-FOLDER-BACKUP-07** / **08** skip when this run is not root and has no deposit sudoers

Host `safe-rm` still refuses cleanup of the suite’s temporary homes (`/tmp/fb-home.*`). The suite still passes. Those directories were not removed with `/bin/rm`.

Installed copies were not replaced. `~/.local/bin/folder-backup` stayed **1.17.0**. `/usr/local/bin/folder-backup` stayed **1.16.1**.

## Verdict

- **Sufficient with Gaps**
- The menu contract above is owned and implemented. The gaps above remain.
