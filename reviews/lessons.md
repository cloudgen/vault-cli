# Lessons — folder-backup

Durable failure modes. **Always re-check on product review.**

| ID | Mode | Prevention | Status |
|----|------|------------|--------|
| L-MENU-SUDOERS-01 | Family token `sudoers` wired as a live command, or operational grant verbs dropped from the dispatcher, or test-purpose verbs put back on a numbered board | Family row is menu-only (client **17**); **172**/**175** stay on the sudoers board; **171**/**173**/**174** stay reserved; five names stay live CLI commands; TP-CLI-13 | open watch |
| L-MENU-TTY-01 | Named `menu` / `self-management` off a terminal prints help, an empty line on the front retries, or row **82** prints only the thin version line | `requirement-shell-cli-default-interaction` 1.9.0; off-terminal stop; empty front leaves; row **82** runs `about`; argv `version` stays thin; TP-CLI-15 · TP-CLI-21 | open watch |
| L-TYPE-N-01 | Non-interactive zero-cli-verb prints help, or places through local `install` (mode 0755), or a terminal with no command places | `requirement-shell-cli-zero-arguments` 1.2.1; interactive boards; non-interactive `inst_self_install`; TP-CLI-07 · TP-CLI-23 | open watch |
| L-CASE2-01 | Empty argv on TTY stays help after case 2 (always-help leak) | `requirement-shell-cli-default-interaction` 1.9.0; TP-CLI-13 empty argv | open watch |
| L-ONLINE-01 | Channel verbs dropped, a pipe with no command prints help, or a terminal with no command downloads | User order 2026-09-30: pipe / `--quiet` / `--json` with no command is `inst_self_install`. A terminal with no command stays the boards. TP-CLI-04/07/10/23 | closed by that order; watch the split |
| L-UNIN-01 | Non-interactive uninstall succeeds without force | TP-LC-05 confirm fail-closed | open watch |
| L-INST-MODE-01 | Install leaves `0711`/`0700` (chmod +x after mktemp) so non-owners cannot run shell ship unit | absolute `chmod 0755` + heal on reinstall; TP-LC-09/10; local-self-management §2.3.1 | open watch |
| L-DEPOSIT-01 | Unprivileged write to `/var/backup` or silent deposit success without sudo | fail-closed + print-sudoers; TP-FOLDER-BACKUP-05 | open watch |
| L-SUDOERS-01 | Auto-write `/etc/sudoers.d` or `NOPASSWD: ALL` fragment | print-only + install-script handoff; narrow Cmnd; TP-FOLDER-BACKUP-01/02/14 | open watch |
| L-SUDOERS-02 | Local `~/.local/bin` treated as production-secure for sudoers (user rewrites binary/stage → jailbreak) | trust tier **S13**; `--allow-test-local`; global preferred; TP-FOLDER-BACKUP-01/01b | open watch |
| L-SUDOERS-03 | Confuse draft removal with host elev removal (or Type 0 delete under `/etc`) | `remove-project-sudoers` draft-only + admin script uninstall; TP-FOLDER-BACKUP-15 | open watch |
| L-SUDOERS-04 | Shared `/etc/sudoers.d/{{APP_NAME}}` basename overwrites another user’s fragment on multi-user host | Per-user draft + installed `{{APP_NAME}}-<user>`; multi-draft list/choose; TP-FOLDER-BACKUP-14/15/15b | open watch |
| L-SUDOERS-05 | Generate fragment as wrong user (`id -un` mismatch with backup operator) | Generate as elevating login; User lines = invoking user; review fragment before install | open watch |
| L-PUSH-VAULT-01 | Bare `git push` uses wrong active SSH vault when default face ≠ repository-user | Pre-git report + `GIT_SSH_COMMAND -i` / activate matching vault (SK-COMMIT-CHECK §3.3); incident 20260810-001 | open watch |
| L-OVERWRITE-01 | Same-day archive overwrite without next-N | naming allocator; TP-FOLDER-BACKUP-08 when root | open watch |
| L-SETU-01 | `set -u` crash with unset HOME | TP-CLI-11 | open watch |
| L-STOR-01 | Shared cache leaf, or a leaf that is not mode 0700 and owned by this login | Volatile leaf `cache-${APP_NAME}-${login}-$$` under `/dev/shm/cache` or `/tmp/cache`; home leaf omits the login; parent 1777 stays shared; silent tier miss; TP-CLI-06 · TP-CLI-12 · TP-FOLDER-BACKUP-02 | open watch |
| L-INBOUND-01 | Submit probes only home `sudoer-approving` (or Type 0 `mkdir` inbound) | Public inbound first (`/var/sudoer-cli/sudoer-request`); no mkdir; TP-FOLDER-BACKUP-21/21b | open watch |
| L-INBOUND-02 | Suite / dispatcher probe runs `submit-sudoer-request` against live `/var/sudoer-cli` (approver sees test add/update files) | Isolated `SUDOER_CLI` + temp queue trio; `--queue-root` on env inbound; TP-CLI-13 must not enqueue; runner snapshot | open watch |
| L-SUDOERS-06 | `[OK] submit` inbound is restore-only while emit/purpose list backup+restore | Inbound is sibling **re-encode**; count `commands[].args` before approve; pretty JSON trips `sudoer-cli` `},{` split; INC-20260817-001 | open watch |
| L-SUDOERS-07 | Installed verb-only fragment ≠ `backup <folder>` (file exists / `sudo -n -l` still password on the operand) | Trailing sudoers `*`; do not skip on TTY or file existence; INC-20260823-001 | open watch |
| L-SUDOERS-08 | Submit of JSON `"*"` lands as cwd listing in inbound/`/etc` (unquoted sibling encode glob) | Fail closed unless inbound args stay `["backup","*"]`; convert ≠ submit re-encode; do not approve `ls` names; INC-20260823-002 | open watch |
| L-OUTPUT-01 | Submit fail-closed `[ERROR]` uses inbound/verb/sibling-re-encode jargon; operator cannot act | Fatal submit errors must name the missing grant, do-not-approve request id, and next command (`generate-sudoer-request`); **requirement-operator-readable-error**; TP-25*; incomplete inbound JSON is **not** a standing expected class (owner); INC-20260817-002 | open watch |
| L-TEST-REVIEW-01 | Green emit TP-22 + stub TP-20 + S14 Pass miss sibling decode drop | Assert inbound after **real** sudoer-cli; pretty + compact fixtures; do not treat `tests/run.sh` PASS as grant fidelity; INC-20260817-001 | open watch |
| L-SAFE-RM-01 | Host `safe-rm` success text lands inside sudoer-cli `$(sr_render_sudoers)` and visudo rejects line 4 | Tests that call real sudoer-cli put a quiet `rm` first on `PATH`. The guard still runs. Production submit on this host fails the same way until sudoer-cli stops capturing `rm` stdout. | open watch |

**Bootstrap parent is selfmanaged (2026-09-30).** Keep its output SSOT, no basename gate, storage leaf, and channel verbs. A terminal with no command stays the folder-backup numbered boards. A pipe, or `--quiet` / `--json` with no command, calls `inst_self_install`. Local `install` stays the mode 0755 copy and self-board row **81**.
