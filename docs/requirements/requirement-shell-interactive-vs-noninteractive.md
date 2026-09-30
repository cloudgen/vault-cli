**file**: docs/requirements/requirement-shell-interactive-vs-noninteractive.md  
**Status**: Active (Version 1.1.3)  
**Area**: shell  
**Key**: `requirement-shell-interactive-vs-noninteractive`  
**Philosophy**: CIAO **v2.10.2** / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **project Single Source of Truth** for how folder-backup behaves in **interactive** (human + TTY) versus **non-interactive** (automation, CI/CD, pipes, `--json` / often `--quiet`) environments.

### 1.1 Human-facing

**In one sentence:** On a real terminal the program may ask one question; in a pipe or with `--json` it must never hang waiting for you to type.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Confirm uninstall unless `--force` | `folder-backup uninstall` |
| Scripts / CI | No prompt; fail closed without `--force` | `folder-backup --json uninstall` |
| Not this file | Numbered work-list membership | `requirement-shell-cli-default-interaction` |

| Includes | Excludes |
|----------|----------|
| Measure TTY once outside helpers; helpers read `TTY` | Live `[ -t` inside `prompt_*` |
| Non-interactive never hangs | Capturing `prompt_ask` with `$()` |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/folder-backup` | ship unit | `TTY` + `prompt_*` |
| `folder-backup --json uninstall` | command | fail closed without `--force` |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Uninstall from a script | Must pass `--force` or it exits 1. | `folder-backup uninstall --force` |
| Uninstall at a prompt | It asks first. | `folder-backup uninstall` |

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Definitions

| Mode | Definition |
|------|------------|
| **Interactive** | Human + usable TTY; confirmations allowed when not overridden by machine flags |
| **Non-interactive** | No human available: CI, scripts, pipes, `--json` (and often `--quiet`). **Must never hang** waiting for input |

### 2.2 Detection (mode SSOT)

| Signal | Variable / check | Meaning |
|--------|------------------|---------|
| TTY | `TTY=1` when stdin **and** stdout are terminals | Interactive UX possible |
| Quiet | `QUIET=1` | Suppress non-essential human chatter |
| JSON | `JSON=1` (implies quiet) | Machine output; no human hang |
| Debug | `DEBUG=1` | Extra stderr diagnostics |
| Force | `FORCE=1` | Skip confirms / force reinstall where documented |

Rules:

1. **Measure `[ -t 0 ]` and `[ -t 1 ]` for interactive capability in the main process, outside functions** (script top-level or a direct setter that assigns `TTY`). Default `TTY=0`; set `TTY=1` only when both are terminals.  
2. `prompt_*`, `out_*` confirm paths, and `about` **MUST consume `TTY`**. **MUST NOT** re-test live `[ -t` inside those helpers as the policy gate.  
3. Prompt decisions **MUST** use shared `prompt_*` helpers — not ad-hoc `read` in domain logic.  
4. After flags are parsed in `app_main`, subsequent code **MUST** see updated mode globals.  
5. Do **not** invent a second parallel mode system per command.

**Complete `prompt_yes_no` sample** (consume `TTY` / `JSON` / `QUIET`; not live `[ -t`):

```sh
prompt_yes_no() {
    : "${JSON:=0}"
    : "${QUIET:=0}"
    : "${TTY:=0}"
    message="$1"
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ]; then
        return 1
    fi
    if [ "${TTY}" -ne 1 ]; then
        return 1
    fi
    out_msg_n "${message} (y/N)? "
    answer=""
    read -r answer || true
    case "${answer}" in
        [Yy]*|[Yy][Ee][Ss]*) return 0 ;;
        *) return 1 ;;
    esac
}
```

**Complete `prompt_ask` sample** (same consume-`TTY` rule). The answer is `PROMPT_ASK_VALUE` in the current shell. **MUST NOT** `_choice=$(prompt_ask …)`.

```sh
# WARNING — do-not-capture-read (PP-A-22)
# Call in the current shell. Do not wrap this function in $().
prompt_ask() {
    : "${JSON:=0}"
    : "${QUIET:=0}"
    : "${TTY:=0}"
    message="${1-}"
    default="${2-}"
    PROMPT_ASK_VALUE="${default}"
    if [ "${JSON}" -eq 1 ] || [ "${QUIET}" -eq 1 ] || [ "${TTY}" -ne 1 ]; then
        return 0
    fi
    out_msg_n "${message}: "
    answer=""
    read -r answer || true
    if [ -n "${answer}" ]; then
        PROMPT_ASK_VALUE="${answer}"
    fi
}
# prompt_ask "Choose draft number to remove" "0"
# _choice="${PROMPT_ASK_VALUE}"
```

### 2.3 Behavioral matrix (this product)

| Action | Interactive | Non-interactive |
|--------|-------------|-----------------|
| `uninstall` | Confirm unless `--force` | **Fail closed** without `--force` (`confirm_required`) |
| `install` | May inform; no required confirm for first install | Proceed without hang |
| `backup` | May show progress via `out_*` | No prompts; fail loud on missing operands / sudo failure |
| `print-sudoers` | Print fragment | Print fragment (stdout/file); no `/etc` write |
| `generate-sudoer-request` | May show path + verify via `out_*` | No prompts; write + verify; no hang |
| `submit-sudoer-request` | May show detect/submit via `out_*` | No prompts; fail closed if sudoer-cli / inbound missing; no hang |
| `menu` / `main` | Numbered list; ignore `--json` | Stop: `menu needs a terminal` (exit 1). **MUST NOT** prompt. **MUST NOT** print help |
| Missing required operand | Clear error | Clear error; non-zero exit |

### 2.4 Implementation Notes (this project)

| Item | Value |
|------|--------|
| **Product** | `folder-backup` |
| **Zero-cli-verb off-TTY** | CLI self-install (`inst_self_install`). Not help. Not local `install`. |
| **Prompt helper** | `prompt_yes_no` for uninstall (exit status). Value prompts use `prompt_ask` then `PROMPT_ASK_VALUE` (current shell) |

### 2.5 Why This Requirement Exists (CIAO)

- **Principle 16 – Interactive vs Non-Interactive**  
- **Principle 1 – Caution**: Never hang automation  
- **Principle 14 – Traceability**: Errors visible under quiet/json contracts

---

## Under command line for normal user only

When this program runs on Termux, Git Bash, Windows Command Prompt, or the same class, **admin privilege** and **dedicated system user privilege** stay unused. **This requirement:** TTY confirms stay your-own-login; **MUST NOT** use a TTY as a reason to wrap `sudo`.

| MUST | MUST NOT |
|------|----------|
| Measure TTY outside helpers | Password-sudo ladder on this class |
| Git Bash / Windows cmd: no Termux `pkg` | Treat WSL as this class |

Detect (typical): Termux — `PREFIX` contains `com.termux` or `TERMUX_VERSION` is set. Git Bash — `MSYSTEM` is `MINGW*` / `MSYS*`. Windows cmd — `OS=Windows_NT` and `COMSPEC` names `cmd.exe` after excluding Git Bash, Cygwin, and WSL.

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail closed on destructive ops without force in non-interactive.  
- **Intentional:** One mode SSOT.  
- **Anti-fragile:** CI-safe.  
- **Over-protect:** No bare `read` in domain paths.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Hang on stdin in non-interactive/json modes.  
2. Auto-yes destructive uninstall without `--force` in non-interactive mode.  
3. Scatter unguarded `read` calls outside `prompt_*`.  
4. Re-test live `[ -t 0 ]` / `[ -t 1 ]` inside `prompt_*` as the interactive-capability gate (helpers consume `TTY`).  
5. Treat non-interactive as license to skip required validation.
6. Capture `prompt_ask` or any `read` helper with `$()` or backticks. The value return is `PROMPT_ASK_VALUE`.

**Violating this rule is a critical interaction-mode regression.**

---

## 5. Acceptance criteria

| ID | Criterion |
|----|-----------|
| AC-1 | Non-interactive uninstall without force fails closed |
| AC-2 | JSON mode never prompts |
| AC-3 | Backup never hangs waiting for optional confirm by default |
| AC-4 | `prompt_ask` assigns `PROMPT_ASK_VALUE` in the current shell; no `$()` capture of that helper |

---

## 6. Related requirements (peer keys only)

| Key | Relationship |
|-----|--------------|
| `requirement-shell-cli-interface` | Flags |
| `requirement-shell-local-self-management` | Uninstall confirm |
| `requirement-shell-output-requirements` | Quiet/json emission |
| `docs/requirements/index.md` | Registry |

---

## 7. Status history

| Date | Status | Note |
|------|--------|------|
| 2026-08-03 | Active | Interactive vs non-interactive for folder-backup |
| 2026-09-23 | Active 1.1.0 | `prompt_ask` returns `PROMPT_ASK_VALUE`; `$()` capture forbidden |
| 2026-09-30 | Active 1.1.1 | Off-TTY empty argv stays help. `self-install` is explicit. |
| 2026-09-30 | Active 1.1.2 | Off-TTY zero-cli-verb is `inst_self_install`. Named `menu` off-TTY stays help. |
| 2026-09-30 | Active 1.1.3 | Named `menu` / `main` off a terminal stop. They do not print help. |

---

**Last Updated**: 2026-09-30  
**Owner**: project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; **CIAO** (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).
