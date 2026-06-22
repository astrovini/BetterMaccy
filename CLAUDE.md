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

## Testing

macOS has no simulator — the Mac is the runtime. For logic changes prefer
fast, headless unit tests over `scripts/dev.sh` (no signing dance, no
Accessibility grant, no launching the brew copy):

- Run one test: `xcodebuild test -scheme BetterMaccy -destination 'platform=macOS' -only-testing:BetterMaccyTests/<Class>/<method>` (drop `-only-testing` for the whole suite). Takes ~30-60s incl. build; the test itself is milliseconds.
- The BetterMaccyTests/UITests targets are HOSTED in BetterMaccy.app, so a run
  launches the app briefly. With the project's `DEVELOPMENT_TEAM` (L228C8LS8X)
  + the Apple Development cert it launches with no Gatekeeper prompt.
- The test plan passes the `enable-testing` launch arg, so Storage.swift uses
  an in-memory store — tests do NOT touch the real history DB.
- Do NOT pass `CODE_SIGN_IDENTITY="-"` or `CODE_SIGNING_ALLOWED=NO`: the hosted
  test bundle then fails to inject and the run silently executes 0 tests (a
  false green), or Gatekeeper blocks the ad-hoc host.
- `BetterMaccy.xctestplan` skips most of `HistoryTests` (inherited from
  upstream). New HistoryTests methods still run because only the class-level
  skip was removed; the originally-listed methods stay individually skipped.

## Gotchas

- `SUFeedURL` in BetterMaccy/Info.plist and `appcast.xml` at the repo root must
  always point at the FORK (astrovini/BetterMaccy), never upstream. If an
  upstream rebase restores p0deje values, Sparkle would auto-update users
  back to official Maccy, silently removing the fork's features.
  release.sh regenerates appcast.xml each release; push it after the
  GitHub release exists.
- The whole project is renamed to BetterMaccy (Xcode project/target/scheme,
  source folder, Swift module, test targets) — a full divergence from
  upstream, so `git rebase origin/master` will conflict heavily on
  project.pbxproj and moved files. That cost was accepted for a clean rebrand.
- Coexistence with official Maccy relies on these staying distinct from the
  upstream values an unlucky rebase could restore: bundle ID
  `com.astrovini.bettermaccy`, the clipboard-history path
  `~/Library/Application Support/BetterMaccy` (hardcoded in Storage.swift),
  and the pasteboard "from me" marker `com.astrovini.bettermaccy`
  (BetterMaccy/Extensions/NSPasteboard.PasteboardType+Types.swift, was
  `org.p0deje.Maccy`). Revert any of these and the two apps step on each other.
- macOS binds the Accessibility (paste) grant to bundle ID + code
  signature. The grant on this machine belongs to the Developer ID
  identity (team L228C8LS8X). Dev builds signed with the same identity
  (what scripts/dev.sh does) inherit it; ad-hoc builds do not — paste
  fails silently, and granting the ad-hoc build re-binds the entry and
  breaks the brew build instead. If TCC gets wedged:
  `tccutil reset Accessibility com.astrovini.bettermaccy`, relaunch, re-grant.
- The fork's core feature lives in `AppState.select()`
  (BetterMaccy/Observables/AppState.swift) and `BetterMaccy/Views/HistoryItemView.swift`
  (Shift+click). Upstream ships the same multi-select machinery behind a
  disabled `multiSelectionEnabled` flag — rebases may conflict there.
