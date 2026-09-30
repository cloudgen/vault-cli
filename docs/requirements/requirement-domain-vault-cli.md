**file**: docs/requirements/requirement-domain-vault-cli.md  
**Status**: Active (Version 1.1.0)  
**Area**: domain  
**Key**: `requirement-domain-vault-cli`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **domain surface Single Source of Truth** for vault-cli: which **vault verbs** exist, what they store, and what **help** and **about** must show.

**vault-cli** lists, adds, and edits vaults on this login. The closed kind set is **ssh-vault**, **github-vault**, and **cloudflare-vault**. The verb that edits an existing vault is **`update`**. **`edit`** is an alias of **`update`** and is not a second menu row. **`self-update`** is the channel refresh of this program and is not this verb.

Numbered-board membership is owned by **`requirement-shell-cli-default-interaction`**. Dispatcher tokens are owned by **`requirement-shell-cli-interface`**. This file owns vault behavior.

The operator is not forced to assemble a multi-field argv or a JSON body from memory. On a terminal, **`add`** and **`update`** ask **one field at a time**. Off a terminal they take flags and **must not** prompt.

### 1.1 Human-facing

**In one sentence:** Type `vault-cli list` to see vault names, `vault-cli add ssh-vault` to store one, and `vault-cli update github-vault` to change one that already exists — ssh-vault, github-vault, and cloudflare-vault only.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | List, add, or edit a vault under your home | `vault-cli list` |
| The other role | A script must pass flags and must not wait for a prompt | `vault-cli add cloudflare-vault --account-id ACCOUNT --token-file ./token` |
| Not this file | Which numbers the boards print | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| `list`, `add`, `update` (alias `edit`) | `self-update` (that replaces this program) |
| ssh-vault, github-vault, cloudflare-vault | Sudoers grant verbs |
| `backup <folder>` and `restore <archive>` | Grant verbs such as `print-sudoers` |
| Names and `token_present` / `key_present` | Printing a token or a private key |

| Surface | What you open | What for |
|---------|---------------|----------|
| `vault-cli help` | command | vault work verbs plus backup and restore |
| `vault-cli about` | command | vault root, counts, and the global backup folder |
| `${HOME}/.local/vaults/` | this login's vault root | ssh, github, and cloudflare trees |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See what is stored | Names only. A token file is reported as present or absent. | `vault-cli list` |
| Add an SSH vault | The program asks the name, then the path of the private-key file, and copies that file. It refuses the name `_default`. | `vault-cli add ssh-vault` |
| Edit a GitHub token | The login and token id must already exist. A new token comes from a file, never from the command line. | `vault-cli update github-vault --login LOGIN --token-id TOKENID --token-file ./token` |
| Add a Cloudflare vault | One account id holds one token. A second add of the same id fails; use `update`. | `vault-cli add cloudflare-vault --account-id ACCOUNT --token-file ./token` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Pillar A — Specialized CLI subcommands

| Command | Operands / flags | Handler | Behavior summary |
|---------|------------------|---------|------------------|
| `list` | optional kind | `vc_list` | Print vault names for one kind or all three. Never print secret bytes. |
| `add` | kind required | `vc_add` | Create one vault. Fail if that selector already exists. |
| `update` | kind + selector required | `vc_update` | Edit one existing vault. Fail if it is missing. Fail if no field changes. |
| `edit` | same as `update` | `vc_update` | Alias. Help lists it as an alias. It is **not** a menu row. |
| `backup` | `<source-folder>` required | `fb_backup` | Pack the folder into the global backup folder. Not a menu row. |
| `restore` | `<archive\|prefix> [dest]`; `--force` `--disk` `--ram` | `fb_restore` | Restore one archive. Default dest is the hard-disk projects tree. Not a menu row. |

**Purpose:** vault tokens and `backup` / `restore` are **operational**. Grant/draft verbs are not commands. This product has **no** test-purpose domain verb.

**Kinds (closed):**

| Kind token | Selector | Secret file |
|------------|----------|-------------|
| `ssh-vault` | `--name` path-safe folder name | private key copied from `--key-file` |
| `github-vault` | `--login` and `--token-id` | one-line token copied from `--token-file` |
| `cloudflare-vault` | `--account-id` | one-line token copied from `--token-file` |

**Routing:** `app_main` **MUST** route `list`, `add`, `update`, `edit`, `backup`, and `restore`. Any other kind token **MUST** fail closed with `unknown_kind`. Unknown operands **MUST** fail closed.

**Menu (pointer only):** client row **11** is `list`, **12** is `add`, **13** is `update`. `backup` and `restore` are typed commands and **MUST NOT** become extra client rows. Membership text lives on `requirement-shell-cli-default-interaction`.

