# Report: requirement coverage — folder-backup 1.8.2

**Date:** 2026-08-17  
**Mode:** SK-REQUIREMENT-SUFFICIENT-CHECK (C-full-product) · SK-REQUIREMENT-REVIEW Step −2/−1/1a  
**Status:** Sufficient with Gaps (P1/P2 closed 2026-08-17)  
**Suite cited:** PASS=219 FAIL=0 SKIP=2 (`tests/run.sh`, 2026-08-17; after P1/P2)

## Summary

Registered product law **owns every live dispatcher verb**. Domain, JSON grant, submit workflow, and artifact samples are present. The claim is **not** “Not sufficient”: there is no unowned domain surface. Remaining Gaps are **law-internal stale OS-tool example**, a few **untested ACs**, and **map hygiene** (RTM / CLI VERSION cite).

This dest remains a Type 0 **submitter**, not the sudoer-cli approval machine.

## Registry inventory (Step −1)

| Bucket | Result |
|--------|--------|
| Registered ∩ on disk | **17** — match |
| Orphans | none |
| Ghosts | none |
| Foreign candidates | none |
| Scope | registry-only |

Class gate (Step −2): **software-development** · exactly one Active `requirement-class-software-dev.md` · Pass.

Bootstrap: A=`cli-template` → B=`folder-backup` (domain extend). Review-only this turn; no rewrite.

## Claim

- **ID:** C-full-product  
- **Text:** Full specialized product including domain backup/restore, privilege emit/submit, and local Type 0 lifecycle.

## SSOT preflight

- Identity: **aligned** — Config `APP_NAME=folder-backup` · `VERSION=1.8.2` · `REPO_USER=cloudgen` · `SCRIPT_URL` empty  
- Install mode: **local-only** (`install` + `uninstall` + `where-is-me`)  
- Notes: CLI interface Implementation Notes still cite `VERSION="1.8.0"` (stale pin; see FB-COV-02)

## Registered law

- Registry rows: **17**  
- Domain requirements present: **yes** (`requirement-domain-folder-backup` sole Active domain)  
- Privilege / JSON: `requirement-three-layer-privilege-model` 1.8.0 · `requirement-sudoer-json-file` 1.1.0  

## Live surfaces (summary)

- **Lifecycle:** empty-argv help, version, about, help, install, uninstall, where-is-me  
- **Domain:** backup, restore, print-sudoers, print-sudoers-install-script, remove-project-sudoers, submit-sudoer-request  
- **Flags:** `--json` `--quiet` `--force` `--debug` `--allow-test-local` `--add` `--update`  
- **Help-only:** none (help verbs match dispatcher allowlist in `app_main`)

## Ownership matrix

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| empty argv / help / version / about | lifecycle | shell-cli-interface · zero-arguments · output | ok |
| install / uninstall / where-is-me | lifecycle | local-self-management | ok |
| backup / restore ops | domain | folder-archive-backup (+ retention daily/total) | ok |
| restore dest whitelist | domain | folder-archive-backup AC-15–18 | ok · TP-16 |
| print-sudoers / install-script / remove draft | domain + privilege | three-layer · domain surface | ok |
| submit-sudoer-request | domain + privilege | three-layer §2.3.3c · sudoer-json-file body | ok |
| host dest → add/update | privilege | three-layer AC-22 | ok · TP-23/23b; other-user row untested |
| JSON grant body | artifact | sudoer-json-file | ok |
| inbound detect / no Type 0 mkdir | privilege | three-layer AC-16/17 | ok · TP-21/21b |
| inbound re-encode fidelity | artifact + privilege | sudoer-json-file AC-9 · three-layer AC-21 | ok · TP-22e/22f |
| online install / SCRIPT_URL / self-update | absent | class + bootstrap-chain | ok (intentionally absent) |
| Type 1 TTY approver / login hook | n/a | — | N/A (Type 0 submitter) |
| LPU / LPA operator account | n/a | — | N/A (sibling `sudoer-adm` is not this product) |

## Artifact filename + content (Step 3c)

| Kind | Filename grammar | Sample basename | Content structure | Sample body (per variant) | Paired convert | Status |
|------|------------------|-----------------|-------------------|---------------------------|----------------|--------|
| Queued JSON sudoer file | yes (`sudoer-{{YYYYMMDD}}-{{PRJ_NAME}}-{{username}}-{{action}}-{{n}}.json`) | yes (add + update) | yes (closed schema §2.4) | yes (add + update + withdrawn OS-tool) | yes (text dual same grant) | **ok** |
| Installed dest basename | yes (`/etc/sudoers.d/{{APP_NAME}}-{{user}}` + legacy) | yes | n/a (sibling install) | n/a | n/a | **ok** (workflow peer) |

