**file**: docs/requirements/requirement-shell-cli-default-interaction.md  
**Status**: Active (Version 1.10.0)  
**Area**: shell  
**Key**: `requirement-shell-cli-default-interaction`  
**Optional RQ-ID**: `RQ-SHELL-CLI-DEFAULT-INTERACTION`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for vault-cli’s **claimed default interactive main menu**.

Channel verbs exist (`self-install`, `version-check`, `self-update`, `self-uninstall`, `self-management`). **`self-update` replaces this program.** It is not the vault edit verb. **Case 2** applies to the **interactive** zero-cli-verb: on a real terminal, with quiet and json off, a bare `vault-cli` run opens the numbered boards. A **non-interactive** zero-cli-verb (no TTY, or `--quiet` / `--json` with no command) is CLI self-install, owned by **`requirement-shell-cli-zero-arguments`**. This file does not replace that path. Named commands **`menu`** and **`main`** open the same boards. Off a terminal those named commands stop: `menu needs a terminal`. Client rows are **`list`**, **`add`**, and **`update`**. Verb behavior is **`requirement-domain-vault-cli`**.

### 1.1 Human-facing

**In one sentence:** At a real terminal, type `vault-cli` with no command to see numbered boards — client-side, self-management, and Exit — with server-side hidden; pick **1** then **13** to edit a vault. A pipe with no command places this program (`requirement-shell-cli-zero-arguments`). Naming `menu` off a terminal stops.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the boards or pick a number | `vault-cli` then `1` |
| The other role | Scripts and CI must not hang on those boards | `vault-cli </dev/null` places this program |
| Not this file | Full command catalog, flags, unknown tokens | `requirement-shell-cli-interface` |