**Global backup folder:** `/var/backups/${APP_NAME}/`. `BACKUP_ROOT` defaults to `/var/backups`. `BACKUP_NOTATION` defaults to `${APP_NAME}`. The deposited file is `${BACKUP_ROOT}/${BACKUP_NOTATION}/${SOURCE_FOLDER_NAME}-YYYYMMDD-N.tar.gz`. For this product that folder is `/var/backups/vault-cli/`.

**Backup and restore rules:**

1. `backup` **MUST** require a readable directory. It **MUST** create the gzip tar as this login in staging, then copy it into the global backup folder. It **MUST NOT** overwrite an existing archive name. It **MUST** verify member and file counts before success.
2. When the global backup folder is not writable by this login, deposit **MUST** fail closed and name the folder plus a next step (create the folder for this login, or re-run as root). It **MUST NOT** tell the operator to run an unrouted grant verb.
3. `restore` **MUST** accept an archive basename, a project prefix, or a path. With no explicit dest, the default host is the hard-disk projects tree. `--ram` selects `${RAM_ROOT}/<project>`. A non-empty dest **MUST** fail closed unless `--force`.
4. `about` **MUST** show `backup_root`, `backup_notation`, and `deposit_dir`.

**Non-goals:** `submit-sudoer-request`, `generate-sudoer-request`, `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`, remote sync, and any command that prints a token or a private key.

**Ship-unit honesty:** `src/vault-cli` routes `vc_list`, `vc_add`, `vc_update`, `fb_backup`, and `fb_restore`. The grant verbs are not routed.

### 2.2 Pillar B — Specialized features

**Vault root:** `${HOME}/.local/vaults` mode **0700**. Children `ssh/`, `github/`, and `cloudflare/` are mode **0700**. Secret files are mode **0600**. Creating a vault **MUST** create missing parents. **MUST NOT** delete the vault root on uninstall.

**ssh-vault layout:**

```text
${HOME}/.local/vaults/ssh/<name>/id_ed25519
${HOME}/.local/vaults/ssh/<name>/id_ed25519.pub
```

`id_ed25519` is the private key (mode **0600**). `id_ed25519.pub` is the public key when the source directory has one (mode **0644**). The name `_default` is reserved. `add` and `update` **MUST** refuse it with `name_reserved`.

**github-vault layout** (one tree, many logins, many tokens per login):

```text
${HOME}/.local/vaults/github/index.json
${HOME}/.local/vaults/github/accounts/<login>/account.json
${HOME}/.local/vaults/github/accounts/<login>/tokens/<token-id>/token
```

**cloudflare-vault layout** (one account id, one token):

```text
${HOME}/.local/vaults/cloudflare/<account-id>/token
```

A second `add` of the same selector **MUST** fail with `vault_exists` and **MUST NOT** overwrite. `update` of a missing selector **MUST** fail with `vault_missing` and **MUST NOT** create.

**Secret transport:**

1. **MUST NOT** accept `--token`, `--private-key`, or any flag whose value is the secret bytes.  
2. Non-interactive secret input is `--token-file` or `--key-file`: a regular file, mode **0600**. A wrong mode **MUST** fail closed with `secret_file_mode`.  
3. The program copies the file into the vault path and **MUST NOT** print the bytes.  
4. `list`, `help`, `about`, and JSON **MUST** report `token_present` or `key_present` only.

**Shape samples (not live accounts, not secret bytes):**

`index.json`:

```json
{
  "schema_version": 1,
  "default_login": "octocat",
  "logins": ["octocat"]
}
```

`account.json`:

```json
{
  "login": "octocat",
  "default_token_id": "repo-admin"
}
```

`list --json` one cloudflare row:

```json
{
  "kind": "cloudflare-vault",
  "account_id": "a1b2c3d4e5",
  "token_present": true
}
```

The `token` file body is one line. This requirement does not print an example of that line.

**TTY walk (one field at a time).** Read each answer in the current shell (`prompt_ask`, then `PROMPT_ASK_VALUE`). **MUST NOT** capture `prompt_ask` with `$()` or backticks. A secret field is not echoed. Off a terminal, missing required flags **MUST** `out_die` with `Next:` and the full command, and **MUST NOT** prompt.

**Kind picker:** when `add` or `update` is run on a terminal without a kind, print this data picker and read again. Numbers are item indexes, not parent-prefix menu numbers.

```text
1. ssh-vault
2. github-vault
3. cloudflare-vault
0. Back
```

**0** / empty line / EOF returns to the front board when the verb was opened from the menu, and returns from the argv verb when it was typed. A token that is not 1, 2, 3, or 0 **MUST** `out_error` and reprint this picker. **MUST NOT** `out_die`.

