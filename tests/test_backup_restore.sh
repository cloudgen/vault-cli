# =============================================================================
# tests/test_backup_restore.sh — folder archive backup and restore
# =============================================================================
# Deposit directory: ${BACKUP_ROOT}/${BACKUP_NOTATION} = /var/backups/${APP_NAME}
# Tests override BACKUP_ROOT so they do not write the host /var/backups tree.
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_backup_restore() {
    t_header "Backup and restore (TP-BACKUP)"

    require_cmd sh
    require_cmd tar
    require_cmd find

    ci_isolated_env

    _src="${CI_HOME}/sample-project"
    mkdir -p "${_src}/nested"
    printf '%s\n' 'backup-payload' > "${_src}/nested/note.txt"
    _root="${CI_HOME}/backups"
    mkdir -p "${_root}"
    _dest_parent="${CI_HOME}/restored"

    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_root}" BACKUP_NOTATION="${APP_NAME}" \
        sh "${SCRIPT}" backup "${_src}" 2>&1)
    _ec=$?
    assert_eq "TP-BACKUP-01 backup exit 0" 0 "$_ec"
    assert_contains "TP-BACKUP-01 complete" "$_out" "Backup complete:"
    assert_contains "TP-BACKUP-01 deposit under app folder" "$_out" "${_root}/${APP_NAME}/"
    assert_contains "TP-BACKUP-01 verified" "$_out" "Verified:"

    _arc=$(find "${_root}/${APP_NAME}" -name 'sample-project-*.tar.gz' 2>/dev/null | head -n 1)
    if [ -n "${_arc}" ] && [ -f "${_arc}" ]; then
        t_pass "TP-BACKUP-01 archive file exists"
    else
        t_fail "TP-BACKUP-01 archive file exists (missing under ${_root}/${APP_NAME})"
        ci_cleanup_env
        return 0
    fi
    case "${_arc}" in
        "${_root}/${APP_NAME}/"*) t_pass "TP-BACKUP-01 archive path is the global folder" ;;
        *) t_fail "TP-BACKUP-01 archive path is the global folder (${_arc})" ;;
    esac

    _j=$(HOME="${CI_HOME}" BACKUP_ROOT="${_root}" BACKUP_NOTATION="${APP_NAME}" \
        sh "${SCRIPT}" --json backup "${_src}" 2>/dev/null)
    assert_eq "TP-BACKUP-02 second backup exit 0" 0 "$?"
    assert_contains "TP-BACKUP-02 json type" "$_j" '"type":"backup"'
    assert_contains "TP-BACKUP-02 json verified" "$_j" '"verified":"true"'
    assert_contains "TP-BACKUP-02 json notation" "$_j" '"backup_notation":"'"${APP_NAME}"'"'
    assert_contains "TP-BACKUP-02 next N" "$_j" 'sample-project-'
    assert_not_contains "TP-BACKUP-02 does not reuse N=1 only" "$_j" 'sample-project-'"$(date +%Y%m%d)"'-1.tar.gz'

    mkdir -p "${_dest_parent}"
    _out=$(HOME="${CI_HOME}" BACKUP_ROOT="${_root}" BACKUP_NOTATION="${APP_NAME}" \
        sh "${SCRIPT}" restore sample-project "${_dest_parent}/sample-project" 2>&1)
    assert_eq "TP-BACKUP-03 restore exit 0" 0 "$?"
    assert_contains "TP-BACKUP-03 restore complete" "$_out" "Restore complete:"
    if [ -f "${_dest_parent}/sample-project/nested/note.txt" ]; then
        _body=$(cat "${_dest_parent}/sample-project/nested/note.txt")
        assert_eq "TP-BACKUP-03 restored bytes" "backup-payload" "${_body}"
    else
        t_fail "TP-BACKUP-03 restored file missing"
    fi

    _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${_root}" sh "${SCRIPT}" backup "${CI_HOME}/no-such-dir" 2>&1 >/dev/null) || true
    assert_contains "TP-BACKUP-04 missing source" "$_err" "Source is not a directory"

    _about=$(sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-BACKUP-05 default backup root" "$_about" '"backup_root":"/var/backups"'
    assert_contains "TP-BACKUP-05 default notation is app name" "$_about" '"backup_notation":"'"${APP_NAME}"'"'
    assert_contains "TP-BACKUP-05 default global folder" "$_about" '"deposit_dir":"/var/backups/'"${APP_NAME}"'"'

    ci_cleanup_env
}