| Includes | Excludes |
|----------|----------|
| Front rows **1** client-side, **8** self-management, **9** Exit | A printed server-side row |
| One hide sentence before the numbers: server-side stays reserved | An empty server loop |
| Client rows **11** list, **12** add, **13** update, **0** Back | Restarting a child board at **1** |
| Self rows **81**–**87** and **0** Back, including **85** `self-update` | `help`, `menu`, `main`, or `edit` as a choice |
| Bare run on a real terminal | Install-ensure on an interactive empty argv |
| `menu` / `main` as the same boards | Vault `update` on the self board |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/vault-cli` | ship file | client rows **11** list / **12** add / **13** update |
| `vault-cli help` | command | listed verbs including lifecycle |
| `vault-cli` | empty argv | numbered boards on a real terminal |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open the boards at a prompt | The program prints **vault-cli**(*live version*) then the front board. On a real terminal the name is bold, the version italic, each short name is bold, and each “what it does” line after the colon is italic and light gray. `--json` on `menu`/`main` is ignored on a real terminal. | `vault-cli` or `vault-cli menu` |
| List vault names | Client row **11**. A finished pick returns to the front board. | `1` then `11` |
| Add a vault | Client row **12**, then one field at a time (`requirement-domain-vault-cli`). | `1` then `12` |
| Edit a vault | Client row **13** runs `update`. It does not run `self-update`. | `1` then `13` |
| Install, version, or replace this program | Front row **8**. Local copy is **81**. Channel refresh is **85** `self-update`. Channel place is **87**. | `8` then `85` |
| Step back one board | Back on a child board | `0` |
| Leave the menu | Exit on the front board | `9` |
| Run a bare invocation in CI | No prompt. The program places itself. | `vault-cli </dev/null` |
| Name the menu in a script | The program stops. The next step is help. | `vault-cli menu </dev/null` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim and case

1. This product **claims** a default interactive main menu.  
2. **Case 2** applies to the **interactive** zero-cli-verb. The non-interactive zero-cli-verb is **`requirement-shell-cli-zero-arguments`** (`inst_self_install`).  
3. This file **owns the numbered boards**. It does not own a pipe with no command.  
4. An interactive zero-cli-verb (`TTY=1`, `JSON=0`, `QUIET=0`, no verb after switches) **MUST** open the numbered boards (`app_cmd_menu`). It **MUST NOT** place the program.  
5. A non-interactive zero-cli-verb **MUST NOT** draw these boards and **MUST NOT** be help. That route is `inst_self_install`.  
6. `--json` or `--quiet` with **no command token** is a non-interactive zero-cli-verb (self-install), including on a terminal.  
7. Routed-verbs **`menu`** and **`main` MUST** call the same handler. They remain valid ways to open the boards.  
8. `app_main` **MUST** route `menu` / `main` to `app_cmd_menu`. `app_main_menu` **MAY** remain a one-line alias of `app_cmd_menu`.  
9. `requirement-shell-cli-zero-arguments` **MUST** stay **Active** and own the non-interactive zero-cli-verb.

### 2.2 Mode check

Measure interactive capability **outside functions** (`TTY=1` only when stdin and stdout are terminals). Helpers consume `TTY` (`requirement-shell-interactive-vs-noninteractive`).

| Invocation | Mode | `--json` | MUST | MUST NOT |
|------------|------|----------|------|----------|
| `vault-cli` (no command) | Interactive (`TTY=1`, not quiet, not json) | off | Draw the numbered boards | Help; hang; place |
| `vault-cli` (no command) | Non-interactive (`TTY=0`, or quiet, or json) | follows the switch | **CLI self-install** (`requirement-shell-cli-zero-arguments`) | Draw the menu; hang; help |
| Flags only, no command (`--debug` / `--force`) | Interactive | off | Draw the numbered boards | Place; help |
| Flags only, no command (`--quiet` / `--json`) | Any | on | CLI self-install | Draw the menu; JSON help |
| `vault-cli menu` or `main` | Interactive (`TTY=1`) | **Ignore** | Draw the numbered boards | Treat as JSON help; hang |
| same | Non-interactive (`TTY=0`) | error when JSON=1 | **Stop**: `menu needs a terminal. Next: vault-cli help` (exit 1; JSON error when JSON=1) | Draw the menu; hang; print help; exit 0 |
| `vault-cli self-management` | Interactive (`TTY=1`) | **Ignore** while drawing | Draw the self board only (§2.3.3) | Draw the front board; hang |
| same | Non-interactive (`TTY=0`) | error when JSON=1 | **Stop**: `self-management needs a terminal. Next: vault-cli help` | Draw the self board; hang; print help |

While a board is **drawing**, saved `JSON` and `QUIET` **MUST** be forced off, then restored before a leaf runs. That force applies only when `TTY=1`. Named `menu` / `main` / `self-management` off a terminal **MUST** `out_die`. A zero-cli-verb `--quiet` or `--json` is self-install, not that stop. Interactive `menu --json` still draws.

### 2.3 Boards

0. **Look (mandatory):** every numbered board **MUST** use the default CLI main menu style. Header **MUST** print live `vault-cli(VERSION)` (no space; same Config scalars as `version`) then the board title. On a TTY the name is **bold** and the version *italic*. Each numbered short name **MUST** be **bold** (SGR **1**). Each numbered `explain` **MUST** be *italic* and light gray (SGR **3** + **37**). The number stays unstyled. **Exit** and **Back** have no explain and stay unstyled. Off-TTY / JSON: **plain** — **MUST NOT** emit CSI. Typical helpers: `util_app_ident` then `out_menu_choice`. **MUST NOT** a bare `vault-cli` on that header. **MUST NOT** print `explain` unstyled on a TTY. **MUST NOT** print the short name unstyled on a TTY.  
1. The front board title **MUST** be `numbered list`.  
2. **Parent-prefix integers.** Child boards **MUST NOT** restart at **1**. Hidden numbers **MUST NOT** be compacted.  
3. Printed command-row text **MUST** be `short-descript: explain`. Routed leaves use the human-readable lines in this file’s tables (they match `requirement-domain-vault-cli` and the self-managed rows below). Category rows (`client-side`, `self-management`) use this file’s table.  
4. A choice **MUST** be read in the **current shell**. Typical: `prompt_line "Choice"` then `_pick="${_prompt_line}"`. **MUST NOT** `_pick=$(prompt_line …)` / `_pick=$(prompt_ask …)` / `$()` / backticks of **any** function whose body contains `read` (do-not-capture-read / **PP-A-22**). stderr+$() is **not** a license.  
5. An invalid choice **MUST** use `out_error` (not `out_die`, not `out_warn`) and **MUST** reprint **this** layer.  
6. **0** / `back` / `Back` / empty line / EOF on a **child** board is **Back** to the parent. `exit` / `quit` on a child board is the same Back. Child boards **MUST NOT** print Exit **9** and **MUST NOT** print Back **8**.  
7. Front Exit is **9**, **99**, `exit`, `quit`, `q`, an empty line, or EOF, and returns 0. `q` on a **child** board is Back.  
8. After a valid leaf opened from the front (or from a child of the front), the front board **MUST** redisplay. **MUST NOT** exit the menu on success. **MUST NOT** stay on the launching child board. A leaf that calls `out_die` still ends the process. A missing required vault field prints `Next:` and the front redisplays.  
9. Typing a **listed leaf verb** at the front pick prompt **MUST** run that leaf, then redisplay the front. Typing `edit` at the front **MUST** run `update` (same handler), then redisplay the front. Typing `self-update` at the front **MUST** be invalid (open **8**, then **85**). Typing a child number on the wrong layer **MUST** be invalid.  
10. **`edit` is not a menu row.** It is the argv alias of `update`. Kind pickers and vault pickers inside `add` / `update` print **0** Back and reprint on a bad token (`requirement-domain-vault-cli`). They **MUST NOT** `out_die`.

#### 2.3.1 Front board

Print the hide sentence **before** the numbers, then the rows below. Row **2** is **not** printed. Typing **2** is an invalid-choice retry. **MUST NOT** add `app_cmd_menu_server`.

Hide sentence (exact): `server-side is hidden: this program does not run a host service. Number 2 stays reserved.`

| # | Token | Label |
|---|-------|-------|
| *(header)* | — | `**vault-cli**(*VERSION*) — numbered list` |
| *(hide)* | — | server-side sentence above |
| 1 | category `client-side` | `client-side: this login's vaults: list, add, and edit` |
| 8 | category `self-management` | `self-management: this CLI install, version, update, uninstall` |
| **9** | **Exit** | leave the menu |

