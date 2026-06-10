# homebrew-xymon

A [Homebrew](https://brew.sh/) tap for [Xymon](https://xymon.com/) on macOS —
**server** and **client**.

```sh
brew tap bonomani/xymon
brew install --HEAD bonomani/xymon/xymon          # server
brew install --HEAD bonomani/xymon/xymon-client   # client only
```

## Always track the latest commit

These formulae carry a `head` stanza pointing at `main`, so `--HEAD` always
builds from the **newest commit**. To pull a fresh commit later (HEAD installs
don't auto-detect new commits), force a re-fetch:

```sh
brew upgrade --fetch-HEAD bonomani/xymon/xymon
# or, to rebuild from scratch at the current tip:
brew reinstall --HEAD bonomani/xymon/xymon
```

That's the always-latest workflow. (When a stable `rel-4.3.31` tarball is later
pinned via `url`/`sha256`, plain `brew install` will give that release while
`--HEAD` keeps giving the latest commit — the two coexist.)

## Status

Both formulae build and install on `macos-latest` via CI (`--HEAD`, latest commit):

- **`xymon`** (server) — ✅ builds & installs. Build-only: it does not create a
  `xymon` user, web-server config, or a launchd service — runtime setup (hosts.cfg,
  web CGIs, a launch mechanism) is left to the admin.
- **`xymon-client`** — ✅ builds & installs. The lighter, self-contained option for
  monitoring a Mac that reports to an existing server.

### Notes

These formulae build Xymon from the `main` branch via its standard
`configure`/`make` build, using Homebrew-provided dependencies
(`openssl@3`, `pcre2`, `rrdtool`, `fping`). Two things are deliberately open:

1. **No pinned release yet.** Homebrew normally pins a `url` + `sha256`. Xymon
   has no published release tarball, so for now these are `--HEAD`-only. Once
   the release workflow cuts `rel-4.3.31` (producing `xymon-4.3.31.tar.gz` +
   `.sha256`), replace the `head` stanza with the pinned `url`/`sha256` — the
   commented block in `Formula/xymon.rb` shows exactly what to add.

2. **Needs a real macOS test pass.** The formulae have not yet been run through
   `brew install` on a Mac. The build is non-interactive (Xymon's `configure`
   is fully env-var driven) and installs into the Homebrew prefix via
   `make install PKGBUILD=1` (which skips the `chown`/user-creation a system
   install would do). Expect to iterate on the `configure` env vars and install
   paths on first run:

   ```sh
   brew install --HEAD --build-from-source --verbose --debug bonomani/xymon/xymon
   ```

## What these formulae are (and aren't)

- **Build-only.** They compile and install the binaries/scripts under the brew
  prefix. They do **not** create a `xymon` user, web-server config, or a launchd
  service — Xymon's server is a system daemon with an opinionated layout, so
  runtime setup (hosts.cfg, web CGIs, a launch mechanism) is left to the admin.
- The **client** is the simpler, more self-contained of the two and the better
  starting point if you just want host monitoring reporting to an existing server.

Tracked upstream alongside the Debian (#28) and FreeBSD (#103) packaging audits.
