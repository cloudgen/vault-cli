# =============================================================================
# tests/test_domain_folder_backup.sh — folder archive backup + domain surface
# =============================================================================
# Primary ops REQ: requirement-folder-archive-backup (NOT domain)
# Domain surface:  requirement-domain-folder-backup (verbs/help/about pointers)
# Privilege peer:  requirement-three-layer-privilege-model
# JSON grant:      requirement-sudoer-json-file
# Other peers:     requirement-shell-idempotency
# TP family: TP-FOLDER-BACKUP-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

# Probe narrow Type 1 deposit without running backup.
# Returns 0 when passwordless allowlisted mkdir for deposit dir works.
fb_ci_sudo_deposit_available() {
    command -v sudo >/dev/null 2>&1 || return 1
    sudo -n /usr/bin/mkdir -p /var/backup/folder-backup >/dev/null 2>&1 \
        || sudo -n /bin/mkdir -p /var/backup/folder-backup >/dev/null 2>&1
}

# Fail-closed path: put a non-elevating "sudo" first on PATH so deposit cannot escalate.
fb_ci_path_without_working_sudo() {
    _bindir=$(mktemp -d "${TMPDIR:-/tmp}/fb-nosudo.XXXXXX")
    printf '%s\n' '#!/bin/sh' 'echo "sudo: simulated unauthorized" >&2' 'exit 1' >"${_bindir}/sudo"
    chmod 0755 "${_bindir}/sudo"
    printf '%s' "${_bindir}:${PATH}"
}

# Host rm is safe-rm. A successful remove prints "[OK] Caller …" on stdout.
# sudoer-cli builds the sudoers file inside $(sr_render_sudoers), and that
# function removes a temp file, so the OK line becomes sudoers text and
# visudo rejects it. This PATH entry still runs safe-rm (refusals stay on
# stderr) and silences only the success line.
fb_ci_quiet_rm_path() {
    if [ ! -x /usr/bin/safe-rm ]; then
        printf '%s' "${PATH}"
        return 0
    fi
    _qr=$(mktemp -d "${TMPDIR:-/tmp}/fb-qrm.XXXXXX")
    mkdir -p "${_qr}/link"
    ln -s /usr/bin/safe-rm "${_qr}/link/rm"
    cat > "${_qr}/rm" << 'EOF'
#!/bin/sh
export QUIET=1
exec "$(dirname "$0")/link/rm" "$@"
EOF
    chmod 0755 "${_qr}/rm"
    printf '%s' "${_qr}:${PATH}"
}

