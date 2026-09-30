**file**: docs/requirements/requirement-three-layer-privilege-model.md  
**Status**: Active (Version 1.12.1)  
**Area**: architecture  
**Key**: `requirement-three-layer-privilege-model`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **three-layer privilege model** as applied to **folder-backup**: which operations run as the invoking user, which use **narrow elevated sudo**, and what is out of scope.

It is also the **product law SSOT for working with sudoers fragment files**: how the CLI **emits** a draft, how an **admin** validates and installs under `/etc/sudoers.d/`, how **`generate-sudoer-request`** writes a local JSON grant you can verify, how **`submit-sudoer-request`** hands a grant to sibling **sudoer-cli** so a **JSON request** lands in the **public inbound**, how **runtime deposit** uses allowlisted `sudo -n`, and how **fail-closed** behaves when elevation is missing.

**JSON sudoer file body** (command identity, schema, samples) is **not** owned here — it is **`requirement-sudoer-json-file`**. That peer **MUST** grant only `{{PRJ_NAME}}` (`folder-backup`); OS-tool commands (`cp`, `mkdir`, …) are forbidden there.

Domain backup semantics (naming, tar, pillars) live in `requirement-domain-folder-backup.md`. Agent procedure for security-gated create is **`SK-CREATE-SUDOERS-FILE`** (not product-source authority).

### 1.1 Human-facing

**In one sentence:** You print a sudoers draft as yourself; an admin installs it; then `folder-backup backup <folder>` can run with the matching passwordless grant — including from automation that has no terminal.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Emit the draft; run `backup <folder>` after install | `folder-backup print-sudoers` |
| Admin | Validate and install under `/etc/sudoers.d/` | `visudo -c` then mode `0440` |
| Not this file | JSON command list shape | `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| Grant must match `backup <source-folder>` (`backup *`) | Verb-only `… backup` with no extra operand |
| Trailing sudoers `*` = one argv wildcard | Frozen `/var/backup/…` or `*.tar.gz` paths in the fragment |
| Non-interactive `sudo -n` of the **matching** line | Blaming “no TTY” when the grant is too narrow |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/folder-backup` | ship unit | live emit **1.10.0** (`backup *` / `restore *`) |
| `folder-backup help` | command | `print-sudoers` / `backup` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Print the draft | You stay unprivileged. The text must include `backup *`. | `folder-backup print-sudoers` |
| After admin install, back up a folder | Automation may use `sudo -n` because NOPASSWD matches the full argv. | `sudo -n /usr/local/bin/folder-backup backup /path/to/dir` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Layer map (this product)

| Layer | Privilege | Actor | folder-backup responsibilities |
|-------|-----------|-------|--------------------------------|
| **Type 0** | Invoking user | End user / automation | Local install/uninstall, diagnostics, path report, tar.gz **create** in user staging, **print / write draft** sudoers fragment |
| **Type 1** | Elevated (controlled sudo) | root via **allowlisted** command only | `folder-backup backup` / `folder-backup restore` (grant body: `requirement-sudoer-json-file`). After elev, deposit/verify/restore run **inside** the ship unit. |
| **Type 2** | Dedicated least-privilege system user | App runtime user | **Not used** — no dedicated app user required |

### 2.2 Least-privilege rules

1. **MUST NOT** require the whole CLI to run as root for normal backup creation.  
2. **MUST** create the tar.gz archive as the invoking user in isolated staging.  
3. **MUST** elevate only for the **deposit** step (and only via allowlisted sudo).  
4. **MUST NOT** grant unrestricted shell, package install, or arbitrary `cp` across the filesystem.  
5. **MUST NOT** open network egress from deposit, restore, or sudoers privilege paths. Explicit channel verbs (`self-install`, `version-check`, `self-update`) are outside this privilege design.  
6. **MUST NOT** treat “sudoers installed” as permission to broaden Cmnds later without a new security review.

---

### 2.3 Working with sudoers fragment files (normative)

#### 2.3.1 Roles and artifacts

| Role | May | Must not |
|------|-----|----------|
| **End user / automation** | Run `print-sudoers`; run `backup` after admin install | Write `/etc/sudoers.d/` as Type 0 |
| **CLI (Type 0)** | Emit fragment to **stdout** or a **user-writable draft path** | Silently install or rewrite `/etc/sudoers.d/*` |
| **Admin (root)** | `visudo -c`, install with mode `0440`, pre-create deposit dir ownership if needed | Install fragments that grant shell/`ALL` |
| **Agent (harness)** | Follow **`SK-CREATE-SUDOERS-FILE`** + **`CL-CREATE-SUDOERS-SECURITY`** before drafting | Auto-write `/etc`; emit without Pass review |

| Artifact | Location (this product) | Authority |
|----------|-------------------------|-----------|
| **Draft fragment** | stdout **or** `${HOME}/.config/folder-backup/sudoers.fragment-<user>` (or path arg to `print-sudoers`); legacy `sudoers.fragment` still recognized for remove | Type 0 write only |
| **Installed fragment** | `/etc/sudoers.d/folder-backup-<user>` (per-user; multi-user safe). Legacy `/etc/sudoers.d/folder-backup` may still exist on older hosts | Admin only; mode `0440` |
| **Security review (pre-emit)** | `reviews/reports/YYYY-MM-DD-sudoers-security-folder-backup.md` (and local security checklist trail when used) | Required before **agent create** of a new draft |
| **External sudoers audit record** | `docs/whitelists/external-sudoers/records/WS-*.md` | Optional audit; no secrets |

#### 2.3.1a Install trust tiers for elevation (mandatory)

| Trust tier | Managed install | Meaning | Allowed review / emit |
|------------|-----------------|---------|------------------------|
| **`production`** | Executable **`${GLOBAL_BIN}/folder-backup`** (typically root-owned, not writable by target user) | Stronger: unprivileged user cannot rewrite the global binary | Full **Pass**; preferred for durable `/etc/sudoers.d/folder-backup-<user>` |
| **`test_local`** | Only **`${USER_BIN}/folder-backup`** (user home) **or** no global | **Weak:** user can change local source/binary and stage content | **Pass (test only)** only; **MUST** warn TEST MODE; **MUST** plan uninstall soon |
| **Unmanaged** | Neither global nor local managed path | No managed install proof | Product emit only with explicit test allow flag; agent create **Block** without install |

**Normative:**

1. **MUST NOT** claim production-secure elevation when only a local managed binary exists.  
2. Local install remains correct for **Type 0** day-to-day use **without** sudoers.  
3. Hosts that will **keep** an installed fragment **SHOULD** use root install → global:  
   `sudo sh src/folder-backup install` or `folder-backup install --global` (as root / writable `GLOBAL_BIN`).  