Front rows **MUST NOT** be `help`, `menu`, `main`, `uninstall`, `where-is-me`, `list`, `add`, `update`, `edit`, or `self-update`. Channel verbs and diagnostics are board **8**, not front rows. Invalid front text: `Not a menu choice '<pick>'. Type 1, 8, or 9, or a listed name.`

#### 2.3.2 Client board (front **1**)

Header title: `client-side`.

| # | Token | Label |
|---|-------|-------|
| 11 | `list` | `list: Show ssh-vault, github-vault, and cloudflare-vault names without secrets` |
| 12 | `add` | `add: Add one ssh-vault, github-vault, or cloudflare-vault` |
| 13 | `update` | `update: Edit one existing ssh-vault, github-vault, or cloudflare-vault` |
| **0** | **Back** | return to the front board |

Typing `edit` **on this board** **MUST** run `update`. It **MUST NOT** add a row **14**. A list, add, or update leaf returns to the **front**. When `add` or `update` needs a kind or a vault name, the picker rules in `requirement-domain-vault-cli` apply (item numbers **1…N**, **0** Back, bad token reprints, **MUST NOT** `out_die`). Invalid client text: `Not a menu choice '<pick>'. Type 11, 12, 13, or 0, or a listed command name.`

#### 2.3.3 Self board (front **8**, and verb `self-management`)

Header title: `self-management`. This product is **dual** place: local copy and channel place are both shown. Labels are the kept-list human-readable explains.