run_test_domain_folder_backup() {
    t_header "Domain folder-backup (TP-FOLDER-BACKUP)"

    require_cmd sh
    require_cmd tar
    require_cmd date

    ci_isolated_env

    # TP-FOLDER-BACKUP-01 print-sudoers human emits fragment; Type 0 must not install /etc
    # Suite has no global install → trust tier test_local/unmanaged → require --allow-test-local
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers --allow-test-local 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-01 print-sudoers exit 0" 0 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-01 NOPASSWD" "$_out" "NOPASSWD"
    assert_contains "TP-FOLDER-BACKUP-01 project backup verb" "$_out" "folder-backup backup"
    assert_contains "TP-FOLDER-BACKUP-01 restore verb" "$_out" "folder-backup restore"
    assert_contains "TP-FOLDER-BACKUP-01 admin install hint" "$_out" "sudoers.d/"
    assert_contains "TP-FOLDER-BACKUP-01 test mode banner" "$_out" "TEST MODE ONLY"
    assert_not_contains "TP-FOLDER-BACKUP-01 no tar Cmnd" "$_out" "tar -tzf"
    # print-sudoers never writes /etc itself. Host may already have admin-installed fragment.
    if [ -e /etc/sudoers.d/folder-backup ]; then
        t_pass "TP-FOLDER-BACKUP-01 host has admin sudoers (print-sudoers is Type 0 only; no /etc write attempted)"
    else
        assert_file_missing "TP-FOLDER-BACKUP-01 no /etc write" "/etc/sudoers.d/folder-backup"
    fi

    # TP-FOLDER-BACKUP-01b refuse test_local emit without allow flag
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-01b refuse without allow-test-local exit 1" 1 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-01b hint allow-test-local" "$_err" "allow-test-local"

    # TP-FOLDER-BACKUP-02 print-sudoers to path (explicit path still supported;
    # keep outside config sudoers.fragment* so multi-draft discovery is not polluted)
    _frag="${CI_HOME}/out/sudoers-draft.txt"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers --allow-test-local "${_frag}" 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-02 write fragment exit 0" 0 "$_ec"
    assert_file_exists "TP-FOLDER-BACKUP-02 fragment file" "${_frag}"
    assert_contains "TP-FOLDER-BACKUP-02 file has project backup" "$(cat "${_frag}")" "folder-backup backup"
    assert_not_contains "TP-FOLDER-BACKUP-02 no ALL ALL" "$(cat "${_frag}")" "NOPASSWD: ALL"
    assert_contains "TP-FOLDER-BACKUP-02 test mode in file" "$(cat "${_frag}")" "TEST MODE ONLY"
    _ci_user=$(id -un 2>/dev/null || echo "unknown")
    assert_contains "TP-FOLDER-BACKUP-02 user-bound" "$(cat "${_frag}")" "${_ci_user} ALL=(root)"
    # TP-FOLDER-BACKUP-22 / 22b / 22c — JSON sudoer file (requirement-sudoer-json-file)
    _jgrant="${_frag}.json"
    assert_file_exists "TP-FOLDER-BACKUP-22 JSON grant file" "${_jgrant}"
    _jbody=$(cat "${_jgrant}")
    assert_contains "TP-FOLDER-BACKUP-22 path is folder-backup" "${_jbody}" '/folder-backup"'
    assert_contains "TP-FOLDER-BACKUP-22 backup args" "${_jbody}" '"backup"'
    assert_contains "TP-FOLDER-BACKUP-22 restore args" "${_jbody}" '"restore"'
    assert_not_contains "TP-FOLDER-BACKUP-22b no mkdir" "${_jbody}" "mkdir"
    assert_not_contains "TP-FOLDER-BACKUP-22b no /usr/bin/cp" "${_jbody}" "/usr/bin/cp"
    assert_not_contains "TP-FOLDER-BACKUP-22b no tar" "${_jbody}" "tar"
    assert_not_contains "TP-FOLDER-BACKUP-22b no /bin/rm" "${_jbody}" "/bin/rm"
    assert_not_contains "TP-FOLDER-BACKUP-22b no install -m" "${_jbody}" "install"
    assert_not_contains "TP-FOLDER-BACKUP-22c no deposit path" "${_jbody}" "/var/backup/folder-backup"
    assert_not_contains "TP-FOLDER-BACKUP-22c no tar.gz operand" "${_jbody}" ".tar.gz"

    # TP-FOLDER-BACKUP-26 emit is backup * / restore * (AC-25; INC-20260823-001)
    _fragtxt=$(cat "${_frag}")
    _stdout26=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers --allow-test-local 2>&1)
    assert_contains "TP-FOLDER-BACKUP-26 stdout backup star" "${_stdout26}" "folder-backup backup *"
    assert_contains "TP-FOLDER-BACKUP-26 file backup star" "${_fragtxt}" "folder-backup backup *"
    assert_contains "TP-FOLDER-BACKUP-26 file restore star" "${_fragtxt}" "folder-backup restore *"
    assert_contains "TP-FOLDER-BACKUP-26 file json backup star" "${_fragtxt}" "folder-backup --json backup *"
    assert_contains "TP-FOLDER-BACKUP-26 file json restore star" "${_fragtxt}" "folder-backup --json restore *"
    _vo=$(printf '%s\n' "${_fragtxt}" | grep -E 'folder-backup backup$' || true)
    if [ -z "${_vo}" ]; then
        t_pass "TP-FOLDER-BACKUP-26 no verb-only backup line"
    else
        t_fail "TP-FOLDER-BACKUP-26 no verb-only backup line" "found: ${_vo}"
    fi
    _vo=$(printf '%s\n' "${_fragtxt}" | grep -E 'folder-backup restore$' || true)
    if [ -z "${_vo}" ]; then
        t_pass "TP-FOLDER-BACKUP-26 no verb-only restore line"
    else
        t_fail "TP-FOLDER-BACKUP-26 no verb-only restore line" "found: ${_vo}"
    fi
    if printf '%s\n' "${_jbody}" | grep -Fq '"args": ["backup", "*"]'; then
        t_pass "TP-FOLDER-BACKUP-26 JSON backup star args"
    else
        t_fail "TP-FOLDER-BACKUP-26 JSON backup star args" "missing literal args backup *"
    fi
    if printf '%s\n' "${_jbody}" | grep -Fq '"args": ["restore", "*"]'; then
        t_pass "TP-FOLDER-BACKUP-26 JSON restore star args"
    else
        t_fail "TP-FOLDER-BACKUP-26 JSON restore star args" "missing literal args restore *"
    fi
    assert_not_contains "TP-FOLDER-BACKUP-26 JSON not verb-only backup" "${_jbody}" '"args": ["backup"]'
    assert_not_contains "TP-FOLDER-BACKUP-26 JSON not verb-only restore" "${_jbody}" '"args": ["restore"]'

    # TP-FOLDER-BACKUP-22e pretty emit through real sudoer-cli keeps both verbs
    _srcli=""
    if [ -x "${REPO_ROOT}/../sudoer-cli/src/sudoer-cli" ] \
        && sh -n "${REPO_ROOT}/../sudoer-cli/src/sudoer-cli" 2>/dev/null; then
        _srcli="${REPO_ROOT}/../sudoer-cli/src/sudoer-cli"
    elif [ -x /usr/local/bin/sudoer-cli ] && sh -n /usr/local/bin/sudoer-cli 2>/dev/null; then
        _srcli=/usr/local/bin/sudoer-cli
    elif command -v sudoer-cli >/dev/null 2>&1; then
        _cand=$(command -v sudoer-cli)
        if sh -n "${_cand}" 2>/dev/null; then
            _srcli="${_cand}"
        fi
    fi
    if [ -n "${_srcli}" ] && [ -x "${_srcli}" ]; then
        _pback="${CI_HOME}/out/pretty-back.sudoers"
        mkdir -p "${CI_HOME}/out"
        # Sibling 1.17+ refuses user-rewritable test GLOBAL_BIN. Convert a
        # production-path copy of the same args (backup * / restore *).
        _jconv="${CI_HOME}/out/pretty-wellknown.json"
        sed 's|"path": *"[^"]*/folder-backup"|"path": "/usr/local/bin/folder-backup"|g' "${_jgrant}" >"${_jconv}"
        PATH=$(fb_ci_quiet_rm_path) HOME="${CI_HOME}" sh "${_srcli}" json-to-sudoers --file "${_jconv}" --out "${_pback}" >/dev/null 2>&1
        assert_eq "TP-FOLDER-BACKUP-22e pretty convert exit 0" 0 "$?"
        _pbtxt=$(cat "${_pback}" 2>/dev/null || true)
        assert_contains "TP-FOLDER-BACKUP-22e convert keeps backup" "${_pbtxt}" "folder-backup backup"
        assert_contains "TP-FOLDER-BACKUP-22e convert keeps restore" "${_pbtxt}" "folder-backup restore"
        assert_contains "TP-FOLDER-BACKUP-22e convert backup star" "${_pbtxt}" "folder-backup backup *"
        assert_contains "TP-FOLDER-BACKUP-22e convert restore star" "${_pbtxt}" "folder-backup restore *"
    else
        t_skip "TP-FOLDER-BACKUP-22e sudoer-cli not installed"
    fi

    # TP-FOLDER-BACKUP-03 backup without source fails
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-03 backup no arg exit 1" 1 "$?"
    assert_contains "TP-FOLDER-BACKUP-03 usage" "$_err" "Usage:"

    # TP-FOLDER-BACKUP-04 backup invalid source fails
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup /no/such/dir-$$ 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-04 missing dir exit 1" 1 "$?"

    # TP-FOLDER-BACKUP-05 deposit fail-closed when escalation cannot succeed
    # Always force unauthorized sudo via PATH so this case stays valid with host sudoers installed.
    _src="${CI_HOME}/sample-src"
    mkdir -p "${_src}"
    printf 'data\n' > "${_src}/file.txt"
    _nopath=$(fb_ci_path_without_working_sudo)
    _err=$(HOME="${CI_HOME}" PATH="${_nopath}" sh "${SCRIPT}" backup "${_src}" 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-05 deposit fail-closed exit 1" 1 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-05 sudoers hint" "$_err" "print-sudoers"
    # cleanup fake sudo dir (prefix before first :)
    _fake=$(printf '%s' "${_nopath}" | cut -d: -f1)
    rm -rf "${_fake}" 2>/dev/null || true

    # TP-FOLDER-BACKUP-06 archive naming visible before deposit fail
    _nopath=$(fb_ci_path_without_working_sudo)
    _out=$(HOME="${CI_HOME}" PATH="${_nopath}" sh "${SCRIPT}" backup "${_src}" 2>&1)
    assert_contains "TP-FOLDER-BACKUP-06 creates archive name pattern" "$_out" "sample-src-"
    assert_contains "TP-FOLDER-BACKUP-06 tar.gz extension" "$_out" ".tar.gz"
    _day=$(date +%Y%m%d)
    assert_contains "TP-FOLDER-BACKUP-06 date segment" "$_out" "${_day}"
    _fake=$(printf '%s' "${_nopath}" | cut -d: -f1)
    rm -rf "${_fake}" 2>/dev/null || true

    # TP-FOLDER-BACKUP-07/08 — elevated deposit (root OR allowlisted sudo -n)
    if [ "$(id -u)" -eq 0 ]; then
        _broot="${CI_HOME}/var-backup"
        mkdir -p "${_broot}"
        _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" BACKUP_NOTATION="folder-backup" \
            sh "${SCRIPT}" backup "${_src}" 2>&1)
        _ec=$?
        assert_eq "TP-FOLDER-BACKUP-07 root deposit exit 0" 0 "$_ec"
        _found=$(find "${_broot}/folder-backup" -name 'sample-src-*.tar.gz' 2>/dev/null | head -n1)
        if [ -n "$_found" ] && [ -f "$_found" ]; then
            t_pass "TP-FOLDER-BACKUP-07 archive deposited"
            _out2=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" BACKUP_NOTATION="folder-backup" \
                sh "${SCRIPT}" backup "${_src}" 2>&1)
            _count=$(find "${_broot}/folder-backup" -name "sample-src-${_day}-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
            if [ "${_count}" -ge 2 ]; then
                t_pass "TP-FOLDER-BACKUP-08 next-N no overwrite (${_count} archives)"
            else
                t_fail "TP-FOLDER-BACKUP-08 expected >=2 archives, got ${_count}"
            fi
        else
            t_fail "TP-FOLDER-BACKUP-07 no archive under ${_broot}/folder-backup"
            t_skip "TP-FOLDER-BACKUP-08 skipped (no first deposit)"
        fi
    elif fb_ci_sudo_deposit_available; then
        # Host admin installed narrow sudoers — exercise real Type 1 deposit
        _marker="ci-elev-$$"
        _elev_src="${CI_HOME}/${_marker}"
        mkdir -p "${_elev_src}"
        printf 'elev\n' > "${_elev_src}/payload.txt"
        _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup "${_elev_src}" 2>&1)
        _ec=$?
        assert_eq "TP-FOLDER-BACKUP-07 sudo deposit exit 0" 0 "$_ec"
        assert_contains "TP-FOLDER-BACKUP-07 deposit path" "$_out" "/var/backup/folder-backup/${_marker}-"
        assert_contains "TP-FOLDER-BACKUP-07 success text" "$_out" "Backup complete"
        assert_contains "TP-FOLDER-BACKUP-07 verified counts" "$_out" "Verified:"
        assert_contains "TP-FOLDER-BACKUP-07 source_files" "$_out" "source_files="
        assert_contains "TP-FOLDER-BACKUP-07 archive_files" "$_out" "archive_files="
        if [ -f "/var/backup/folder-backup/${_marker}-${_day}-1.tar.gz" ] \
            || find /var/backup/folder-backup -name "${_marker}-${_day}-*.tar.gz" 2>/dev/null | grep -q .; then
            t_pass "TP-FOLDER-BACKUP-07 archive present under deposit dir"
            _out2=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup "${_elev_src}" 2>&1)
            _ec2=$?
            assert_eq "TP-FOLDER-BACKUP-08 second deposit exit 0" 0 "$_ec2"
            _count=$(find /var/backup/folder-backup -name "${_marker}-${_day}-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
            if [ "${_count}" -ge 2 ]; then
                t_pass "TP-FOLDER-BACKUP-08 next-N no overwrite (${_count} archives via sudo)"
            else
                t_fail "TP-FOLDER-BACKUP-08 expected >=2 archives via sudo, got ${_count}"
            fi
        else
            # Deposit may succeed with root ownership; listing may still work on 0755 dir
            if printf '%s' "$_out" | grep -q 'Backup complete'; then
                t_pass "TP-FOLDER-BACKUP-07 archive deposited (success message; dir list limited)"
                _out2=$(HOME="${CI_HOME}" sh "${SCRIPT}" backup "${_elev_src}" 2>&1)
                if printf '%s' "$_out2" | grep -q -- "-${_day}-2.tar.gz"; then
                    t_pass "TP-FOLDER-BACKUP-08 next-N via sudo (name -2)"
                else
                    assert_contains "TP-FOLDER-BACKUP-08 next-N name" "$_out2" "-${_day}-"
                fi
            else
                t_fail "TP-FOLDER-BACKUP-07 no archive evidence under /var/backup/folder-backup"
                t_skip "TP-FOLDER-BACKUP-08 skipped (no first deposit)"
            fi
        fi
    else
        t_skip "TP-FOLDER-BACKUP-07 elevated deposit (not root; sudoers deposit not available)"
        t_skip "TP-FOLDER-BACKUP-08 next-N full deposit (not root; sudoers deposit not available)"
    fi

    # TP-FOLDER-BACKUP-09 help/about domain fields already partially CLI; confirm about deposit_dir
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-FOLDER-BACKUP-09 about backup_root" "$_out" '"backup_root"'
    assert_contains "TP-FOLDER-BACKUP-09 about sudo_deposit" "$_out" '"sudo_deposit"'

    # TP-FOLDER-BACKUP-10 path-ish: sanitize leaves basename only (source with nested ok)
    _nested="${CI_HOME}/proj/nested-name"
    mkdir -p "${_nested}"
    echo y > "${_nested}/b.txt"
    # Prefer nosudo for naming check so we do not require deposit; if sudo works, success still names leaf
    _nopath=$(fb_ci_path_without_working_sudo)
    _out=$(HOME="${CI_HOME}" PATH="${_nopath}" sh "${SCRIPT}" backup "${_nested}" 2>&1)
    assert_contains "TP-FOLDER-BACKUP-10 uses leaf basename" "$_out" "nested-name-"
    _fake=$(printf '%s' "${_nopath}" | cut -d: -f1)
    rm -rf "${_fake}" 2>/dev/null || true

    # -------------------------------------------------------------------------
    # TP-FOLDER-BACKUP-11..13 restore (ops SSOT; default dest host = hard-disk)
    # -------------------------------------------------------------------------
    # Build a user-readable archive under controlled BACKUP_ROOT (no sudo needed)
    _broot="${CI_HOME}/var-backup"
    _dep="${_broot}/folder-backup"
    mkdir -p "${_dep}"
    _rsrc="${CI_HOME}/restore-src-tree"
    mkdir -p "${_rsrc}/sub"
    printf 'restore-me\n' > "${_rsrc}/a.txt"
    printf 'nested\n' > "${_rsrc}/sub/b.txt"
    # Create archive matching product naming via tar (leaf = restore-src-tree)
    _day=$(date +%Y%m%d)
    _aname="restore-src-tree-${_day}-1.tar.gz"
    tar -C "${CI_HOME}" -czf "${_dep}/${_aname}" "restore-src-tree"
    # TP-FOLDER-BACKUP-11 restore missing archive fails
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" sh "${SCRIPT}" restore no-such-archive-xyz 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-11 missing archive exit 1" 1 "$?"
    # TP-FOLDER-BACKUP-12 restore to explicit dest (override host SSOT)
    _rdest="${CI_HOME}/projects-sim"
    mkdir -p "${_rdest}"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" \
        sh "${SCRIPT}" restore "${_aname}" "${_rdest}/restore-src-tree" 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-12 restore exit 0" 0 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-12 restore complete" "$_out" "Restore complete"
    assert_contains "TP-FOLDER-BACKUP-12 verified files" "$_out" "Verified:"
    assert_file_exists "TP-FOLDER-BACKUP-12 restored file" "${_rdest}/restore-src-tree/a.txt"
    # TP-FOLDER-BACKUP-13 default host is hard-disk (message) when no dest
    _proot="${CI_HOME}/prjs"
    mkdir -p "${_proot}"
    # non-empty dest fails without --force
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" PROJECTS_ROOT="${_proot}" \
        sh "${SCRIPT}" restore restore-src-tree 2>&1) || true
    # first restore to hard-disk default
    rm -rf "${_proot}/restore-src-tree"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" PROJECTS_ROOT="${_proot}" \
        sh "${SCRIPT}" restore restore-src-tree 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-13 hard-disk default exit 0" 0 "$_ec"
    assert_contains "TP-FOLDER-BACKUP-13 host hard-disk" "$_out" "hard-disk"
    assert_file_exists "TP-FOLDER-BACKUP-13 on projects root" "${_proot}/restore-src-tree/a.txt"
    # second without force fails
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot}" PROJECTS_ROOT="${_proot}" \
        sh "${SCRIPT}" restore restore-src-tree 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-13 non-empty without force exit 1" 1 "$?"

    # print-sudoers includes restore as project verb (not OS-tool reverse cp)
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers --allow-test-local 2>&1)
    assert_contains "TP-FOLDER-BACKUP-01c restore verb allowlist" "$_out" "folder-backup restore"

    # TP-FOLDER-BACKUP-14 admin install script (project-sudoers-file handoff; per-user names)
    _script="${CI_HOME}/sudoers-admin.sh"
    _user=$(id -un 2>/dev/null || echo "unknown")
    _draft_default="${CI_HOME}/.config/folder-backup/sudoers.fragment-${_user}"
    : "${CI_SUDOERS_D:=${CI_HOME}/sudoers.d}"
    _installed_default="${CI_SUDOERS_D}/folder-backup-${_user}"
    _installed_real="/etc/sudoers.d/folder-backup-${_user}"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers-install-script --allow-test-local "${_script}" 2>&1)
    _ec=$?
    assert_eq "TP-FOLDER-BACKUP-14 install-script exit 0" 0 "$_ec"
    assert_file_exists "TP-FOLDER-BACKUP-14 admin script file" "${_script}"
    assert_file_exists "TP-FOLDER-BACKUP-14 project-sudoers-file draft per-user" "${_draft_default}"
    assert_contains "TP-FOLDER-BACKUP-14 script has install" "$(cat "${_script}")" "cmd_install"
    assert_contains "TP-FOLDER-BACKUP-14 script has uninstall" "$(cat "${_script}")" "cmd_uninstall"
    assert_contains "TP-FOLDER-BACKUP-14 per-user installed path" "$(cat "${_script}")" "${_installed_default}"
    assert_contains "TP-FOLDER-BACKUP-14 no etc write by type0" "$_out" "Handoff"
    # generated script is valid sh; status without root
    sh -n "${_script}"
    assert_eq "TP-FOLDER-BACKUP-14 admin script sh -n" 0 "$?"
    _st=$(sh "${_script}" status 2>&1)
    assert_contains "TP-FOLDER-BACKUP-14 status draft path" "$_st" "sudoers.fragment-${_user}"
    # Type 0 must not have written /etc (host may already have fragment)
    assert_contains "TP-FOLDER-BACKUP-14 require root for install" "$(sh "${_script}" install 2>&1 || true)" "root"

    # TP-FOLDER-BACKUP-15 remove-project-sudoers (draft only; probe host elev; multi-draft choose)
    _draft="${_draft_default}"
    assert_file_exists "TP-FOLDER-BACKUP-15 draft exists before remove" "${_draft}"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-15 remove without force fail-closed" 1 "$?"
    assert_file_exists "TP-FOLDER-BACKUP-15 draft remains without force" "${_draft}"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force 2>&1)
    assert_eq "TP-FOLDER-BACKUP-15 remove --force exit 0" 0 "$?"
    assert_file_missing "TP-FOLDER-BACKUP-15 draft removed" "${_draft}"
    assert_contains "TP-FOLDER-BACKUP-15 mentions host path" "$_out" "sudoers.d/"
    # Isolated probe: seed this-user fragment so STILL ACTIVE is deterministic
    mkdir -p "${CI_SUDOERS_D}"
    printf '# probe\n' > "${_installed_default}"
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force 2>&1)
    assert_contains "TP-FOLDER-BACKUP-15 host elev still active warn" "$_out" "STILL ACTIVE"
    # refuse /etc path (legacy or real per-user dest)
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force /etc/sudoers.d/folder-backup 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-15 refuse /etc exit 1" 1 "$?"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force "${_installed_real}" 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-15 refuse per-user /etc exit 1" 1 "$?"
    # already absent is success; still honest about host elev
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force 2>&1)
    assert_eq "TP-FOLDER-BACKUP-15 already absent exit 0" 0 "$?"
    assert_contains "TP-FOLDER-BACKUP-15 already absent text" "$_out" "not present"
    assert_contains "TP-FOLDER-BACKUP-15 already-absent still warns host elev" "$_out" "STILL ACTIVE"
    rm -f "${_installed_default}"
    _json=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force --json 2>/dev/null)
    assert_contains "TP-FOLDER-BACKUP-15 json host_fragment_present" "$_json" "host_fragment_present"

    # TP-FOLDER-BACKUP-15b multi-draft: non-interactive must require path when multiple exist
    mkdir -p "${CI_HOME}/.config/folder-backup"
    printf '# legacy draft\n' > "${CI_HOME}/.config/folder-backup/sudoers.fragment"
    printf '# user draft\n' > "${_draft_default}"
    printf '# other draft\n' > "${CI_HOME}/.config/folder-backup/sudoers.fragment-otheruser"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-15b multi-draft noninteractive needs path" 1 "$?"
    assert_contains "TP-FOLDER-BACKUP-15b multi-draft message" "$_err" "multiple drafts"
    # explicit path removes only that draft
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force "${_draft_default}" 2>&1)
    assert_eq "TP-FOLDER-BACKUP-15b remove explicit path exit 0" 0 "$?"
    assert_file_missing "TP-FOLDER-BACKUP-15b explicit draft removed" "${_draft_default}"
    assert_file_exists "TP-FOLDER-BACKUP-15b legacy draft remains" "${CI_HOME}/.config/folder-backup/sudoers.fragment"
    assert_file_exists "TP-FOLDER-BACKUP-15b other draft remains" "${CI_HOME}/.config/folder-backup/sudoers.fragment-otheruser"

    # TP-FOLDER-BACKUP-15c TTY multi-draft picker reads the number in this shell
    if command -v python3 >/dev/null 2>&1; then
        rm -f "${CI_HOME}/.config/folder-backup/sudoers.fragment" \
            "${CI_HOME}/.config/folder-backup/sudoers.fragment-otheruser" \
            "${_draft_default}"
        mkdir -p "${CI_HOME}/.config/folder-backup"
        printf '# legacy\n' > "${CI_HOME}/.config/folder-backup/sudoers.fragment"
        printf '# aaa\n' > "${CI_HOME}/.config/folder-backup/sudoers.fragment-aaa"
        printf '# zzz\n' > "${CI_HOME}/.config/folder-backup/sudoers.fragment-zzz"
        _out=$(HOME="${CI_HOME}" LC_ALL=C PTY_IN="2" ci_pty_run remove-project-sudoers --force)
        assert_contains "TP-FOLDER-BACKUP-15c shows the question" "$_out" "Choose draft number to remove"
        assert_not_contains "TP-FOLDER-BACKUP-15c choice is not glued to the prompt" "$_out" "Invalid choice"
        assert_contains "TP-FOLDER-BACKUP-15c removed the second draft" "$_out" "sudoers.fragment-aaa"
        assert_file_missing "TP-FOLDER-BACKUP-15c second draft gone" "${CI_HOME}/.config/folder-backup/sudoers.fragment-aaa"
        assert_file_exists "TP-FOLDER-BACKUP-15c legacy remains" "${CI_HOME}/.config/folder-backup/sudoers.fragment"
        assert_file_exists "TP-FOLDER-BACKUP-15c third draft remains" "${CI_HOME}/.config/folder-backup/sudoers.fragment-zzz"
    else
        t_skip "TP-FOLDER-BACKUP-15c TTY multi-draft picker (no python3 for PTY)"
    fi

    # TP-FOLDER-BACKUP-16 restore dest whitelist (W-ETC-USER / hard deny /etc/passwd)
    _broot16="${CI_HOME}/backup-root16"
    _dep16="${_broot16}/folder-backup"
    mkdir -p "${_dep16}"
    _rsrc16="${CI_HOME}/wl-src"
    mkdir -p "${_rsrc16}"
    printf 'wl\n' > "${_rsrc16}/f.txt"
    _day16=$(date +%Y%m%d)
    _aname16="wl-src-${_day16}-1.tar.gz"
    tar -C "${CI_HOME}" -czf "${_dep16}/${_aname16}" "wl-src"
    _user16=$(id -un 2>/dev/null || echo "unknown")
    # AC-18: /etc/passwd always refuse
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot16}" \
        sh "${SCRIPT}" restore "${_aname16}" /etc/passwd 2>&1 >/dev/null)
    _ec16=$?
    assert_eq "TP-FOLDER-BACKUP-16 refuse /etc/passwd exit 1" 1 "${_ec16}"
    assert_contains "TP-FOLDER-BACKUP-16 passwd message" "$_err" "/etc/passwd"
    # Exact /etc refuse
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot16}" \
        sh "${SCRIPT}" restore "${_aname16}" /etc 2>&1 >/dev/null)
    _ec16=$?
    assert_eq "TP-FOLDER-BACKUP-16 refuse exact /etc exit 1" 1 "${_ec16}"
    # /etc/<other-user> refuse (pick a name that is not invoker)
    _other16="nginx-adm"
    if [ "${_other16}" = "${_user16}" ]; then
        _other16="not-${_user16}-x"
    fi
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot16}" \
        sh "${SCRIPT}" restore "${_aname16}" "/etc/${_other16}" 2>&1 >/dev/null)
    _ec16=$?
    assert_eq "TP-FOLDER-BACKUP-16 refuse /etc/other-user exit 1" 1 "${_ec16}"
    assert_contains "TP-FOLDER-BACKUP-16 other-user whitelist message" "$_err" "whitelist"
    # W-ETC-USER: dest /etc/{{username}} must pass dest gate (not hard refuse messages).
    # Extract may still fail later (permissions under /etc); that still proves gate allow.
    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot16}" \
        sh "${SCRIPT}" restore "${_aname16}" "/etc/${_user16}" 2>&1 >/dev/null)
    _ec16=$?
    assert_not_contains "TP-FOLDER-BACKUP-16 W-ETC-USER not pure system refuse" "$_err" "Refusing restore under system path"
    assert_not_contains "TP-FOLDER-BACKUP-16 W-ETC-USER not dangerous exact refuse" "$_err" "dangerous system path"
    assert_not_contains "TP-FOLDER-BACKUP-16 W-ETC-USER not protected passwd refuse" "$_err" "protected system path"
    if [ "${_ec16}" -eq 0 ]; then
        t_pass "TP-FOLDER-BACKUP-16 W-ETC-USER full restore exit 0 (writable)"
    else
        t_pass "TP-FOLDER-BACKUP-16 W-ETC-USER dest gate allowed (later fail ec=${_ec16} OK)"
    fi

    # TP-FOLDER-BACKUP-18 daily retention: max 5 same-day per basename (writable BACKUP_ROOT)
    _broot18="${CI_HOME}/ret-daily-root"
    _dep18="${_broot18}/folder-backup"
    mkdir -p "${_dep18}"
    _rsrc18="${CI_HOME}/ret-daily-src"
    mkdir -p "${_rsrc18}"
    printf 'd\n' > "${_rsrc18}/f.txt"
    _day18=$(date +%Y%m%d)
    # Pre-seed 5 same-day archives (N=1..5); next backup creates N=6 then prunes to 5
    _i=1
    while [ "${_i}" -le 5 ]; do
        printf 'x' > "${_dep18}/ret-daily-src-${_day18}-${_i}.tar.gz"
        _i=$((_i + 1))
    done
    # Other basename must not be pruned
    printf 'y' > "${_dep18}/other-proj-${_day18}-1.tar.gz"
    # Other day for same basename must not be pruned by daily rule
    printf 'z' > "${_dep18}/ret-daily-src-20200101-1.tar.gz"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot18}" BACKUP_NOTATION="folder-backup" \
        MAX_DAILY_BACKUPS=5 MAX_TOTAL_BACKUPS=30 \
        sh "${SCRIPT}" backup "${_rsrc18}" 2>&1)
    _ec18=$?
    assert_eq "TP-FOLDER-BACKUP-18 daily retention backup exit 0" 0 "${_ec18}"
    _cnt18=$(find "${_dep18}" -name "ret-daily-src-${_day18}-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
    assert_eq "TP-FOLDER-BACKUP-18 same-day count ≤5" 5 "${_cnt18}"
    assert_file_missing "TP-FOLDER-BACKUP-18 pruned lowest N (1)" "${_dep18}/ret-daily-src-${_day18}-1.tar.gz"
    assert_file_exists "TP-FOLDER-BACKUP-18 other day kept" "${_dep18}/ret-daily-src-20200101-1.tar.gz"
    # TP-FOLDER-BACKUP-18b: other basename not deleted by daily prune
    assert_file_exists "TP-FOLDER-BACKUP-18b other basename kept" "${_dep18}/other-proj-${_day18}-1.tar.gz"

    # TP-FOLDER-BACKUP-18c failed backup does not trigger daily prune (AC-5)
    _broot18c="${CI_HOME}/ret-daily-fail-root"
    _dep18c="${_broot18c}/folder-backup"
    mkdir -p "${_dep18c}"
    _day18c=$(date +%Y%m%d)
    _i=1
    while [ "${_i}" -le 6 ]; do
        printf 'k' > "${_dep18c}/ret-fail-daily-${_day18c}-${_i}.tar.gz"
        _i=$((_i + 1))
    done
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot18c}" BACKUP_NOTATION="folder-backup" \
        MAX_DAILY_BACKUPS=5 MAX_TOTAL_BACKUPS=30 \
        sh "${SCRIPT}" backup "${CI_HOME}/ret-fail-daily" 2>&1)
    _ec18c=$?
    assert_eq "TP-FOLDER-BACKUP-18c failed backup exit 1" 1 "${_ec18c}"
    _cnt18c=$(find "${_dep18c}" -name "ret-fail-daily-${_day18c}-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
    assert_eq "TP-FOLDER-BACKUP-18c same-day still 6" 6 "${_cnt18c}"
    assert_file_exists "TP-FOLDER-BACKUP-18c lowest N kept" "${_dep18c}/ret-fail-daily-${_day18c}-1.tar.gz"

    # TP-FOLDER-BACKUP-17 total retention: max 30 per basename
    _broot17="${CI_HOME}/ret-total-root"
    _dep17="${_broot17}/folder-backup"
    mkdir -p "${_dep17}"
    _rsrc17="${CI_HOME}/ret-total-src"
    mkdir -p "${_rsrc17}"
    printf 't\n' > "${_rsrc17}/f.txt"
    _day17=$(date +%Y%m%d)
    # Seed 30 archives across older days + today will add 31st then prune to 30
    _j=1
    while [ "${_j}" -le 15 ]; do
        printf 'o' > "${_dep17}/ret-total-src-20200101-${_j}.tar.gz"
        _j=$((_j + 1))
    done
    _j=1
    while [ "${_j}" -le 15 ]; do
        printf 'o' > "${_dep17}/ret-total-src-20200102-${_j}.tar.gz"
        _j=$((_j + 1))
    done
    # Foreign basename filler (must remain)
    printf 'f' > "${_dep17}/foreign-name-20200101-1.tar.gz"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot17}" BACKUP_NOTATION="folder-backup" \
        MAX_DAILY_BACKUPS=50 MAX_TOTAL_BACKUPS=30 \
        sh "${SCRIPT}" backup "${_rsrc17}" 2>&1)
    _ec17=$?
    assert_eq "TP-FOLDER-BACKUP-17 total retention backup exit 0" 0 "${_ec17}"
    _cnt17=$(find "${_dep17}" -name "ret-total-src-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
    assert_eq "TP-FOLDER-BACKUP-17 total count ≤30" 30 "${_cnt17}"
    # Oldest day/N should go first (20200101-1)
    assert_file_missing "TP-FOLDER-BACKUP-17 pruned oldest" "${_dep17}/ret-total-src-20200101-1.tar.gz"
    # TP-FOLDER-BACKUP-17b cross-basename isolation
    assert_file_exists "TP-FOLDER-BACKUP-17b foreign basename kept" "${_dep17}/foreign-name-20200101-1.tar.gz"

    # TP-FOLDER-BACKUP-17c failed backup does not trigger total prune (AC-5)
    _broot17c="${CI_HOME}/ret-total-fail-root"
    _dep17c="${_broot17c}/folder-backup"
    mkdir -p "${_dep17c}"
    _j=1
    while [ "${_j}" -le 16 ]; do
        printf 'o' > "${_dep17c}/ret-fail-total-20200101-${_j}.tar.gz"
        _j=$((_j + 1))
    done
    _j=1
    while [ "${_j}" -le 15 ]; do
        printf 'o' > "${_dep17c}/ret-fail-total-20200102-${_j}.tar.gz"
        _j=$((_j + 1))
    done
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_broot17c}" BACKUP_NOTATION="folder-backup" \
        MAX_DAILY_BACKUPS=50 MAX_TOTAL_BACKUPS=30 \
        sh "${SCRIPT}" backup "${CI_HOME}/ret-fail-total" 2>&1)
    _ec17c=$?
    assert_eq "TP-FOLDER-BACKUP-17c failed backup exit 1" 1 "${_ec17c}"
    _cnt17c=$(find "${_dep17c}" -name "ret-fail-total-*.tar.gz" 2>/dev/null | wc -l | tr -d ' ')
    assert_eq "TP-FOLDER-BACKUP-17c total still 31" 31 "${_cnt17c}"
    assert_file_exists "TP-FOLDER-BACKUP-17c oldest kept" "${_dep17c}/ret-fail-total-20200101-1.tar.gz"

    # print-sudoers must not grant OS-tool rm (retention runs after elev internally)
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" print-sudoers --allow-test-local 2>&1)
    assert_not_contains "TP-FOLDER-BACKUP-01d no retention rm Cmnd" "$_out" "rm -f"

    # TP-FOLDER-BACKUP-22d submit refuses OS-tool grant file (AC-7)
    _badgrant="${CI_HOME}/out/bad-os-tool.json"
    mkdir -p "${CI_HOME}/out"
    printf '%s\n' '{"commands":[{"path":"/usr/bin/mkdir","args":["-p","/var/backup/folder-backup"]}]}' >"${_badgrant}"
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_badgrant}" 2>&1 >/dev/null)
    _ec22d=$?
    assert_eq "TP-FOLDER-BACKUP-22d refuse OS-tool grant exit 1" 1 "${_ec22d}"
    assert_contains "TP-FOLDER-BACKUP-22d refuse message" "${_err}" "OS-tool"

    # TP-FOLDER-BACKUP-19 submit fail-closed when sudoer-cli missing
    _err=$(HOME="${CI_HOME}" SUDOER_CLI="${CI_HOME}/no-such-sudoer-cli" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local 2>&1 >/dev/null)
    _ec19=$?
    assert_eq "TP-FOLDER-BACKUP-19 submit missing cli exit 1" 1 "${_ec19}"
    assert_contains "TP-FOLDER-BACKUP-19 missing sudoer-cli" "$_err" "sudoer-cli not found"

    # TP-FOLDER-BACKUP-20 submit via stub sudoer-cli into writable inbound
    _stub_dir="${CI_HOME}/stub-sudoer"
    mkdir -p "${_stub_dir}/bin" "${_stub_dir}/sudoer-approving"
    cat > "${_stub_dir}/bin/sudoer-cli" <<'STUB'
