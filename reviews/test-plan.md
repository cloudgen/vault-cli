# Test plan — vault-cli

Maps **TP-*** coverage to `tests/`.  
**Suite entry:** `./tests/run.sh`  
**Ship unit on disk:** `src/vault-cli`  
**Product VERSION on disk:** 1.0.0  
**Last plan update:** 2026-09-30  
**Last suite run:** `sh tests/run.sh` (1.0.0: PASS=367 FAIL=0 SKIP=0)

The 1.0.0 run sources `tests/test_cli.sh`, `tests/test_local_lifecycle.sh`, and `tests/test_domain_vault.sh`. It does not source `tests/test_domain_folder_backup.sh`. Rows that cite **TP-FOLDER-BACKUP-*** describe that withdrawn file. They are not this run. Client rows **11** list / **12** add / **13** update are proved by **TP-CLI-13** and **TP-VAULT-01..06**.

Status: **have** = automated today · **todo** = needed · **optional** · **n/a** · **skip** (environment)

---

## Baseline coverage

| Area | Status | Evidence |
|------|--------|----------|
| Syntax `sh -n` | have | TP-CLI-01 |
| version / help / about human + JSON | have | TP-CLI-02..06 |
| Non-interactive zero-cli-verb = CLI self-install (copy, mode 0700, second run already installed) | have | TP-CLI-07 |
| Switches with no verb: `--quiet` / `--json` / non-TTY `--debug` place; TTY `--debug` stays the boards; `--debug version` stays version | have | TP-CLI-23 |
| TTY empty argv + `menu`/`main` boards (front **1**/**8**/**9**, client **11**/**12**/**13**, self **81**–**87**); named `menu` off a terminal stops | have | TP-CLI-13..16 · **19** · **21** |
| TTY main-menu look (nametag + bold short name + gray italic explain) | have | TP-CLI-18 |
| Unknown + quiet + set -u HOME | have | TP-CLI-08..11 |
| Per-login per-process cache folder + persistence `${HOME}/.local/vault-cli/` | have | TP-CLI-06 · TP-CLI-12 |
| Channel verbs listed; offline version-check / self-update fail closed; a script `$0` with no command copies and does not fetch | have | TP-CLI-04, TP-CLI-07, TP-CLI-10 |
| Local install / idempotent / uninstall / mode 0755 | have | TP-LC-01..10 |
| Help Work commands are `list` / `add` / `update` / `edit`; `self-update` stays under self-managed; grant heading is absent | have | TP-CLI-04 · TP-CLI-17 |
| Independent generate dest readable without sudo | have | TP-FOLDER-BACKUP-24/24b/24c/24d |
| Operator-readable inbound-fidelity `[ERROR]` | have | TP-FOLDER-BACKUP-25/25b/25c |
| Submit detect: public inbound first; env override; no Type 0 mkdir | have | TP-FOLDER-BACKUP-19/20/21/21b |
| JSON sudoer file is `folder-backup` backup/restore only (no OS tools / path / filename) | have | TP-FOLDER-BACKUP-22/22b/22c |
| Pretty emit + inbound body keep both verbs (sibling re-encode fidelity) | have | TP-FOLDER-BACKUP-22e/22f |
| Submit action: host `/etc/sudoers.d` fragment → update; else add | have | TP-FOLDER-BACKUP-23/23b/23c |
| Domain surface: print-sudoers allowlist + test-mode gate | have | TP-FOLDER-BACKUP-01, 01b, 01c, 02 |
| Admin install-script handoff (project-sudoers-file) | have | TP-FOLDER-BACKUP-14 |
| Remove project-sudoers draft only | have | TP-FOLDER-BACKUP-15 |
| Multi-draft remove choose / path-required | have | TP-FOLDER-BACKUP-15b · **15c** |
| Per-user draft + installed sudoers basename | have | TP-FOLDER-BACKUP-14 · 15 |
| Backup ops (name, fail-closed, verify) | have | TP-FOLDER-BACKUP-03..06 · **requirement-folder-archive-backup** |
| Elevated deposit + next-N + verify | have (root **or** allowlisted `sudo -n`) | TP-FOLDER-BACKUP-07/08 |
| Restore (explicit + hard-disk default) | have | TP-FOLDER-BACKUP-11..13 |
| Companion SHA-256 on download | todo | Ship unit fetches `${SCRIPT_URL}.sha256` on `self-install` / `self-update`. Suite does not stand up a companion. No live GitHub fetch. |