| # | Token | Label |
|---|-------|-------|
| 81 | `install` | `install: Copy this program into your bin or /usr/local/bin` |
| 82 | `version` | `version: Show version and detailed diagnostics (about)` |
| 83 | `about` | `about: Show diagnostics including vault root and vault counts` |
| 84 | `version-check` | `version-check: Compare this version with the channel` |
| 85 | `self-update` | `self-update: Replace the placed binary from the channel` |
| 86 | `self-uninstall` | `self-uninstall: Remove the channel-placed binary` |
| 87 | `self-install` | `self-install: Copy this file, or download it when the shell is a pipe` |
| **0** | **Back** | return to the caller |

`uninstall` and `where-is-me` stay **typed commands**. Their absence is **not** a hide cause (no hide sentence on this board). **81** is the local copy. **85** is `self-update` (replace this program from the channel). **87** is the channel place. **86** is channel remove, not local `uninstall`. On this board, row **82** and a typed `version` **MUST** run `app_about`. Argv `vault-cli version` stays `app_version` (the thin version line). Row **83** also runs `app_about`. Row **85** **MUST NOT** call `vc_update`.

Opened from the front, Back **and** a finished leaf both return to the front. Opened as the argv verb `self-management`, the self board is the whole session: a leaf runs and the verb ends; Back ends the verb; the front board is not opened. Handler: `app_cmd_menu_self`. `app_default_self_loop` saves JSON and QUIET, and on a terminal calls `app_cmd_menu_self`. Off a terminal it stops with `self-management needs a terminal`. Invalid self text: `Not a menu choice '<pick>'. Type 81-87, 0 back, or a listed command name.`

### 2.4 No sudoers board

The client board **MUST NOT** print row **17**. `requirement-shell-cli-sudoers-submenu` is **Withdrawn**. `vault-cli sudoers` **MUST** be an unknown command.

### 2.5 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `vault-cli` |
| **Claimed** | yes |
| **Case** | **2** for the interactive zero-cli-verb. Non-interactive place is `requirement-shell-cli-zero-arguments` |
| **Empty argv owner** | **Split.** This file: interactive boards. Zero-arguments: non-interactive `inst_self_install` |
| **Menu verbs** | empty argv on TTY; `menu` (preferred named); `main` alias |
| **Handlers** | `app_cmd_menu` · `app_cmd_menu_client` · `app_cmd_menu_self` |
| **Aliases** | `app_main_menu` → `app_cmd_menu`; `app_default_self_loop` → `app_cmd_menu_self`; argv `edit` → `vc_update` |
| **Client rows** | **11** `list` · **12** `add` · **13** `update` |
| **Ship unit** | `src/vault-cli` prints client rows **11** list, **12** add, and **13** update. |
| **Kept list** | `reviews/cli-routed-verb-table.md` |
| **Look** | Default CLI main menu style — header `vault-cli(VERSION)`; TTY bold short name; TTY italic + light-gray explain; `out_menu_choice` / `util_app_ident` |
| **Choice read** | Current-shell `prompt_line` → `_prompt_line` (not `$()`) |
| **Front** | **1** / **8** / **9**; number **2** reserved and hidden |
| **Exit** | **9** on the front only |
| **Back** | **0** on child boards |
| **Test-purpose (this product)** | none |
| **Typed-only (not a hide cause)** | `uninstall`, `where-is-me` |
| **Zero-cli-verb peer** | `requirement-shell-cli-zero-arguments` (Active) |
| **Honesty** | Client rows **11**/**12**/**13** and the front client-side explain match `src/vault-cli`. Self board **81**–**87** matches the dispatcher, including row **85** `self-update`. |

**Normative front draft** (README / this fence use markdown emphasis; the live TTY uses SGR, never paste CSI here):

```text
[INFO] **vault-cli**(*VERSION*) — numbered list
[INFO] server-side is hidden: this program does not run a host service. Number 2 stays reserved.
1. **client-side**: *this login's vaults: list, add, and edit*
8. **self-management**: *this CLI install, version, update, uninstall*
9. Exit
```

