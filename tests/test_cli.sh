# =============================================================================
# tests/test_cli.sh — CLI surface
# Channel verbs are listed. version-check / self-update use a non-empty
# unreachable URL (127.0.0.1 only). A non-interactive line with no command
# copies this file (self-install). No live GitHub fetch.
# =============================================================================
# Primary REQs: requirement-shell-cli-interface, requirement-shell-cli-default-interaction,
# requirement-shell-output-requirements, requirement-shell-cli-storage
# TP family: TP-CLI-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface (TP-CLI)"

    require_cmd sh
    require_cmd grep
    require_cmd tar

    # Isolate HOME/cache so about/version do not mkdir on the live login.
    ci_isolated_env

    # TP-CLI-01 syntax
    sh -n "${SCRIPT}"
    assert_eq "TP-CLI-01 sh -n ship unit" 0 "$?"

    # TP-CLI-02 version human
    _out=$(sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-02 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-02 version mentions app" "$_out" "${APP_NAME}"
    assert_contains "TP-CLI-02 version mentions VERSION" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-03 version json
    _out=$(sh "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 type version" "$_out" '"type":"version"'
    assert_contains "TP-CLI-03 app field" "$_out" "\"app\":\"${APP_NAME}\""
    assert_contains "TP-CLI-03 version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # TP-CLI-04 help lists local lifecycle, selfmanaged channel verbs, and domain
    _out=$(sh "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help uninstall" "$_out" "uninstall"
    assert_contains "TP-CLI-04 help where-is-me" "$_out" "where-is-me"
    assert_contains "TP-CLI-04 help list" "$_out" "list [ssh-vault|github-vault|cloudflare-vault]"
    assert_contains "TP-CLI-04 help add" "$_out" "add <kind>"
    assert_contains "TP-CLI-04 help update" "$_out" "update <kind>"
    assert_contains "TP-CLI-04 help edit" "$_out" "edit <kind>"
    assert_contains "TP-CLI-04 help --name" "$_out" "--name"
    assert_contains "TP-CLI-04 help --key-file" "$_out" "--key-file"
    assert_contains "TP-CLI-04 help --token-file" "$_out" "--token-file"
    assert_contains "TP-CLI-04 help VAULT_ROOT" "$_out" "VAULT_ROOT"
    assert_not_contains "TP-CLI-04 help omits print-sudoers" "$_out" "print-sudoers"
    assert_not_contains "TP-CLI-04 help omits grant heading" "$_out" "Grant and draft setup"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_contains "TP-CLI-04 help menu" "$_out" "Numbered boards: client-side, self-management, and Exit"
    assert_contains "TP-CLI-04 help main" "$_out" "Same as menu"
    assert_contains "TP-CLI-04 help self-install" "$_out" "self-install"
    assert_contains "TP-CLI-04 help self-update" "$_out" "self-update"
    assert_contains "TP-CLI-04 help self-uninstall" "$_out" "self-uninstall"
    assert_contains "TP-CLI-04 help version-check" "$_out" "version-check"
    assert_contains "TP-CLI-04 help SCRIPT_URL channel" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 no CHECKSUM" "$_out" "CHECKSUM"

    # TP-CLI-17 work commands are list/add/update/edit. self-update stays above that slice.
    assert_contains "TP-CLI-17 work heading" "$_out" "Work commands:"
    assert_not_contains "TP-CLI-17 no grant heading" "$_out" "Grant and draft setup"
    _work=$(printf '%s' "$_out" | sed -n '/Work commands:/,/Global Options:/p')
    assert_contains "TP-CLI-17 work has list" "$_work" "list [ssh-vault|github-vault|cloudflare-vault]"
    assert_contains "TP-CLI-17 work has add" "$_work" "add <kind>"
    assert_contains "TP-CLI-17 work has update" "$_work" "update <kind>"
    assert_contains "TP-CLI-17 work has edit" "$_work" "edit <kind>"
    assert_contains "TP-CLI-17 work has backup" "$_work" "backup <source-folder>"
    assert_contains "TP-CLI-17 work has restore" "$_work" "restore <archive|prefix> [dest]"
    assert_contains "TP-CLI-17 work names global backup folder" "$_work" "/var/backups/${APP_NAME}/"
    assert_not_contains "TP-CLI-17 work omits self-update" "$_work" "self-update"
    assert_not_contains "TP-CLI-17 work omits print-sudoers" "$_work" "print-sudoers"

    # TP-CLI-05 help json (short structured note — not a long human dump)
    _out=$(sh "${SCRIPT}" --json help 2>/dev/null)
    assert_eq "TP-CLI-05 help --json exit 0" 0 "$?"
    assert_contains "TP-CLI-05 help json success" "$_out" '"type":"success"'
    assert_contains "TP-CLI-05 help json command" "$_out" '"command":"help"'
    assert_contains "TP-CLI-05 help json note" "$_out" '"note"'
    assert_not_contains "TP-CLI-05 help json not human Usage" "$_out" "Usage:"

    # TP-CLI-06 about json domain + cache folders, no channel
    _out=$(sh "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-06 type about" "$_out" '"type":"about"'
    assert_contains "TP-CLI-06 cache_used" "$_out" '"cache_used"'
    assert_contains "TP-CLI-06 cache_preferred field" "$_out" '"cache_preferred"'
    assert_contains "TP-CLI-06 cache_preferred path" "$_out" '"cache_preferred":"/dev/shm/cache/cache-'"${APP_NAME}"'-'
    assert_contains "TP-CLI-06 cache_fallback field" "$_out" '"cache_fallback"'
    assert_contains "TP-CLI-06 cache_fallback_2" "$_out" '"cache_fallback_2"'
    assert_contains "TP-CLI-06 cache_fallback leaf" "$_out" "cache-${APP_NAME}"
    assert_contains "TP-CLI-06 effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-06 persistence_storage field" "$_out" '"persistence_storage"'
    assert_contains "TP-CLI-06 persistence_storage leaf" "$_out" "/.local/${APP_NAME}"
    assert_contains "TP-CLI-06 vault_root" "$_out" '"vault_root"'
    assert_contains "TP-CLI-06 vault_root path" "$_out" '"vault_root":"'
    assert_contains "TP-CLI-06 ssh_vault_count" "$_out" '"ssh_vault_count"'
    assert_contains "TP-CLI-06 github_vault_count" "$_out" '"github_vault_count"'
    assert_contains "TP-CLI-06 cloudflare_vault_count" "$_out" '"cloudflare_vault_count"'
    assert_contains "TP-CLI-06 ssh_vault_reserved" "$_out" '"ssh_vault_reserved"'
    assert_contains "TP-CLI-06 backup_root" "$_out" '"backup_root":"/var/backups"'
    assert_contains "TP-CLI-06 backup_notation" "$_out" '"backup_notation":"'"${APP_NAME}"'"'
    assert_contains "TP-CLI-06 deposit_dir" "$_out" '"deposit_dir":"/var/backups/'"${APP_NAME}"'"'
    assert_not_contains "TP-CLI-06 no CHECKSUM" "$_out" "CHECKSUM"
    assert_not_contains "TP-CLI-06 no SCRIPT_URL" "$_out" "SCRIPT_URL"

    _hout=$(sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-06 human Cache folder used" "$_hout" "Cache folder used:"
    assert_contains "TP-CLI-06 human Cache folder preferred" "$_hout" "Cache folder (preferred):"
    assert_contains "TP-CLI-06 human Cache folder 1st fallback" "$_hout" "Cache folder (1st fallback):"
    assert_contains "TP-CLI-06 human Cache folder 2nd fallback" "$_hout" "Cache folder (2nd fallback):"
    assert_contains "TP-CLI-06 human Persistence storage" "$_hout" "Persistence storage:"
    assert_contains "TP-CLI-06 human Persistence path leaf" "$_hout" "/.local/${APP_NAME}"
    assert_contains "TP-CLI-06 human deposit directory" "$_hout" "Deposit directory: /var/backups/${APP_NAME}"
    assert_not_contains "TP-CLI-06 no Storage (effective) label" "$_hout" "Storage (effective)"
    assert_not_contains "TP-CLI-06 no Storage (fallback) label" "$_hout" "Storage (fallback)"
    assert_not_contains "TP-CLI-06 no Cache folder (live) label" "$_hout" "Cache folder (live)"

    # TP-CLI-07 off-TTY empty argv = CLI self-install (copy; not help; not the boards)
    _out=$(SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" sh "${SCRIPT}" 2>&1)
    _ec=$?
    assert_eq "TP-CLI-07 empty argv exit 0" 0 "$_ec"
    assert_file_exists "TP-CLI-07 empty argv installed binary" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-CLI-07 empty argv self-install banner" "$_out" "Starting self-install"
    assert_contains "TP-CLI-07 empty argv copies the local script" "$_out" "Installing from local script"
    assert_not_contains "TP-CLI-07 empty argv is not help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-07 empty argv not numbered list" "$_out" "9. Exit"
    _mode=$(stat -c '%a' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || stat -f '%OLp' "${CI_USER_BIN}/${APP_NAME}" 2>/dev/null || echo "")
    case "${_mode}" in
        700|0700) t_pass "TP-CLI-07 local dest mode 0700" ;;
        *) t_fail "TP-CLI-07 local dest mode 0700, got '${_mode}'" ;;
    esac
    _out=$(SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" sh "${SCRIPT}" 2>&1)
    assert_eq "TP-CLI-07 second empty argv exit 0" 0 "$?"
    assert_contains "TP-CLI-07 second empty argv already installed" "$_out" "already installed"
    rm -f "${CI_USER_BIN}/${APP_NAME}"

    # TP-CLI-08 unknown command fail-closed
    _err=$(sh "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown error text" "$_err" "Unknown command"

    _err=$(sh "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-08 unknown --json type" "$_err" '"type":"out_error"'

    # TP-CLI-09 quiet suppresses version info
    _out=$(sh "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-09 quiet version exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-09 quiet suppresses human version"
    else
        t_fail "TP-CLI-09 quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    # TP-CLI-10 selfmanaged channel verbs are routed. Offline URL must not install.
    _offurl="http://127.0.0.1:9/folder-backup-offline"
    _err=$(SCRIPT_URL="${_offurl}" sh "${SCRIPT}" self-update 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 self-update exit 1" 1 "$?"
    assert_not_contains "TP-CLI-10 self-update is routed" "$_err" "Unknown command"
    assert_contains "TP-CLI-10 self-update fetch failure" "$_err" "Failed to fetch"

    _err=$(SCRIPT_URL="${_offurl}" sh "${SCRIPT}" version-check 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 version-check exit 1" 1 "$?"
    assert_not_contains "TP-CLI-10 version-check is routed" "$_err" "Unknown command"
    assert_contains "TP-CLI-10 version-check fetch failure" "$_err" "Failed to fetch"

    _err=$(sh "${SCRIPT}" self-uninstall 2>&1 >/dev/null)
    assert_eq "TP-CLI-10 self-uninstall absent exit 0" 0 "$?"
    assert_not_contains "TP-CLI-10 self-uninstall is routed" "$_err" "Unknown command"

    # TP-CLI-20 do-not-capture-read: no $() of a prompt helper in the ship unit
    _cap=$(grep -n '$(prompt_' "${SCRIPT}" | grep -v ':[[:space:]]*#' || true)
    if [ -z "${_cap}" ]; then
        t_pass "TP-CLI-20 no command substitution of prompt helpers"
    else
        t_fail "TP-CLI-20 captured prompt helper: ${_cap}"
    fi

    # TP-CLI-11 set -u HOME unset still works for version
    _out=$(env -u HOME sh "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-11 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-11 env -u HOME version text" "$_out" "${PRODUCT_VERSION}"

    # TP-CLI-12 cache isolation under temp HOME (per login + process id)
    ci_isolated_env
    _login=$(id -un 2>/dev/null || echo "unknown")
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-12 isolated about has app in cache" "$_out" "${APP_NAME}"
    _pref=$(printf '%s' "$_out" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _pid="${_pref##*-}"
    case "${_pref}" in
        /dev/shm/cache/cache-"${APP_NAME}"-"${_login}"-[0-9]*)
            t_pass "TP-CLI-12 cache_preferred is shm login process leaf"
            ;;
        *) t_fail "TP-CLI-12 cache_preferred unexpected: '${_pref:-empty}'" ;;
    esac
    _fb=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_fallback 1st" "/tmp/cache/cache-${APP_NAME}-${_login}-${_pid}" "${_fb}"
    _fb2=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_fallback 2nd" "${CI_HOME}/.cache/cache-${APP_NAME}-${_pid}" "${_fb2}"
    _used=$(printf '%s' "$_out" | sed -n 's/.*"cache_used":"\([^"]*\)".*/\1/p' | head -n1)
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 cache_used matches effective" "${_eff}" "${_used}"
    if [ -n "$_eff" ] && [ -d "$_eff" ] && [ ! -h "$_eff" ]; then
        t_pass "TP-CLI-12 effective cache directory exists"
    else
        t_fail "TP-CLI-12 effective cache missing: '${_eff:-empty}'"
    fi
    case "${_eff}" in
        /dev/shm/"${APP_NAME}"|/dev/shm/"${APP_NAME}"-*)
            t_fail "TP-CLI-12 effective cache must not be ram-drive project shape: '${_eff}'"
            ;;
        *) t_pass "TP-CLI-12 effective cache is not a ram-drive project shape" ;;
    esac
    _perm=$(command ls -ld "${_eff}" 2>/dev/null | cut -c1-10)
    assert_eq "TP-CLI-12 cache leaf mode 0700" "drwx------" "${_perm}"
    if [ -O "${_eff}" ]; then
        t_pass "TP-CLI-12 cache leaf owned by this login"
    else
        t_fail "TP-CLI-12 cache leaf not owned by this login: '${_eff}'"
    fi
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" FOLDER_BACKUP_CACHE_SKIP=preferred \
        sh "${SCRIPT}" about 2>&1 >/dev/null)
    assert_not_contains "TP-CLI-12 silent cache fallback" "${_err}" "fallback"
    assert_not_contains "TP-CLI-12 silent cache fallback error" "${_err}" "Cannot create cache"
    _skip=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" FOLDER_BACKUP_CACHE_SKIP=preferred \
        sh "${SCRIPT}" --json about 2>/dev/null)
    _skip_eff=$(printf '%s' "$_skip" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_fb=$(printf '%s' "$_skip" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 skipped preferred uses 1st fallback" "${_skip_fb}" "${_skip_eff}"
    _gb=$(HOME="${CI_HOME}" FOLDER_BACKUP_CACHE_HOST=gitbash sh "${SCRIPT}" --json about 2>/dev/null)
    _gb_pref=$(printf '%s' "$_gb" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _gb_pid="${_gb_pref##*-}"
    assert_eq "TP-CLI-12 gitbash preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_gb_pid}" "${_gb_pref}"
    _gb_fb=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 gitbash 1st fallback" "${CI_HOME}/AppData/Local/Temp/cache-${APP_NAME}-${_gb_pid}" "${_gb_fb}"
    _gb_fb2=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 gitbash no 2nd fallback" "" "${_gb_fb2}"
    _mac=$(HOME="${CI_HOME}" FOLDER_BACKUP_CACHE_HOST=mac sh "${SCRIPT}" --json about 2>/dev/null)
    _mac_pref=$(printf '%s' "$_mac" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _mac_pid="${_mac_pref##*-}"
    assert_eq "TP-CLI-12 mac preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_mac_pid}" "${_mac_pref}"
    _mac_fb=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 mac 1st fallback" "${CI_HOME}/Library/Caches/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb}"
    _mac_fb2=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 mac 2nd fallback" "${CI_HOME}/cache/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb2}"
    _hum_l=$(HOME="${CI_HOME}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 linux about used" "${_hum_l}" "Cache folder used:"
    assert_contains "TP-CLI-12 linux about preferred path" "${_hum_l}" "/dev/shm/cache/cache-${APP_NAME}-${_login}-"
    assert_contains "TP-CLI-12 linux about 2nd path" "${_hum_l}" "/.cache/cache-${APP_NAME}-"
    _hum_gb=$(HOME="${CI_HOME}" FOLDER_BACKUP_CACHE_HOST=gitbash sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 gitbash about 1st" "${_hum_gb}" "AppData/Local/Temp/cache-${APP_NAME}-"
    assert_not_contains "TP-CLI-12 gitbash about omits 2nd" "${_hum_gb}" "Cache folder (2nd fallback)"
    _hum_mac=$(HOME="${CI_HOME}" FOLDER_BACKUP_CACHE_HOST=mac sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-12 mac about 1st" "${_hum_mac}" "Library/Caches/cache-${APP_NAME}-"
    assert_contains "TP-CLI-12 mac about 2nd path" "${_hum_mac}" "Cache folder (2nd fallback): ${CI_HOME}/cache/cache-${APP_NAME}-"
    _pers=$(printf '%s' "$_out" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-12 persistence_storage path" "${CI_HOME}/.local/${APP_NAME}" "$_pers"
    if [ -n "$_pers" ] && [ -d "$_pers" ]; then
        t_pass "TP-CLI-12 persistence storage directory exists"
    else
        t_fail "TP-CLI-12 persistence storage missing: '${_pers:-empty}'"
    fi
    case "${_pers}" in
        */.local/bin|*/.local/bin/) t_fail "TP-CLI-12 persistence must not be USER_BIN: '${_pers}'" ;;
        *) t_pass "TP-CLI-12 persistence is not the install bin directory" ;;
    esac
    ci_cleanup_env

    # TP-CLI-15 named menu / self-management off a terminal stop.
    # A line with no command is TP-CLI-07 / TP-CLI-23 (self-install), not this block.
    _out=$(sh "${SCRIPT}" menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-15 menu off-TTY exit 1" 1 "$_ec"
    assert_contains "TP-CLI-15 menu off-TTY needs a terminal" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-15 menu off-TTY is not help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-15 menu off-TTY not the numbered list" "$_out" "9. Exit"

    _out=$(sh "${SCRIPT}" main 2>&1)
    _ec=$?
    assert_eq "TP-CLI-15 main off-TTY exit 1" 1 "$_ec"
    assert_contains "TP-CLI-15 main off-TTY needs a terminal" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-15 main off-TTY is not help" "$_out" "Usage:"

    _out=$(sh "${SCRIPT}" --json menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-15 menu --json off-TTY exit 1" 1 "$_ec"
    assert_contains "TP-CLI-15 menu --json off-TTY JSON error" "$_out" '"type":"out_error"'
    assert_contains "TP-CLI-15 menu --json off-TTY message" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-15 menu --json off-TTY not JSON help" "$_out" '"type":"success"'
    assert_not_contains "TP-CLI-15 menu --json off-TTY not numbered list" "$_out" "9. Exit"

    _out=$(sh "${SCRIPT}" --quiet menu 2>&1)
    _ec=$?
    assert_eq "TP-CLI-15 menu --quiet off-TTY exit 1" 1 "$_ec"
    assert_contains "TP-CLI-15 menu --quiet off-TTY needs a terminal" "$_out" "menu needs a terminal"
    assert_not_contains "TP-CLI-15 menu --quiet off-TTY is not help" "$_out" "Usage:"

    _out=$(sh "${SCRIPT}" self-management 2>&1)
    _ec=$?
    assert_eq "TP-CLI-15 self-management off-TTY exit 1" 1 "$_ec"
    assert_contains "TP-CLI-15 self-management off-TTY needs a terminal" "$_out" "self-management needs a terminal"
    assert_not_contains "TP-CLI-15 self-management off-TTY is not help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-15 self-management off-TTY not the board" "$_out" "81. install:"

    _out=$(sh "${SCRIPT}" --json self-management 2>&1)
    _ec=$?
    assert_eq "TP-CLI-15 self-management --json off-TTY exit 1" 1 "$_ec"
    assert_contains "TP-CLI-15 self-management --json off-TTY JSON error" "$_out" '"type":"out_error"'
    assert_contains "TP-CLI-15 self-management --json off-TTY message" "$_out" "self-management needs a terminal"
    assert_not_contains "TP-CLI-15 self-management --json off-TTY not JSON help" "$_out" '"type":"success"'
    assert_not_contains "TP-CLI-15 self-management --json off-TTY not the board" "$_out" "81. install:"

    assert_contains "TP-CLI-15 help lists menu" "$(sh "${SCRIPT}" help 2>/dev/null)" "Numbered boards: client-side, self-management, and Exit"
    assert_contains "TP-CLI-15 help lists main" "$(sh "${SCRIPT}" help 2>/dev/null)" "Same as menu"
    assert_contains "TP-CLI-15 help says a pipe places this program" "$(sh "${SCRIPT}" help 2>/dev/null)" "a pipe places this program"

    # TP-CLI-23 a switch is not a verb. Isolate bins so this does not place
    # into the login that is running the suite.
    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" sh "${SCRIPT}" --quiet 2>&1)
    assert_eq "TP-CLI-23 --quiet exit 0" 0 "$?"
    assert_file_exists "TP-CLI-23 --quiet placed binary" "${CI_USER_BIN}/${APP_NAME}"
    assert_not_contains "TP-CLI-23 --quiet is not help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-23 --quiet is not the boards" "$_out" "9. Exit"
    ci_cleanup_env

    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" sh "${SCRIPT}" --json 2>&1)
    assert_eq "TP-CLI-23 --json exit 0" 0 "$?"
    assert_file_exists "TP-CLI-23 --json placed binary" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-CLI-23 --json success" "$_out" '"type":"out_success"'
    assert_not_contains "TP-CLI-23 --json is not help" "$_out" "Usage:"
    assert_not_contains "TP-CLI-23 --json is not the boards" "$_out" "9. Exit"
    ci_cleanup_env

    ci_isolated_env
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${CI_GLOBAL_BIN}" SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" sh "${SCRIPT}" --debug 2>&1)
    assert_eq "TP-CLI-23 non-TTY --debug exit 0" 0 "$?"
    assert_file_exists "TP-CLI-23 non-TTY --debug placed binary" "${CI_USER_BIN}/${APP_NAME}"
    assert_contains "TP-CLI-23 non-TTY --debug self-install banner" "$_out" "Starting self-install"
    assert_not_contains "TP-CLI-23 non-TTY --debug is not help" "$_out" "Usage:"
    ci_cleanup_env

    _out=$(sh "${SCRIPT}" --debug version 2>/dev/null)
    assert_contains "TP-CLI-23 --debug version stays version" "$_out" "version ${PRODUCT_VERSION}"
    assert_not_contains "TP-CLI-23 --debug version is not self-install" "$_out" "Starting self-install"

    if command -v python3 >/dev/null 2>&1; then
        _esc=$(printf '\033')
        _out=$(PTY_IN="9" ci_pty_run)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY empty argv client row" "$_plain" "1. client-side: this login's vaults: list, add, and edit"
        assert_contains "TP-CLI-13 TTY empty argv server hidden" "$_plain" "server-side is hidden: this program does not run a host service. Number 2 stays reserved."
        assert_contains "TP-CLI-13 TTY empty argv self row" "$_plain" "8. self-management: this CLI install, version, update, uninstall"
        assert_contains "TP-CLI-13 TTY empty argv Exit 9" "$_plain" "9. Exit"
        assert_contains "TP-CLI-13 TTY empty argv ident token" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_not_contains "TP-CLI-13 TTY empty argv hides generate row" "$_plain" "generate-sudoer-request:"
        assert_not_contains "TP-CLI-13 TTY empty argv no list row on front" "$_plain" "11. list:"

        _out=$(PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY menu client row" "$_plain" "1. client-side: this login's vaults: list, add, and edit"
        assert_contains "TP-CLI-13 TTY menu self row" "$_plain" "8. self-management: this CLI install, version, update, uninstall"
        assert_contains "TP-CLI-13 TTY menu Exit 9" "$_plain" "9. Exit"
        _out=$(PTY_IN="9" ci_pty_run main)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY main client row" "$_plain" "1. client-side: this login's vaults: list, add, and edit"
        assert_contains "TP-CLI-13 TTY main Exit 9" "$_plain" "9. Exit"
        _out=$(PTY_IN="$(printf '%s\n' 'list' '9')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY typed list shows ssh-vault" "$_plain" "ssh-vault"
        assert_contains "TP-CLI-13 TTY typed list shows github-vault" "$_plain" "github-vault"
        assert_contains "TP-CLI-13 TTY typed list shows cloudflare-vault" "$_plain" "cloudflare-vault"
        _out=$(PTY_IN="$(printf '%s\n' '12' '9')" ci_pty_run menu)
        assert_contains "TP-CLI-13 TTY pick 12 not a menu choice" "$_out" "Not a menu choice"
        _out=$(PTY_IN="$(printf '%s\n' '1' '0' '9')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 TTY client list row" "$_plain" "11. list: Show ssh-vault, github-vault, and cloudflare-vault names without secrets"
        assert_contains "TP-CLI-13 TTY client add row" "$_plain" "12. add: Add one ssh-vault, github-vault, or cloudflare-vault"
        assert_contains "TP-CLI-13 TTY client update row" "$_plain" "13. update: Edit one existing ssh-vault, github-vault, or cloudflare-vault"
        assert_not_contains "TP-CLI-13 TTY client has no sudoers row" "$_plain" "17. sudoers:"
        assert_not_contains "TP-CLI-13 TTY client has no edit row" "$_plain" "14. edit:"
        assert_contains "TP-CLI-13 TTY client Back 0" "$_plain" "0. Back"
        _err=$(sh "${SCRIPT}" sudoers 2>&1 >/dev/null)
        assert_eq "TP-CLI-13 sudoers not a live command" 1 "$?"
        assert_contains "TP-CLI-13 sudoers unknown" "$_err" "Unknown command"
        ci_isolated_env
        _live13=$(ci_snapshot_live_sudoer_inbound)
        for _verb in generate-sudoer-request submit-sudoer-request print-sudoers print-sudoers-install-script remove-project-sudoers; do
            _err=$(HOME="${CI_HOME}" \
                GLOBAL_BIN="${CI_GLOBAL_BIN}" \
                USER_BIN="${CI_USER_BIN}" \
                SUDOER_CLI="${CI_HOME}/no-such-sudoer-cli" \
                SUDOER_QUEUE_INBOUND="${CI_SUDOER_INBOUND}" \
                SUDOER_PUBLIC_ROOT="${CI_HOME}/var-sudoer-cli-absent" \
                sh "${SCRIPT}" "${_verb}" 2>&1 >/dev/null) || true
            assert_contains "TP-CLI-13 ${_verb} is not a live command" "$_err" "Unknown command"
        done
        _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${CI_HOME}/backups" sh "${SCRIPT}" backup 2>&1 >/dev/null) || true
        assert_contains "TP-CLI-13 backup is a live command" "$_err" "Usage:"
        assert_not_contains "TP-CLI-13 backup is not unknown" "$_err" "Unknown command"
        _err=$(HOME="${CI_HOME}" BACKUP_ROOT="${CI_HOME}/backups" sh "${SCRIPT}" restore missing-archive 2>&1 >/dev/null) || true
        assert_contains "TP-CLI-13 restore is a live command" "$_err" "Archive not found"
        assert_not_contains "TP-CLI-13 restore is not unknown" "$_err" "Unknown command"
        ci_assert_no_live_sudoer_enqueue "TP-CLI-13 did not enqueue live sudoer inbound" "${_live13}"
        ci_cleanup_env

        _out=$(PTY_IN="9" ci_pty_run --json menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-14 TTY menu --json still numbered list" "$_plain" "9. Exit"
        assert_contains "TP-CLI-14 TTY menu --json client row" "$_plain" "1. client-side: this login's vaults"
        assert_not_contains "TP-CLI-14 TTY menu --json ignores JSON help" "$_out" '"type":"success"'

        _out=$(PTY_IN="$(printf '%s\n' '8' '0' '9')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-13 self board install" "$_plain" "81. install: Copy this program into your bin or /usr/local/bin"
        assert_contains "TP-CLI-13 self board version is about" "$_plain" "82. version: Show version and detailed diagnostics (about)"
        assert_contains "TP-CLI-13 self board self-install" "$_plain" "87. self-install: Copy this file, or download it when the shell is a pipe"
        assert_contains "TP-CLI-13 self board back" "$_plain" "0. Back"
        assert_not_contains "TP-CLI-13 self board no where-is-me row" "$_plain" "where-is-me:"

        _out=$(PTY_IN="0" ci_pty_run --json self-management)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-14 TTY self-management --json still the board" "$_plain" "81. install:"
        assert_not_contains "TP-CLI-14 TTY self-management --json ignores JSON help" "$_out" '"type":"success"'

        ci_isolated_env
        _out=$(PTY_IN="9" SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" ci_pty_run --json)
        assert_file_exists "TP-CLI-23 TTY --json placed binary" "${CI_USER_BIN}/${APP_NAME}"
        assert_contains "TP-CLI-23 TTY --json success" "$_out" '"type":"out_success"'
        assert_not_contains "TP-CLI-23 TTY --json is not the boards" "$_out" "9. Exit"
        ci_cleanup_env

        ci_isolated_env
        _out=$(PTY_IN="9" ci_pty_run --debug)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-23 TTY --debug shows the front" "$_plain" "1. client-side:"
        if [ -e "${CI_USER_BIN}/${APP_NAME}" ]; then
            t_fail "TP-CLI-23 TTY --debug placed a binary"
        else
            t_pass "TP-CLI-23 TTY --debug does not place"
        fi
        ci_cleanup_env

        _out=$(PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_not_contains "TP-CLI-16 no help row" "$_plain" "help: Show this help"
        assert_not_contains "TP-CLI-16 no install row" "$_plain" "install: Copy this program"
        assert_not_contains "TP-CLI-16 no uninstall row" "$_plain" "uninstall: Remove the managed binary"
        assert_not_contains "TP-CLI-16 no where-is-me row" "$_plain" "where-is-me: Show running"
        assert_not_contains "TP-CLI-16 no version row" "$_plain" "version: Show version and detailed diagnostics"
        assert_not_contains "TP-CLI-16 no about row" "$_plain" "about: Show diagnostics"
        assert_not_contains "TP-CLI-16 no print-sudoers row" "$_plain" "print-sudoers: Write a grant file"
        assert_not_contains "TP-CLI-16 no install-script row" "$_plain" "print-sudoers-install-script: Write an admin script"
        assert_not_contains "TP-CLI-16 no generate row" "$_plain" "generate-sudoer-request: Write a local JSON grant"
        assert_not_contains "TP-CLI-16 no submit on main" "$_plain" "submit-sudoer-request: Hand the JSON grant"
        assert_not_contains "TP-CLI-16 no remove on main" "$_plain" "remove-project-sudoers: Remove the local grant"
        assert_not_contains "TP-CLI-16 no menu row" "$_plain" "menu: Show the numbered list"
        assert_not_contains "TP-CLI-16 no main row" "$_plain" "main: Same numbered list"
        assert_not_contains "TP-CLI-16 no self-install row" "$_plain" "self-install:"
        assert_not_contains "TP-CLI-16 no self-update row" "$_plain" "self-update:"
        assert_not_contains "TP-CLI-16 no self-uninstall row" "$_plain" "self-uninstall:"
        assert_not_contains "TP-CLI-16 no version-check row" "$_plain" "version-check:"
        assert_contains "TP-CLI-16 front category self-management" "$_plain" "8. self-management:"

        # TP-CLI-18 — default CLI main menu style (product alias of portable TP-CLI-17)
        _out=$(PTY_IN="9" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-18 TTY ident token" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_contains "TP-CLI-18 TTY header bold name" "$_out" "${_esc}[1m${APP_NAME}${_esc}[0m"
        assert_contains "TP-CLI-18 TTY header italic version" "$_out" "(${_esc}[3m${PRODUCT_VERSION}${_esc}[0m)"
        assert_contains "TP-CLI-18 TTY explain SGR 3;37" "$_out" "${_esc}[3;37m"
        assert_contains "TP-CLI-18 TTY short name bold" "$_out" "1. ${_esc}[1mclient-side${_esc}[0m: "
        assert_contains "TP-CLI-18 TTY Exit unstyled" "$_plain" "9. Exit"
        _out=$(PTY_IN="$(printf '%s\n' '1' '0' '9')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-18 TTY submenu ident token" "$_plain" "${APP_NAME}(${PRODUCT_VERSION})"
        assert_contains "TP-CLI-18 TTY submenu title" "$_plain" "client-side"
        assert_contains "TP-CLI-18 TTY submenu header bold name" "$_out" "${_esc}[1m${APP_NAME}${_esc}[0m"
        assert_contains "TP-CLI-18 TTY submenu short bold" "$_out" "11. ${_esc}[1mlist${_esc}[0m: "
        _out=$(PTY_IN="$(printf '%s\n' '12' '9')" ci_pty_run menu)
        assert_contains "TP-CLI-19 invalid choice retries" "$_out" "Not a menu choice '12'"
        _plain=$(ci_strip_ansi "$_out")
        _front_n=$(printf '%s\n' "$_plain" | grep -c "1. client-side:" || true)
        if [ "${_front_n}" -ge 2 ]; then
            t_pass "TP-CLI-19 invalid choice reprints this board"
        else
            t_fail "TP-CLI-19 invalid choice did not reprint the front board (count=${_front_n})"
        fi
        _out=$(PTY_IN="$(printf '\n')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-21 empty Enter shows the front" "$_plain" "9. Exit"
        assert_not_contains "TP-CLI-21 empty Enter is not a bad choice" "$_out" "Not a menu choice"
        _front_n=$(printf '%s\n' "$_plain" | grep -c "1. client-side:" || true)
        if [ "${_front_n}" -eq 1 ]; then
            t_pass "TP-CLI-21 empty Enter leaves the front"
        else
            t_fail "TP-CLI-21 empty Enter did not leave the front (count=${_front_n})"
        fi
        _out=$(PTY_IN="$(printf '%s\n' '8' '' '9')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_contains "TP-CLI-21 empty on self is Back" "$_plain" "81. install:"
        assert_contains "TP-CLI-21 empty on self returns to the front" "$_plain" "9. Exit"
        assert_not_contains "TP-CLI-21 empty on self is not a bad choice" "$_out" "Not a menu choice"
        _out=$(PTY_IN="$(printf '%s\n' '8' '82' '9')" ci_pty_run menu)
        assert_contains "TP-CLI-21 row 82 runs about" "$_out" "Cache folder used"
        assert_not_contains "TP-CLI-21 row 82 is not the thin version line" "$_out" "version ${PRODUCT_VERSION}"
        _out=$(PTY_IN="$(printf '%s\n' 'version' '9')" ci_pty_run menu)
        assert_contains "TP-CLI-21 typed version runs about" "$_out" "Cache folder used"
        assert_not_contains "TP-CLI-21 typed version is not the thin version line" "$_out" "version ${PRODUCT_VERSION}"
        _plain=$(ci_strip_ansi "$_out")
        _front_n=$(printf '%s\n' "$_plain" | grep -c "1. client-side:" || true)
        if [ "${_front_n}" -ge 2 ]; then
            t_pass "TP-CLI-21 finished leaf redisplays the front board"
        else
            t_fail "TP-CLI-21 finished leaf did not redisplay the front board (count=${_front_n})"
        fi
        _off=$(sh "${SCRIPT}" menu 2>/dev/null)
        assert_not_contains "TP-CLI-18 off-TTY menu no explain CSI" "$_off" "${_esc}[3;37m"
        assert_not_contains "TP-CLI-18 off-TTY menu no ident CSI" "$_off" "${_esc}[1m${APP_NAME}"
        ci_isolated_env
        _empty=$(SCRIPT_URL="http://127.0.0.1:9/folder-backup-offline" sh "${SCRIPT}" 2>/dev/null)
        assert_not_contains "TP-CLI-18 off-TTY empty argv no explain CSI" "$_empty" "${_esc}[3;37m"
        rm -f "${CI_USER_BIN}/${APP_NAME}"
        ci_cleanup_env
    else
        t_skip "TP-CLI-13 TTY menu (no python3 for PTY)"
        t_skip "TP-CLI-13 TTY client board (no python3 for PTY)"
        t_skip "TP-CLI-14 TTY menu --json (no python3 for PTY)"
        t_skip "TP-CLI-16 TTY exclusions (no python3 for PTY)"
        t_skip "TP-CLI-18 TTY menu look (no python3 for PTY)"
        t_skip "TP-CLI-18 TTY submenu header (no python3 for PTY)"
    fi
}