---

## TP rows

### TP-CLI (CLI surface)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-CLI-01 | `sh -n` ship unit | `tests/test_cli.sh` | requirement-shell-cli-interface | **have** |
| TP-CLI-02 | version human | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-03 | version JSON | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-04 | help lists channel verbs and SCRIPT_URL; print-sudoers + install-script + remove-project-sudoers + generate-sudoer-request + submit-sudoer-request; no CHECKSUM in help | test_cli | requirement-shell-cli-interface · domain | **have** |
| TP-CLI-05 | help JSON short | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-06 | about JSON cache_used / cache_preferred / cache_fallback / cache_fallback_2 / persistence_storage + human Cache folder used, preferred, 1st fallback, 2nd fallback + Persistence storage + domain fields + channel script_url | test_cli | requirement-shell-cli-storage · domain | **have** |
| TP-CLI-07 | off-TTY empty argv copies this file (self-install), mode 0700, second run already installed; not help and not the boards | test_cli | **shell-cli-zero-arguments** AC-1 / AC-2 / AC-5 · **shell-cli-default-interaction** AC-1 | **have** |
| TP-CLI-08 | unknown fail-closed | test_cli | requirement-shell-cli-interface | **have** |
| TP-CLI-09 | quiet suppresses version | test_cli | requirement-shell-output-requirements | **have** |
| TP-CLI-10 | channel verbs routed; offline version-check / self-update fail closed (non-empty dead URL); self-uninstall with no binary exits 0 | test_cli | requirement-bootstrap-chain | **have** |
| TP-CLI-11 | env -u HOME version | test_cli | class / defensive | **have** |
| TP-CLI-12 | Linux / Git Bash / Mac cache chains; silent skip of preferred; leaf mode 0700 owned by this login; persistence `${HOME}/.local/folder-backup` exists | test_cli | requirement-shell-cli-storage | **have** |
| TP-CLI-13 | interactive empty argv **and** `menu` print front **1**/**8**/**9**, hidden server sentence, client **11**/**12**/**17**, sudoers **172**/**175** + hide sentence + Back **0**, self **81**/**87**; `sudoers` not dispatched; members live **without** enqueueing live inbound | test_cli | **shell-cli-default-interaction** AC-3 / AC-10 / AC-11 · **shell-cli-sudoers-submenu** AC-1–AC-5 | **have** |
| TP-CLI-14 | interactive `menu --json` still prints the list | test_cli | **shell-cli-default-interaction** AC-4 | **have** |
| TP-CLI-15 | non-interactive `menu` / `main` / `self-management` exit 1 (`needs a terminal`); `menu --json` off a terminal is a JSON error. Flags-only `--json` is **TP-CLI-23** (self-install), not this row | test_cli | **shell-cli-default-interaction** AC-5 | **have** |
| TP-CLI-16 | front board shows **8** self-management and omits help / verb rows that belong on a child board (backup, grant verbs, test-purpose) | test_cli | **shell-cli-default-interaction** AC-6 · **shell-cli-sudoers-submenu** AC-5 | **have** |
| TP-CLI-17 | help lists test-purpose grant-emit verbs under a heading apart from operational | test_cli | **shell-cli-interface** AC-9 | **have** |
| TP-CLI-18 | default CLI main menu style: header `APP_NAME(VERSION)` bold/italic; short name bold; numbered explain italic + light gray; Exit unstyled; no CSI off-TTY; sudoers title (portable **TP-CLI-17** alias) | test_cli | **shell-cli-default-interaction** AC-8 · **shell-cli-sudoers-submenu** AC-6 · **shell-output-requirements** AC-5 | **have** |
| TP-CLI-19 | child number **12** on the front is invalid and the front reprints | test_cli | **shell-cli-default-interaction** AC-12 | **have** |
| TP-CLI-20 | ship unit has no `$()` of `prompt_*` helpers | test_cli | **shell-script-coding** · **shell-interactive-vs-noninteractive** AC-4 | **have** |
| TP-CLI-21 | empty Enter on the front leaves; row **82** and a typed `version` run `about` and the front reprints. Argv `version` stays the thin line | test_cli | **shell-cli-default-interaction** AC-12 / AC-13 | **have** |
| TP-CLI-23 | `--quiet`, `--json`, and non-TTY `--debug` with no command place the CLI; TTY `--json` places and is not the boards; TTY `--debug` shows the front and does not place; `--debug version` stays version | test_cli | **shell-cli-zero-arguments** AC-3 / AC-4 | **have** |

