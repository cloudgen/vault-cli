**file**: docs/requirements/requirement-sudoer-json-file.md  
**Status**: Active (Version 1.4.0)  
**Area**: architecture  
**Key**: `requirement-sudoer-json-file`  
**Optional RQ-ID**: `RQ-SUDOER-JSON-FILE`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for the **JSON-type sudoer file**: the machine encoding of this product’s elevation grant (the body a Type 0 submit hands to the sibling allocator, or an equivalent JSON dual of that grant).

The grant **MUST** name only the project command **`{{PRJ_NAME}}`**. It **MUST NOT** allowlist other shell or OS tools (`cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, shells, …). Those extra tools **increase design complexity and thereby weaken security**.

This file does **not** own:

| Concern | Owner |
|---------|--------|
| Type 0/1/2 map, `print-sudoers` emit, admin install, submit **workflow** (detect / no inbound `mkdir` / no `/etc` write) | `requirement-three-layer-privilege-model` |
| Domain verb catalog / help / about | `requirement-domain-folder-backup` |
| Backup / restore operations | `requirement-folder-archive-backup` |

Queued **basename** allocation remains sibling-owned. This requirement owns **command identity and JSON body shape**.

### 1.1 Human-facing

**In one sentence:** The JSON grant says this login may run `folder-backup backup <folder>` and `folder-backup --json backup <folder>` (and restore twins) as root — the `*` in args is a sudoers extra operand, not a disk path.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | The username in the JSON | live emit uses `id -un` |
| Admin / already root | Installs the matching fragment | `visudo -c` then mode `0440` |
| Not this file | How to emit and submit the fragment | `requirement-three-layer-privilege-model` |

| Includes | Excludes |
|----------|----------|
| `backup` / `restore` plus one `*` | Verb-only `["backup"]` |
| **`--json` as a separate command object per verb** (`["--json","backup","*"]` / `["--json","restore","*"]`) | Frozen `/var/backup/…` or `*.tar.gz` in args; cwd listings in place of `"*"` |
| Project command only | `mkdir` / `cp` / `tar` as root tools |

| Surface | What you open | What for |
|---------|---------------|----------|
| `folder-backup generate-sudoer-request` | command | JSON grant on a readable dest |
| `./src/folder-backup` | ship unit | emit (Gap until 1.3.0 implemented) |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Generate the JSON grant | You can `cat` the dest without sudo. Both verbs must include `*`. | `folder-backup generate-sudoer-request` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 What a JSON sudoer file is

1. A JSON sudoer file is a **closed-schema object** that states: who may elevate, which **product** the grant is for, add vs update, and a **commands** list.  
2. It is **not** `sudoers(5)` text. It is **not** this product’s `--json` CLI status.  
3. Sibling approval software **MAY** convert a text dual into this JSON. Conversion **MUST NOT** invent OS-tool commands that this requirement forbids.  
4. If both a text fragment and a JSON sudoer file represent the **same** grant, they **MUST** be equivalent: both elevate **`{{PRJ_NAME}}` only**. A text file that allowlists `mkdir`/`cp`/… **MUST NOT** be treated as a valid dual of a compliant JSON sudoer file.  
5. Pretty-printed JSON (newlines and spaces between `commands[]` objects) is a **legal** encoding of this schema. Compact one-line JSON is also legal. A decoder **MUST** accept both.

### 2.2 Command identity — `{{PRJ_NAME}}` only (sacred)

**`{{PRJ_NAME}}`** is the product command (the ship-unit basename). It is the **only** elevated program this JSON may grant.

| Rule | Detail |
|------|--------|
| **Identity** | Every `commands[].path` **MUST** be the **managed global** product command: `{{GLOBAL_BIN}}/{{PRJ_NAME}}` |
| **Basename** | `basename(path)` **MUST** equal `{{PRJ_NAME}}` |
| **One program** | The grant **MUST NOT** list any other executable |
| **No local binary** | **MUST NOT** elevate `{{USER_BIN}}/{{PRJ_NAME}}` (user-rewritable; not production-secure) |
| **No OS tools** | **MUST NOT** list `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, `ln`, `mv`, `chown`, `dd`, or any shell (`sh`, `bash`, `dash`) — including `/bin/*` and `/usr/bin/*` twins |
| **No ALL** | **MUST NOT** use `ALL`, `NOPASSWD: ALL`, or an empty/unrestricted command set |

**Why OS-tool grants are forbidden (complexity is a security defect):**

| OS-tool design | What it costs | How it weakens security |
|----------------|---------------|-------------------------|
| One line per helper (`mkdir`, `cp`, `install`, `chmod`, `tar`, `rm`) | Fragment and JSON grow with every new backup need | Larger allowlist; easier to miss a dangerous twin (`/bin` vs `/usr/bin`) |
| Dest / stage / filename operands in the grant | Paths and `*.tar.gz` freeze into `/etc` | Host HOME, deposit trees, and archive names become sudoers law; env overrides break elev or over-grant |
| Wildcards to “keep it matching” | `*` and `*.tar.gz` on shared deposit | User can `cp`/`rm`/`tar` as root **without** running `{{PRJ_NAME}}` |
| Runtime must stay lockstep with the grant | Second lock after elev | Each product change needs a new sudoers review; agents add “just one more” Cmnd |

Elevating **`{{PRJ_NAME}}`** once is the smaller, stronger grant: after an admin has installed that command, the program performs mkdir/copy/tar/rm **internally**. Those live tools are **not** a second sudoers catalog.

### 2.3 Arguments — product verbs, no path or filename hardcode

1. `commands[].args` **MUST** be a product elev verb plus **exactly one** sudoers operand wildcard: `["backup", "*"]` and `["restore", "*"]`. The string `*` is **not** a filesystem path.  
2. **MUST** include a `backup` grant when durable deposit is in scope.  
3. **MUST** include a `restore` grant when elevated restore-stage fetch is in scope.  
4. **MUST NOT** put deposit paths, stage paths, host HOME, or archive filenames in `args` (no `/var/backup/…`, no `/dev/shm/…`, no `*.tar.gz`, no `NAME-YYYYMMDD-N.tar.gz`). Paths and names are **Config / product law**, not grant operands.  
5. **MUST NOT** grant `install`, `uninstall`, `print-sudoers`, `print-sudoers-install-script`, `remove-project-sudoers`, `generate-sudoer-request`, or `submit-sudoer-request` as elevated commands (those stay Type 0).  
6. **MUST NOT** grant `{{PRJ_NAME}}` with **no** verb when that would let the user run any subcommand as root. Verb-bound entries are required. **MUST NOT** emit verb-only `["backup"]` / `["restore"]` (sudoers exact-argv would not match `backup <source-folder>`).  
7. This CLI documents `--json` as a global flag **before** the verb. `commands[]` **MUST** include **separate** objects `["--json", "backup", "*"]` and `["--json", "restore", "*"]` in addition to the bare-verb objects. `--json` **MUST** be the first arg. Bare `backup *` **MUST NOT** be treated as covering `folder-backup --json backup <folder>` (`sudoers(5)` exact argv). Other CLI flags (`--force`, `--disk`, `--ram`) **MUST NOT** be frozen as host paths; the product validates them after elev.

### 2.4 Closed schema (normative)

| Field | Type | Required | Rule |
|-------|------|----------|------|
| `schema_version` | integer | yes | `1` for this requirement |
| `purpose` | string | yes | Human purpose; no secrets |
| `username` | string | yes | Target login (submitter); not `ALL` |
| `service` | string | yes | **MUST** equal `{{PRJ_NAME}}` |
| `action` | string | yes | `add` or `update` only |
| `commands` | array | yes | Non-empty; every element obeys §2.2–2.3 |
| `commands[].runas` | string | yes | `root` |
| `commands[].tags` | array | yes | `NOPASSWD` **MAY** appear when non-interactive deposit is product law; residual risk stays on the privilege peer |
| `commands[].path` | string | yes | Absolute `{{GLOBAL_BIN}}/{{PRJ_NAME}}` only |
| `commands[].args` | array of strings | yes | Required objects: `["backup", "*"]`, `["restore", "*"]`, `["--json", "backup", "*"]`, `["--json", "restore", "*"]` |

**MUST NOT** add undeclared privilege fields (extra binaries, `env_keep` shells, `ALL`). Unknown sibling metadata **MUST NOT** widen `commands`.

### 2.5 Filename grammar (queued artifact — sibling allocator)

This product **MUST NOT** invent the dest basename. Sibling grammar (informative for pairing):

```text
sudoer-{{YYYYMMDD}}-{{PRJ_NAME}}-{{username}}-{{action}}-{{n}}.json
```

**Worked sample basename (add):** `sudoer-20260815-folder-backup-{{USERNAME}}-add-1.json`  
**Worked sample basename (update):** `sudoer-20260815-folder-backup-{{USERNAME}}-update-1.json`

### 2.6 Complete sample bodies (maximum grant; add vs update)

**Maximum** JSON for this product: both elev verbs **and** `--json` twins (`sudoers(5)` exact argv). Compact and pretty are the same grant. Your-own-login emit **MUST NOT** add dest-stamped `submit_by`.

Normative **add** JSON (this project’s filled values — see §2.8):

```json
{
  "schema_version": 1,
  "purpose": "Allow {{USERNAME}} to run folder-backup backup and restore as root.",
  "username": "{{USERNAME}}",
  "service": "folder-backup",
  "action": "add",
  "commands": [
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/folder-backup", "args": ["backup", "*"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/folder-backup", "args": ["restore", "*"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/folder-backup", "args": ["--json", "backup", "*"]},
    {"runas": "root", "tags": ["NOPASSWD"], "path": "/usr/local/bin/folder-backup", "args": ["--json", "restore", "*"]}
  ]
}
```

Normative **update** JSON: same `commands`; `"action": "update"` only.

Equivalent **text dual** of the same grant (not a second allowlist of OS tools):

```text
# Purpose: Allow {{USERNAME}} to run folder-backup backup and restore as root.
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup backup *
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup restore *
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup --json backup *
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup --json restore *
```

JSON without the `--json` objects is **not** the dual of this text. `"*"` is a quoted string (not a cwd listing).

**Withdrawn (forbidden) encoding** — do not copy into a JSON sudoer file:

```json
{
  "path": "/usr/bin/mkdir",
  "args": ["-p", "/var/backup/folder-backup"]
}
```

That shape (and `cp` / `tar` / `rm` / `install` / `chmod` siblings) is **non-compliant**. It is the complexity/security defect this requirement exists to end.

### 2.7 Submit / emit honesty

1. When `submit-sudoer-request` builds or accepts a JSON sudoer file, the body **MUST** satisfy §2.2–2.4.  
2. **MUST** fail closed if an input file’s `commands` contain a forbidden path or OS-tool basename.  
3. **MUST NOT** “fix” a forbidden file by submitting it anyway.  
4. Trust-tier gates (production vs test_local) remain on `requirement-three-layer-privilege-model`. This requirement does not weaken those gates.  
5. **Independent generate:** this JSON **MUST** be writable by a Type 0 **subcommand** (this product: `generate-sudoer-request`) **without** submit, inbound, or `/etc`. Dest **MUST** be invoking-user readable so tests and review can `cat` it without sudo. Submit temp and inbound are **not** that dest. Workflow/readability law: `requirement-three-layer-privilege-model` §2.3.2a.

### 2.7a Re-encode / convert fidelity (sacred)

Sibling (or this product) **MAY** decode then re-encode the grant when converting or queueing. That rewrite is still **this** grant.

1. Decode / convert / re-encode **MUST** preserve **every** `commands[]` object: `path`, `args`, `runas`, `tags`.  
2. **MUST NOT** silently drop a verb so that purpose still says “backup and restore” while `commands` lists only `restore` (or only `backup`). Purpose is **not** completeness.  
3. **MUST** treat pretty-printed and compact JSON as the same grant. A splitter that only recognizes the token `},{` is non-compliant (it loses objects when `}, {` or `},\n{` appear).  
4. If the codec cannot represent the full `commands` array, it **MUST** fail closed (`invalid_json` or product equivalent). Silent last-`args`-wins is forbidden.  
5. `[OK] submitted` / a request_id **MUST NOT** be treated as proof the queued body equals the emit dual. When the inbound file is readable, submit **MUST** fail closed if required verbs are missing.  
6. Proof **MUST** exercise pretty **and** compact multi-command fixtures — compact-only suite green is not fidelity.

### 2.8 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **`{{PRJ_NAME}}` / `APP_NAME`** | `folder-backup` |
| **`{{GLOBAL_BIN}}`** | `/usr/local/bin` |
| **Elevated path** | `/usr/local/bin/folder-backup` |
| **Allowed args** | **Maximum:** `["backup","*"]`, `["restore","*"]`, `["--json","backup","*"]`, `["--json","restore","*"]`. Ship-unit compact JSON **Gap** until it emits the `--json` twins (text `print-sudoers` already has the four lines). |
| **Forbidden paths (examples)** | `/usr/bin/mkdir`, `/bin/mkdir`, `/usr/bin/cp`, `/bin/cp`, `/usr/bin/install`, `/usr/bin/tar`, `/bin/tar`, `/bin/rm`, `/usr/bin/rm`, `/usr/bin/chmod`, `/bin/chmod` |
| **Ship unit** | `src/folder-backup` |
| **Submit verb** | `submit-sudoer-request` → `fb_submit_sudoer_request` |
| **Generate verb** | `generate-sudoer-request` → `fb_generate_sudoer_request` (independent compact dual; dest readable without sudo) |
| **Generate dest (default)** | `${HOME}/.config/folder-backup/sudoer-request-<user>.json` (path operand for suite/review) |
| **Service field** | `folder-backup` |
| **Worked user in samples** | `{{USERNAME}}` (placeholder; live emit uses `id -un`) |
| **Privilege / workflow peer** | `requirement-three-layer-privilege-model` |
| **Ship unit emit** | Text dual **1.11.0** has `--json` lines. Compact JSON **Gap vs 1.4.0** until `fb_sudoers_json_text` / `_compact` include the `--json` objects. Host `/etc` is admin-installed (not Type 0). |

### 2.9 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 10 – Least privilege**: The grant is one managed binary and two verbs — not a catalog of root `cp`/`mkdir`/`rm`.  
- **CIAO Principle 1 – Caution**: Extra sudoers lines are extra ways to be wrong; complexity is treated as a vulnerability.  
- **CIAO Principle 2 – Intentional**: The JSON file means “this user may run `{{PRJ_NAME}} backup <folder>` and `restore <token>` as root” (`args` verb plus `*`), nothing else.  
- **CIAO Principle 9 – Type 0 / 1 / 2**: JSON is the Type 1 **grant**. Live mkdir/copy/tar after elev are not a second grant.  
- **CIAO Principle 21 – Dual policies**: Core rules use `{{PRJ_NAME}}` / `{{GLOBAL_BIN}}`; this section fills `folder-backup` and `/usr/local/bin`.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** generating the JSON grant stays your-own-login; the file **MUST NOT** become a reason to wrap `sudo` or write `/etc` on that class.

| MUST | MUST NOT |
|------|----------|
| Write JSON under a user-readable dest | In-tool `sudo` to place the grant |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Refuse OS-tool JSON even if an older fragment or review used it.  
- **Intentional:** `service` and `path` basename are the same name: `{{PRJ_NAME}}`.  
- **Anti-fragile:** Paths and archive names stay in Config; changing `BACKUP_ROOT` must not require a new sudoers JSON.  
- **Over-protect:** Verb-bound `backup *` / `restore *`; no bare-binary grant; no `USER_BIN` path; no verb-only exact argv.  
- **Stay-honest:** compact JSON emit is **Gap** vs 1.4.0 until it includes `--json` twins; inbound after submit must still list both verbs **and** those twins; `"*"` must not glob; do not revive OS-tool Cmnds.  
- **Anti-fragile (codec):** Re-encode is lossy unless proven; pretty JSON is legal input.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Put `cp`, `mkdir`, `install`, `chmod`, `tar`, `rm`, or a shell in a JSON sudoer file `commands` list.  
2. Treat “more specific wildcards” (`*.tar.gz`, `/var/backup/…/*`) as a substitute for `{{PRJ_NAME}}`-only.  
3. Hardcode deposit, stage, HOME, or archive **filenames** into `path` or `args`.  
4. Elevate `{{USER_BIN}}/{{PRJ_NAME}}` in this JSON.  
5. Grant `{{PRJ_NAME}}` with no verb (whole CLI as root).  
5b. Emit verb-only `args: ["backup"]` / `["restore"]` when operate argv includes a source folder or restore token.  
6. Claim an OS-tool emit (`mkdir`/`cp`/`tar`/`rm`) is compliant with this requirement.  
7. Duplicate submit/install workflow law here (that stays on the privilege peer).  
8. Store secrets in the JSON body.  
9. Cite templates or skills as product-source authority for this grant.  
10. Treat a sibling re-encode that dropped `commands[]` objects as “still the same grant” because `purpose` or `[OK]` survived.  
11. Mark emit-only tests (substring `"backup"` on the draft dual) as proof the **queued inbound** kept every verb.  
12. Require callers to emit minified `},{` only in order to skip a whitespace-tolerant decoder.  
13. Make submit, inbound, or a deleted temp the only way to obtain this JSON for tests or review. Independent generate to a readable dest is required.  
14. Omit `--json` `commands[]` objects, or treat `backup *` as covering `--json backup <folder>`.  
15. Unquote JSON `"*"` so a shell glob freezes cwd names into the grant.

**Violating this rule is a critical privilege / complexity-as-insecurity regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Every `commands[].path` is `{{GLOBAL_BIN}}/{{PRJ_NAME}}` (this project: `/usr/local/bin/folder-backup`) |
| AC-2 | `service` equals `{{PRJ_NAME}}` (`folder-backup`) |
| AC-3 | `args` **MUST** be the four objects `["backup","*"]`, `["restore","*"]`, `["--json","backup","*"]`, `["--json","restore","*"]`. Verb-only or missing `--json` twins **Fail** |
| AC-4 | No `mkdir` / `cp` / `install` / `chmod` / `tar` / `rm` / shell basename appears in `path` or `args` |
| AC-5 | No deposit/stage/HOME path and no `*.tar.gz` / archive filename in the JSON grant |
| AC-6 | Add and update samples exist and differ only by `action` |
| AC-7 | Submit of a file that violates AC-1–AC-5 fails closed |
| AC-8 | Text dual lists `backup *`, `restore *`, `--json backup *`, `--json restore *` (same argv set as JSON) |
| AC-9 | Pretty-printed grant with both verbs survives sibling `json-to-sudoers` / submit re-encode as **both** verbs (or submit fail-closed if inbound readable and a verb is missing) |
| AC-10 | Independent generate subcommand writes this JSON to an invoking-user-readable dest; suite opens it without sudo |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-three-layer-privilege-model` | Privilege layers; submit/install workflow; trust tiers |
| `requirement-domain-folder-backup` | `submit-sudoer-request` surface; defers JSON **body** here |
| `requirement-folder-archive-backup` | `backup` / `restore` ops after elev |
| `requirement-shell-cli-interface` | Verb routing |
| `requirement-project-folder` | Global bin / ship unit |
| `requirement-class-software-dev` | Residual points JSON sudoer file here |
| `docs/requirements/index.md` | Registry |
| `./src/folder-backup` | Implementation under test |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-FOLDER-BACKUP-22** | `tests/test_domain_folder_backup.sh` | **have** — JSON sudoer file `path` is only `/usr/local/bin/folder-backup` |
| **TP-FOLDER-BACKUP-22b** | same | **have** — JSON sudoer file contains no `mkdir`/`cp`/`tar`/`rm`/`install`/`chmod` |
| **TP-FOLDER-BACKUP-22c** | same | **have** — JSON sudoer file contains no deposit/stage path and no `*.tar.gz` |
| **TP-FOLDER-BACKUP-22e** | same | **have** — pretty emit through real `sudoer-cli` keeps `backup` and `restore` |
| **TP-FOLDER-BACKUP-22f** | same | **have** — stub inbound body still contains both verbs (not file-count only) |
| **TP-FOLDER-BACKUP-24 / 24d** | same | **have** — independent generate dest; suite reads file without sudo |
| **TP-FOLDER-BACKUP-26 / 26b** | same | **have** — JSON `args` include `*` after each verb; verb-only **Fail** (do not reuse TP-25) |
| **TP-FOLDER-BACKUP-27** *(map from TP-SUDOER-JSON-21)* | same | **todo** — compact/pretty JSON includes `--json` twins; text dual matches; `"*"` not cwd names |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-15 | Active 1.0.0 | JSON sudoer file SSOT; grant is `{{PRJ_NAME}}` only; OS-tool commands forbidden (complexity weakens security) |
| 2026-08-15 | Active 1.0.1 | Ship unit 1.8.0 emit matches §2.6; DTV 22/22b/22c **have** |
| 2026-08-17 | Active 1.1.0 | §2.7a re-encode fidelity; pretty JSON legal; AC-9; TP-22e/22f; INC-20260817-001 |
| 2026-08-17 | Active 1.2.0 | §2.7 item 5 independent generate to a dest tests/review can read; AC-10; TP-24d |
| 2026-08-23 | Active 1.3.0 | `args` **MUST** be verb plus `*`; verb-only withdrawn; AC-3/AC-8 |
| 2026-08-23 | Active 1.4.0 | Maximum JSON **MUST** include `--json` twins; AC-3/AC-8; emit Gap until compact JSON matches |

---

**Last Updated**: 2026-08-23  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
