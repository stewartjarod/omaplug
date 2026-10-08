---
name: omarket
description: Find, inspect, install, and audit Omarchy shell plugins (bar widgets, overlays, panels, services) from the community marketplace at plugins.omarchy.org. Use when the user wants a new bar widget or desktop feature on Omarchy, asks "is there a plugin for X", wants to install a plugin by name, or wants to check whether installed plugins are running verified code.
---

# omarket

`omarket` searches the Omarchy plugin marketplace (5,000+ plugins) and installs plugins pinned to the exact commit the marketplace verified. Always use `--json` when reading output.

## Find a plugin

```bash
omarket search <words...> --json            # the user's words are fine; filler words are ignored
omarket search spotify --trust verified --json
omarket search --category Productivity -n 10 --json   # no query: most popular first
omarket categories --json                    # valid categories, kinds, top tags
```

- Results must match every word; if nothing does, omarket falls back to partial matches and says so on **stderr**. Treat partial matches as weaker.
- Only the top 20 are returned by default. A `showing N of M` note on stderr means there are more: narrow the query or pass `--limit 0`.
- Listings that cannot be installed with `omarchy plugin add` (manual-setup suites, etc.) are hidden unless you pass `--all`.

Each result has `id`, `name`, `description`, `trust`, `copies`, `views`, `hearts`, `stars`, `kind`, `installable`, `installed`, `enabled`, `installedAs`. `copies` (install commands copied on the marketplace site) is the best available signal of how many people use a plugin. Pick by relevance first, then prefer `trust: "verified"`, then higher `copies`.

If `installedAs` differs from `id`, the user already runs that plugin under another id (usually their own fork). Do not install the listing again.

## Inspect before installing

```bash
omarket info <id> --json
```

Show the user the name, description, trust level, usage, and repo before installing anything. For an installed id the marketplace does not list, `info` returns `listed: false` and `forkOf` (the listing it was forked from, if any).

## Trust levels

- `verified` — the marketplace verified this exact commit. Safe default.
- `stale` — an older commit was verified; upstream has moved. `omarket install` pins the verified commit automatically.
- `unreviewed` — never verified. **Ask the user before installing**, then pass `--allow-unverified`.
- `builtin` — ships with Omarchy. Do not install; run `omarchy plugin enable <id>`.

Never pass `--latest` or `--allow-unverified` without the user's explicit approval. Plugins run unsandboxed inside the desktop shell.

## Install

```bash
omarket install <id> --yes                       # installed disabled, pinned to verified commit
omarket install <id> --yes --enable              # and enable it
omarket install <id> --yes --section right       # bar widgets only: place it in a bar section (implies --enable)
omarket install <id> --dry-run                   # show what would happen
```

`--yes` is required when no terminal is attached. Confirm with `omarchy plugin list --json`.

Install refuses when the plugin is already installed, including as a fork under another id, and when `--section` is used on something that is not a bar widget. Relay the error to the user rather than working around it.

## Audit installed plugins

```bash
omarket audit --json
```

Statuses:
- `verified` — running the exact commit the marketplace verified.
- `ahead` — the verified commit plus the user's own commits on top. Deliberate, not a problem.
- `fork` — installed under a different id but descends from a listed plugin (matched by git remote). `base` is the listing; `relation`/`aheadBy`/`behindBy` say how it compares. Usually the user's own fork.
- `behind` — older than the verified commit; `omarchy plugin update <id>` would catch it up.
- `drifted` — different code than verified, with no ancestry relationship (e.g. after `omarchy plugin update` pulled unverified commits). Mention it.
- `unreviewed`, `unlisted` — no verified commit exists, or not in the marketplace at all.
- `repo-mismatch` — installed from a different repo than the listing and the code is unrelated. Flag this to the user.

`source` and `branch` show where the running code comes from (the remote the checked-out branch tracks).

## Manage installed plugins

Use the Omarchy CLI: `omarchy plugin enable|disable|remove|update <id>`. Note `omarchy plugin update` moves to upstream HEAD, which may not be verified; run `omarket audit` afterwards.