### TP-LC (local lifecycle)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-LC-01 | install → USER_BIN | test_local_lifecycle | requirement-shell-local-self-management | **have** |
| TP-LC-02 | installed binary version | test_local_lifecycle | local self-management | **have** |
| TP-LC-03 | reinstall already-installed | test_local_lifecycle | requirement-shell-idempotency | **have** |
| TP-LC-04 | where-is-me | test_local_lifecycle | local self-management | **have** |
| TP-LC-05 | uninstall JSON no force fail-closed | test_local_lifecycle | interactive-vs-noninteractive | **have** |
| TP-LC-06 | uninstall --force removes | test_local_lifecycle | local self-management | **have** |
| TP-LC-07 | uninstall absent no-op | test_local_lifecycle | idempotency | **have** |
| TP-LC-08 | about shows installed | test_local_lifecycle | local self-management | **have** |
| TP-LC-09 | installed mode is `0755` (readable+executable) | test_local_lifecycle | local self-management §2.3.1 | **have** |
| TP-LC-10 | reinstall without force heals `0711` → `0755` | test_local_lifecycle | local self-management §2.3.1 | **have** |

### TP-FOLDER-BACKUP (domain + privilege)

| TP-ID | Intent | Suite | Primary requirement(s) | Status |
|-------|--------|-------|------------------------|--------|
| TP-FOLDER-BACKUP-01 | print-sudoers with allow; TEST MODE banner; no Type 0 `/etc` write; tar -tzf | test_domain | three-layer §2.3.1a/§2.3.3 · domain | **have** |
| TP-FOLDER-BACKUP-01b | refuse print-sudoers without `--allow-test-local` when not production | test_domain | three-layer trust tier **S13** | **have** |
| TP-FOLDER-BACKUP-01c | print-sudoers text dual includes project **restore** verb | test_domain | three-layer · folder-archive-backup | **have** |
| TP-FOLDER-BACKUP-01d | print-sudoers must not grant `rm -f` | test_domain | sudoer-json-file AC-4 | **have** (suite-only until this row) |
| TP-FOLDER-BACKUP-02 | print-sudoers to path; narrow; per-user stage; test mode in file | test_domain | three-layer privilege | **have** |
| TP-FOLDER-BACKUP-03 | backup missing operand | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-04 | backup missing dir | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-05 | deposit fail-closed without working sudo | test_domain | folder-archive-backup · three-layer | **have** |
| TP-FOLDER-BACKUP-06 | archive name YYYYMMDD + tar.gz | test_domain | **folder-archive-backup** · idempotency | **have** |
| TP-FOLDER-BACKUP-07 | elevated deposit + verify counts (root or sudo -n) | test_domain | **folder-archive-backup** · three-layer | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-08 | same-day next-N no overwrite | test_domain | **folder-archive-backup** · idempotency | **have** (host sudoers or root) |
| TP-FOLDER-BACKUP-09 | about domain diagnostics | test_domain | domain about pillar | **have** |
| TP-FOLDER-BACKUP-10 | leaf basename in archive name | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-11 | restore missing archive fail-closed | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-12 | restore to explicit dest + verify | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-13 | restore default host hard-disk + non-empty refuse | test_domain | **folder-archive-backup** | **have** |
| TP-FOLDER-BACKUP-14 | print-sudoers-install-script: draft + admin script; sh -n; root required for install | test_domain | three-layer §2.3.3a · project-sudoers-file | **have** |
| TP-FOLDER-BACKUP-19 | submit-sudoer-request fail-closed when sudoer-cli missing | test_domain | three-layer §2.3.3c | **have** |
| TP-FOLDER-BACKUP-20 | submit-sudoer-request via stub cli writes inbound file | test_domain | three-layer §2.3.3c | **have** |
| TP-FOLDER-BACKUP-21 | submit detect prefers public inbound over leftover `sudoer-approving`; no Type 0 mkdir | test_domain | three-layer §2.3.3c AC-16/17 | **have** |
| TP-FOLDER-BACKUP-21b | `SUDOER_QUEUE_INBOUND` wins over public inbound | test_domain | three-layer §2.3.3c detect priority 1 | **have** |
| TP-FOLDER-BACKUP-22 | JSON sudoer file `path` is only `/usr/local/bin/folder-backup` | test_domain | **sudoer-json-file** AC-1 | **have** |
| TP-FOLDER-BACKUP-22b | JSON sudoer file contains no mkdir/cp/tar/rm/install/chmod | test_domain | **sudoer-json-file** AC-4 | **have** |
| TP-FOLDER-BACKUP-22c | JSON sudoer file contains no deposit/stage path and no `*.tar.gz` | test_domain | **sudoer-json-file** AC-5 | **have** |
| TP-FOLDER-BACKUP-22d | submit refuses OS-tool grant file | test_domain | **sudoer-json-file** AC-7 | **have** |
| TP-FOLDER-BACKUP-22e | pretty emit through real sudoer-cli keeps backup **and** restore (convert + submit) | test_domain | **sudoer-json-file** AC-9 · three-layer AC-21 | **have** |
| TP-FOLDER-BACKUP-22f | stub inbound **body** still contains both verbs (not file-count only) | test_domain | **sudoer-json-file** AC-9 | **have** |
| TP-FOLDER-BACKUP-23 | this-user host fragment under `SUDOERS_D_DIR` → default submit **update** | test_domain | three-layer AC-22 | **have** |
| TP-FOLDER-BACKUP-23b | `--add` overrides host-present default | test_domain | three-layer AC-22 | **have** |
| TP-FOLDER-BACKUP-23c | other-user host fragment does not flip this user to **update** | test_domain | three-layer AC-22 | **have** |
| TP-FOLDER-BACKUP-24 | generate-sudoer-request writes compact JSON with both verbs | test_domain | three-layer §2.3.3d AC-23 | **have** |
| TP-FOLDER-BACKUP-24b | generate explicit path; refuse `/etc` | test_domain | three-layer AC-23 | **have** |
| TP-FOLDER-BACKUP-24c | generated file through real sudoer-cli convert keeps both verbs | test_domain | three-layer AC-23 · sudoer-json-file AC-9 | **have** |
| TP-FOLDER-BACKUP-24d | generate dest is readable without sudo; suite `cat`s body | test_domain | three-layer §2.3.2a AC-24 · sudoer-json-file AC-10 | **have** |
| TP-FOLDER-BACKUP-25 | inbound-fidelity error names incompleteness in operator words | test_domain | operator-readable-error AC-1 | **have** |
| TP-FOLDER-BACKUP-25b | same error names `generate-sudoer-request` | test_domain | operator-readable-error AC-2 | **have** |
| TP-FOLDER-BACKUP-25c | same error does not contain `sibling re-encode` | test_domain | operator-readable-error AC-3 | **have** |
| TP-FOLDER-BACKUP-26 | print-sudoers text + JSON emit `backup *` / `restore *`; verb-only **Fail** | test_domain | three-layer AC-25 · **sudoer-json-file** AC-3/AC-8 · INC-20260823-001 | **have** |
| TP-FOLDER-BACKUP-26b | generate compact JSON `args` include `*` after each verb | test_domain | **sudoer-json-file** AC-3 · three-layer AC-25 | **have** |
| TP-FOLDER-BACKUP-27 | compact/pretty JSON includes `--json` twins; text dual matches; `"*"` not cwd names | test_domain | **sudoer-json-file** AC-8/AC-26 · three-layer AC-26 | **todo** (compact JSON emit Gap) |
| TP-FOLDER-BACKUP-15 | remove-project-sudoers: force remove draft; refuse `/etc`; already absent; host elev probe | test_domain | three-layer §2.3.3b · project-sudoers-file | **have** |
| TP-FOLDER-BACKUP-15b | multi-draft: list + non-interactive requires path; explicit path removes one only | test_domain | three-layer AC-15 · L-SUDOERS-04 | **have** |
| TP-FOLDER-BACKUP-15c | TTY multi-draft picker: choice 2 removes the second draft; prompt text is not glued onto the number | test_domain | **shell-interactive-vs-noninteractive** AC-4 | **have** |
| TP-FOLDER-BACKUP-16 | restore dest whitelist: refuse `/etc/passwd` + exact `/etc` + `/etc/<other>`; W-ETC-USER `/etc/{{username}}` gate allow | test_domain | **folder-archive-backup** §2.6b.2a · INC-20260812-001 | **have** |
| TP-FOLDER-BACKUP-17 | total retention: after deposit, prune oldest until ≤30 per basename | test_domain | **retention-total** | **have** |
| TP-FOLDER-BACKUP-17b | total retention: no cross-basename delete | test_domain | **retention-total** | **have** |
| TP-FOLDER-BACKUP-17c | failed backup does not prune prior total archives | test_domain | **retention-total** AC-5 | **have** |
| TP-FOLDER-BACKUP-18 | daily retention: same-day prune lowest N until ≤5 | test_domain | **retention-daily** | **have** |
| TP-FOLDER-BACKUP-18b | daily retention: does not delete other days / other basename | test_domain | **retention-daily** | **have** |
| TP-FOLDER-BACKUP-18c | failed backup does not prune prior same-day archives | test_domain | **retention-daily** AC-5 | **have** |