4. Elevating `${USER_BIN}/folder-backup` as a Cmnd is **forbidden** for production Pass; this product’s deposit uses fixed OS tools, but residual **stage content** risk remains.  
5. Stage allowlists **MUST** bind to **per-user** product stage roots (`…/folder-backup-<user>/`), not bare `/tmp/*` or home-wide trees.

#### 2.3.2 Operator workflow (mandatory order)

| Step | Who | Action |
|------|-----|--------|
| 1 | User / admin | Prefer **global** install before durable sudoers; local install OK for Type 0-only |
| 2 | User | Run `folder-backup print-sudoers` **or** `folder-backup print-sudoers <draft-path>` (test_local requires `--allow-test-local` or `ALLOW_TEST_LOCAL_SUDOERS=1`) |
| 3 | CLI (Type 0) | Emit **narrow** fragment for the **invoking user**; print trust tier + warnings |
| 4 | User | Optionally run `folder-backup print-sudoers-install-script` → admin script under `/dev/shm` (or temp) |
| 4a | User | Run `folder-backup generate-sudoer-request` (optional dest path) — **independent** JSON grant on a dest **readable without sudo** for tests and review. Not inbound. Not `/etc`. |
| 4b | User (when sudoer-cli + sudoer-adm are present) | Optionally run `folder-backup submit-sudoer-request [file]` to hand the **reviewed** file to sudoer-cli, which **allocates a JSON request** in the **public inbound** (Type 0; no `/etc` write; no inbound `mkdir`). Approver still must approve. |
| 5 | **Admin** | Review draft (and TEST MODE banner if present); either manual `visudo -c` + `install -m 0440`, **or** `sudo sh <admin-script> install` / `replace`, **or** approve a queued request via sudoer-cli |
| 6 | **Admin** | Optional: ensure `/var/backup/folder-backup` exists with safe ownership/mode (script `install` may mkdir) |
| 7 | User | Run `folder-backup backup <dir>`; deposit uses **only** allowlisted `sudo -n` commands |
| 8 | Admin (test_local / leave elev) | **Uninstall soon**: `sudo sh <admin-script> uninstall` (or `sudo rm /etc/sudoers.d/folder-backup-<user>`) |

#### 2.3.2a Independent sudoer generate (sacred)

**Purpose:** **Any** sudoer artifact this product generates (text fragment, JSON grant, or a future dual) **MUST** be producible by a **Type 0 subcommand** that writes the file **independently** of submit, approve, and `/etc` install. Tests and review **MUST** open that file **without sudo**.

This rule applies to every generate surface. Today that is `print-sudoers` (text dual + pretty `.json`) and `generate-sudoer-request` (compact JSON grant). A later generate verb is in scope the day it is added.

| Rule | Detail |
|------|--------|
| **Subcommand** | Routed, help-listed Type 0 verb. A helper used only inside `submit-sudoer-request` is **not** independent generate. |
| **Independent** | The command writes the artifact and returns. It does **not** queue inbound, write `/etc`, or require sibling allocate. |
| **Readable dest** | After return, the invoking user **MUST** be able to read the dest (`[ -r ]` / `cat` **without** sudo). Suite and review use that dest as the fixture. |
| **Default dest** | Deterministic and documented in Implementation Notes. Optional path operand **MUST** override so tests isolate under `$HOME`, suite temp, or `/dev/shm`. |
| **Forbidden dest** | `/etc/**`; sibling inbound (`/var/sudoer-cli/**` or other inbound); a mode the invoking user cannot read; a submit scratch temp **deleted** before return. |
| **Status** | `--json` **MUST** report `path` of the written file. Human output **MUST** print that path. |
| **Not a substitute** | Submit temp, inbound after queue, and purpose text are **not** the review/test fixture for generate. |

**Normative:**

1. **MUST NOT** make submit, inbound, or admin install the only way to obtain a sudoer body for tests or review.  
2. **MUST** keep body law on `requirement-sudoer-json-file` (JSON) or §2.3.4 (text dual). This section owns **independence and readability**.  
3. Review / suite **MUST** `cat` the generate dest (or an explicit path operand) without sudo. Grep on stdout-only emit is allowed for `print-sudoers` with no path; a path write **MUST** still be readable on disk.

#### 2.3.3 `print-sudoers` (Type 0) product rules

1. **MUST** emit reviewable plain text suitable for `sudoers(5)` (no passwords, tokens, or private keys).  
2. **MUST NOT** write `/etc/sudoers.d/` or any path under `/etc` from the unprivileged CLI path.  
3. **MUST** target the **invoking user** in User specification lines (product default: current user).  
4. **MUST** document short **admin steps** in human output: `visudo -c`, install mode `0440`, destination name.  
5. When a **path argument** is given, **MUST** write the fragment only to that user-writable path (create parent dirs as needed), leave it **invoking-user readable** (§2.3.2a), and report success via `out_*`.  
6. When **no path** is given, **MUST** print the fragment to **stdout** (plus admin hints on stderr/info channels per output SSOT).  
7. Re-running `print-sudoers` **MUST** be safe (idempotent emit; does not mutate installed `/etc` file).  
8. Fragment content **MUST** match product deposit paths and staging roots used by `fb_deposit_archive` / storage resolve (so allowlisted wildcards actually match runtime stage paths).  
9. **MUST** detect trust tier from global vs local managed install presence.  
10. When trust tier is **`test_local`** (or unmanaged): **MUST** refuse emit unless `--allow-test-local` **or** env `ALLOW_TEST_LOCAL_SUDOERS=1`; **MUST** print a **TEST MODE ONLY / uninstall soon** warning; fragment header **MUST** carry the same warning.  
11. When trust tier is **`production`**: emit without the test allow flag; header **SHOULD** note managed global path.  
12. JSON emit **MUST** include `trust_tier` (`production` \| `test_local` \| `unmanaged`) and `test_mode` (`true`/`false`).  
13. Fragment text **MUST** match §2.3.4 / §2.3.4a: each of `backup` and `restore` **MUST** be followed by sudoers `*` (one extra operand). Verb-only lines **MUST NOT** be emitted. JSON argv lines (`--json backup *`) **MUST** be emitted (and matching JSON `commands[]` objects).

#### 2.3.3a `print-sudoers-install-script` (Type 0) product rules

**Purpose:** Generate a handoff shell script so an account **with sudo** can install, uninstall, or replace the **project-sudoers-file** under `/etc/sudoers.d/` without the Type 0 CLI writing `/etc` itself. See term **`project-sudoers-file`**.

