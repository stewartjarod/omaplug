# omaplug

Search, install, and audit [Omarchy](https://omarchy.org) shell plugins from the
[community marketplace](https://plugins.omarchy.org) — from the terminal, or
from a coding agent.

```console
$ omaplug search bluetooth --trust verified -n 3
Advanced Bluetooth Audio  ssupt.bluetooth-audio  ★9  verified
    Adds Bluetooth device details, reliable controls, codec selection, and per-device connect-time audio policies
Better Bluetooth  io.github.aryan-techie.bluetooth  ★1  verified
    Bluetooth device list with connect/disconnect, plus a background auto-reconnect watcher for devices you pin.
...

$ omaplug install ssupt.bluetooth-audio --section right
```

## Why

The marketplace verifies a plugin at **one exact commit**. `omarchy plugin add`
clones whatever upstream `HEAD` is now. When those differ, you get code nobody
verified — about one in five listings at any given time.

omaplug closes that gap:

- **Installs pin to the verified commit.** Even when upstream has moved on,
  you get the code that was checked. `--latest` opts out, explicitly.
- **Four trust levels, not two.** `verified`, `stale` (a verified commit exists
  but upstream moved), `unreviewed`, and `builtin`.
- **`omaplug audit`** tells you which installed plugins are running verified
  code, which have drifted (e.g. after `omarchy plugin update`), and which were
  installed from a different repo than the listing claims.
- **Agent-friendly.** Every read command has `--json`, nothing prompts without a
  terminal, and a ready-made agent skill ships with it.

omaplug never runs plugin code or catalog-provided shell strings. It builds the
`omarchy plugin add` call itself from a validated GitHub URL, lets Omarchy
clone and validate, checks out the verified commit, validates again, and only
then enables.

## Install

**Arch package (from the latest release):**

```bash
sudo pacman -U https://github.com/stewartjarod/omaplug/releases/download/v0.1.0/omaplug-0.1.0-1-any.pkg.tar.zst
```

**Build it yourself with makepkg:**

```bash
git clone https://github.com/stewartjarod/omaplug
cd omaplug/aur && makepkg -si
```

An AUR package is coming.

**From source:**

```bash
git clone https://github.com/stewartjarod/omaplug
cd omaplug && sudo make install
```

Requires `bash`, `jq`, `curl`, and `git` — all present on Omarchy.

## Usage

```
omaplug search [query...] [options]   Search the marketplace
omaplug info <id> [--json]            Show one plugin in detail
omaplug install <id> [options]        Install a plugin (pinned to its verified commit)
omaplug audit [--json] [--strict]     Check installed plugins against what was verified
omaplug categories [--json]           List categories, kinds, and top tags
omaplug refresh                       Re-download the marketplace catalog
omaplug skill [--install]             Print (or install) the agent skill
```

Search filters: `--trust`, `--category`, `--kind`, `--tag`, `--installed`,
`--all` (include listings that can't be installed with `omarchy plugin add`),
`--sort relevance|stars|updated|added|name`, `--limit`.

Install options: `--enable`, `--section left|center|right`, `--latest`,
`--allow-unverified`, `--dry-run`, `--yes`.

`audit --strict` exits `2` if anything installed is not running a verified
commit — useful in a hook or a cron job.

## Using it from a coding agent

```bash
omaplug skill --install     # writes ~/.claude/skills/omaplug/SKILL.md
```

For other agents, point them at `omaplug skill` (prints the same instructions)
or `/usr/share/omaplug/SKILL.md`. The skill tells the agent to prefer verified
plugins and to ask you before installing anything unverified.

## How it works

The marketplace publishes its full catalog at
`https://plugins.omarchy.org/catalog.json`. omaplug downloads it (HTTPS only,
size-capped), reduces it to the fields it needs with a derived trust level, and
caches both under `~/.cache/omaplug/` for 24 hours. If a refresh fails it keeps
using the last good copy.

| Variable | Default |
|---|---|
| `OMAPLUG_CATALOG_URL` | `https://plugins.omarchy.org/catalog.json` |
| `OMAPLUG_TTL_HOURS` | `24` |
| `OMAPLUG_OFFLINE` | unset — set to `1` to never fetch |

## Caveats

- Verification is the marketplace's static check of one commit. It is **not** a
  security audit; plugins run unsandboxed inside `omarchy-shell`. See the
  marketplace's [VERIFICATION.md](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/VERIFICATION.md).
- `omarchy plugin update` fast-forwards a pinned plugin to upstream `HEAD`.
  Run `omaplug audit` afterwards.
- Pinning applies to single-plugin (`root-plugin`) repositories, which are
  nearly all listings. Monorepos install at `HEAD` with a warning.

## License

MIT. Not affiliated with Omarchy or the marketplace maintainers.
