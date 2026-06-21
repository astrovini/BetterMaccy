# BetterMaccy

Personal fork of [Maccy](https://github.com/p0deje/Maccy) (macOS clipboard
manager, Swift/SwiftUI) with multi-select paste. Both the app/product name
and the repo are "BetterMaccy". It installs and runs side-by-side with
official Maccy thanks to a distinct bundle ID and storage path.

## Remotes and branches

- `origin` = upstream p0deje/Maccy (pull only — no write access)
- `fork` = astrovini/BetterMaccy (ours; `master` tracks `fork/master`)
- `master` = upstream master + a small stack of fork commits (multi-select
  paste, Option+V default shortcut, paste-automatically default, bundle ID
  `com.astrovini.bettermaccy`, Sparkle feed removed, release tooling)

Upstream sync: `git fetch origin && git rebase origin/master && git push --force-with-lease`.

## Building and releasing

- Local dev build + run: `./scripts/dev.sh` (builds, signs with the
  Developer ID identity, launches from DerivedData). Do NOT launch the
  raw xcodebuild output: the embedded Sparkle framework's Team ID
  mismatch kills it at startup (dyld error), and ad-hoc re-signing makes
  paste fail (see Gotchas). Quit and `open /Applications/BetterMaccy.app` to
  return to the brew-installed copy.
- Distribution (signed + notarized + zipped): `./scripts/release.sh`, then
  follow [RELEASING.md](RELEASING.md) (GitHub release + bump the cask in
  ~/Documents/Projects/homebrew-tap). Users install via
  `brew install --cask astrovini/tap/bettermaccy`.

## Gotchas

- `SUFeedURL` in Maccy/Info.plist and `appcast.xml` at the repo root must
  always point at the FORK (astrovini/BetterMaccy), never upstream. If an
  upstream rebase restores p0deje values, Sparkle would auto-update users
  back to official Maccy, silently removing the fork's features.
  release.sh regenerates appcast.xml each release; push it after the
  GitHub release exists.
- Coexistence with official Maccy relies on three things staying distinct:
  bundle ID `com.astrovini.bettermaccy`, app name `BetterMaccy` (a
  PRODUCT_NAME override — the Xcode target/scheme is still named "Maccy"),
  and the clipboard-history path `~/Library/Application Support/BetterMaccy`
  (hardcoded in Storage.swift). An upstream rebase could revert the storage
  path to `Maccy/` and make both apps share one history DB — watch for it.
- macOS binds the Accessibility (paste) grant to bundle ID + code
  signature. The grant on this machine belongs to the Developer ID
  identity (team L228C8LS8X). Dev builds signed with the same identity
  (what scripts/dev.sh does) inherit it; ad-hoc builds do not — paste
  fails silently, and granting the ad-hoc build re-binds the entry and
  breaks the brew build instead. If TCC gets wedged:
  `tccutil reset Accessibility com.astrovini.bettermaccy`, relaunch, re-grant.
- The fork's core feature lives in `AppState.select()`
  (Maccy/Observables/AppState.swift) and `Maccy/Views/HistoryItemView.swift`
  (Shift+click). Upstream ships the same multi-select machinery behind a
  disabled `multiSelectionEnabled` flag — rebases may conflict there.