1. **MUST** refresh/write the **project-sudoers-file** (default `${HOME}/.config/folder-backup/sudoers.fragment-<user>`) using the same trust rules as `print-sudoers` before writing the admin script.  
2. **MUST** write the admin script only under a **user-writable / volatile** path: prefer `/dev/shm/folder-backup-<user>-sudoers-admin.sh`, else product storage/temp — **MUST NOT** write under `/etc`.  
3. **MUST NOT** itself write `/etc/sudoers.d/` or run install as a silent Type 0 side effect.  
4. Generated script **MUST** install to **`/etc/sudoers.d/folder-backup-<user>`** (per-user suffix) so multi-user admin installs do not overwrite each other.  
5. Generated script **MUST** support at least:
   - `install` — `visudo -c` on draft → `install -m 0440` → per-user installed path → re-`visudo -c`  
   - `uninstall` — remove `/etc/sudoers.d/folder-backup-<user>` only (this user’s fragment; leave other users intact)  
   - `replace` — uninstall then install (refresh host from current project-sudoers-file)  
   - `status` — report draft + installed presence; **SHOULD** note legacy shared path and other-user fragments when present  
6. Generated script **MUST** require **root** for install/uninstall/replace.  
7. Generated script **MUST NOT** embed passwords or secrets.  
8. Human output **MUST** print handoff lines: `sudo sh <script> install|uninstall|replace`.  
9. JSON **SHOULD** include `script_path`, `project_sudoers_file`, `installed_path`, `trust_tier`, `user`.

#### 2.3.3b `remove-project-sudoers` (Type 0) product rules

**Purpose:** Remove the **project-sudoers-file** draft (product-owned, user-writable). Does **not** remove the installed host fragment under `/etc/sudoers.d/`.

1. Default discovery: drafts under `${HOME}/.config/folder-backup/` matching legacy `sudoers.fragment` and `sudoers.fragment-*` (default emit path is `sudoers.fragment-<user>`). Optional path argument selects one draft.  
2. **MUST NOT** remove paths under `/etc` (fail closed with hint to admin leave-elev: `sudo rm /etc/sudoers.d/folder-backup-<user>` and/or admin script `uninstall`).  
3. When **multiple** drafts exist and no path is given:  
   - **Interactive** → **MUST** list numbered drafts and let the user choose which to remove (or cancel).  
   - **Non-interactive** / json / quiet → **MUST** fail closed and require an explicit path argument.  
4. Zero drafts → success no-op for the default path (already absent). One draft → operate on that draft.  
5. Interactive confirm unless `--force`; non-interactive/json/quiet without force → **fail closed**.  
6. On success (removed or already absent), human output **MUST probe** host elev paths (`/etc/sudoers.d/folder-backup-<user>`, legacy `/etc/sudoers.d/folder-backup`, and other `/etc/sudoers.d/folder-backup-*` when present):  
   - **Any present** → **MUST** warn that host elevation is still active (draft ≠ installed elev); **MUST** list present paths; **MUST** point to admin leave-elev for this user and/or `print-sudoers-install-script` then `sudo sh <script> uninstall`.  
   - **None present** → **SHOULD** state host fragment also absent (no “if any” hedge; no false elev lecture).  
7. JSON **SHOULD** include `path`, `status` (`removed` \| `already_absent`), `installed_path`, `host_fragment_present` (`0` \| `1`).

#### 2.3.3c `submit-sudoer-request` (Type 0) product rules

**Purpose:** This product is a **Type 0 sudoers-grant submitter**. When the sibling approval CLI and approver account are present, it hands a self-scoped sudoers fragment (or file) to that CLI so the CLI **allocates a JSON request file** in the sibling’s **public inbound**. This product remains Type 0: it **MUST NOT** write `/etc`, **MUST NOT** `mkdir` the production inbound, **MUST NOT** approve or reject, and **MUST NOT** choose the queued dest basename.

**Roles (this verb):**

| Role | Who | May | Must not |
|------|-----|-----|----------|
| **Submitter** | Invoking login via this CLI | Detect approval CLI + inbound; emit or pass a self-scoped fragment; invoke sibling submit | `mkdir` inbound; write `/etc`; pick dest basename; approve |
| **Allocator** | Sibling approval CLI (`{{APPROVAL_APP}}`) | Allocate `request_id`; exclusive-create JSON in inbound; `chmod 0640` | Trust a caller-supplied dest basename |
| **Approver** | Sibling LPU (`{{APPROVER}}`) | Move inbound → accepted/declined; install dest | This product’s Type 0 path |

**Inbound detect (mandatory order — first existing directory wins):**

| Priority | Candidate | When |
|----------|-----------|------|
| 1 | `SUDOER_QUEUE_INBOUND` | Set **and** is an existing directory (tests / explicit override) |
| 2 | `/var/{{APPROVAL_APP}}/{{INBOUND_BASENAME}}` | **Preferred production public inbound** (must already exist) |
| 3 | `{{approver-home}}/{{INBOUND_BASENAME}}` | F4 **view** (symlink to the public real dir) |
| 4 | Legacy only: `{{approver-home}}/sudoer-approving`, `/etc/{{APPROVER}}/sudoer-approving`, `/home/{{APPROVER}}/sudoer-approving` | Transitional hosts; **not** the preferred real dir |

Filled conventional names for this compose live in §2.5. Core rules **MUST NOT** treat a home-only `sudoer-approving` directory as the preferred real inbound.

**Normative rules:**

