# =============================================================================
# tests/helpers.sh — shared assertions for vault-cli CI tests
# =============================================================================
# Source from test scripts (POSIX /bin/sh). Does not modify product code.
# =============================================================================

# shellcheck disable=SC2034
: "${TESTS_ROOT:=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
: "${REPO_ROOT:=$(CDPATH= cd -- "${TESTS_ROOT}/.." && pwd)}"
: "${SCRIPT:=${REPO_ROOT}/src/vault-cli}"
: "${APP_NAME:=vault-cli}"
: "${PASS:=0}"
: "${FAIL:=0}"
: "${SKIP:=0}"

# Product VERSION SSOT from ship unit (keep tests free of frozen semver literals)
PRODUCT_VERSION=$(grep '^VERSION="' "${SCRIPT}" 2>/dev/null | head -n1 | cut -d'"' -f2)
: "${PRODUCT_VERSION:=unknown}"
PRODUCT_APP=$(grep '^APP_NAME="' "${SCRIPT}" 2>/dev/null | head -n1 | cut -d'"' -f2)
: "${PRODUCT_APP:=${APP_NAME}}"
APP_NAME="${PRODUCT_APP}"

# --- output ---
t_info()  { printf '  · %s\n' "$*"; }
t_pass()  { PASS=$((PASS + 1)); printf '  PASS  %s\n' "$*"; }
t_fail()  { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$*" >&2; }
t_skip()  { SKIP=$((SKIP + 1)); printf '  SKIP  %s\n' "$*"; }
t_header() { printf '\n== %s ==\n' "$*"; }

# --- assertions ---
assert_eq() {
    _lab="$1"; _exp="$2"; _act="$3"
    if [ "$_exp" = "$_act" ]; then
        t_pass "$_lab"
    else
        t_fail "$_lab (expected='$(_trunc "$_exp")' actual='$(_trunc "$_act")')"
    fi
}

assert_contains() {
    _lab="$1"; _hay="$2"; _ndl="$3"
    case "$_hay" in
        *"$_ndl"*) t_pass "$_lab" ;;
        *) t_fail "$_lab (missing '$(_trunc "$_ndl")' in '$(_trunc "$_hay")')" ;;
    esac
}

assert_not_contains() {
    _lab="$1"; _hay="$2"; _ndl="$3"
    case "$_hay" in
        *"$_ndl"*) t_fail "$_lab (unexpected '$(_trunc "$_ndl")')" ;;
        *) t_pass "$_lab" ;;
    esac
}

assert_exit() {
    _lab="$1"; _exp="$2"; shift 2
    "$@" >/dev/null 2>&1
    _act=$?
    assert_eq "$_lab" "$_exp" "$_act"
}

assert_file_exists() {
    _lab="$1"; _path="$2"
    if [ -e "$_path" ]; then
        t_pass "$_lab"
    else
        t_fail "$_lab (missing $_path)"
    fi
}

assert_file_missing() {
    _lab="$1"; _path="$2"
    if [ -e "$_path" ]; then
        t_fail "$_lab (still exists: $_path)"
    else
        t_pass "$_lab"
    fi
}

_trunc() {
    printf '%s' "$1" | tr '\n' ' ' | cut -c1-160
}

# Strip SGR CSI (ESC[…m) so membership asserts stay stable when TTY ink is on.
ci_strip_ansi() {
    _esc=$(printf '\033')
    printf '%s' "$1" | sed "s/${_esc}\\[[0-9;]*m//g"
}

# Isolated HOME + USER_BIN + GLOBAL_BIN for install tests.
# GLOBAL_BIN is redirected so a host /usr/local/bin install cannot pollute
# uninstall target selection or trust-tier detection (TP-LC / print-sudoers).
# Sudoer submit is fenced: missing SUDOER_CLI + temp inbound + absent public
# root so a live /var/sudoer-cli/sudoer-request is never the default dest.
# Sets CI_HOME, CI_USER_BIN, CI_GLOBAL_BIN, CI_SUDOER_INBOUND.
ci_isolated_env() {
    CI_SAVED_HOME="${HOME-}"
    CI_HOME=$(mktemp -d "${TMPDIR:-/tmp}/fb-home.XXXXXX")
    CI_USER_BIN="${CI_HOME}/.local/bin"
    CI_GLOBAL_BIN="${CI_HOME}/.global-bin"
    mkdir -p "${CI_USER_BIN}" "${CI_GLOBAL_BIN}"
    export HOME="${CI_HOME}"
    export USER_BIN="${CI_USER_BIN}"
    export GLOBAL_BIN="${CI_GLOBAL_BIN}"
    # Isolate host sudoers.d probe so a live /etc/sudoers.d fragment
    # does not flip default submit add → update (TP-23 uses this dir).
    CI_SUDOERS_D="${CI_HOME}/sudoers.d"
    mkdir -p "${CI_SUDOERS_D}"
    export SUDOERS_D_DIR="${CI_SUDOERS_D}"
    # Fence live sudoer inbound (TP-CLI-13 must not enqueue host requests).
    # Trio layout matches sudoer-cli --queue-root so a real binary cannot
    # fall back to /var/sudoer-cli if a test forgets SUDOER_CLI.
    CI_SUDOER_QUEUE="${CI_HOME}/sudoer-cli-queue"
    mkdir -p "${CI_SUDOER_QUEUE}/sudoer-request" \
        "${CI_SUDOER_QUEUE}/sudoer-approved" \
        "${CI_SUDOER_QUEUE}/sudoer-rejected"
    CI_SUDOER_INBOUND="${CI_SUDOER_QUEUE}/sudoer-request"
    export SUDOER_QUEUE_INBOUND="${CI_SUDOER_INBOUND}"
    export SUDOER_PUBLIC_ROOT="${CI_HOME}/var-sudoer-cli-absent"
    export SUDOER_CLI="${CI_HOME}/no-such-sudoer-cli"
    unset SUDOER_CLI_QUEUE_ROOT 2>/dev/null || true
    unset LPU_HOME 2>/dev/null || true
    # Do not inherit a caller SCRIPT_URL or CHECKSUM. Channel tests set their own URL.
    unset SCRIPT_URL 2>/dev/null || true
    unset CHECKSUM 2>/dev/null || true
    unset VAULT_ROOT 2>/dev/null || true
}

