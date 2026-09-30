# Report: bootstrap specialize — folder-backup 1.6.1

**Date:** 2026-08-13  
**Mode:** local specialize review + fix  
**Status:** closed (alignment fixes applied)

## Summary

Re-specialized from sibling **cli-template** (A → B). Live origin is no longer selfmanaged. Type 0 body inherited from A; domain `fb_*` re-extended. Local review found VERSION surface drift; those cites now match ship unit **1.6.1**. Suite after specialize: PASS=157 FAIL=0 SKIP=2.

## Issues

### Issue 1 -- Severity: bug
- File: README.md:3
- Description: Version badge still 1.6.0
- Suggestion: Badge 1.6.1
- Status: closed

### Issue 2 -- Severity: bug
- File: SECURITY.md:7
- Description: Supported current still 1.6.0
- Suggestion: 1.6.1 current; keep 1.6.0 supported
- Status: closed

### Issue 3 -- Severity: bug
- File: docs/requirements/README.md:12
- Description: Version SSOT still 1.0.0
- Suggestion: 1.6.1
- Status: closed

### Issue 4 -- Severity: suggestion
- File: docs/requirements/requirement-shell-cli-interface.md:67
- Description: Peer law Version SSOT 1.0.0 / “trimmed” wording
- Suggestion: 1.6.1; online absent inherited from cli-template
- Status: closed

### Issue 5 -- Severity: suggestion
- File: src/folder-backup:501
- Description: `inst_get_version` comments named self-update / version-check
- Suggestion: Local about/install diagnostics only
- Status: closed