1. **MUST** detect the approval CLI (`{{APPROVAL_APP}}`): env `SUDOER_CLI` if executable, else global bin, else user bin, else `PATH`. Missing → fail closed with install hint.  
2. **MUST** detect the approver login (`{{APPROVER}}`, override `SUDOER_ADM_USER`) via `id`. Missing → fail closed with setup hint (`sudo {{APPROVAL_APP}} setup`).  
3. **MUST** detect inbound using the table above. Missing → fail closed with setup hint. Not writable for exclusive create → fail closed (production inbound is create-only for others: mode **3773**, no other-readdir).  
4. **MUST NOT** `mkdir` (or `mkdir -p`) the production inbound, its public parent, or any F4 view.  
5. **MUST NOT** treat this product’s deposit directory as an inbound.  
6. **MUST** report detections on `about` (human + JSON): approval CLI path or `not_found`; approver or `absent`; inbound path or `not_found`; writable flag. About inbound **SHOULD** name the preferred public path when reporting `not_found`.  
7. Default input is the same fragment `print-sudoers` would emit (same trust-tier gate). Optional file operand submits that file instead (refuse symlink / missing).  
8. **MUST** invoke the detected approval CLI `add-sudoer-request` or `update-sudoer-request` with `--service` equal to this product’s `APP_NAME` and a purpose string (`--purpose` or product default). That sibling call **is** what creates the queued **JSON** file.  
8a. **Default action from host probe (this user only):** if `/etc/sudoers.d/{{APP_NAME}}-{{username}}` exists (or legacy `/etc/sudoers.d/{{APP_NAME}}`), default sibling verb is **`update-sudoer-request`**. If neither exists (or the directory is unreadable and `sudo -n test -e` cannot confirm), default is **`add-sudoer-request`**. Other users’ `{{APP_NAME}}-<other>` files **MUST NOT** flip this user’s action. `--update` / `--add` **MUST** override the probe. Type 0 **MUST NOT** write `/etc`. Probe dir **MAY** be overridden with `SUDOERS_D_DIR` (tests).  
9. **MUST NOT** invent or pass a dest basename for the queued file. `request_id` is whatever the sibling allocator returns.  
10. When pointing the sibling at a queue root, **MUST** use the **parent of the real public inbound** (or leave the sibling on its public default). **MUST NOT** export a home directory that still uses the legacy `sudoer-approving` child as if it were the public queue root.  
11. **MUST NOT** write `/etc/sudoers.d` or `/etc/passwd` from this verb.  
12. Product `--json` status **SHOULD** include `request_id`, `action`, `action_source` (`detected` \| `explicit`), `host_fragment_present`, `host_fragment_path`, `service`, `sudoer_cli`, `sudoer_adm`, `inbound`. That status object is **not** the queued request file. About **SHOULD** report `host_sudoers_present` / `host_sudoers_path`.  
13. **Inbound fidelity:** the queued body **is** the grant the approver will install. `[OK] submitted`, the purpose string, and the emit dual are **not** substitutes. When `${inbound}/${request_id}` is readable, submit **MUST** fail closed if `commands` lost a required elev verb (`backup` / `restore`). When it is not readable (production inbound often `0640` after LPU chown), stay-honest: do **not** claim the queued file equals emit. Fatal copy **MUST** be operator-readable (name the missing grant, do not approve the request id, point at `generate-sudoer-request`).  
14. Review / suite **MUST NOT** treat a stub `sudoer-cli` that `cp`s the input, or emit-only substring greps, as proof of sibling re-encode fidelity. Pretty-printed emit **MUST** be a fixture (INC-20260817-001).  
15. Default submit handoff (no file operand) **MUST** pass a grant that still names both verbs after sibling convert on the detected `sudoer-cli`. Compact one-line JSON (`},{` between `commands[]` objects) is a **legal** handoff of the same grant (pretty remains the `print-sudoers` dual).  

#### 2.3.3d `generate-sudoer-request` (Type 0) product rules

**Purpose:** Independent generate (§2.3.2a) for the **JSON request grant**. Write a **local** file the operator, suite, and review can read **before** `submit-sudoer-request`. Incomplete inbound is caught on disk, not after queueing. It is **not** a second inbound allocator.

1. **MUST** apply the same trust-tier gate as `print-sudoers` / submit (`--allow-test-local` / `ALLOW_TEST_LOCAL_SUDOERS` when not production).  
2. Default dest **MUST** be `${HOME}/.config/{{APP_NAME}}/sudoer-request-<user>.json`. Optional path operand **MUST** override (tests isolate here).  
3. **MUST NOT** write `/etc` or `/var/sudoer-cli` (or other inbound). **MUST NOT** `mkdir` inbound. **MUST NOT** pick a queued `request_id`.  
4. Body **MUST** satisfy `requirement-sudoer-json-file` (both `backup` and `restore`; no OS-tool commands).  
5. After write, **MUST** leave the dest **owner-readable** (`u+r`) and verify the file still names both verbs. Fail closed if either is missing.  
6. When `sudoer-cli` is detected, **MUST** run `json-to-sudoers` on the file and fail closed if convert drops a verb. Missing `sudoer-cli` **MUST NOT** block generate; report convert as skipped.  
7. Human output **MUST** name the path, state that both verbs were verified, and give the next command: `{{APP_NAME}} submit-sudoer-request <path>`. `--json` **MUST** include `path`.  
8. `--add` / `--update` and the host-fragment probe **MUST** match submit (so the written `action` is the one submit would use).  
9. Re-run **MAY** overwrite the same dest (draft, not inbound).  
10. Suite / review **MUST** open this dest (or the path operand) **without sudo**. Submit scratch temp and inbound are **not** this fixture.  
11. `print-sudoers [path]` remains the independent generate for the **text fragment** (and pretty `<path>.json`). This verb is the independent generate for the **submit JSON grant**.

**Queued JSON (sibling-owned shape — this product must produce input that converts):**

The queued artifact lives **in the inbound directory**. Filename grammar and closed schema are **owned by the sibling approval product**. This product **MUST** pass a self-scoped sudoers text dual (or already-valid request JSON) that the sibling can convert and queue. Worked basename + body for **this** product’s grant are in §2.5. Sibling decode/re-encode **MUST** preserve every `commands[]` object (`requirement-sudoer-json-file` §2.7a); a restore-only inbound after a backup+restore emit is a **different** grant.

#### 2.3.4 Fragment content constraints (mandatory)

Generated or admin-installed fragments for this product **MUST** match the JSON grant (`requirement-sudoer-json-file`): **`{{PRJ_NAME}}` only**.

| Rule | Detail |
|------|--------|
| **User-bound** | Only the intended login — not `ALL` users |
| **Cmnd absolute** | Only `{{GLOBAL_BIN}}/{{PRJ_NAME}}` (this product: `/usr/local/bin/folder-backup`) |
| **Verbs + one operand wildcard** | Each Cmnd **MUST** be `{{GLOBAL_BIN}}/{{PRJ_NAME}} backup *` and `… restore *`. The trailing `*` is a **sudoers(5) one-operand wildcard** so `backup <source-folder>` / `restore <token>` match. Verb-only (`… backup` with no `*`) **MUST NOT** be emitted or installed. |
| **JSON argv switches** | **MUST** also emit `--json backup *` and `--json restore *` (different argv). JSON grant **MUST** include matching `commands[]` objects (**`requirement-sudoer-json-file`** 1.4.0). |
| **No OS tools** | **MUST NOT** list `mkdir`, `cp`, `install`, `chmod`, `tar`, `rm`, or shells |
| **No frozen paths** | **MUST NOT** freeze deposit/stage/HOME paths or `*.tar.gz` / archive **filenames** into the fragment. The sudoers `*` is **not** a path. |
| **No broad rights** | **MUST NOT** include `ALL=(ALL) ALL`, `NOPASSWD: ALL`, or unrestricted shells |
| **NOPASSWD scope** | `NOPASSWD:` **MUST** appear on those project-command lines so non-interactive `sudo -n` of the **full argv** works; residual risk **MUST** be stated in the security review |
| **No secrets** | No passwords, API keys, or private key material in the file or comments |
| **Comments** | Header **SHOULD** state purpose, product, date/generator, and that admin must `visudo -c` |