#!/bin/sh
_file=""
_svc=""
while [ $# -gt 0 ]; do
    case "$1" in
        --json) ;;
        --file) _file="$2"; shift ;;
        --purpose) shift ;;
        --service) _svc="$2"; shift ;;
        add-sudoer-request|update-sudoer-request) ;;
        *) ;;
    esac
    shift
done
[ -n "${_file}" ] && [ -f "${_file}" ] || exit 1
_id="sudoer-20260814-${_svc:-folder-backup}-stub-add-1.json"
# inbound parent is LPU_HOME/sudoer-approving when compose exports LPU_HOME
_in="${LPU_HOME:-}/sudoer-approving"
[ -d "${_in}" ] || _in="${SUDOER_QUEUE_INBOUND:-}"
[ -d "${_in}" ] || exit 1
cp "${_file}" "${_in}/${_id}" || exit 1
printf 'request_id=%s\n' "${_id}"
exit 0
STUB
    chmod 0755 "${_stub_dir}/bin/sudoer-cli"
    _out=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-approving" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local 2>&1)
    _ec20=$?
    assert_eq "TP-FOLDER-BACKUP-20 submit stub exit 0" 0 "${_ec20}"
    assert_contains "TP-FOLDER-BACKUP-20 request_id" "$_out" "request_id="
    assert_contains "TP-FOLDER-BACKUP-20 default add when no host fragment" "$_out" "Submitted add"
    _njson=$(find "${_stub_dir}/sudoer-approving" -type f | wc -l | tr -d ' ')
    assert_eq "TP-FOLDER-BACKUP-20 inbound has file" 1 "${_njson}"
    _stub_body=$(cat "${_stub_dir}/sudoer-approving/"*.json 2>/dev/null || true)
    assert_contains "TP-FOLDER-BACKUP-22f stub inbound has backup" "${_stub_body}" '"backup"'
    assert_contains "TP-FOLDER-BACKUP-22f stub inbound has restore" "${_stub_body}" '"restore"'

    # TP-FOLDER-BACKUP-23 host fragment present → default action=update
    _user23=$(id -un)
    : "${CI_SUDOERS_D:=${CI_HOME}/sudoers.d}"
    mkdir -p "${CI_SUDOERS_D}"
    printf '# host fragment\n' > "${CI_SUDOERS_D}/folder-backup-${_user23}"
    _j23=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-approving" \
        SUDOERS_D_DIR="${CI_SUDOERS_D}" \
        sh "${SCRIPT}" --json submit-sudoer-request --allow-test-local 2>/dev/null)
    _ec23=$?
    assert_eq "TP-FOLDER-BACKUP-23 host present submit exit 0" 0 "${_ec23}"
    assert_contains "TP-FOLDER-BACKUP-23 action update" "${_j23}" '"action":"update"'
    assert_contains "TP-FOLDER-BACKUP-23 detected" "${_j23}" '"action_source":"detected"'
    assert_contains "TP-FOLDER-BACKUP-23 host present true" "${_j23}" '"host_fragment_present":"true"'

    # TP-FOLDER-BACKUP-23b --add overrides host present
    _j23b=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-approving" \
        SUDOERS_D_DIR="${CI_SUDOERS_D}" \
        sh "${SCRIPT}" --json submit-sudoer-request --add --allow-test-local 2>/dev/null)
    assert_eq "TP-FOLDER-BACKUP-23b --add override exit 0" 0 "$?"
    assert_contains "TP-FOLDER-BACKUP-23b forced add" "${_j23b}" '"action":"add"'
    assert_contains "TP-FOLDER-BACKUP-23b explicit" "${_j23b}" '"action_source":"explicit"'
    rm -f "${CI_SUDOERS_D}/folder-backup-${_user23}"

    # TP-FOLDER-BACKUP-23c other user's fragment does not flip this user to update
    printf '# other user host fragment\n' > "${CI_SUDOERS_D}/folder-backup-otheruser"
    _j23c=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub_dir}/bin/sudoer-cli" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="${_stub_dir}/sudoer-approving" \
        SUDOERS_D_DIR="${CI_SUDOERS_D}" \
        sh "${SCRIPT}" --json submit-sudoer-request --allow-test-local 2>/dev/null)
    assert_eq "TP-FOLDER-BACKUP-23c other-user submit exit 0" 0 "$?"
    assert_contains "TP-FOLDER-BACKUP-23c stays add" "${_j23c}" '"action":"add"'
    assert_contains "TP-FOLDER-BACKUP-23c detected" "${_j23c}" '"action_source":"detected"'
    assert_contains "TP-FOLDER-BACKUP-23c host present false" "${_j23c}" '"host_fragment_present":"false"'
    rm -f "${CI_SUDOERS_D}/folder-backup-otheruser"

    # TP-FOLDER-BACKUP-24 generate writes verified compact JSON (both verbs)
    _user24=$(id -un)
    _gen_default="${CI_HOME}/.config/folder-backup/sudoer-request-${_user24}.json"
    _out24=$(HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local 2>&1)
    _ec24=$?
    assert_eq "TP-FOLDER-BACKUP-24 generate exit 0" 0 "${_ec24}"
    assert_file_exists "TP-FOLDER-BACKUP-24 default dest exists" "${_gen_default}"
    _gen_body=$(cat "${_gen_default}" 2>/dev/null || true)
    assert_contains "TP-FOLDER-BACKUP-24 compact token" "${_gen_body}" '},{'
    assert_contains "TP-FOLDER-BACKUP-24 has backup" "${_gen_body}" '"backup"'
    assert_contains "TP-FOLDER-BACKUP-24 has restore" "${_gen_body}" '"restore"'
    if printf '%s\n' "${_gen_body}" | grep -Fq '"args":["backup","*"]'; then
        t_pass "TP-FOLDER-BACKUP-26b generate compact backup star"
    else
        t_fail "TP-FOLDER-BACKUP-26b generate compact backup star" "missing compact args backup *"
    fi
    if printf '%s\n' "${_gen_body}" | grep -Fq '"args":["restore","*"]'; then
        t_pass "TP-FOLDER-BACKUP-26b generate compact restore star"
    else
        t_fail "TP-FOLDER-BACKUP-26b generate compact restore star" "missing compact args restore *"
    fi
    assert_contains "TP-FOLDER-BACKUP-24 human next submit" "${_out24}" "submit-sudoer-request"
    assert_not_contains "TP-FOLDER-BACKUP-24 no /etc dest" "${_out24}" "/etc/sudoers.d/"

    # TP-FOLDER-BACKUP-24b explicit path + /etc refuse
    _gen_exp="${CI_HOME}/out/verified-grant.json"
    mkdir -p "${CI_HOME}/out"
    _out24b=$(HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local "${_gen_exp}" 2>&1)
    assert_eq "TP-FOLDER-BACKUP-24b explicit path exit 0" 0 "$?"
    assert_file_exists "TP-FOLDER-BACKUP-24b explicit dest" "${_gen_exp}"
    assert_contains "TP-FOLDER-BACKUP-24b explicit backup" "$(cat "${_gen_exp}")" '"backup"'
    _err24c=$(HOME="${CI_HOME}" sh "${SCRIPT}" generate-sudoer-request --allow-test-local /etc/sudoers.d/folder-backup-nope 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-24b refuse /etc exit 1" 1 "$?"
    assert_contains "TP-FOLDER-BACKUP-24b refuse /etc message" "${_err24c}" "/etc"

    # TP-FOLDER-BACKUP-24d dest is readable without sudo (review/suite fixture)
    if [ -r "${_gen_exp}" ]; then
        t_pass "TP-FOLDER-BACKUP-24d dest readable without sudo"
    else
        t_fail "TP-FOLDER-BACKUP-24d dest readable without sudo" "not readable: ${_gen_exp}"
    fi
    _body24d=$(cat "${_gen_exp}" 2>/dev/null || true)
    assert_contains "TP-FOLDER-BACKUP-24d cat without sudo has backup" "${_body24d}" '"backup"'
    assert_contains "TP-FOLDER-BACKUP-24d cat without sudo has restore" "${_body24d}" '"restore"'

    # TP-FOLDER-BACKUP-24c generated file through real sudoer-cli convert keeps both verbs
    if [ -n "${_srcli}" ] && [ -x "${_srcli}" ]; then
        _p24="${CI_HOME}/out/gen-convert.sudoers"
        _gconv="${CI_HOME}/out/gen-wellknown.json"
        sed 's|"path": *"[^"]*/folder-backup"|"path": "/usr/local/bin/folder-backup"|g' "${_gen_exp}" >"${_gconv}"
        PATH=$(fb_ci_quiet_rm_path) HOME="${CI_HOME}" sh "${_srcli}" json-to-sudoers --file "${_gconv}" --out "${_p24}" >/dev/null 2>&1
        assert_eq "TP-FOLDER-BACKUP-24c convert exit 0" 0 "$?"
        _c24=$(cat "${_p24}" 2>/dev/null || true)
        assert_contains "TP-FOLDER-BACKUP-24c convert backup" "${_c24}" "folder-backup backup"
        assert_contains "TP-FOLDER-BACKUP-24c convert restore" "${_c24}" "folder-backup restore"
        assert_contains "TP-FOLDER-BACKUP-24c convert backup star" "${_c24}" "folder-backup backup *"
        assert_contains "TP-FOLDER-BACKUP-24c convert restore star" "${_c24}" "folder-backup restore *"
    fi

    # TP-FOLDER-BACKUP-25 operator-readable inbound-fidelity error (restore-only queued body)
    _stub25="${CI_HOME}/stub-drop"
    mkdir -p "${_stub25}/bin" "${_stub25}/sudoer-approving"
    cat > "${_stub25}/bin/sudoer-cli" <<'STUB25'
#!/bin/sh
_file=""
_svc=""
while [ $# -gt 0 ]; do
    case "$1" in
        --json) ;;
        --file) _file="$2"; shift ;;
        --purpose) shift ;;
        --service) _svc="$2"; shift ;;
        add-sudoer-request|update-sudoer-request) ;;
        *) ;;
    esac
    shift