---

## Privilege / sudoers coverage map (reviewer quick ref)

| Behavior | TP | Law |
|----------|----|-----|
| User detection for fragment = `id -un` | implicit (fragment User lines in 01/02/14) | three-layer · skill SK-CREATE-SUDOERS-FILE |
| Trust tier test_local refuse without allow | 01b | §2.3.1a · **S13** |
| TEST MODE banner + uninstall soon | 01, 02 | §2.3.3 |
| Project-sudoers-file draft write | 02, 14 | term project-sudoers-file |
| Admin install script (no Type 0 `/etc`) | 14 | §2.3.3a |
| Remove draft only | 15 | §2.3.3b |
| Deposit fail-closed | 05 | §2.3.7 |
| Elev Tables S11–S12 | n/a automated (agent/harness) | mold + checklist; product OS-tool deposit |
| JSON emit identity (no OS-tool / path hardcode) | 22 / 22b / 22c / 22d | **sudoer-json-file** AC-1..7 |
| Pretty emit + real sibling convert/submit keeps both verbs | **22e** | **sudoer-json-file** AC-9 · three-layer AC-21 · **JR-3/JR-4** |
| Stub inbound **body** still has both verbs | **22f** | AC-9 · **JR-6** (not file-count only) |
| Independent generate dest (compact + readable) | **24 / 24d** | three-layer AC-23/24 · **JR-9** · **S16** |
| Operator-readable inbound-fidelity error | **25 / 25b / 25c** | operator-readable-error AC-1..3 · **L-OUTPUT-01** |
| Review gate JSON re-encode | n/a automated | `what-to-review` **JR-1..9** · **S15** / **S16** · INC-20260817-001 |