Runtime deposit/restore **MAY** still call `sudo -n mkdir`/`cp`/`tar`/`rm` internally. That is **not** a reason to put those tools in the fragment. Do **not** replace a working OS-tool host fragment with this grant until `backup`/`restore` re-exec via the project command.

#### 2.3.4a Example sudoers fragment (this product)

**Normative text dual** of the JSON grant (same as `requirement-sudoer-json-file` §2.6).  
**Not** a secret. Admin **MUST** still run `visudo -c` on the host before install.  
Draft often at `${HOME}/.config/folder-backup/sudoers.fragment-<user>`; installed at `/etc/sudoers.d/folder-backup-<user>`.  
`print-sudoers` **MUST** emit this shape (backup/restore with trailing `*`; JSON argv lines **SHOULD**).

```sudoers
# Purpose: Allow {{USERNAME}} to run folder-backup backup and restore as root.
# Trailing * = one extra operand (source folder / restore token). Verb-only does not match.
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup backup *
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup restore *
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup --json backup *
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup --json restore *
```

**What this example intentionally omits:** `NOPASSWD: ALL`, shell Cmnds, package managers, `mkdir`/`cp`/`install`/`chmod`/`tar`/`rm`, frozen `/var/backup/…` or `*.tar.gz` **paths**, elevation of `${USER_BIN}/folder-backup`.

**Withdrawn (forbidden) emit** — verb-only; `sudo -n folder-backup backup /some/dir` does **not** match:

```sudoers
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup backup
{{USERNAME}} ALL=(root) NOPASSWD: /usr/local/bin/folder-backup restore
```

**Test-local header (when tier is test_local — not production):**

```text
# WARNING: TEST MODE ONLY — local managed binary is user-rewritable.
# Uninstall this fragment soon: sudo rm /etc/sudoers.d/folder-backup-<user>
# Production: sudo install global binary, re-emit print-sudoers, re-review, reinstall fragment.
```

#### 2.3.5 Admin install rules

1. Admin **MUST** validate with `visudo -c -f <file>` before install.  
2. Admin **MUST** install with restrictive mode (typically **`0440`**, owner `root:root`).  
3. Preferred installed path: **`/etc/sudoers.d/folder-backup-<user>`** (per-user; multi-user safe).  
4. Product CLI and agents **MUST NOT** perform this install as a silent Type 0 side effect.  
5. After install, deposit dir **`/var/backup/folder-backup`** **SHOULD** exist (admin may pre-create; the project command creates it after elev).  
6. Admin **MUST NOT** install multiple users into a single shared basename that would overwrite another user’s allowlist.

#### 2.3.6 Runtime elevation after sudoers install

| Rule | Detail |
|------|--------|
| **Invocation** | After a `backup *` fragment, non-root deposit **SHOULD** re-exec `sudo -n {{GLOBAL_BIN}}/folder-backup backup <source-folder>` (same for restore). **Gap:** ship unit deposit still uses Type 1 inner `sudo -n mkdir`/`cp` until that re-exec is wired. |
| **Scope** | Only the **just-staged** archive into `/var/backup/folder-backup/`. OS-tool `sudo -n` from Type 1 internals is residual — not a second sudoers catalog. |
| **Root path** | If `id -u` is 0, deposit **MAY** copy without sudo into the destination |
| **Logging** | Report success/failure via `out_*`; **never** print sudo passwords |
| **Probe honesty** | **MUST NOT** claim elevation is impossible solely because there is no TTY. **MUST NOT** treat `sudo -n … backup` **without** a folder operand as proof deposit works. **MUST NOT** treat `sudo -n true` failure as “no elev” when only narrow Cmnds are allowlisted. Verb-only grant + `backup <dir>` password prompt is **grant-too-narrow**, not missing TTY. |

#### 2.3.7 Fail-closed (mandatory)

If sudo is missing, not authorized for the deposit Cmnd, or the destination cannot be written:

1. Deposit **MUST** fail with non-zero exit.  
2. Human error **MUST** point to `print-sudoers` and admin install under `/etc/sudoers.d/`.  
3. **MUST NOT** silently skip deposit and claim backup success.  
4. **MUST NOT** fall back to writing archives into `/var/backup/...` as an unprivileged user when that path is not writable.

#### 2.3.8 Agent / harness create path (when creating or revising fragments)

When an agent **creates or materially revises** a sudoers draft (beyond re-running product `print-sudoers`):

1. **MUST** follow **`SK-CREATE-SUDOERS-FILE`**.  
2. **MUST** complete **`CL-CREATE-SUDOERS-SECURITY`** with **Pass** or **Pass (test only)** before writing the draft file, including:  
   - **S11–S12** when elev Tables A/B/C (or equivalent elev whitelist) are claimed/registered — fragment ⊆ Table A; no silent widen  
   - **S13** trust tier **always** — production requires global managed binary; local-only → **Pass (test only)** only  
3. **MUST** identify **target user** (default: current user).  
4. **MUST** prove a **managed binary** install exists at global and/or local install location for `folder-backup`. New fragments **MUST** elevate `{{GLOBAL_BIN}}/folder-backup backup` and `restore` only (not OS-tool deposit).  
5. **MUST** publish a short security review under `reviews/reports/` (or filled checklist) with verdict **Pass** (production) or **Pass (test only)**.  
6. **MUST NOT** default the write target to `/etc/sudoers.d/`.  
7. **MUST NOT** mark production **Pass** for local-only managed installs.  
8. **SHOULD** update `docs/whitelists/external-sudoers/records/WS-*` when the fragment is **applied** on a host (no secrets); test_local → status **test / to-uninstall**.  
9. **SHOULD** point operators at `print-sudoers-install-script` for admin install/uninstall/replace handoff of the **project-sudoers-file** (Type 0 never writes `/etc`).

---

### 2.4 Runtime elevation contract (summary)

