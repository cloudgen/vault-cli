**file**: docs/requirements/requirement-shell-cli-sudoers-submenu.md  
**Status**: Withdrawn (Version 1.1.1)  
**Area**: shell  
**Key**: `requirement-shell-cli-sudoers-submenu`  
**Optional RQ-ID**: `RQ-SHELL-CLI-SUDOERS-SUBMENU`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

**Withdrawn 2026-09-30.** The vault-cli client board is `list`, `add`, and `update` (`requirement-shell-cli-default-interaction`). It does not open a sudoers board. The body below is history.

This file was the **product Single Source of Truth** for folder-backup’s **sudoers board**: opened from client row **17**, listing only the operational grant/draft verbs, and keeping the test-purpose numbers reserved. The front, client, and self boards stay on `requirement-shell-cli-default-interaction`. JSON grant **body** stays on `requirement-sudoer-json-file`. Emit / submit **workflow** stays on `requirement-three-layer-privilege-model`.

This file exists so the sudoers board is a **named, transferable** product law — not a buried paragraph on the front-board requirement.

### 1.1 Human-facing

**In one sentence:** On a real terminal, open client-side and pick **17** to hand in a grant or remove a local draft; the three test commands stay typed, not numbered; typing `sudoers` as a command is unknown.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Open the grant board or type an operational verb | `folder-backup` then `1` then `17` |
| The other role | Scripts type the five names; they never hang on this board | `folder-backup generate-sudoer-request` |
| Not this file | Front, client, and self rows; empty argv; JSON grant body | `requirement-shell-cli-default-interaction` · `requirement-sudoer-json-file` |