Client board (after **1**):

```text
[INFO] **vault-cli**(*VERSION*) — client-side
11. **list**: *Show ssh-vault, github-vault, and cloudflare-vault names without secrets*
12. **add**: *Add one ssh-vault, github-vault, or cloudflare-vault*
13. **update**: *Edit one existing ssh-vault, github-vault, or cloudflare-vault*
0. Back
```

**Invocation samples (CI-M1a):**

```text
vault-cli
vault-cli menu
vault-cli main
vault-cli menu --json
vault-cli self-management
vault-cli list
vault-cli add ssh-vault --name NAME --key-file ./id_ed25519
vault-cli update github-vault --login LOGIN --token-id TOKENID --token-file ./token
vault-cli edit cloudflare-vault --account-id ACCOUNT --token-file ./token
```

On a real terminal the first three **MUST** show the front board. `vault-cli menu --json` on a real terminal **MUST** still show the front board. `vault-cli self-management` on a real terminal **MUST** show the self board and **MUST NOT** show the front board first. Off a terminal, `vault-cli` with no command **MUST** place the program. Off a terminal, `vault-cli menu` and `vault-cli self-management` **MUST** stop (`menu needs a terminal` / `self-management needs a terminal`, exit 1). `vault-cli --json` with no command **MUST** place the program. `vault-cli menu --json` off a terminal **MUST** be a JSON error, not JSON help. An empty line on the front **MUST** leave. Row **82** and a typed `version` on a board **MUST** run `about`. Row **13** and a typed `update` **MUST** run `vc_update`. A typed `edit` **MUST** run that same handler and **MUST NOT** be a numbered row. `vault-cli sudoers` **MUST** fail as unknown.

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: Empty argv has one owner (this file, case 2). Daily vault work is client-side (`list`, `add`, `update`). This program’s own place and channel refresh is self-management (`self-update` is row **85**). There is no host service, so server-side stays reserved.  
- **Principle 1 – Caution**: Scripts do not hang. A pipe with no command places the CLI. An interactive line does not.  
- **Principle 16 – Interactive vs non-interactive**: TTY vs pipe is explicit.  
- **Principle 10 – Least privilege**: Vault rows do not wrap sudo. `self-update` stays on board **8**.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** the numbered boards show list, add, and update; picking them **MUST NOT** wrap `sudo`.

| MUST | MUST NOT |
|------|----------|
| Numbered boards as this login | Hang; wrap sudo to place this program |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