| Rule | Detail |
|------|--------|
| Invocation | `sudo -n` after passwordless fragment; non-interactive without ticket **fails closed** |
| Scope | Deposit only — not package install, not shell |
| Destination create | Deposit dir `/var/backup/folder-backup` **SHOULD** exist (admin or project command after elev) |
| Staging | Cache chain in `requirement-shell-cli-storage` (Linux: `/dev/shm/cache/cache-folder-backup-<login>-<pid>`, else `/tmp/cache/...`, else `${HOME}/.cache/cache-folder-backup-<pid>`) — Type 1 internals, **not** fragment operands |

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product / APP_NAME** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **BACKUP_ROOT** | `/var/backup` |
| **BACKUP_NOTATION default** | `folder-backup` |
| **Deposit directory** | `/var/backup/folder-backup` |
| **Project sudoers file (draft)** | `${HOME}/.config/folder-backup/sudoers.fragment-<user>` via `print-sudoers` / install-script refresh |
| **Admin install path** | `/etc/sudoers.d/folder-backup-<user>` (per-user) |
| **Admin install script (default)** | `/dev/shm/folder-backup-<user>-sudoers-admin.sh` via `print-sudoers-install-script` |
| **Type 2 system user** | None |
| **CLI commands** | `print-sudoers` → `fb_print_sudoers`; `print-sudoers-install-script` → `fb_print_sudoers_install_script`; `remove-project-sudoers` → `fb_remove_project_sudoers`; `generate-sudoer-request` → `fb_generate_sudoer_request`; `submit-sudoer-request` → `fb_submit_sudoer_request`; deposit → `fb_deposit_archive` |
| **Independent JSON generate dest** | `${HOME}/.config/folder-backup/sudoer-request-<user>.json` (owner-readable; path operand for suite/review) |
| **Independent text generate dest** | `print-sudoers [path]` → that path (plus pretty `<path>.json`) |
| **Sibling approval CLI** | `sudoer-cli` (`SUDOER_CLI` override) |
| **Sibling approver** | `sudoer-adm` (`SUDOER_ADM_USER` override); this host home `/etc/sudoer-adm` |
| **Preferred public inbound** | `/var/sudoer-cli/sudoer-request` (mode **3773**, owner `sudoer-adm:sudoer-adm`) |
| **Test public root** | `SUDOER_PUBLIC_ROOT` (default `/var/sudoer-cli`) — tests only; production create remains Type 1 setup |
| **F4 view** | `/etc/sudoer-adm/sudoer-request` → public inbound |
| **Public queue root** | `/var/sudoer-cli` (sibling default) |
| **Legacy inbound names** | `…/sudoer-approving` — last-fallback only |
| **Queued basename (sibling allocator)** | `sudoer-{{YYYYMMDD}}-folder-backup-{{user}}-add-{{n}}.json` (or `update`) |
| **Worked sample basename** | `sudoer-20260815-folder-backup-{{USERNAME}}-add-1.json` |
| **Worked dest after approve** | `/etc/sudoers.d/folder-backup-{{USERNAME}}` |
| **Term** | `project-sudoers-file` · `sudoers-fragment` |
| **Whitelist meaning** | **Sudoers command allowlist** (narrow lines) — not server-maintenance ops registry |
| **Applied host record** | `docs/whitelists/external-sudoers/records/WS-20260803-001-folder-backup.md` |
| **Security review (example)** | `reviews/reports/2026-08-09-sudoers-security-folder-backup.md` (supersedes 2026-08-03 local-only Pass for production claims) |
| **Agent skill / checklist** | `SK-CREATE-SUDOERS-FILE` · `CL-CREATE-SUDOERS-SECURITY` (**S11–S12** elev tables when claimed; **S13** trust tier) |
| **Example fragment** | §2.3.4a (full text); live draft often `${HOME}/.config/folder-backup/sudoers.fragment-<user>` |
| **Test emit gate** | `--allow-test-local` or `ALLOW_TEST_LOCAL_SUDOERS=1` when tier ≠ production |
| **Global install for production** | `sudo sh src/folder-backup install` or root/`--global` → `/usr/local/bin/folder-backup` |

**Paired text dual + queued JSON** (same grant; sibling closed schema). `print-sudoers` JSON dual is pretty (`fb_sudoers_json_text`). Live submit default and `generate-sudoer-request` hand the **compact** dual (`fb_sudoers_json_text_compact`) so sibling convert keeps both verbs. `--json` CLI status from `submit-sudoer-request` is **not** the queued file.

**JSON body SSOT:** `requirement-sudoer-json-file` — grant is **`folder-backup` only** (`backup` / `restore`). **MUST NOT** encode `mkdir` / `cp` / `tar` / `rm` / `install` / `chmod` (or deposit/stage/archive-name operands) in the queued JSON. Complete add/update samples live on that peer.

**Worked add basename:** `sudoer-20260815-folder-backup-{{USERNAME}}-add-1.json`  
**Worked update basename:** `sudoer-20260815-folder-backup-{{USERNAME}}-update-1.json`

§2.3.4a remains the **legacy text-fragment** example (OS-tool deposit). That shape is **not** a valid dual of the JSON sudoer file. When emit is updated, the text dual **MUST** match `requirement-sudoer-json-file` §2.6 (`/usr/local/bin/folder-backup backup` and `restore` only).

**Admin install script (worked shape).** Live emit is `print-sudoers-install-script` → `/dev/shm/folder-backup-<user>-sudoers-admin.sh`. Complete verb skeleton (values filled for this product):

```sh
#!/bin/sh
# folder-backup — admin sudoers install / uninstall
# RUN: sudo sh /dev/shm/folder-backup-{{USERNAME}}-sudoers-admin.sh install|uninstall|replace|status
set -u
PROJECT_SUDOERS_FILE="${HOME}/.config/folder-backup/sudoers.fragment-{{USERNAME}}"
INSTALLED_SUDOERS="/etc/sudoers.d/folder-backup-{{USERNAME}}"
die() { printf '%s\n' "ERROR: $*" >&2; exit 1; }
require_root() { [ "$(id -u)" -eq 0 ] || die "Must run as root"; }
cmd_install() {
    require_root
    [ -f "${PROJECT_SUDOERS_FILE}" ] || die "missing draft"
    visudo -c -f "${PROJECT_SUDOERS_FILE}" || die "visudo -c draft"
    install -m 0440 -o root -g root "${PROJECT_SUDOERS_FILE}" "${INSTALLED_SUDOERS}"
    visudo -c -f "${INSTALLED_SUDOERS}" || die "visudo -c installed"
}
cmd_uninstall() { require_root; rm -f "${INSTALLED_SUDOERS}"; }
cmd_replace() { cmd_uninstall; cmd_install; }
cmd_status() { ls -la "${INSTALLED_SUDOERS}" "${PROJECT_SUDOERS_FILE}" 2>/dev/null || true; }
case "${1:-}" in
    install) cmd_install ;;
    uninstall) cmd_uninstall ;;
    replace) cmd_replace ;;
    status) cmd_status ;;
    *) printf '%s\n' "Usage: sudo sh $0 {install|uninstall|replace|status}"; exit 1 ;;
esac
```

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 9 – Three Types of Commands**  
- **Principle 10 – Least-Privilege User**  
- **Principle 1 – Caution**: Fail closed without working sudoers  
- **Principle 20 – Over-protect**: Do not collapse elevation into “just run as root” or `NOPASSWD: ALL`

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. You may still print a grant draft as yourself. **This requirement:** deposit `sudo` and `/etc` install stay unused on that class — fail closed instead of wrapping `sudo`.

