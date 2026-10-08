# omarket

*Formerly `omaplug` — renamed to avoid clashing with the marketplace plugins of that name.*

Search, install, and audit [Omarchy](https://omarchy.org) shell plugins from the
[community marketplace](https://plugins.omarchy.org) — from the terminal, or
from a coding agent.

```console
$ omarket search bluetooth --trust verified -n 3
Advanced Bluetooth Audio  ssupt.bluetooth-audio  ★9  verified
    Adds Bluetooth device details, reliable controls, codec selection, and per-device connect-time audio policies
Better Bluetooth  io.github.aryan-techie.bluetooth  ★1  verified
    Bluetooth device list with connect/disconnect, plus a background auto-reconnect watcher for devices you pin.
...

$ omarket install ssupt.bluetooth-audio --section right
```

## Why

The marketplace verifies a plugin at **one exact commit**. `omarchy plugin add`
clones whatever upstream `HEAD` is now. When those differ, you get code nobody
verified — about one in five listings at any given time.

omarket closes that gap:

- **Installs pin to the verified commit.** Even when upstream has moved on,
  you get the code that was checked. `--latest` opts out, explicitly.
- **Four trust levels, not two.** `verified`, `stale` (a verified commit exists
  but upstream moved), `unreviewed`, and `builtin`.
- **`omarket audit`** tells you which installed plugins are running verified
  code, which carry your own commits on top of it, which are forks of a listed
  plugin under a new id, which have drifted (e.g. after `omarchy plugin
  update`), and which were installed from a different repo than the listing
  claims.
- **Agent-friendly.** Every read command has `--json`, nothing prompts without a
  terminal, and a ready-made agent skill ships with it.

omarket never runs plugin code or catalog-provided shell strings. It builds the
`omarchy plugin add` call itself from a validated GitHub URL, lets Omarchy
clone and validate, checks out the verified commit, validates again, and only
then enables.

## Install

**Arch package (from the latest release):**

```bash
sudo pacman -U https://github.com/stewartjarod/omarket/releases/download/v0.3.1/omarket-0.3.1-1-any.pkg.tar.zst
```

**Build it yourself with makepkg:**

```bash
git clone https://github.com/stewartjarod/omarket
cd omarket/aur && makepkg -si
```

An AUR package is coming.

**From source:**

```bash
git clone https://github.com/stewartjarod/omarket
cd omarket && sudo make install
```

Requires `bash`, `jq`, `curl`, and `git` — all present on Omarchy.

## Usage

```
omarket search [query...] [options]   Search the marketplace
omarket info <id> [--json]            Show one plugin in detail
omarket install <id> [options]        Install a plugin (pinned to its verified commit)
omarket audit [--json] [--strict]     Check installed plugins against what was verified
omarket categories [--json]           List categories, kinds, and top tags
omarket refresh                       Re-download the marketplace catalog
omarket skill [--install]             Print (or install) the agent skill
```

Search filters: `--trust`, `--category`, `--kind`, `--tag`, `--installed`,
`--all` (include listings that can't be installed with `omarchy plugin add`),
`--sort relevance|popular|views|hearts|stars|updated|added|name`, `--limit`.

Install options: `--enable`, `--section left|center|right`, `--latest`,
`--allow-unverified`, `--dry-run`, `--yes`.

### Popularity

Results show **↓ copies** and **♥ hearts** from the marketplace website's
public stats (`api.omarchyplugins.com/v1/stats`). A copy means someone copied
the install command from the listing — the closest thing to an install count
that exists. Installs made directly with `omarchy plugin add` (or omarket) are
not counted, and omarket never reports anything back. `info` also shows
listing views and GitHub stars.

### Audit

```console
$ omarket audit
jarod.protonvpn          on   fork      of tharin.protonvpn: verified commit + 22 of your own
                                        from https://github.com/you/omarchy-protonvpn (jarod)
crmne.mpris              on   verified  running the commit the marketplace verified
```

| Status | Meaning |
|---|---|
| `verified` | Running the exact commit the marketplace verified |
| `ahead` | The verified commit plus your own commits on top |
| `fork` | A different id whose git remotes point at a listed plugin; shows how it compares |
| `behind` | Older than the verified commit |
| `drifted` | Different code from what was verified, e.g. after `omarchy plugin update` |
| `unreviewed` / `unlisted` | No verified commit exists / not in the marketplace |
| `repo-mismatch` | Installed from a different repo than the listing, and the code is unrelated |

`audit --strict` exits `2` if anything is not `verified`, `ahead`, or `fork` —
useful in a hook or a cron job.

## Using it from a coding agent

```bash
omarket skill --install     # writes ~/.claude/skills/omarket/SKILL.md
```

For other agents, point them at `omarket skill` (prints the same instructions)
or `/usr/share/omarket/SKILL.md`. The skill tells the agent to prefer verified
plugins and to ask you before installing anything unverified.

## How it works

The marketplace publishes its full catalog at
`https://plugins.omarchy.org/catalog.json`. omarket downloads it (HTTPS only,
size-capped), reduces it to the fields it needs with a derived trust level, and
caches both under `~/.cache/omarket/` for 24 hours. If a refresh fails it keeps
using the last good copy.

| Variable | Default |
|---|---|
| `OMARKET_CATALOG_URL` | `https://plugins.omarchy.org/catalog.json` |
| `OMARKET_TTL_HOURS` | `24` |
| `OMARKET_OFFLINE` | unset — set to `1` to never fetch |

## Caveats

- Verification is the marketplace's static check of one commit. It is **not** a
  security audit; plugins run unsandboxed inside `omarchy-shell`. See the
  marketplace's [VERIFICATION.md](https://github.com/omacom/omarchy-plugin-marketplace/blob/main/VERIFICATION.md).
- `omarchy plugin update` fast-forwards a pinned plugin to upstream `HEAD`.
  Run `omarket audit` afterwards.
- Pinning applies to single-plugin (`root-plugin`) repositories, which are
  nearly all listings. Monorepos install at `HEAD` with a warning.

## License

MIT. Not affiliated with Omarchy or the marketplace maintainers.
