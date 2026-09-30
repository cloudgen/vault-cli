# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.0 (current) | Yes |

This command surface is vault-cli **1.0.0**. Older folder-backup release numbers are a previous command surface. They are not this program's supported set.

## Reporting a Vulnerability

Please **do not** open a public issue for security-sensitive reports when a private channel is available.

**Maintainer contact (email):** `wongcf22@gmail.com`

- Source of contact: product **author-email** SSOT in [`LICENSE.md`](./LICENSE.md) (Copyright line).
- Prefer email, or a private security advisory on [github.com/cloudgen/vault-cli](https://github.com/cloudgen/vault-cli), for vulnerability details, reproduction steps, and impact.
- Do not include exploit weaponization guides in public channels.
- Do not paste token or private-key bytes into a report. Name the file mode and the command, and keep the secret out of the message.

## Security Design Principles (CIAO)

This project follows **[CIAO](https://github.com/cloudgen/ciao)** / **[CIAO-Lite](https://github.com/cloudgen/ciao-lite)** defensive design. Security-relevant intent:

| Letter | Principle | Security application |
|--------|-----------|----------------------|
| **C** | **Caution** | Unknown kind, reserved ssh name `_default`, wrong file mode, and a secret on argv fail closed. |
| **I** | **Intentional** | `update` edits one existing vault. `self-update` replaces the program. `add` does not overwrite. |
| **A** | **Anti-fragile** | Vault files are created under this login's home with mode `0700` directories and mode `0600` secrets. A missing download companion warns and continues. A mismatch aborts. |
| **O** | **Over-protect** | List, help, about, and JSON show `token_present` or `key_present`. They do not print secret bytes. Uninstall does not delete the vault root. |

Full principles: [CIAO](https://github.com/cloudgen/ciao) · [CIAO-Lite](https://github.com/cloudgen/ciao-lite).

This section is **design posture**, not a third-party certification claim.

## Install integrity and trust

`self-install` and `self-update` download from the channel in [`README.md`](./README.md). When `CHECKSUM` is unset, the program fetches the companion `${SCRIPT_URL}.sha256` (published as `src/vault-cli.sha256`).

| Fact | Honest statement |
|------|------------------|
| **Default path** | Automatic companion verification. No env pin is required for a normal channel install or self-update. |
| **Algorithm** | SHA-256. Human mode shows the companion link, the expected value, and the result. |
| **Match** | Install continues. |
| **Mismatch** | Install aborts. Mismatched bytes are not placed. |
| **Missing sidecar** | Warn and continue. This is not “always verified.” |
| **Optional pin** | `CHECKSUM` is a secondary pin for one run (CI or an out-of-band freeze). It is not listed in `help` or `about`. A pin taken from the same URL is not stronger than the automatic companion. |
| **Trust bound** | Same-channel SHA-256 proves the downloaded file matches the companion. It does not prove a separate signature or a different trust root. |

Operator steps stay in the README. Local `install` copies the file you are running and does not use this check.

## Scope notes

- Vault files live under `~/.local/vaults` (override `VAULT_ROOT`), mode `0700`. Secret files are mode `0600`.
- An ssh private key is `ssh/<name>/id_ed25519`. A GitHub token is `github/accounts/<login>/tokens/<token-id>/token` (one line). A Cloudflare token is `cloudflare/<account-id>/token` (one line).
- `--token` and `--private-key` are refused. The error does not echo the rejected value. Put the secret in a regular file mode `0600` and pass `--token-file` or `--key-file`.
- `list`, `help`, and `about` do not print secret bytes.
- `add` refuses an existing selector. `update` refuses a missing selector. The ssh name `_default` is reserved.
- Uninstall removes the program binary. It does not delete the vault root.
- These work commands do not call `sudo`.
- Related docs: [`README.md`](./README.md), [`LICENSE.md`](./LICENSE.md).