| MUST | MUST NOT |
|------|----------|
| Keep your own login only | In-tool `sudo`; wrap `apt`/`dnf`; write `/etc`; create a dedicated system user |
| Fail closed if a host deposit would need admin privilege | Recommend `sudo curl \| sh` |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

**Implementation Notes:** ship unit has **no detect helper yet** (Gap). Linux with a root login remains the primary host.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Narrow allowlist; admin review gate; fail closed.  
- **Intentional:** Type 0 archive vs Type 1 deposit vs Type 0 print-sudoers are separate.  
- **Anti-fragile:** Clear operator path when elevation missing; draft outside `/etc`.  
- **Over-protect:** No unrestricted sudoers templates; security review before agent create.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Grant `ALL=(ALL) NOPASSWD: ALL` or equivalent in product-generated fragments.  
2. Auto-write `/etc/sudoers.d` from an unprivileged `print-sudoers` or agent draft path.  
3. Require root for tar creation of user-readable source trees.  
4. Introduce Type 2 system user without explicit product redesign.  
5. Use elevation for unrelated package installs or shell escapes.  
6. Store passwords or private keys in sudoers records, fragments, or requirements.  
7. Emit a **new** agent-authored fragment without **Pass** / **Pass (test only)** security review (`CL-CREATE-SUDOERS-SECURITY`).  
8. Broaden wildcards to entire `/tmp/*` or home-wide trees without redesign + review.  
9. Mark deposit success when elevated copy failed.  
10. Cite templates/skills as product-source behavioral authority (source cites **this** requirement and peers).  
11. Claim **production-secure** sudoers when only `${USER_BIN}/folder-backup` (user-rewritable) exists.  
12. Emit test_local fragments **without** TEST MODE warnings and uninstall-soon guidance.  
13. Elevate `${USER_BIN}/folder-backup` under a production Pass.  
14. `mkdir` the sibling production inbound (or its public parent) from this Type 0 CLI.  
15. Treat `/var/backup/folder-backup` (deposit) as the sudoer inbound.  
16. Probe **only** `{{approver-home}}/sudoer-approving` as the preferred real inbound when `/var/sudoer-cli/sudoer-request` is the public dest.  
17. Invent the queued JSON dest basename instead of calling the sibling allocator.  
18. Put `cp` / `mkdir` / `tar` / `rm` / `install` / `chmod` (or deposit/stage/archive-name operands) into the **JSON sudoer file** — that body is `requirement-sudoer-json-file` (`{{PRJ_NAME}}` only).  
19. Treat `[OK] Submitted` or checklist S14 Pass as proof the **inbound** `commands[]` still has `backup` and `restore`.  
20. Hide sudoer generate only inside `submit-sudoer-request` (no independent Type 0 subcommand).  
21. Treat inbound, `/etc`, or a deleted submit temp as the **review/test fixture** for a generated sudoer file. Tests and review **MUST** read an independent generate dest without sudo.  
22. Emit or install verb-only `NOPASSWD: … folder-backup backup` (no trailing `*`) when operate argv is `backup <source-folder>`.  
23. Blame “no TTY” or “folder-backup needs a terminal” when `sudo -n … backup <folder>` fails because the grant is verb-only.  
24. Treat `sudo -n … backup` with **no** folder operand as proof that deposit works.

