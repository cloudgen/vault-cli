**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 2.4.0)  
**Area**: architecture  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Declare the **bootstrap chain** for this product: ordered lineage, direction, architecture inheritance, and the **domain extend** of vault list / add / update onto the parent CLI you install for yourself.

**Direction is sacred:** ancestor → descendant only. Never reverse-copy this product onto the bootstrap parent.

### 1.1 Human-facing

**In one sentence:** vault-cli is rebuilt from the sibling **selfmanaged** CLI; copy architecture **from** that parent **to** this product, never the reverse.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Work in this tree (`src/vault-cli` **1.0.0**) | `sh src/vault-cli version` |
| The parent | Sibling `selfmanaged` — self-install, version-check, self-update, self-uninstall | Keep that tree as the origin |
| Not this file | Vault field rules and the numbered boards | `requirement-domain-vault-cli` |

| Includes | Excludes |
|----------|----------|
| Ancestor → descendant only | Copying this product onto selfmanaged “to share fixes” |
| Parent channel verbs kept, plus this product’s local `install` | Calling local `install` from a pipe with no command |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/vault-cli` | ship unit | `list` / `add` / `update` routed; version **1.0.0** |
| `docs/requirements/index.md` | registry | lineage row |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Change this product | Edits stay here. Do not overwrite the parent CLI. | work under this workspace root |
| Check install mode | A terminal with no command is the numbered boards. A pipe with no command is `self-install`. | `curl … \| sh` places this program |

---

## 2. Core Rules (Mandatory)

### 2.1 Direction

1. Every edge **MUST** be **ancestor → descendant** only.  
2. Plans **MUST NOT** copy this product’s ship unit onto the bootstrap parent to “share fixes.”  
3. Detected reverse-copy **MUST** be treated as critical pollution (restore parent; rebuild this product).

### 2.2 Chain declaration (this product)

| Field | Value |
|-------|--------|
| **Root / hop 0 (A)** | `selfmanaged` — Type 0 self-managed CLI with channel verbs (sibling workspace `{{PROJECTS_ROOT}}/selfmanaged`) |
| **Leaf / hop 1 (B)** | `vault-cli` — this workspace product |
| **Immediate origin of leaf** | `selfmanaged` |
| **Specialize mode** | **Domain extend** (list, add, and update ssh-vault, github-vault, and cloudflare-vault) **and keep** A’s channel verbs. Not a trim. |
| **A ship unit** | Sibling: `{{PROJECTS_ROOT}}/selfmanaged/src/selfmanaged` (not in this tree; do not write it from here) |
| **B ship unit** | `src/vault-cli` (version **1.0.0**) |
| **A channel ownership** | `self-install`, `version-check`, `self-update`, `self-uninstall`; composed `SCRIPT_URL` |
| **B channel ownership** | Same verbs, retargeted to `REPO_USER` / `REPO_NAME` = this product. A non-interactive zero-cli-verb is `inst_self_install` (CLI place), not local `install`. |
| **A domain** | none (Type 0 lifecycle) |
| **B domain** | vault list / add / update (see `requirement-domain-vault-cli`). `update` edits a vault. `self-update` stays a channel verb. |
| **Retired names (not live hops)** | `cli-template` — live parent from 2026-08-13 through 2026-09-29. **Not** the live parent after 2.2.0. |

### 2.3 Architecture inheritance (B from A)

B **MUST** inherit A’s structural contracts:

| Layer | Inherit / extend |
|-------|------------------|
| Runtime | POSIX `/bin/sh`, `set -u`, explicit errors |
| Output SSOT | `out_*` family |
| Modular prefixes | `out_`, `inst_`, `util_`, `app_`, `path_`, `prompt_`; domain uses dedicated `vc_` prefix |
| Entry / dispatch | Single `app_main`; always call `app_main "$@"` at end |
| Global flags | `--quiet` / `--json` / `--debug` / `--force` / `--global` |
| Integrity companion | **Keep** A’s `CHECKSUM` download check when set. No separate checksum requirement file. |
| Online lifecycle | **Keep** `self-install`, `version-check`, `self-update`, `self-uninstall`, `self-management` |
| Local lifecycle | **Keep** vault-cli `install` / `uninstall` / `where-is-me` (`inst_local_*`, mode **0755**) |
| Empty argv | **Extend** interactive boards / non-interactive `inst_self_install` |
| Domain | **Add** on B only |

### 2.4 Keep / extend matrix (normative for this product)

| Surface | Decision | Notes for vault-cli |
|---------|----------|-------------------------|
| `out_*` output SSOT | **Keep** | Surgical only |
| Modular single-file design | **Keep** | Ship unit under `src/` |
| Global flags + `app_main` | **Keep** | Same contracts; domain flags added on B |
| Storage resolve | **Keep / adapt** | Cache resolve stays. Vault files use the login vault root in `requirement-domain-vault-cli` |
| Idempotency / interactive modes | **Keep / retarget** | Domain confirm paths stay fail-closed |
| Online channel (`SCRIPT_URL`, `REPO_*`) | **Keep** | Composed for this product. Help lists the URL. `install` does not download. |
| Non-interactive zero-cli-verb | **Take as CLI self-install** | `inst_self_install` (copy or download). Not local `install`. Interactive line stays the boards |
| `self-install` / `version-check` / `self-update` / `self-uninstall` | **Keep** | Explicit verbs. `self-install` is `inst_self_install` (script copy or download). |
| `self-management` | **Keep** | TTY opens the self board (front row **8**, rows **81**–**87**). Off a terminal it stops (`self-management needs a terminal`). |
| Companion `CHECKSUM` | **Keep code path** | Optional env. Not a second requirement file. |
| Local `install` / `uninstall` / `where-is-me` | **Keep** | `install` stays `inst_local_install` (mode **0755**). Do not alias it to `self-install`. |
| Domain vault list / add / update | **Add** | Domain SSOT `requirement-domain-vault-cli`. Backup, restore, and grant verbs are not this product’s commands |
| Domain / out Protection Zones | **Keep spirit** | Do not “simplify away” defensive layers for style |

### 2.5 Identity retarget (B only)

| Concern | B value |
|---------|---------|
| `APP_NAME` | `vault-cli` |
| `VERSION` | ship unit SSOT in `src/vault-cli` (hard-assign **1.0.0**; do not pin a second number here) |
| Primary day-to-day install | Local copy `install` → `${USER_BIN}` (default `~/.local/bin`), mode **0755** |
| Channel place | `self-install` / `self-update`, and a non-interactive zero-cli-verb (copy when `$0` is a file; download when piped) |
| README | The pipe one-liner is the online install. Local `install` stays the checkout copy |

### 2.6 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **A (bootstrap)** | `selfmanaged` at `{{PROJECTS_ROOT}}/selfmanaged` (do not reverse-copy; do not edit A from this tree) |
| **B (this product)** | vault-cli |
| **Specialize intent** | A’s architecture and channel verbs, plus the vault-cli domain and the vault-cli main menu (client rows list, add, update) |
| **Install mode** | **Dual.** `install` copies the running file (mode 0755) and is self-board row **81**. `self-install` is the channel verb (row **87**) and the non-interactive zero-cli-verb. A terminal with no command is the numbered boards. |
| **Cache host knob** | `SELFMANAGED_CACHE_HOST` stays that name (inherited). Do not rename it. |
| **Domain after specialize** | Active `requirement-domain-vault-cli` |
| **Historical origin** | 2026-08-03 first named `selfmanaged` then trimmed online. 2026-08-13 retargeted A to `cli-template` and dropped the channel. 2026-09-30 user ordered A=`selfmanaged` again and **kept** the channel. |

### 2.7 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Lineage and domain extend are explicit.  
- **Principle 1 – Caution**: Channel verbs are explicit. A terminal with no command is the boards. A pipe with no command is self-install.  
- **Principle 18 / Over-protect**: Reverse-copy is forbidden pollution.  
- **Principle 21 – Dual policies**: Complete B law; portable cores elsewhere.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution**: Matrix before delete; verify no half-live install.  
- **Intentional**: Explicit keep/extend; the registry names the live parent.  
- **Anti-fragile**: Keep battle-tested `out_*` / modular patterns from A.  
- **Over-protect**: Never reverse-copy; do not hide the channel or alias `install` to it.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Reverse-copy `vault-cli` onto `selfmanaged` or treat reverse as “cleanup.”  
2. Name `cli-template` as this product’s live origin without updating this file.  
3. Point a zero-cli-verb line at `inst_local_install`, or print help for a pipe with no command.  
4. Alias `install` to `inst_self_install`, or drop `self-install` while claiming A’s lifecycle.  
5. Drop `out_*` / modular Protection Zones as “part of specialize.”  
6. Invent a second bootstrap origin that contradicts this declaration without updating this file.  
7. Rename `SELFMANAGED_CACHE_HOST`.

**Violating this rule is a critical bootstrap-direction regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Hop table names A=selfmanaged, B=vault-cli, direction A→B |
| AC-2 | Keep/extend matrix matches the registry (channel verbs kept; vault domain present; interactive boards / non-interactive self-install) |
| AC-3 | B identity retarget complete (`APP_NAME=vault-cli`, `VERSION` matches the ship unit hard-assign, this product’s `SCRIPT_URL`) |
| AC-4 | Domain SSOT present for the vault surface (`list` / `add` / `update`), not a backup surface |
| AC-5 | `install` is local copy mode 0755; `self-install` is the channel verb |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-class-software-dev` | Class gate |
| `requirement-shell-local-self-management` | Local `install` / `uninstall` / `where-is-me` (not the channel verbs) |
| `requirement-shell-cli-zero-arguments` | **Active** — non-interactive zero-cli-verb is `inst_self_install` |
| `requirement-shell-cli-default-interaction` | Interactive zero-cli-verb numbered boards |
| `requirement-domain-vault-cli` | Domain extend |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status | Note |
|----------------|-------|--------|------|
| **TP-CLI-04,10** | `tests/test_cli.sh` | have | help lists channel verbs; offline `version-check` / `self-update` fail closed |
| **TP-CLI-07** | `tests/test_cli.sh` | have | Off-TTY empty argv is CLI self-install |
| **TP-CLI-13** | `tests/test_cli.sh` | have | TTY front and client rows **11** list / **12** add / **13** update |
| **TP-VAULT-01..06** | `tests/test_domain_vault.sh` | have | `requirement-domain-vault-cli` |
| **TP-FOLDER-BACKUP-*** | `tests/test_domain_folder_backup.sh` | not sourced by `tests/run.sh` | withdrawn backup surface; does not prove the vault domain |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Declared A=selfmanaged → B=folder-backup (trim online) |
| 2026-08-13 | Active 2.0.0 | Re-specialize: A=cli-template → B=folder-backup (domain extend). selfmanaged retired. |
| 2026-08-28 | Active 2.1.0 | Empty argv **extend**: case 2 TTY menu; Type O still absent |
| 2026-09-30 | Active 2.2.0 | User ordered A=`selfmanaged` again. Channel verbs kept. Empty argv stays case 2. `install` stays the local copy. |
| 2026-09-30 | Active 2.2.1 | Self board is front row **8**. Empty argv wording is numbered boards. Version cell and AC-3 point at the ship unit. |
| 2026-09-30 | Active 2.3.0 | Non-interactive zero-cli-verb is `inst_self_install`. Interactive line stays the boards. Local `install` stays the 0755 copy. |
| 2026-09-30 | Active 2.4.0 | B is vault-cli. Domain extend is list/add/update (`requirement-domain-vault-cli`). Handler prefix `vc_`. Ship unit is `src/vault-cli`. Channel verbs stay. Do not reverse-copy. |
| 2026-09-30 | Active 2.4.0 | Disk ship unit is `src/vault-cli` **1.0.0**. `vc_*` handlers are routed. Channel verbs stay. Do not reverse-copy. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