---

## Optional / host-only (not Core CI blockers)

| Item | Status | Notes |
|------|--------|--------|
| Admin script `install` on live host | optional | Requires sudo account; suite only checks root gate |
| Global install → production trust tier | optional | Host: `sudo sh src/folder-backup install` then print-sudoers without allow |
| Fragment drift vs installed `/etc/sudoers.d` | optional | Security review host gate |

---

## Vault-cli law (have)

`sh tests/run.sh` on `src/vault-cli` **1.0.0** is PASS=367 FAIL=0 SKIP=0. That run proves the rows below.

| ID | Intent | Status |
|----|--------|--------|
| TP-VAULT-01..06 | list / add / update behavior in `requirement-domain-vault-cli` (no secret bytes on list or argv) | **have** — `tests/test_domain_vault.sh` |
| TP-CLI-13 (vault board) | front **1** / **8** / **9**; client **11** list / **12** add / **13** update / **0** Back; no row **17**; `edit` is not a numbered row; row **85** stays `self-update` | **have** — `tests/test_cli.sh` |
| TP-CLI-17 (vault help) | help lists list/add/update/edit under Work commands and keeps `self-update` off that heading | **have** — `tests/test_cli.sh` |

---

## Rules

1. Closing a **bug** finding updates the matching TP to **have**.  
2. Do not mark TP **have** without a suite assertion (or honest skip/n/a).  
3. Do not reintroduce online TP-CURL/TP-CSUM as Core without product-mode change.  
4. Trust-tier and project-sudoers-file changes require TP-FOLDER-BACKUP-01b/14/15 (or successors) stay **have**.  
5. JSON grant / submit reviews require **TP-FOLDER-BACKUP-22e/22f** stay **have**. Do not mark re-encode fidelity **have** from emit-only 22/22b/22c or stub-`cp` 20.  
6. Closing INC-20260817-001 host queue still needs a live inbound that lists both verbs (product/suite ≠ approved host file).  