| Includes | Excludes |
|----------|----------|
| Client family row **17** `sudoers` (menu-only) | `sudoers` as a typed command |
| Operational rows **172** and **175** | Test-purpose rows on this board |
| Reserved numbers **171**, **173**, **174** | Those numbers reused or compacted |
| **0** Back | Back **8** or Exit **9** on this board |
| One hide sentence for the test commands | Install / version / about on this board |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./src/folder-backup` | ship unit | live menu + live setup verbs |
| `folder-backup help` | command | listed setup verbs, test-purpose under their own heading |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Open grant/drafts | Operational rows only | `folder-backup` then `1` then `17` |
| Queue inbound | Same handler as row **172** | `folder-backup submit-sudoer-request` |
| Remove local draft | Same handler as row **175** | `folder-backup remove-project-sudoers` |
| Write a JSON grant | Typed command. Not a numbered row. | `folder-backup generate-sudoer-request` |
| Emit sudoers text | Typed command. Not a numbered row. | `folder-backup print-sudoers` |
| Write admin script | Typed command. Not a numbered row. | `folder-backup print-sudoers-install-script` |
| Step back to client-side | Back | `0` |
| Type the family name as a command | Unknown — not a command | `folder-backup sudoers` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Claim

1. This product **claims** a sudoers board under client-side.  
2. A claimed front board is required (`requirement-shell-cli-default-interaction`).  
3. **MUST NOT** hang off-TTY (this board exists only on the interactive menu path).

### 2.2 Family row

1. The family token **MUST** be `sudoers`. Explain **MUST** be `Grant and drafts`. The number **MUST** be client **17** (owned as a row by `requirement-shell-cli-default-interaction`).  
2. **`sudoers` is not a live CLI command.** Choosing **17** or typing `sudoers` at the **client** pick prompt **MUST** open this board. Typing `sudoers` at the **front** pick prompt **MUST** be an invalid choice on the front. `folder-backup sudoers` **MUST** remain unknown.  
3. **MUST NOT** list the five setup verbs on the **front** board or the **client** board.

### 2.3 Sudoers board — operational grant and drafts

Choosing client **17** / `sudoers` **MUST** print this board. Header **MUST** use the same `folder-backup(VERSION)` nametag. Title: `sudoers (grant and drafts)`. Explain text **MUST** follow the same default CLI main menu style as the other boards (short name bold; explain italic and light gray).

Print this hide sentence **before** the numbers (exact):

`Test commands stay off this list. Type generate-sudoer-request, print-sudoers, or print-sudoers-install-script. Numbers 171, 173, and 174 stay reserved.`

| # | Command | Label | Setup kind |
|---|---------|-------|------------|
| **171** | `generate-sudoer-request` | **reserved — not printed** | JSON grant (test-purpose) |
| 172 | `submit-sudoer-request` | `submit-sudoer-request: Hand the JSON grant to the approval queue` | Inbound queue |
| **173** | `print-sudoers` | **reserved — not printed** | sudoers text (test-purpose) |
| **174** | `print-sudoers-install-script` | **reserved — not printed** | Admin script (test-purpose) |
| 175 | `remove-project-sudoers` | `remove-project-sudoers: Remove the local grant draft only` | Remove draft |
| **0** | **Back** | return to the client board (not a command) | — |

- **0** / `back` / `Back` / empty line / EOF / `exit` / `quit` returns to the **client** board (does not run a handler, does not leave the whole menu).  
- A listed number or listed verb runs that handler, then returns to the **front** board (command finished).  
- **171**, **173**, and **174** **MUST** stay reserved. **MUST NOT** print those rows. **MUST NOT** compact **172** and **175** down to 1 and 2.  
- All five grouped verbs **MUST** remain live CLI verbs. Only **172** and **175** appear on this board.  
- **MUST NOT** put `install` / `version` / `about` / `help` / `menu` / `main` on this list.  
- Typing `submit-sudoer-request` or `remove-project-sudoers` at the **front** pick prompt **MUST** run that handler, then redisplay the front. Typing a test-purpose name at a menu prompt **MUST** be an invalid choice; those names run as argv commands.  
- Choice **MUST** be read in the **current shell**. **MUST NOT** `$()` a `read` helper.  
- Invalid text: `Not a menu choice '<pick>'. Type 172, 175, or 0, or a listed command name.`

### 2.4 Implementation Notes (this product)

| Item | Value |
|------|--------|
| **Product** | `folder-backup` |
| **Claimed** | yes |
| **Family token** | `sudoers` |
| **Family number** | client **17** |
| **Handler** | `app_cmd_menu_sudoers` |
| **Printed members** | `submit-sudoer-request` (**172**) · `remove-project-sudoers` (**175**) |
| **Reserved, not printed** | `generate-sudoer-request` (**171**) · `print-sudoers` (**173**) · `print-sudoers-install-script` (**174**) |
| **Choice read** | Current-shell `prompt_line` → `_prompt_line` |
| **Return** | leaf returns so the front redisplays; Back returns so the client board reprints |
| **Honesty** | **Implemented** |

**Invocation samples:**

```text
folder-backup generate-sudoer-request
folder-backup submit-sudoer-request
folder-backup print-sudoers
folder-backup print-sudoers-install-script
folder-backup remove-project-sudoers
```

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 2 – Intentional**: The grant board is a named law. Operators see the two verbs they run. Test commands stay typed.  
- **Principle 1 – Caution**: `sudoers` is never dispatched; scripts do not hang.  
- **Principle 21 – Dual policies**: Portable catalog of setup kinds; this product prints only the operational rows and reserves the rest.  
- **Principle 10 – Least privilege**: Print/submit stay Type 0 drafts; the menu never writes `/etc`.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** grant/draft setup verbs stay Type 0 drafts; this board **MUST NOT** install `/etc`.

| MUST | MUST NOT |
|------|----------|
| Print / generate JSON as this login | Wrap `sudo` from a menu pick |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Family token unknown; no hang off-TTY.  
- **Intentional:** Operational rows are explicit. Test-purpose numbers stay reserved.  
- **Anti-fragile:** Typed member verbs still run without the menu.  
- **Over-protect:** Test-purpose verbs stay off every numbered board; Back is **0**.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Wire `sudoers` as a live `app_main` command.  
2. Drop `submit-sudoer-request` or `remove-project-sudoers` from this board while they remain live.  
3. Put the five setup verbs on the **front** board, or put a test-purpose verb on this board.  
4. Number Back as anything other than **0**, print Exit **9** on this board, or reuse **171** / **173** / **174**.  
5. Hang off-TTY on this board’s path.  
6. Capture the choice with `$()` of a `read` helper.  
7. Auto-write `/etc` from a menu choice.  
8. Collapse this file back into `requirement-shell-cli-default-interaction` as the only owner.  
9. Compact **172** and **175** because the reserved rows are hidden.

**Violating this rule is a critical dispatcher / hang / transferability regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Client family row is **17** `sudoers: Grant and drafts` |
| AC-2 | Choosing **17** / `sudoers` at the client prompt opens this board with **172**, **175**, the test-command hide sentence, and **0** Back. Rows **171**, **173**, and **174** are not printed |
| AC-3 | `folder-backup sudoers` is unknown |
| AC-4 | The five names remain live CLI verbs |
| AC-5 | The five names are **not** front-board rows. The three test-purpose names are **not** on this board |
| AC-6 | Board nametag is live `folder-backup(VERSION)`; title is `sudoers (grant and drafts)` |
| AC-7 | Choice is current-shell `prompt_line` / `_prompt_line` |
| AC-8 | A finished **172** or **175** returns to the front board. **0** returns to the client board |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-default-interaction` | Front and client boards; **points** here for row **17** |
| `requirement-shell-cli-interface` | Dual mention: five setup verbs remain routed |
| `requirement-domain-folder-backup` | Domain catalog of those verbs; help apart; test-purpose off numbered boards |
| `requirement-sudoer-json-file` | JSON grant **body** |
| `requirement-three-layer-privilege-model` | Emit / submit **workflow** |
| `requirement-shell-interactive-vs-noninteractive` | `TTY`; no hang |
| `requirement-shell-output-requirements` | `out_menu_choice` |
| `docs/requirements/index.md` | Registry |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-CLI-13** | `tests/test_cli.sh` | **have** — client **17**, rows **172**/**175**, hide sentence, no **171** row, Back **0**, `sudoers` unknown, members live (AC-1–AC-5) |
| **TP-CLI-16** | same | **have** — grant verbs off the **front** board (AC-5) |
| **TP-CLI-18** | same | **have** — sudoers title and bold short name (AC-6) |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-09-03 | Active 1.0.0 | Dedicated sudoers-submenu SSOT; five setup kinds on the second board; Back 8 / Exit 9 |
| 2026-09-30 | Active 1.1.0 | Opened as client **17**. Printed rows **172** and **175** only. **171**/**173**/**174** reserved. Back **0**. A leaf returns to the front |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