## TTY measurement (Step 3d)

- In scope: **yes** (uninstall / remove-project-sudoers confirm)  
- Measure outside functions: **yes** (interactive REQ §2.2)  
- Helpers consume TTY: **yes** + complete `prompt_yes_no` / `prompt_ask` samples  
- Temp: storage REQ has `util_mktemp` sample and forbids `$$`  

## Named workflow machine (Step 3e)

- In scope: **yes** (Type 0 sudoers-grant submitter)  
- Named machine + roles (submitter / allocator / approver) + inbound detect + no-mkdir + sibling allocate: **yes** (three-layer §2.3.3c)

## TTY approver path (Step 3f)

- In scope: **N/A**

## LPU / LPA operator (Step 3g)

- In scope: **N/A** (this product does not own `sudoer-adm`)

## AC ↔ TP (high-signal)

| REQ | ACs with automated TP | Gaps / notes |
|-----|------------------------|--------------|
| three-layer | 2, 3, 4, 9, 11, 13–22 | AC-7 host-dependent (TP-07/08 **SKIP**); AC-8/12 agent checklist; AC-22 other-user no TP |
| sudoer-json-file | 1–5, 7–9 | AC-6 samples in REQ (law, not suite) |
| folder-archive-backup | 1–6, 10–18 | AC-7/8/9 need deposit (SKIP without elev); AC-8 JSON verify fields thin |
| retention daily/total | 1–4, 6 | AC-5 failed-backup does not prune: **no TP** |
| domain | 1–7 | about `host_sudoers_present` in TP-CLI-06 |
| shell family | CLI-01..12 · LC-01..10 | modular/output mostly indirect |
| class / bootstrap / project-folder | CLI-04/10/11 · LC-01 · FB-06 | review-time ACs |

## Honesty / consistency

1. **FB-COV-01 (medium)** — **closed:** three-layer **1.8.1** §2.3.4 / §2.3.4a is the `folder-backup backup`/`restore` text dual.  
2. **FB-COV-02 (low)** — **closed:** CLI interface notes cite ship unit `VERSION=` SSOT (no stale pin).  
3. **FB-COV-03 (low)** — **closed:** test-plan TP-01c one-liner matches the restore-verb assertion.  
4. **FB-COV-04 (low)** — **closed:** RTM sudoer-json-file row includes **TP-22d**.  
5. **FB-COV-05 (low)** — **closed:** **TP-23c** other-user fragment stays `add`.  
6. **FB-COV-06 (low)** — **closed:** **TP-17c / 18c** failed backup does not prune.

## ID notation (Step 0-ID)

- DTV uses **TP-*** · Pass  
- `RQ-SUDOER-JSON-FILE` declared on that REQ · Pass  
- No harness path dump in `index.md` · Pass  

## Least privilege (Step 0-LP)

- Type 0 vs Type 1 deposit vs no Type 2 · Pass  
- JSON grant `{{PRJ_NAME}}` only · Pass  
- Stale OS-tool example (FB-COV-01) · **Revise** that example when authorized  
- LPU/LPA review · **N/A**

## Verdict

**Sufficient with Gaps**

Every live product surface has a registered owner; artifact filename + samples exist; submit workflow is named; suite covers inbound, re-encode, and host-probe add/update. Gaps are stale privilege example text, a few untested AC rows, and review-map hygiene — not missing domain law.

## Recommendations

- **P0:** none.  
- **P1:** **done** — three-layer 1.8.1 project-command example.  
- **P2:** **done** — TP-23c · TP-17c/18c · CLI VERSION cite · RTM 22d · TP-01c one-liner.

## Checklist A–G (review-only)

| Section | Result |
|---------|--------|
| A class/registry/bootstrap | Pass (no rewrite) |
| B template/coverage | Pass with Gaps (FB-COV-01 example) |
| B2 ID notation | Pass |
| B3 least privilege | Pass with Gaps (example) · LPU N/A |
| C dual policy | Pass (stale VERSION cite = notes hygiene) |
| D naming | Pass |
| E defensive | Pass (incidents 001/017 considered) |
| F process | Pass (findings only) |
| G git-surface | Pass |
