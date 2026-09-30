# vault-cli - List, add, and update ssh-vault, github-vault, and cloudflare-vault on this login

![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/vault-cli?style=flat-square)](https://github.com/cloudgen/vault-cli)

**vault-cli** stores ssh keys, GitHub tokens, and Cloudflare tokens for this login under `~/.local/vaults`. `list` shows names. It does not show the secret.

| You (your own login) | Admin / already root | Not this |
|----------------------|----------------------|----------|
| Install to `~/.local/bin`, then list, add, and update vaults in `~/.local/vaults` | The same one-liner as root places the program in `/usr/local/bin` | A token or a private key on the command line. `self-update` replaces the program. It does not edit a vault. |

| Includes | Excludes |
|----------|----------|
| Pipe install, numbered boards, `list` / `add` / `update`, local `install`, `self-update` | Printing a token or a private key. Deleting `~/.local/vaults` when you uninstall the program. |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Install from the internet | No root. Places the program in `~/.local/bin` (mode `0700`). | `curl -fsSL https://raw.githubusercontent.com/cloudgen/vault-cli/main/src/vault-cli \| sh` |
| Open the boards | On a real terminal, a bare run shows client-side, self-management, and Exit. | `vault-cli` |
| See vault names | Three kinds, no secret bytes. | `vault-cli list` |
| Store one ssh key | The key file is mode `0600`. A sibling `.pub` is copied when it is a regular file. | `vault-cli add ssh-vault --name NAME --key-file ./id_ed25519` |

## Features

- **Install for yourself**: copy this program into `~/.local/bin` (`install`); remove it (`uninstall`); ask where it lives (`where-is-me`). Uninstall does not delete `~/.local/vaults`.
- **Pipe install**: `curl … \| sh` places this program (`self-install`). A checkout file copies; a pipe downloads. Your login gets mode `0700`. Root gets `/usr/local/bin` at mode `0755`. `version-check` and `self-update` use the same GitHub raw URL. A terminal with no command does not do this.
- **Scratch stays with this login and this run**: temporary files live in a private folder named for you and this process. `about` prints the folder in use, the preferred folder, and the fallbacks. Notes that must survive a reboot stay in `~/.local/vault-cli`.
- **Numbered boards**: on a real terminal, a bare `vault-cli` (or `menu` / `main`) shows client-side, self-management, and Exit. Server-side stays hidden. **1** then **11** lists names. **1** then **12** adds one vault. **1** then **13** edits one vault that already exists. **8** opens install, version, and the channel refresh. A finished command returns to the front. **0** steps back.
- **Three kinds**: `ssh-vault`, `github-vault`, and `cloudflare-vault`. `add` does not overwrite. `update` does not create. The ssh name `_default` is reserved.
- **Secrets stay in files**: `--key-file` and `--token-file` point at a regular file mode `0600`. `--token` and `--private-key` are refused. List, help, and about never print those bytes.
- **Fail closed**: unknown kind, missing selector, wrong file mode, and a second add of the same selector stop with a next command.
- **Folder backup and restore**: `vault-cli backup /path/to/project` packs that folder into `/var/backups/vault-cli/` as `NAME-YYYYMMDD-N.tar.gz`. `vault-cli restore NAME` puts it back on the hard-disk projects tree. These are typed commands. They are not numbered-board rows. If that folder is not writable by this login, the command stops and tells you to create it or re-run as root.

## Quick Installation

### Online (this is the install)

**Your own login (no root):**

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/vault-cli/main/src/vault-cli | sh
```

That one line places `~/.local/bin/vault-cli` (mode `0700`). It does not print help. A second run says the program is already installed.

**Already a root login.** Same one-liner as root. The file lands in `/usr/local/bin/vault-cli` (mode `0755`):

```sh
curl -fsSL https://raw.githubusercontent.com/cloudgen/vault-cli/main/src/vault-cli | sh
```

Then:

```sh
vault-cli version
```

**From a checkout** (copy this file, mode `0755`, no download):

```sh
sh src/vault-cli install
```

`sh src/vault-cli` with no command, off a terminal, is the other place: it copies this file the way `self-install` does (mode `0700` for your login). On a terminal that same bare run opens the boards and does not copy.

### Download check

`self-install` and `self-update` download from `https://raw.githubusercontent.com/cloudgen/vault-cli/main/src/vault-cli`. When `CHECKSUM` is unset, the program fetches the companion `https://raw.githubusercontent.com/cloudgen/vault-cli/main/src/vault-cli.sha256` (published as `src/vault-cli.sha256`). Human mode shows the companion link, the expected value, and the result. No env pin is required.

| Result | What happens |
|--------|----------------|
| Match | Install continues. |
| Mismatch | Install stops. The downloaded bytes are not placed. |
| Companion missing | A warning, then install continues. This is not “always verified.” |

`CHECKSUM` is an optional pin for one run (CI or an out-of-band freeze). It is not listed in `help` or `about`. A pin taken from the same URL is not stronger than the companion the program already fetches. Local `install` copies the file you are running and does not use this check.

Regenerate the companion after the script changes:

```sh
sha256sum src/vault-cli | awk '{print $1}' > src/vault-cli.sha256
```

### Numbered list

After install, on a terminal:

```text
$ vault-cli
[INFO] **vault-cli**(*1.0.0*) — numbered list
[INFO] server-side is hidden: this program does not run a host service. Number 2 stays reserved.
1. **client-side**: *this login's vaults: list, add, and edit*
8. **self-management**: *this CLI install, version, update, uninstall*
9. Exit
```

Choose a number, or type a listed command name. `9` leaves the program. `0` on a submenu goes back. After a command finishes, the front board is shown again. A number or name that is not on this list prints an error and lets you choose again.

Client-side (`1`):

```text
[INFO] **vault-cli**(*1.0.0*) — client-side
11. **list**: *Show ssh-vault, github-vault, and cloudflare-vault names without secrets*
12. **add**: *Add one ssh-vault, github-vault, or cloudflare-vault*
13. **update**: *Edit one existing ssh-vault, github-vault, or cloudflare-vault*
0. Back
```

`edit` is the same command as `update`. It is not a numbered row.

Self-management (`8`):

```text
[INFO] **vault-cli**(*1.0.0*) — self-management
81. **install**: *Copy this program into your bin or /usr/local/bin*
82. **version**: *Show version and detailed diagnostics (about)*
83. **about**: *Show diagnostics including vault root and vault counts*
84. **version-check**: *Compare this version with the channel*
85. **self-update**: *Replace the placed binary from the channel*
86. **self-uninstall**: *Remove the channel-placed binary*
87. **self-install**: *Copy this file, or download it when the shell is a pipe*
0. Back
```

Row **82** and a typed `version` on a board show diagnostics. `vault-cli version` on the command line stays the one-line version.

## Usage

```text
vault-cli [command] [options]
```

On a real terminal, no command shows the numbered boards. A pipe, or `--quiet` / `--json` with no command, places the program. Naming `menu` off a terminal stops.

**Work commands**

| Command | What it does |
|---------|----------------|
| `list [kind]` | Show names. Never show a token or a private key. |
| `add <kind>` | Add one vault. On a terminal, one question at a time. |
| `update <kind>` | Edit one vault that already exists. |
| `edit <kind>` | Same as `update`. Not a menu row. |

Kinds: `ssh-vault`, `github-vault`, `cloudflare-vault`.

**Self-management** (this is the program, not a vault): `self-install`, `version-check`, `self-update`, `self-uninstall`, `self-management`.

**Your own login:** `install`, `uninstall`, `where-is-me`, `version`, `about`, `help`, `menu`, `main`.

**Flags:** `--quiet` / `-q`, `--json`, `--force`, `--global`, `--debug`, `--name`, `--key-file`, `--login`, `--token-id`, `--account-id`, `--token-file`.

Off a terminal, `add` and `update` take flags and do not prompt. A missing flag stops with `Next:` and the full command.

**Environment**

| Variable | Role |
|----------|------|
| `REPO_USER` | Git host owner (default `cloudgen`) |
| `REPO_NAME` | Git repository name (default `vault-cli`) |
| `SCRIPT_URL` | Channel for `self-install` / `version-check` / `self-update` (default `https://raw.githubusercontent.com/cloudgen/vault-cli/main/src/vault-cli`) |
| `VAULT_ROOT` | Vault files (default `${HOME}/.local/vaults`, mode `0700`) |
| `USER_BIN` / `GLOBAL_BIN` | Install destinations |

Persistence for this program is `${HOME}/.local/vault-cli`. Vault files are `VAULT_ROOT`, not that folder.

## Examples

```sh
vault-cli list

printf '%s\n' 'one-line-token' > ./token
chmod 0600 ./token ./id_ed25519

vault-cli add ssh-vault --name NAME --key-file ./id_ed25519
vault-cli add github-vault --login LOGIN --token-id TOKENID --token-file ./token
vault-cli add cloudflare-vault --account-id ACCOUNT --token-file ./token
vault-cli update github-vault --login LOGIN --token-id TOKENID --token-file ./token
vault-cli edit cloudflare-vault --account-id ACCOUNT --token-file ./token

vault-cli about
vault-cli --json list
```

Put the real secret in the mode `0600` file. Do not pass it as `--token` or `--private-key`.

## Platform Compatibility

| Platform | Status |
|----------|--------|
| Linux, `/bin/sh` | Supported |
| `mkdir`, `chmod`, `cat`, `awk` | Required for vault files |
| macOS / BSD | Not primary; `stat` mode flags may differ |

These work commands do not call `sudo`.

## Repository

Public source: [github.com/cloudgen/vault-cli](https://github.com/cloudgen/vault-cli).

```text
git clone git@github.com:cloudgen/vault-cli.git
```

## Related Projects

- [vault-cli](https://github.com/cloudgen/vault-cli) — this product
- [CIAO Defensive Programming](https://github.com/cloudgen/ciao)
- [CIAO-Lite](https://github.com/cloudgen/ciao-lite)
- [selfmanaged](https://github.com/cloudgen/selfmanaged) — bootstrap parent. This product keeps that channel and adds list, add, and update.

## Contributing

Keep changes surgical. Honor **CIAO-Lite Protection Zones** in `src/vault-cli`. Product behavior must stay consistent with live `docs/requirements/requirement-*.md`. Run `sh tests/run.sh` before proposing commits.

## License

MIT License — see [`LICENSE.md`](./LICENSE.md).

## Last Update

2026-09-30 — version **1.0.0**. The program is vault-cli. Work commands are `list`, `add`, and `update` (`edit` is the same as `update`), plus typed `backup` and `restore`. Archives go to `/var/backups/vault-cli/`. Secrets live under `~/.local/vaults`. `self-update` still replaces the program.