done
[ -n "${_file}" ] && [ -f "${_file}" ] || exit 1
_id="sudoer-20260817-${_svc:-folder-backup}-stub-drop-1.json"
_in="${LPU_HOME:-}/sudoer-approving"
[ -d "${_in}" ] || _in="${SUDOER_QUEUE_INBOUND:-}"
[ -d "${_in}" ] || exit 1
printf '%s\n' '{"purpose":"backup and restore","commands":[{"args":["restore"]}]}' >"${_in}/${_id}" || exit 1
printf 'request_id=%s\n' "${_id}"
exit 0
STUB25
    chmod 0755 "${_stub25}/bin/sudoer-cli"
    _err25=$(HOME="${CI_HOME}" \
        SUDOER_CLI="${_stub25}/bin/sudoer-cli" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="${_stub25}/sudoer-approving" \
        sh "${SCRIPT}" submit-sudoer-request --allow-test-local 2>&1 >/dev/null)
    assert_eq "TP-FOLDER-BACKUP-25 inbound incomplete exit 1" 1 "$?"
    assert_contains "TP-FOLDER-BACKUP-25 what happened" "${_err25}" "incomplete"
    assert_contains "TP-FOLDER-BACKUP-25b next generate" "${_err25}" "generate-sudoer-request"
    assert_not_contains "TP-FOLDER-BACKUP-25c no sibling jargon" "${_err25}" "sibling re-encode"

    # TP-FOLDER-BACKUP-22e (submit path): real sudoer-cli + readable test inbound
    if [ -n "${_srcli}" ] && [ -x "${_srcli}" ]; then
        _q22="${CI_HOME}/sr-real-q"
        mkdir -p "${_q22}/sudoer-request" "${_q22}/sudoer-approved" "${_q22}/sudoer-rejected"
        _jsub="${CI_HOME}/out/pretty-wellknown.json"
        if [ ! -f "${_jsub}" ]; then
            t_skip "TP-FOLDER-BACKUP-22e real submit (no well-known grant fixture)"
        else
            _live22e=$(ci_snapshot_live_sudoer_inbound)
            _out22e=$(PATH=$(fb_ci_quiet_rm_path) HOME="${CI_HOME}" \
                SUDOER_CLI="${_srcli}" \
                SUDOER_ADM_USER="$(id -un)" \
                SUDOER_QUEUE_INBOUND="${_q22}/sudoer-request" \
                SUDOER_CLI_ALLOW_TEST_ROOTS=1 \
                sh "${SCRIPT}" submit-sudoer-request --allow-test-local "${_jsub}" 2>&1)
            _ec22e=$?
            assert_eq "TP-FOLDER-BACKUP-22e real submit exit 0" 0 "${_ec22e}"
            _n22=$(find "${_q22}/sudoer-request" -name 'sudoer-*.json' -type f | wc -l | tr -d ' ')
            assert_eq "TP-FOLDER-BACKUP-22e real inbound has file" 1 "${_n22}"
            _real_body=$(cat "${_q22}/sudoer-request/"sudoer-*.json 2>/dev/null || true)
            assert_contains "TP-FOLDER-BACKUP-22e inbound backup" "${_real_body}" '"backup"'
            assert_contains "TP-FOLDER-BACKUP-22e inbound restore" "${_real_body}" '"restore"'
            ci_assert_no_live_sudoer_enqueue "TP-FOLDER-BACKUP-22e did not enqueue live inbound" "${_live22e}"
        fi
    fi

    # TP-FOLDER-BACKUP-21 public inbound preferred over leftover home sudoer-approving
    _pub21="${CI_HOME}/var-sudoer-cli"
    mkdir -p "${_pub21}/sudoer-request" "${CI_HOME}/sudoer-approving"
    # leftover real dir must not win
    _j21=$(HOME="${CI_HOME}" \
        SUDOER_PUBLIC_ROOT="${_pub21}" \
        SUDOER_ADM_USER="$(id -un)" \
        SUDOER_QUEUE_INBOUND="" \
        sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-FOLDER-BACKUP-21 about prefers public inbound" "${_j21}" "${_pub21}/sudoer-request"
    assert_not_contains "TP-FOLDER-BACKUP-21 not leftover approving" "${_j21}" "${CI_HOME}/sudoer-approving"
    # Type 0 must not mkdir a missing public inbound
    _missing21="${CI_HOME}/var-sudoer-cli-absent"
    _j21b=$(HOME="${CI_HOME}" \
        SUDOER_PUBLIC_ROOT="${_missing21}" \
        SUDOER_ADM_USER="no-such-sudoer-adm-fb21" \
        SUDOER_QUEUE_INBOUND="" \
        sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-FOLDER-BACKUP-21 missing public is not_found" "${_j21b}" '"sudoer_inbound":"not_found"'
    assert_file_missing "TP-FOLDER-BACKUP-21 no Type 0 mkdir public inbound" "${_missing21}/sudoer-request"
    assert_file_missing "TP-FOLDER-BACKUP-21 no Type 0 mkdir public parent" "${_missing21}"

    # TP-FOLDER-BACKUP-21b env override wins over public inbound
    _env21="${CI_HOME}/env-inbound"
    mkdir -p "${_env21}"
    _j21c=$(HOME="${CI_HOME}" \
        SUDOER_PUBLIC_ROOT="${_pub21}" \
        SUDOER_QUEUE_INBOUND="${_env21}" \
        SUDOER_ADM_USER="$(id -un)" \
        sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-FOLDER-BACKUP-21b env inbound wins" "${_j21c}" "${_env21}"
    assert_not_contains "TP-FOLDER-BACKUP-21b env beats public" "${_j21c}" "${_pub21}/sudoer-request"

    # cleanup remaining drafts
    HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force "${CI_HOME}/.config/folder-backup/sudoers.fragment" >/dev/null 2>&1 || true
    HOME="${CI_HOME}" sh "${SCRIPT}" remove-project-sudoers --force "${CI_HOME}/.config/folder-backup/sudoers.fragment-otheruser" >/dev/null 2>&1 || true

    ci_cleanup_env
}