**Vault picker:** when `update` has a kind and no selector on a terminal, print the existing names of that kind as **1…N** and **0** Back. A bad token reprints that list (`out_error`). **MUST NOT** `out_die`. When that kind has no vaults, print `No ssh-vault yet. Next: vault-cli add ssh-vault` (same sentence with `github-vault` or `cloudflare-vault`) and return. **MUST NOT** prompt for a new name on `update`.

**Field table:**

| Verb | Field | Secret? | Prompt | Flag | Skip if |
|------|-------|---------|--------|------|---------|
| add ssh-vault | name | no | Vault name | `--name` | flag present |
| add ssh-vault | key file | file contents | Path to private key file | `--key-file` | flag present |
| update ssh-vault | name | no | Vault name | `--name` | flag present |
| update ssh-vault | key file | file contents | Path to replacement private key file | `--key-file` | omitted means keep the current key; then another field must change or `nothing_to_update` |
| add github-vault | login | no | GitHub login | `--login` | flag present |
| add github-vault | token id | no | Token id | `--token-id` | flag present |
| add github-vault | token file | file contents | Path to one-line token file | `--token-file` | flag present |
| update github-vault | login | no | GitHub login | `--login` | flag present |
| update github-vault | token id | no | Token id | `--token-id` | flag present |
| update github-vault | token file | file contents | Path to replacement token file | `--token-file` | omitted is `nothing_to_update` |
| add cloudflare-vault | account id | no | Cloudflare account id | `--account-id` | flag present |
| add cloudflare-vault | token file | file contents | Path to one-line token file | `--token-file` | flag present |
| update cloudflare-vault | account id | no | Cloudflare account id | `--account-id` | flag present |
| update cloudflare-vault | token file | file contents | Path to replacement token file | `--token-file` | omitted is `nothing_to_update` |

`update` with a selector and no replacement file **MUST** fail with `nothing_to_update` except ssh-vault, which has only the key as mutable secret: omitting `--key-file` on ssh-vault `update` is also `nothing_to_update`.

**Error tokens** (human line plus JSON `error` when `--json`):

| Token | When |
|-------|------|
| `unknown_kind` | kind is not one of the three |
| `name_required` | ssh-vault selector missing off a terminal |
| `name_reserved` | ssh name is `_default` |
| `login_required` | github login missing off a terminal |
| `token_id_required` | github token id missing off a terminal |
| `account_id_required` | cloudflare account id missing off a terminal |
| `key_file_required` | ssh `add` has no key file off a terminal |
| `token_file_required` | github or cloudflare `add` has no token file off a terminal |
| `secret_file_mode` | secret file is not a regular file mode 0600 |
| `vault_exists` | `add` selector already exists |
| `vault_missing` | `update` selector does not exist |
| `nothing_to_update` | `update` would not change a secret file |
| `secret_refused` | a flag tried to pass secret bytes on argv |

### 2.3 Pillar C — Specialized project help items

`help` **MUST** list these under **Work commands:**. There is no grant-emit heading on this product.

| Help row | Text intent |
|----------|-------------|
| `list [ssh-vault\|github-vault\|cloudflare-vault]` | Show names. Never show a token or a private key. |
| `add <kind>` | Add one vault. On a terminal, one question at a time. |
| `update <kind>` | Edit one vault that already exists. |
| `edit` | Same as `update`. |
| `backup <source-folder>` | Pack that folder into `/var/backups/${APP_NAME}/`. |
| `restore <archive\|prefix> [dest]` | Restore an archive. Default dest is the hard-disk projects tree. |

`self-update` **MUST** stay under the self-managed heading, not under Work commands.

### 2.4 Pillar D — Specialized project about items

`about` **MUST** add these fields and **MUST NOT** add secret bytes:

| Field | Meaning |
|-------|---------|
| Vault root | `${HOME}/.local/vaults` |
| ssh-vault count | number of `ssh/<name>/` directories except a refusal to count `_default` as an operator vault; if `_default` exists it is listed as reserved, not as an operator vault |
| github-vault count | number of `accounts/<login>/` directories |
| cloudflare-vault count | number of `cloudflare/<account-id>/` directories |
| Backup root | `/var/backups` (`backup_root`) |
| Backup notation | `${APP_NAME}` (`backup_notation`) |
| Deposit directory | `/var/backups/${APP_NAME}/` (`deposit_dir`) |

### 2.5 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `vault-cli` |
| **Vault root** | `${HOME}/.local/vaults` |
| **Kinds** | `ssh-vault`, `github-vault`, `cloudflare-vault` |
| **Edit verb** | `update`; alias `edit` |
| **Channel verb that is not this edit** | `self-update` |
| **Handlers** | `vc_list`, `vc_add`, `vc_update`, `fb_backup`, `fb_restore` |
| **Menu rows** | client **11** / **12** / **13**. `backup` and `restore` are not rows |
| **Global backup folder** | `/var/backups/${APP_NAME}/` (`BACKUP_ROOT=/var/backups`, `BACKUP_NOTATION=${APP_NAME}`) |
| **Privilege** | vault verbs are this login only and do not call `sudo`. Backup deposit into a folder this login cannot write fails closed |
| **Ship unit** | `src/vault-cli` (POSIX `/bin/sh`, version **1.0.0**) |
| **Approver** | none. This login edits its own vault files. No dest approver. |
| **Repository owner** | not declared in this tree (no git origin). Do not copy a donor forge URL into this file. |