**Implementation Notes:** ship unit has **no detect helper yet** (Gap).

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Do not hang off-TTY. Do not place on an interactive zero-cli-verb. Do not print help for a non-interactive zero-cli-verb.  
- **Intentional:** Case 2; labels from the kept list; domain categories use parent-prefix numbers.  
- **Anti-fragile:** `menu` / `main` open the same boards as a bare TTY run; Back **0** returns to the parent; a finished leaf redisplays the front.  
- **Over-protect:** Test-purpose verbs stay off every numbered board; front Exit is **9**; child Back is **0**; number **2** stays reserved.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Route a non-interactive zero-cli-verb to help, or withdraw `requirement-shell-cli-zero-arguments`.  
2. Place the program on an interactive zero-cli-verb, or call `inst_local_install` from that line.  
3. Invent menu labels instead of `command: what it does` from the kept list (category rows use this file’s table).  
4. Put `help`, `menu`, `main`, `uninstall`, `where-is-me`, or `edit` on any numbered board.  
4b. Put `list`, `add`, `update`, or `self-update` on the **front** board.  
4c. Reopen a sudoers board or client row **17**. `requirement-shell-cli-sudoers-submenu` is Withdrawn.  
4d. Print a server-side row, or add `app_cmd_menu_server`, while this program has no host service.  
5. Restart a child board at **1**, compact a hidden number, number front Exit as anything other than **9**, or print Back **8** / Exit **9** on a child board. Child Back **MUST** be **0**.  
6. Draw the menu on a non-interactive zero-cli-verb, or on off-TTY `menu` / `self-management`. Off-TTY named menu **MUST** stop; it **MUST NOT** print help.  
7. Treat interactive `vault-cli menu --json` as JSON help.  
7b. Send row **82** or a typed `version` on a numbered board to the thin `app_version` line. Argv `version` stays that thin line.  
7c. Treat an empty line on the front as an invalid choice. Empty on the front is Exit.  
8. Drop `menu`/`main` routing after attaching the boards to empty argv.  
9. Auto-write `/etc` from a menu choice (print/submit stay Type 0 drafts).  
10. Claim the ship unit lacks the TTY empty-argv menu while `app_main` routes empty argv to `app_cmd_menu`.  
11. Capture the menu choice (or extra field) with `$()` / backticks of a `read` helper, or “fix” a freeze by stderr+$() (**PP-A-22** / do-not-capture-read).  
12. Print a board header as a bare `vault-cli` without live `VERSION`, or unstyled on a TTY.  
13. Draw a numbered board off the default CLI main menu style — short name **MUST** be bold on a TTY; `explain` **MUST** be *italic* and light gray. **MUST NOT** emit CSI off-TTY.  
14. Wire row **13** to `self-update`, or wire row **85** to `vc_update`.  
15. Exit the menu after a successful leaf, or stay on the child board that launched it, when the operator entered from the front.  
16. Treat `uninstall` / `where-is-me` absence from the self board as a hide cause.

