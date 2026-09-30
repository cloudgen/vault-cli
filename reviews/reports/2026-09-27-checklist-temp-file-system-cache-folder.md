# Filled run: CL-TEMP-FILE-SYSTEM — folder-backup 1.16.5 cache folder

**Date:** 2026-09-27  
**Blank form:** `docs/templates/checklists/checklist-temp-file-system.md`  
**Product:** folder-backup (`src/folder-backup`)  
**Change type:** fix  
**Related law:** `requirement-shell-cli-storage` **1.4.0** · `LM-SHELL-CLI-STORAGE` **1.6.0**  
**Proof:** **TP-CLI-06** · **TP-CLI-12** (`tests/test_cli.sh`)  
**Suite:** `sh tests/run.sh` — PASS=410 FAIL=0 SKIP=2 (2026-09-27)

## Verdict

- [x] **Pass** — per-login per-process cache directory; mktemp files; silent tier miss; cleanup
- [ ] **Revise**
- [ ] **Block**

Reviewer / role: Implement + Review (this change)  
Date: 2026-09-27

## 1. Leaves (blocking)

- [x] Scratch created with `mktemp` / `util_mktemp` under `${TMPDIR}` (after storage resolve)
- [x] `mkdir` of one cache tier is fail-soft and silent (**TP-CLI-12** skip of preferred: no `fallback` text on stderr, no `Cannot create cache`, live path is the 1st fallback)
- [x] Linux: `/dev/shm/cache/cache-${APP_NAME}-${login}-$$`, then `/tmp/cache/...`, then `${HOME}/.cache/cache-${APP_NAME}-$$` (**TP-CLI-12**)
- [x] Git Bash: `/tmp/cache/cache-${APP_NAME}-${login}-$$`, then `${HOME}/AppData/Local/Temp/cache-${APP_NAME}-$$`. No 2nd fallback line (**TP-CLI-12**)
- [x] Mac: `/tmp/cache/...`, then `${HOME}/Library/Caches/cache-${APP_NAME}-$$`, then `${HOME}/cache/cache-${APP_NAME}-$$` (**TP-CLI-12**)
- [x] Cache directory may end in `-$$`. Scratch files stay `mktemp` (`util_mktemp` uses `XXXXXX`, not `${APP_NAME}.$$`)
- [x] `ps -p $$` is not used as a cache path
- [x] `mktemp` failure stays fail-closed (`util_mktemp` falls through to `mktemp`, then dies only when the resolver has no tier)
- [x] Chosen leaf mode **0700** and owned by this login (`util_cache_try_dir` refuses a symlink, another owner, or a mode that is not `drwx------`) (**TP-CLI-12**). Live path is not `/dev/shm/${APP_NAME}` or `/dev/shm/${APP_NAME}-${login}`

## 2. Cleanup

- [x] Success path removes scratch after last read (backup staging `trap`; cache directory itself is the process leaf)
- [x] Fatal helpers still `exit 1` only when every cache tier failed (`Cannot create cache folder`)
- [x] Re-run does not reuse another process’s leaf (`$$` is this process)

## 3. Root vs leaf

- [x] Root still from `util_resolve_storage`. No second chain
- [x] `TMPDIR` exported to the chosen cache directory (`app_main`)
- [x] Persistence is not a cache tier: `${HOME}/.local/${APP_NAME}` (no login suffix, no `$$`)

## 4. Proof

- [x] **TP-CLI-06** human labels: Cache folder used, preferred, 1st fallback, 2nd fallback, Persistence storage. JSON: `cache_used`, `cache_preferred`, `cache_fallback`, `cache_fallback_2`, `persistence_storage`
- [x] **TP-CLI-12** Linux, Git Bash, and Mac chains; silent skip; mode 0700; persistence `${HOME}/.local/${APP_NAME}`
- [x] Full suite PASS=410 FAIL=0 SKIP=2 (skips remain elevated deposit TP-FOLDER-BACKUP-07 and 08 when not root)

## Scope

| Field | Value |
|-------|--------|
| Script / ship unit | `src/folder-backup` 1.16.5 |
| Related requirement | `requirement-shell-cli-storage` 1.4.0 |
| Change type | fix |