### 2.6 Why This Requirement Exists (Direct CIAO Alignment)

- **Principle 1 – Caution:** Missing vaults, reserved names, and secret argv fail closed.  
- **Principle 2 – Intentional:** `update` edits a vault. `self-update` replaces the program.  
- **Principle 9 – Three types of commands:** These verbs are normal-user work. They do not change the computer as root.  
- **Principle 10 – Least privilege:** Secret files are mode 0600 under this login's home.  
- **Principle 16 – Interactive vs non-interactive:** The field walk runs on a terminal only.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** `list`, `add`, and `update` stay available as this login and **MUST NOT** wrap `sudo`. Git Bash and Windows cmd **MUST NOT** invoke Termux `pkg`.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Unknown kind, missing selector, and secret-on-argv fail loud.  
- **Intentional:** Three kinds, three work verbs, one alias.  
- **Anti-fragile:** `add` does not overwrite; `update` does not create.  
- **Over-protect:** List and about never print secret bytes. `self-update` stays a different verb.

## 4. Protection Rule (Sacred)

**Future AI assistants or maintainers MUST NOT**:

1. Treat `self-update` as the vault edit verb, or put vault `update` on the self-management board.  
2. Add a fourth vault kind without updating this file and the client menu together.  
3. Accept a token or a private key as an argv value.  
4. Print token or private-key bytes in list, help, about, JSON, or logs.  
5. Let `add` overwrite an existing selector, or let `update` create a missing one.  
6. Allow an operator ssh-vault named `_default`.  
7. Prompt for fields when there is no terminal.  
8. Route these verbs through `sudo` or through a sudoers grant.  
9. Claim `vc_list` / `vc_add` / `vc_update` are implemented while `src/vault-cli` does not route them.

## 5. Related artifacts (versioned surface only)

| Artifact | Role |
|----------|------|
| `docs/requirements/index.md` | Registry |
| `docs/requirements/requirement-shell-cli-interface.md` | Dual mention of `list`, `add`, `update`, `edit` |
| `docs/requirements/requirement-shell-cli-default-interaction.md` | Client rows **11** / **12** / **13** |
| `src/vault-cli` | Ship file. Routes `list`, `add`, `update`, and `edit`. |

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-VAULT-01** | `tests/test_domain_vault.sh` | **have** — `list` with no vaults prints three empty kinds and no secret bytes |
| **TP-VAULT-02** | `tests/test_domain_vault.sh` | **have** — `add ssh-vault` refuses `_default` and refuses key bytes on argv |
| **TP-VAULT-03** | `tests/test_domain_vault.sh` | **have** — `add` of an existing selector is `vault_exists`; `update` of a missing selector is `vault_missing` |
| **TP-VAULT-04** | `tests/test_domain_vault.sh` | **have** — off a terminal, `add` without flags exits 1 with `Next:` and does not prompt |
| **TP-VAULT-05** | `tests/test_domain_vault.sh` | **have** — `edit` routes to the same handler as `update` and is not a menu row |
| **TP-VAULT-06** | `tests/test_domain_vault.sh` | **have** — help lists `list` / `add` / `update` under Work commands and `self-update` under self-managed |
| **TP-BACKUP-01..05** | `tests/test_backup_restore.sh` | **have** — backup, next N, restore bytes, missing source, default folder `/var/backups/${APP_NAME}` |

**Map:** `reviews/test-plan.md`

## 6. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-30 | Active 1.0.0 | Domain SSOT for vault-cli. Verbs `list`, `add`, `update` (alias `edit`). Kinds ssh-vault, github-vault, cloudflare-vault. Supersedes `requirement-domain-folder-backup`. Handlers Gap. |
| 2026-09-30 | Active 1.0.0 | Handlers `vc_list`, `vc_add`, and `vc_update` are routed on `src/vault-cli` **1.0.0**. Proof **TP-VAULT-01** through **TP-VAULT-06** in `tests/test_domain_vault.sh`. `sh tests/run.sh`: PASS=367 FAIL=0 SKIP=0. |
| 2026-09-30 | Active 1.1.0 | `backup` and `restore` are routed typed commands (not menu rows). Global backup folder is `/var/backups/${APP_NAME}/`. Grant verbs stay unrouted. Proof **TP-BACKUP-01** through **TP-BACKUP-05**. |

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
