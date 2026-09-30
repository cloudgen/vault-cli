**file**: docs/requirements/requirement-operator-readable-error.md  
**Status**: Active (Version 1.0.0)  
**Area**: shell  
**Key**: `requirement-operator-readable-error`  
**Optional RQ-ID**: `RQ-OPERATOR-READABLE-ERROR`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **product Single Source of Truth** for **operator-facing error wording** on folder-backup.

Every blocking `[ERROR]` **MUST** be understandable to a person at the prompt: **what happened**, **what it means**, and **what to do next** — the same concreteness as a human-intro page. Channel ownership stays on `requirement-shell-output-requirements`. Fail-fast vs degrade stays on that peer’s `out_die` contract plus product fail-closed rules. This file owns **copy**.

### 1.1 Human-facing

**In one sentence:** When this program stops with `[ERROR]`, the line names what went wrong and the next `folder-backup` command — not an internal jargon token.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Read the error and type the next command | `folder-backup generate-sudoer-request` |
| The other role | Scripts parse the same sentence in JSON `message` | `folder-backup --json …` |
| Not this file | Which printer function emits the line | `requirement-shell-output-requirements` |

| Includes | Excludes |
|----------|----------|
| What happened + next step | A fatal that is only `sibling re-encode` |
| JSON `message` matching the human sentence | Dropping a fail-closed check to sound nicer |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/folder-backup` | ship unit | live `out_die` text |
| `folder-backup generate-sudoer-request /etc/x` | command | worked `/etc` refuse |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Hit a blocked submit | The line names incompleteness and the generate command. | read `[ERROR]`; then `folder-backup generate-sudoer-request` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Sacred shape

Every fatal `out_die` / blocking `out_error` **MUST** include:

| Slot | Required | This product |
|------|----------|--------------|
| **What happened** | yes | One concrete sentence |
| **What it means** | SHOULD | Restate if the first sentence uses an internal noun |
| **What to do next** | yes | A `folder-backup` command, `sudo …`, or “ask an admin” |
| **Do not** | when dangerous | e.g. do not approve a named request file |

JSON `message` **MUST** be that same sentence.

### 2.2 Forbidden as the whole message

**MUST NOT** ship a blocking error whose only text is:

| Token | Replace with |
|-------|----------------|
| `inbound grant` | “queued sudo request” / the file name |
| `backup verb` / `restore verb` | “allows backup” / “allows restore” |
| `sibling re-encode` | “the approval CLI rewrote the request” **after** the operator sentence, or omit |
| Incident IDs alone | Operator sentence first |

### 2.3 Fail-closed honesty

1. **MUST NOT** remove inbound-fidelity, trust-tier, or dest-refuse checks to pass §2.1.  
2. If a request file was already queued, the error **MUST** name it and say **do not approve**.  
3. Purpose text and `[OK]` are **not** completeness.

### 2.4 Printer

**MUST** still use `out_die` / `out_error` (`requirement-shell-output-requirements`). Quiet still shows errors.

### 2.5 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `folder-backup` |
| **Ship unit** | `src/folder-backup` |
| **Printer** | `out_die` / `out_error` |
| **Worked inbound miss** | `Queued sudo request is incomplete: it allows restore but not backup. Do not approve <id>. … generate-sudoer-request` |
| **Worked generate `/etc`** | `generate-sudoer-request refuses to write under /etc (your own login). Use a path under your home or /dev/shm.` |
| **Banned as whole message** | `sibling re-encode?` · `inbound grant lost … verb` |
| **Class** | software-development — this wording law is required |

### 2.6 Why This Requirement Exists (CIAO)

- **Principle 1 – Caution**: Fail loud; tell the person the next command.  
- **Principle 2 – Intentional**: Wording SSOT is explicit.  
- **Principle 5 – Output SSOT**: Still `out_*`.  
- **Stay-honest**: Do not pretend `[OK]` or purpose text completed the grant.

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** error copy only — **MUST NOT** tell the operator to `sudo curl | sh` or wrap `sudo` as the next step on that class.

| MUST | MUST NOT |
|------|----------|
| Next step is a `folder-backup` command or “ask an admin” | Recommend `sudo curl \| sh` |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Keep fail-closed.  
- **Intentional:** Three slots on every blocking error.  
- **Anti-fragile:** JSON `message` equals human text.  
- **Over-protect:** Do not “simplify” by dropping the check.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Restore jargon-only inbound errors (`inbound grant lost backup verb (sibling re-encode?)`).  
2. Remove inbound-fidelity or dest-refuse to sound friendlier.  
3. Duplicate `out_*` channel law here.  
4. Give `--json` a different story than `[ERROR]`.  
5. Treat a docs page as a substitute for fixing the CLI line.

**Violating this rule is an honesty / operator-UX regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Representative fatal inbound-fidelity error names incompleteness in operator words |
| AC-2 | That error names a next command (`generate-sudoer-request`) |
| AC-3 | That error does not contain `sibling re-encode` as the explanation |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-output-requirements` | Printer / channels |
| `requirement-three-layer-privilege-model` | Submit / generate fail-closed |
| `requirement-sudoer-json-file` | Grant body |
| `requirement-class-software-dev` | Class residual points here |
| `docs/requirements/index.md` | Registry |
| `./src/folder-backup` | Implementation |

---

## Design-time verification

| TP family / ID | Suite | Status |
|----------------|-------|--------|
| **TP-FOLDER-BACKUP-25** | `tests/test_domain_folder_backup.sh` | **have** — inbound-fidelity error is operator-readable (what happened) |
| **TP-FOLDER-BACKUP-25b** | same | **have** — same error names `generate-sudoer-request` |
| **TP-FOLDER-BACKUP-25c** | same | **have** — same error does not contain `sibling re-encode` |

**Matrix:** `reviews/requirement-test-matrix.md`  
**Map:** `reviews/test-plan.md`

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-17 | Active 1.0.0 | Operator-readable errors; TP-25; class residual |

---

**Last Updated**: 2026-08-17  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