ci_cleanup_env() {
    if [ -n "${CI_HOME:-}" ] && [ -d "${CI_HOME}" ]; then
        rm -rf "${CI_HOME}"
    fi
    CI_HOME=
    CI_USER_BIN=
    CI_GLOBAL_BIN=
    CI_SUDOER_INBOUND=
    CI_SUDOERS_D=
    unset USER_BIN GLOBAL_BIN SUDOERS_D_DIR 2>/dev/null || true
    unset SUDOER_CLI SUDOER_QUEUE_INBOUND SUDOER_PUBLIC_ROOT 2>/dev/null || true
    unset SUDOER_CLI_QUEUE_ROOT LPU_HOME 2>/dev/null || true
    if [ -n "${CI_SAVED_HOME+x}" ]; then
        HOME="${CI_SAVED_HOME}"
        export HOME
        unset CI_SAVED_HOME
    fi
}

# Snapshot this user's folder-backup files in the live public inbound.
# Public inbound is typically 3773 (drop-in, no list). Probe known names
# with [ -e ] instead of listing the directory.
# Prints __absent__ when /var/sudoer-cli/sudoer-request does not exist.
ci_snapshot_live_sudoer_inbound() {
    _dir="/var/sudoer-cli/sudoer-request"
    _user=$(id -un 2>/dev/null || echo unknown)
    _day=$(date +%Y%m%d)
    if [ ! -d "${_dir}" ]; then
        printf '%s\n' "__absent__"
        return 0
    fi
    _found=""
    for _act in add update remove; do
        _n=1
        while [ "${_n}" -le 99 ]; do
            _f="${_dir}/sudoer-${_day}-folder-backup-${_user}-${_act}-${_n}.json"
            if [ -e "${_f}" ]; then
                _found="${_found}${_act}-${_n} "
            fi
            _n=$((_n + 1))
        done
    done
    printf '%s' "${_found}"
}

ci_assert_no_live_sudoer_enqueue() {
    _lab="$1"
    _before="$2"
    if [ "${_before}" = "__absent__" ]; then
        t_skip "${_lab} (live inbound not present)"
        return 0
    fi
    _after=$(ci_snapshot_live_sudoer_inbound)
    assert_eq "${_lab}" "${_before}" "${_after}"
}

ci_run() {
    sh "${SCRIPT}" "$@"
}

# Run the ship unit on a PTY (stdin+stdout are terminals). Writes the child
# payload from PTY_IN (default "9") then captures combined output to stdout.
# Requires python3. Caller assigns: _out=$(PTY_IN=9 ci_pty_run menu)
ci_pty_run() {
    PTY_IN="${PTY_IN:-9}" python3 - "${SCRIPT}" "$@" <<'PY'
import os, pty, select, signal, sys, time
script = sys.argv[1]
cmd = sys.argv[2:]
raw = os.environ.get("PTY_IN", "9")
if not raw.endswith("\n"):
    raw += "\n"
payload = raw.encode()
pid, fd = pty.fork()
if pid == 0:
    os.execv("/bin/sh", ["sh", script] + cmd)
time.sleep(0.2)
try:
    os.write(fd, payload)
except OSError:
    pass
out = bytearray()
end = time.time() + 4
while time.time() < end:
    r, _, _ = select.select([fd], [], [], 0.2)
    if fd in r:
        try:
            chunk = os.read(fd, 4096)
        except OSError:
            break
        if not chunk:
            break
        out += chunk
    wpid, _st = os.waitpid(pid, os.WNOHANG)
    if wpid:
        break
else:
    try:
        os.kill(pid, signal.SIGTERM)
        time.sleep(0.2)
        os.kill(pid, signal.SIGKILL)
    except OSError:
        pass
try:
    os.waitpid(pid, 0)
except ChildProcessError:
    pass
sys.stdout.buffer.write(out.replace(b"\r\n", b"\n").replace(b"\r", b"\n"))
PY
}

ci_capture() {
    _out="$1"; _err="$2"; shift 2
    if [ "$1" = "--" ]; then shift; fi
    "$@" >"$_out" 2>"$_err"
    CI_EXIT=$?
}

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        t_fail "required command missing: $1"
        return 1
    fi
    return 0
}
