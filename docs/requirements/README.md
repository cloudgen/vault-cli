# Requirements

Authoritative specialized product law for **vault-cli** lives here.

**Current state (2026-09-30):** Specialized **software-development** product. Left genesis. Bootstrap parent is sibling **selfmanaged**. Channel verbs stay (`self-install`, `version-check`, `self-update`, `self-uninstall`). A terminal with no command is the numbered boards. A pipe with no command is `self-install`. Domain extend: `list`, `add`, and `update` for ssh-vault, github-vault, and cloudflare-vault. Registry is populated — see `index.md`.

## Product identity (summary)

| Field | Value |
|-------|--------|
| Product / `APP_NAME` | `vault-cli` |
| Version SSOT | `1.0.0` (ship unit hard-assign) |
| Ship unit | `src/vault-cli` |
| Default install | `~/.local/bin/vault-cli` |
| Install mode | **Dual.** `install` copies this file (mode `0755`). A pipe with no command, and `self-install`, place the CLI (local `0700`, global `0755`). A terminal with no command is the boards. |
| Vault root | `${HOME}/.local/vaults` (mode `0700`). Owned by `requirement-domain-vault-cli`. Uninstall does not delete it. |
| Persistence | `${HOME}/.local/vault-cli` (`${HOME}/.local/${APP_NAME}`) |
| Domain surface | `requirement-domain-vault-cli` — `list` / `add` / `update` (`edit` aliases `update`) |
| Withdrawn backup law | `requirement-domain-folder-backup`, `requirement-folder-archive-backup`, both retention files, `requirement-shell-cli-sudoers-submenu` |

## Class requirement gate

| Class | Required class file |
|-------|---------------------|
| software-development | `requirement-class-software-dev.md` (**Active**) |
| genesis-template | N/A — this workspace is no longer genesis |

## Purpose

- **Plan** designs work by reading and updating these docs.  
- **Implement** delivers code that **traces** to these requirements.  
- **Review** verifies delivery against requirements and CIAO checklists.

## Layout

| Path | Role |
|------|------|
| `docs/requirements/index.md` | Registry of all requirements — keep in sync |
| `docs/requirements/requirement-*.md` | CIAO-style project requirements |

## Status values

Typical: `draft` · `Active` · `approved` · `in-progress` · `done` · `deprecated` · `superseded`

## Rules

1. Never invent paths — verify on disk.  
2. Class files only via class process; non-class via create-specific process.  
3. Never dump harness inventories into this versioned surface.  
4. Online install requirements stay **absent** unless product mode is explicitly changed.  
5. Sole domain SSOT: `requirement-domain-vault-cli.md`.
