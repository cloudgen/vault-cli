# Product review: folder-backup (JSON sudoer file)

**Date:** 2026-08-15  
**Reviewer:** session agent  
**Product:** folder-backup `VERSION=1.8.0`  
**Ship unit:** `src/folder-backup`  
**Scope:** JSON sudoer file grant (`requirement-sudoer-json-file`); emit + suite + maps  
**Method:** disk read + `tests/run.sh`  
**Baseline:** suite run recorded in this change

## Summary

The elevation grant is now the project command only (`/usr/local/bin/folder-backup backup` and `restore`). OS-tool sudoers lines (`mkdir`/`cp`/`tar`/`rm`) are withdrawn: they grew the allowlist and let a user run those tools as root without the product. JSON emit (`<draft>.json` and submit default) matches the requirement samples. Live Type 1 deposit on hosts that still have the old OS-tool fragment continues to work until admin reinstalls; new fragments need a matching runtime re-exec path (documented residual).

## Strengths

| Area | Notes |
|------|--------|
| Law | Dedicated `requirement-sudoer-json-file`; three-layer defers JSON body |
| Emit | `fb_sudoers_json_text` + text dual share one grant |
| Tests | TP-22/22b/22c plus updated 01/01c/01d/02 |
| Honesty | Residual: runtime still uses `sudo -n mkdir/cp` for deposit until `sudo folder-backup backup` is wired |

## Findings

### FB-SUDOER-01 — Severity: P2 (medium)
- **Area:** SEC  
- **Status:** open (CHANGELOG + print-sudoers warn; runtime re-exec not in 1.8.0)  
- **Location:** `fb_deposit_archive` / `fb_remove_deposit_archive` / `fb_fetch_archive_readable`  
- **Description:** Runtime still elevates OS tools (`sudo -n mkdir`/`cp`/`tar`/`rm`). New fragments do not allowlist those tools. Hosts that **replace** the fragment with 1.8.0 text will lose non-root deposit until backup/restore re-execs `sudo ${GLOBAL_BIN}/folder-backup backup|restore`.  
- **Impact:** Admin who installs the new fragment without a runtime re-exec will see fail-closed deposit.  
- **Suggestion:** Next change: non-root `backup`/`restore` re-exec via allowlisted project command (operands via `*`).  
- **Cross-ref:** `requirement-sudoer-json-file` §2.3 · elev-is-approval  

## Non-findings (explicitly OK)

| Check | Result |
|-------|--------|
| JSON path identity | `/usr/local/bin/folder-backup` only |
| No OS-tool JSON commands | Pass (TP-22b) |
| No deposit/filename hardcode in JSON | Pass (TP-22c) |
| Type 0 still does not write `/etc` | Pass (TP-01) |
| Trust-tier refuse without allow | Pass (TP-01b) |

## Priority remediation order

1. Wire non-root backup/restore to `sudo -n ${GLOBAL_BIN}/folder-backup backup|restore *` (closes FB-SUDOER-01).  
2. Re-review host fragments after that runtime change.  

## Related

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-sudoer-json-file.md` | Grant law |
| `reviews/test-plan.md` | TP-22 family |
| `reviews/reports/2026-08-09-sudoers-security-folder-backup.md` | Prior OS-tool Pass (test only); superseded for grant **shape** |

**Written by:** session agent  
**Review status:** Findings open (FB-SUDOER-01 residual runtime)
