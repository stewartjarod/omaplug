---
name: omaplug
description: Find, inspect, install, and audit Omarchy shell plugins (bar widgets, overlays, panels, services) from the community marketplace at plugins.omarchy.org. Use when the user wants a new bar widget or desktop feature on Omarchy, asks "is there a plugin for X", wants to install a plugin by name, or wants to check whether installed plugins are running verified code.
---

# omaplug

`omaplug` searches the Omarchy plugin marketplace (5,000+ plugins) and installs plugins pinned to the exact commit the marketplace verified. Always use `--json` when reading output.

## Find a plugin

```bash
omaplug search <words...> --json            # all words must match name/id/tags/description
omaplug search spotify --trust verified --json
omaplug search --category Productivity --sort stars -n 10 --json
omaplug categories --json                    # valid categories, kinds, top tags
```

Each result has `id`, `name`, `description`, `trust`, `stars`, `kind`, `installed`, `enabled`. Pick by relevance first, then prefer `trust: "verified"`, then stars.

## Inspect before installing

```bash
omaplug info <id> --json
```

Show the user the name, description, trust level, and repo before installing anything.

## Trust levels

- `verified` — the marketplace verified this exact commit. Safe default.
- `stale` — an older commit was verified; upstream has moved. `omaplug install` pins the verified commit automatically.
- `unreviewed` — never verified. **Ask the user before installing**, then pass `--allow-unverified`.
- `builtin` — ships with Omarchy. Do not install; run `omarchy plugin enable <id>`.

Never pass `--latest` or `--allow-unverified` without the user's explicit approval. Plugins run unsandboxed inside the desktop shell.

## Install

```bash
omaplug install <id> --yes                       # installed disabled, pinned to verified commit
omaplug install <id> --yes --enable              # and enable it
omaplug install <id> --yes --section right       # bar widget into a bar section (implies --enable)
omaplug install <id> --dry-run                   # show what would happen
```

`--yes` is required when no terminal is attached. Confirm with `omarchy plugin list --json`.

## Audit installed plugins

```bash
omaplug audit --json
```

Statuses: `verified` (running the verified commit), `drifted` (running a different commit, e.g. after `omarchy plugin update`), `unreviewed`, `unlisted`, `repo-mismatch` (installed from a different repo than the listing — flag this to the user).

## Manage installed plugins

Use the Omarchy CLI: `omarchy plugin enable|disable|remove|update <id>`. Note `omarchy plugin update` moves to upstream HEAD, which may not be verified; run `omaplug audit` afterwards.