**Violating this rule is a critical dispatcher / hang / honesty / look regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | A non-interactive zero-cli-verb does not draw these boards (place is `requirement-shell-cli-zero-arguments`) |
| AC-2 | Case 2 recorded for the interactive line; `menu` / `main` named and routed to `app_cmd_menu` |
| AC-3 | Interactive empty argv **and** interactive `menu` draw the front board: hide sentence, **1** client-side, **8** self-management, **9** Exit; row **2** is not printed |
| AC-4 | Interactive `menu --json` still draws the front board |
| AC-5 | Non-interactive `menu` / `main` / `self-management` exit 1 with `needs a terminal` (JSON error when `--json`). `--json` **with no command** is self-install, not JSON help |
| AC-6 | No numbered board lists `help`, `menu`, `main`, `uninstall`, `where-is-me`, or `edit`. The front board does not list `list`, `add`, `update`, or `self-update` |
| AC-7 | Leaf labels match kept-list human-readable `verb: explain`; category explains are this file’s tables |
| AC-8 | TTY header is live `vault-cli(VERSION)` with bold name and italic version; short name is bold; numbered `explain` is italic and light gray; number, Exit, and Back stay unstyled; no CSI off-TTY |
| AC-9 | Menu choice is current-shell `prompt_line` / `_prompt_line`; **MUST NOT** `$()` a `read` helper |
| AC-10 | Client **1** lists **11** `list` / **12** `add` / **13** `update` / **0** Back. Self **8** lists **81**–**87** and **0** Back. Row **85** is `self-update`. |
| AC-11 | `vault-cli sudoers` is unknown. Typing `edit` runs `update` and is not a numbered row. Typing `self-update` on the front is invalid. |
| AC-12 | A finished leaf redisplays the front board. An invalid child number reprints the front board. Typing **2** is an invalid retry. An empty line on the front leaves |
| AC-13 | Row **82** and a typed `version` on a board run `about`. Argv `vault-cli version` stays the thin version line |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-zero-arguments` | **Active** owner of the non-interactive zero-cli-verb (`inst_self_install`) |
| `requirement-shell-cli-interface` | Dual mention: empty argv row + `menu` / `main` + self board on the command table |
| `requirement-shell-interactive-vs-noninteractive` | `TTY`; no hang |
| `requirement-shell-output-requirements` | `out_*`; bold short name; reuse `app_help` |
| `requirement-shell-local-self-management` | `install` is self row **81**; `uninstall` / `where-is-me` stay typed |
| `requirement-domain-vault-cli` | `list` / `add` / `update`; kind picker and vault picker |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-07** | `tests/test_cli.sh` | **have** — off-TTY empty argv places the CLI, not these boards (AC-1) |
| **TP-CLI-13** | `tests/test_cli.sh` | **have** — client board **11** list / **12** add / **13** update / **0** Back, no row **17** (AC-3 / AC-10 / AC-11) |
| **TP-CLI-14** | same | **have** — interactive `menu --json` still prints the front board (AC-4) |
| **TP-CLI-15** | same | **have** — non-interactive `menu` and `self-management` stop (`needs a terminal`, exit 1) (AC-5) |
| **TP-CLI-23** | same | **have** — `--json` / `--quiet` with no verb place; TTY `--debug` draws the front (AC-5 / AC-3) |
| **TP-CLI-16** | same | **have** — front shows **8** self-management and omits verb rows that belong on a child board (AC-6) |
| **TP-CLI-18** | same | **have** — ink rules in AC-8; header is `vault-cli(VERSION)`; client short name `list` is bold |
| **TP-CLI-19** | same | **have** — child number **12** on the front is invalid and the front reprints (AC-12) |
| **TP-CLI-21** | same | **have** — empty Enter leaves the front; row **82** and typed `version` run `about`; the front reprints (AC-12 / AC-13) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-23 | Active 1.0.0 | Case 3 claimed; menu/main Gap; nine-row list; Exit 99 |
| 2026-08-23 | Active 1.1.0 | Colon labels; exclude version/about; test-purpose print-sudoers / generate-sudoer-request / print-sudoers-install-script; N=4 Exit 9 |
| 2026-08-23 | Active 1.2.0 | Ship unit routes `menu` / `main`; Gap closed; empty argv stayed help (case 3) |
| 2026-08-28 | Active 1.3.0 | **Case 2**: TTY empty argv = numbered list; off-TTY empty argv = help; zero-arguments Withdrawn |
| 2026-09-03 | Active 1.4.0 | Default CLI main menu style (header nametag + TTY gray italic explain); do-not-capture-read MUST; **TP-CLI-18** |
| 2026-09-03 | Active 1.5.0 | Family row **sudoers** + submenu (five grant/draft setup verbs remain live CLI commands; Back 8 / Exit 9); main **N = 3**; `sudoers` not dispatched |
| 2026-09-03 | Active 1.6.0 | Submenu **body** moved to **`requirement-shell-cli-sudoers-submenu`**; this file keeps the family row on the start list |
| 2026-09-30 | Active 1.6.1 | Channel verbs are live and stay off the flat list. Case 2 still owns empty argv. |
| 2026-09-30 | Active 1.7.0 | Hierarchical boards: front **1** / hidden **2** / **8** / **9**; client **11**/**12**/**17**; self **81**–**87**; child Back **0**; finished leaf redisplays the front; short name bold |
| 2026-09-30 | Active 1.8.0 | Non-interactive zero-cli-verb moves to `requirement-shell-cli-zero-arguments` (self-install). This file keeps the interactive boards. Named `menu` off-TTY stays help. |
| 2026-09-30 | Active 1.9.0 | Named `menu` / `main` / `self-management` off a terminal stop (`needs a terminal`). Empty Enter on the front leaves. Row **82** and a typed `version` on a board run `about`. Argv `version` stays the thin line. Interactive `menu --json` still draws. |
| 2026-09-30 | Active 1.10.0 | Product vault-cli. Client board is **11** list / **12** add / **13** update / **0** Back. `edit` aliases `update` and is not a row. Row **85** stays `self-update`. No sudoers board. Client rows are Gap on `src/folder-backup`. |
| 2026-09-30 | Active 1.10.0 | Client rows **11**/**12**/**13** and the front client-side explain are on `src/vault-cli` **1.0.0**. **TP-CLI-13** and **TP-CLI-18** have. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