**Violating this rule is a critical privilege regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Layer map documents Type 0 vs Type 1 deposit vs no Type 2 |
| AC-2 | `print-sudoers` does not write `/etc/sudoers.d` |
| AC-3 | Deposit fails closed without working allowlisted sudo |
| AC-4 | Generated fragment is narrow (no ALL ALL / NOPASSWD: ALL) |
| AC-5 | Admin install path and `visudo -c` + mode `0440` documented in human output or product docs |
| AC-6 | Fragment stage paths align with runtime storage resolve for the user (per-user roots) |
| AC-7 | With admin-installed allowlist, non-root `backup` can deposit via `sudo -n` (host-dependent proof) |
| AC-8 | Agent create path requires security review Pass / Pass (test only) before draft write |
| AC-9 | test_local emit requires allow flag/env; warnings present in human output and fragment header (**S13**) |
| AC-10 | production tier requires global managed binary; product docs prefer global before durable sudoers (**S13**) |
| AC-11 | `print-sudoers-install-script` refreshes project-sudoers-file, writes admin script under `/dev/shm` or temp only, supports install/uninstall/replace/status, never Type 0 `/etc` write |
| AC-12 | Agent/checklist: **S11–S12** when elev tables claimed; **S13** trust tier always for production claims |
| AC-13 | `remove-project-sudoers` deletes draft only; refuses `/etc`; confirm/`--force`; probes host path and warns when elev still active |
| AC-14 | Draft default and installed path include **user suffix**; multi-user installs do not share one `/etc/sudoers.d/folder-backup` basename |
| AC-15 | `remove-project-sudoers` with multiple drafts lists and chooses interactively; non-interactive requires explicit path |
| AC-16 | `submit-sudoer-request` detect order: env override → public `/var/sudoer-cli/sudoer-request` → F4 `…/sudoer-request` → optional legacy `sudoer-approving` |
| AC-17 | Submit **MUST NOT** `mkdir` inbound; missing dir fails closed with `sudo sudoer-cli setup` hint |
| AC-18 | Submit creates the queued artifact **only** by invoking sibling `add-sudoer-request` / `update-sudoer-request`; dest basename is sibling-allocated JSON under the public inbound |
| AC-19 | About reports sudoer-cli / sudoer-adm / inbound (path or `not_found`) and writable flag |
| AC-20 | Queued JSON **body** obeys `requirement-sudoer-json-file` (`{{PRJ_NAME}}` only; no OS-tool commands) |
| AC-21 | When inbound `${request_id}` is readable after submit, body still contains required elev verbs; emit-only / stub-`cp` tests do not satisfy this AC |
| AC-22 | Default submit action is **update** when this user’s `/etc/sudoers.d/{{APP_NAME}}-{{user}}` (or legacy unsuffixed) exists; else **add**. `--add`/`--update` override. Other users’ fragments do not count |
| AC-23 | `generate-sudoer-request` writes a local JSON grant with both verbs, refuses `/etc` and inbound, verifies the file (and sibling convert when `sudoer-cli` is present), and does not queue |
| AC-24 | **Any** sudoer generate is an independent Type 0 subcommand (§2.3.2a) that writes an invoking-user-readable dest (not `/etc`, not inbound, not a deleted temp). Suite/review `cat` that dest without sudo |
| AC-25 | `print-sudoers` text dual **MUST** contain `backup *` and `restore *`. Verb-only `… backup` / `… restore` lines **Fail**. `sudo -n {{GLOBAL_BIN}}/folder-backup backup <dir>` **MUST** be the intended NOPASSWD match (host proof after admin install) |
| AC-26 | Text dual **MUST** also contain `--json backup *` and `--json restore *`. JSON grant **MUST** include the matching `commands[]` objects (`requirement-sudoer-json-file` 1.4.0). Bare-verb Cmnd **MUST NOT** be treated as covering `--json`. |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-sudoer-json-file` | **JSON sudoer file** body SSOT (`{{PRJ_NAME}}` only; no OS-tool commands) |
| `requirement-folder-archive-backup` | Backup ops that invoke Type 1 deposit/verify |
| `requirement-domain-folder-backup` | Domain surface; submit-sudoer-request verb |
| `requirement-shell-cli-interface` | Command privilege labels (`backup`, `print-sudoers`, `submit-sudoer-request`) |
| `requirement-project-folder` | `/var/backup` deposit paths; config draft location |
| `requirement-shell-cli-storage` | Staging roots for Type 1 internals (not fragment operands) |
| `requirement-shell-output-requirements` | `out_*` for print-sudoers and deposit errors |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-FOLDER-BACKUP-01** | `tests/test_domain_folder_backup.sh` | have — print-sudoers emit; no Type 0 `/etc` write |
| **TP-FOLDER-BACKUP-02** | same | have — file draft; narrow content |
| **TP-FOLDER-BACKUP-05** | same | have — deposit fail-closed without working sudo |
| **TP-FOLDER-BACKUP-07** | same | have — elevated deposit (root **or** allowlisted `sudo -n`) |
| **TP-FOLDER-BACKUP-08** | same | have — next-N after elevated deposit |
| **TP-FOLDER-BACKUP-19** | same | have — submit fail-closed when sudoer-cli missing |
| **TP-FOLDER-BACKUP-20** | same | have — stub cli writes a file (env inbound override) |
| **TP-FOLDER-BACKUP-21** | same | have — detect prefers public inbound; Type 0 does not mkdir |
| **TP-FOLDER-BACKUP-21b** | same | have — `SUDOER_QUEUE_INBOUND` wins over public |
| **TP-FOLDER-BACKUP-22 / 22b / 22c** | same | **have** — JSON sudoer file body (`requirement-sudoer-json-file`) |
| **TP-FOLDER-BACKUP-22e / 22f** | same | **have** — pretty emit + inbound body fidelity (AC-21) |
| **TP-FOLDER-BACKUP-23 / 23b / 23c** | same | **have** — host fragment → update; `--add` override; other-user dest ignored |
| **TP-FOLDER-BACKUP-24 / 24b / 24c / 24d** | same | **have** — generate compact verified JSON; refuse `/etc`; convert keeps both verbs; dest readable without sudo |
| **TP-FOLDER-BACKUP-26 / 26b** | same | **have** — emit contains `backup *` / `restore *`; verb-only **Fail** (AC-25). Do not reuse TP-25 (operator-readable inbound errors). |
| **TP-FOLDER-BACKUP-27** | same | **todo** — compact JSON `--json` twins (AC-26). Text already has the four lines. |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active 1.0.0 | Privilege + basic sudoers fragment workflow for folder-backup |
| 2026-08-03 | Active 1.1.0 | Full **working with sudoers files** law: roles, content, admin install, fail-closed, agent security gate, RTM elev cases |
| 2026-08-03 | Active 1.1.1 | §2.3.4a **example sudoers fragment** (folder-backup deposit allowlist) |
| 2026-08-14 | Active 1.4.0 | `submit-sudoer-request` compose (§2.3.3c) |
| 2026-08-15 | Active 1.5.0 | Submit = JSON via sibling allocator into **public inbound** `/var/sudoer-cli/sudoer-request`; no Type 0 mkdir; legacy `sudoer-approving` last |
| 2026-08-15 | Active 1.6.0 | JSON sudoer file **body** deferred to `requirement-sudoer-json-file`; OS-tool JSON samples withdrawn |
| 2026-08-17 | Active 1.7.0 | Submit inbound fidelity §2.3.3c items 13–14; AC-21; INC-20260817-001 |
| 2026-08-17 | Active 1.8.0 | Submit default **update** when this user’s `/etc/sudoers.d` fragment exists; AC-22; TP-23 |
| 2026-08-17 | Active 1.8.1 | §2.3.4 / §2.3.4a example is `folder-backup` backup/restore only (OS-tool illustration withdrawn); TP-23c |
| 2026-08-17 | Active 1.9.0 | `generate-sudoer-request` §2.3.3d; submit compact handoff; AC-23; TP-24; INC-20260817-002 |
| 2026-08-17 | Active 1.10.0 | §2.3.2a independent generate (any sudoer generate = Type 0 subcommand → readable dest); AC-24; TP-24d |
| 2026-08-23 | Active 1.11.0 | Sudoers exact-argv: `backup *` / `restore *` required; verb-only withdrawn; AC-25; probe honesty |
| 2026-08-23 | Active 1.12.0 | `--json backup *` / `--json restore *` **MUST** (not SHOULD); JSON body dual on `requirement-sudoer-json-file` 1.4.0 |
| 2026-09-27 | Active 1.12.1 | Staging cache leaf is per login and per process (`requirement-shell-cli-storage` 1.4.0) |
| 2026-09-30 | Active 1.12.1 | Privilege paths stay off the network. Channel download is not a sudoers grant. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
