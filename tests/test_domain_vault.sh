# =============================================================================
# tests/test_domain_vault.sh — vault-cli list / add / update
# =============================================================================
# Primary REQ: requirement-domain-vault-cli
# TP family: TP-VAULT-*
# =============================================================================

# shellcheck source=helpers.sh
. "${TESTS_ROOT}/helpers.sh"

_vault_mode() {
    stat -c '%a' "$1" 2>/dev/null || stat -f '%OLp' "$1" 2>/dev/null || printf '%s' ""
}

run_test_domain_vault() {
    t_header "Domain vault-cli (TP-VAULT)"

    require_cmd sh
    require_cmd awk

    ci_isolated_env
    unset VAULT_ROOT

    _root="${CI_HOME}/.local/vaults"
    _fix="${CI_HOME}/fixtures"
    mkdir -p "${_fix}"
    printf '%s\n' 'fixture-private-key-line' 'second-key-line' > "${_fix}/id_ed25519"
    printf '%s\n' 'fixture-public-key-line' > "${_fix}/id_ed25519.pub"
    printf '%s\n' 'fixture-token-line' > "${_fix}/token"
    printf '%s\n' 'fixture-token-line-two' > "${_fix}/token-two"
    printf '%s\n' 'line-one' 'line-two' > "${_fix}/token-bad"
    chmod 0600 "${_fix}/id_ed25519" "${_fix}/id_ed25519.pub" "${_fix}/token" \
        "${_fix}/token-two" "${_fix}/token-bad"
    cp "${_fix}/id_ed25519" "${_fix}/id_ed25519.loose"
    chmod 0644 "${_fix}/id_ed25519.loose"

    # TP-VAULT-01 list with no vaults names the three kinds and no secret bytes
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" list 2>/dev/null)
    assert_eq "TP-VAULT-01 list exit 0" 0 "$?"
    assert_contains "TP-VAULT-01 ssh-vault heading" "$_out" "ssh-vault"
    assert_contains "TP-VAULT-01 github-vault heading" "$_out" "github-vault"
    assert_contains "TP-VAULT-01 cloudflare-vault heading" "$_out" "cloudflare-vault"
    assert_not_contains "TP-VAULT-01 no private key bytes" "$_out" "fixture-private-key-line"
    assert_not_contains "TP-VAULT-01 no token bytes" "$_out" "fixture-token-line"
    _j=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json list 2>/dev/null)
    assert_contains "TP-VAULT-01 json vaults" "$_j" '"vaults":[]'
    assert_contains "TP-VAULT-01 json kinds" "$_j" '"kinds":["ssh-vault","github-vault","cloudflare-vault"]'
    assert_not_contains "TP-VAULT-01 json no private key" "$_j" "fixture-private-key-line"

    # TP-VAULT-02 reserved name and secret bytes on argv
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json add ssh-vault --name _default --key-file "${_fix}/id_ed25519" 2>&1 >/dev/null)
    assert_eq "TP-VAULT-02 _default exit 1" 1 "$?"
    assert_contains "TP-VAULT-02 name_reserved" "$_err" '"error":"name_reserved"'
    assert_file_missing "TP-VAULT-02 _default dir absent" "${_root}/ssh/_default"
    _all=$(HOME="${CI_HOME}" sh "${SCRIPT}" add ssh-vault --name work --private-key 'fixture-private-key-line' 2>&1)
    assert_eq "TP-VAULT-02 --private-key exit 1" 1 "$?"
    assert_contains "TP-VAULT-02 secret sentence" "$_all" "cannot be passed on the command line"
    assert_contains "TP-VAULT-02 secret Next" "$_all" "Next:"
    assert_not_contains "TP-VAULT-02 secret value not echoed" "$_all" "fixture-private-key-line"
    _j=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json add ssh-vault --name work --private-key=fixture-private-key-line 2>&1 >/dev/null)
    assert_contains "TP-VAULT-02 secret_refused" "$_j" '"error":"secret_refused"'
    assert_not_contains "TP-VAULT-02 json omits secret value" "$_j" "fixture-private-key-line"
    assert_file_missing "TP-VAULT-02 no vault from refused key" "${_root}/ssh/work"

    # Happy path: ssh key plus sibling public key
    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" add ssh-vault --name work --key-file "${_fix}/id_ed25519" 2>&1)
    assert_eq "TP-VAULT happy ssh add exit 0" 0 "$?"
    assert_contains "TP-VAULT happy ssh added" "$_out" "Added ssh-vault work."
    if cmp -s "${_fix}/id_ed25519" "${_root}/ssh/work/id_ed25519"; then
        t_pass "TP-VAULT happy ssh key bytes copied"
    else
        t_fail "TP-VAULT happy ssh key bytes copied"
    fi
    if cmp -s "${_fix}/id_ed25519.pub" "${_root}/ssh/work/id_ed25519.pub"; then
        t_pass "TP-VAULT happy ssh pub bytes copied"
    else
        t_fail "TP-VAULT happy ssh pub bytes copied"
    fi
    _mode=$(_vault_mode "${_root}/ssh/work/id_ed25519")
    case "${_mode}" in
        600|0600) t_pass "TP-VAULT happy ssh key mode 0600" ;;
        *) t_fail "TP-VAULT happy ssh key mode 0600, got '${_mode}'" ;;
    esac
    _mode=$(_vault_mode "${_root}/ssh/work/id_ed25519.pub")
    case "${_mode}" in
        644|0644) t_pass "TP-VAULT happy ssh pub mode 0644" ;;
        *) t_fail "TP-VAULT happy ssh pub mode 0644, got '${_mode}'" ;;
    esac
    _mode=$(_vault_mode "${_root}")
    case "${_mode}" in
        700|0700) t_pass "TP-VAULT happy vault root mode 0700" ;;
        *) t_fail "TP-VAULT happy vault root mode 0700, got '${_mode}'" ;;
    esac

    # TP-VAULT-03 add existing is vault_exists; update missing is vault_missing
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json add ssh-vault --name work --key-file "${_fix}/id_ed25519" 2>&1 >/dev/null)
    assert_eq "TP-VAULT-03 second add exit 1" 1 "$?"
    assert_contains "TP-VAULT-03 vault_exists" "$_err" '"error":"vault_exists"'
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json update ssh-vault --name missing-name --key-file "${_fix}/id_ed25519" 2>&1 >/dev/null)
    assert_eq "TP-VAULT-03 update missing exit 1" 1 "$?"
    assert_contains "TP-VAULT-03 vault_missing" "$_err" '"error":"vault_missing"'
    assert_file_missing "TP-VAULT-03 missing dir not created" "${_root}/ssh/missing-name"

    # TP-VAULT-04 off a terminal, add without flags does not prompt
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" add 2>&1 >/dev/null)
    assert_eq "TP-VAULT-04 add no flags exit 1" 1 "$?"
    assert_contains "TP-VAULT-04 Next" "$_err" "Next:"
    assert_not_contains "TP-VAULT-04 does not prompt" "$_err" "Vault name"

    # TP-VAULT-05 edit is update and is not a menu row
    _edit=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json edit ssh-vault --name missing-name --key-file "${_fix}/id_ed25519" 2>&1 >/dev/null)
    _upd=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json update ssh-vault --name missing-name --key-file "${_fix}/id_ed25519" 2>&1 >/dev/null)
    assert_contains "TP-VAULT-05 edit vault_missing" "$_edit" '"error":"vault_missing"'
    assert_eq "TP-VAULT-05 edit matches update" "$_upd" "$_edit"
    _help=$(HOME="${CI_HOME}" sh "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-VAULT-05 help edit alias" "$_help" "Same as update. Not a menu row."
    if command -v python3 >/dev/null 2>&1; then
        _out=$(PTY_IN="$(printf '%s\n' '1' '0' '9')" ci_pty_run menu)
        _plain=$(ci_strip_ansi "$_out")
        assert_not_contains "TP-VAULT-05 client board has no edit row" "$_plain" "edit:"
        assert_contains "TP-VAULT-05 client board lists update" "$_plain" "13. update:"
    else
        t_skip "TP-VAULT-05 client board (no python3 for PTY)"
    fi

    # TP-VAULT-06 help work slice
    _work=$(printf '%s' "$_help" | sed -n '/Work commands:/,/Global Options:/p')
    _self=$(printf '%s' "$_help" | sed -n '/Self-management/,/Work commands:/p')
    assert_contains "TP-VAULT-06 work list" "$_work" "list [ssh-vault|github-vault|cloudflare-vault]"
    assert_contains "TP-VAULT-06 work add" "$_work" "add <kind>"
    assert_contains "TP-VAULT-06 work update" "$_work" "update <kind>"
    assert_contains "TP-VAULT-06 work edit" "$_work" "edit <kind>"
    assert_not_contains "TP-VAULT-06 work omits self-update" "$_work" "self-update"
    assert_contains "TP-VAULT-06 self-update stays self-managed" "$_self" "self-update"

    # Loose mode, github, cloudflare, replace, list hides bytes
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json add ssh-vault --name loose --key-file "${_fix}/id_ed25519.loose" 2>&1 >/dev/null)
    assert_eq "TP-VAULT loose key exit 1" 1 "$?"
    assert_contains "TP-VAULT loose key secret_file_mode" "$_err" '"error":"secret_file_mode"'
    assert_file_missing "TP-VAULT loose key dir absent" "${_root}/ssh/loose"

    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" add github-vault --login octo --token-id ci --token-file "${_fix}/token" 2>&1)
    assert_eq "TP-VAULT github add exit 0" 0 "$?"
    assert_contains "TP-VAULT github added" "$_out" "Added github-vault octo/ci."
    if cmp -s "${_fix}/token" "${_root}/github/accounts/octo/tokens/ci/token"; then
        t_pass "TP-VAULT github token bytes copied"
    else
        t_fail "TP-VAULT github token bytes copied"
    fi
    _idx=$(cat "${_root}/github/index.json" 2>/dev/null || true)
    assert_not_contains "TP-VAULT github index omits token" "$_idx" "fixture-token-line"

    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json add github-vault --login octo --token-id bad --token-file "${_fix}/token-bad" 2>&1 >/dev/null)
    assert_eq "TP-VAULT two-line token exit 1" 1 "$?"
    assert_contains "TP-VAULT two-line token_file_required" "$_err" '"error":"token_file_required"'

    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" add cloudflare-vault --account-id acct1 --token-file "${_fix}/token" 2>&1)
    assert_eq "TP-VAULT cloudflare add exit 0" 0 "$?"
    assert_contains "TP-VAULT cloudflare added" "$_out" "Added cloudflare-vault acct1."
    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json add cloudflare-vault --account-id acct1 --token-file "${_fix}/token-two" 2>&1 >/dev/null)
    assert_eq "TP-VAULT cloudflare second add exit 1" 1 "$?"
    assert_contains "TP-VAULT cloudflare vault_exists" "$_err" '"error":"vault_exists"'

    _err=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json update github-vault --login octo --token-id ci 2>&1 >/dev/null)
    assert_eq "TP-VAULT nothing_to_update exit 1" 1 "$?"
    assert_contains "TP-VAULT nothing_to_update" "$_err" '"error":"nothing_to_update"'

    _out=$(HOME="${CI_HOME}" sh "${SCRIPT}" update github-vault --login octo --token-id ci --token-file "${_fix}/token-two" 2>&1)
    assert_eq "TP-VAULT github update exit 0" 0 "$?"
    assert_contains "TP-VAULT github updated" "$_out" "Updated github-vault octo/ci."
    if cmp -s "${_fix}/token-two" "${_root}/github/accounts/octo/tokens/ci/token"; then
        t_pass "TP-VAULT github token replaced"
    else
        t_fail "TP-VAULT github token replaced"
    fi

    _list=$(HOME="${CI_HOME}" sh "${SCRIPT}" list 2>/dev/null)
    assert_contains "TP-VAULT list shows ssh name" "$_list" "  work"
    assert_contains "TP-VAULT list shows github" "$_list" "  octo/ci"
    assert_contains "TP-VAULT list shows cloudflare" "$_list" "  acct1"
    assert_not_contains "TP-VAULT list omits private key" "$_list" "fixture-private-key-line"
    assert_not_contains "TP-VAULT list omits token" "$_list" "fixture-token-line-two"
    _j=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json list 2>/dev/null)
    assert_contains "TP-VAULT json key_present" "$_j" '"key_present":true'
    assert_contains "TP-VAULT json token_present" "$_j" '"token_present":true'
    assert_not_contains "TP-VAULT json omits token bytes" "$_j" "fixture-token-line-two"
    assert_not_contains "TP-VAULT json omits key bytes" "$_j" "fixture-private-key-line"

    mkdir -p "${_root}/ssh/_default"
    _about=$(HOME="${CI_HOME}" sh "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-VAULT about vault root" "$_about" "Vault root:"
    assert_contains "TP-VAULT about ssh count" "$_about" "ssh-vault count:   1"
    assert_contains "TP-VAULT about github count" "$_about" "github-vault count: 1"
    assert_contains "TP-VAULT about cloudflare count" "$_about" "cloudflare-vault count: 1"
    assert_contains "TP-VAULT about reserved" "$_about" "ssh-vault reserved: _default"
    assert_not_contains "TP-VAULT about omits token" "$_about" "fixture-token-line-two"
    _j=$(HOME="${CI_HOME}" sh "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-VAULT about json ssh count" "$_j" '"ssh_vault_count":"1"'
    assert_contains "TP-VAULT about json reserved" "$_j" '"ssh_vault_reserved":"_default"'
    _list=$(HOME="${CI_HOME}" sh "${SCRIPT}" list 2>/dev/null)
    assert_not_contains "TP-VAULT list omits reserved name" "$_list" "  _default"

    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" install >/dev/null 2>&1
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" sh "${SCRIPT}" uninstall --force >/dev/null 2>&1
    assert_file_exists "TP-VAULT uninstall keeps vault key" "${_root}/ssh/work/id_ed25519"

    ci_cleanup_env
}
