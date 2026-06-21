# Releasing BetterMaccy

How to ship a new version to the Homebrew tap. End users install with:

```sh
brew install --cask astrovini/tap/bettermaccy
```

## One-time prerequisites (already set up)

- **Developer ID Application certificate** in the login keychain
  (`Developer ID Application: José Miranda (L228C8LS8X)`). Created via
  Xcode → Settings → Accounts → Manage Certificates.
- **Notarization credentials** stored as keychain profile `maccy-notary`,
  backed by an App Store Connect API key (key ID `BH7PL4HXDX`, the
  `AuthKey_*.p8` file — keep it somewhere safe; it can't be re-downloaded).
  Recreate with:
  `xcrun notarytool store-credentials maccy-notary --key <path>.p8 --key-id <id> --issuer <issuer-uuid>`
- **`gh` CLI** authenticated as `astrovini`, with the default repo set to the
  fork: `gh repo set-default astrovini/BetterMaccy`. This clone's `origin`
  points at upstream (p0deje/Maccy), so without a default, bare `gh` commands
  (including `gh release create` below) resolve to **upstream** — they fail or
  report the wrong releases. Pass `-R p0deje/Maccy` for the rare upstream query.
- The Homebrew tap repo: <https://github.com/astrovini/homebrew-tap>,
  local clone at `~/Documents/Projects/homebrew-tap`.

## Release steps

1. Bump `MARKETING_VERSION` (e.g. `2.6.1` → `2.6.2`) AND
   `CURRENT_PROJECT_VERSION` (e.g. `61` → `62`; Sparkle compares this
   one, so it must increase every release) in `Maccy.xcodeproj` — both
   appear twice in project.pbxproj. Commit and push.

2. Build, sign, notarize, staple, and package:

   ```sh
   ./scripts/release.sh
   ```

   Produces `dist/BetterMaccy-<version>.zip` and prints its sha256.
   Notarization is automated (no human review) but can take 5–60 minutes.

3. Create the GitHub release:

   ```sh
   gh release create v<version> dist/BetterMaccy-<version>.zip \
     --title "BetterMaccy <version>" --notes "<what changed>"
   ```

4. Update the cask in `~/Documents/Projects/homebrew-tap/Casks/bettermaccy.rb`:
   set `version` and `sha256` to the new values, then commit and push.

5. Commit and push the regenerated `appcast.xml` (release.sh rewrites it).
   This powers the in-app "Check now"/automatic update checks via Sparkle;
   it must be pushed only after the GitHub release exists, or in-app
   updates will 404.

6. Verify like a user would:

   ```sh
   brew upgrade bettermaccy   # or: brew install --cask astrovini/tap/bettermaccy
   spctl --assess --type exec -v /Applications/BetterMaccy.app   # expect: Notarized Developer ID
   ```

## Pulling in upstream Maccy updates

`origin` points at upstream (p0deje/Maccy); `fork` is astrovini/BetterMaccy.
`master` tracks the fork and carries our commits on top of upstream:

```sh
git fetch origin
git rebase origin/master
git push --force-with-lease
```

Then release as above. Watch for upstream changes to `Maccy/Info.plist`
and `appcast.xml`: `SUFeedURL` must keep pointing at
`raw.githubusercontent.com/astrovini/BetterMaccy/master/appcast.xml` and
the appcast must keep listing our releases — if a rebase restores
upstream's values, Sparkle would update users back to official Maccy,
silently removing the fork's features. Also watch `AppState.select()` /
`HistoryItemView` (our multi-select paste changes).

## Fork changes vs upstream

- Multi-select paste: `multiSelectionEnabled = true`; Enter pastes the
  selection as one newline-joined block; Shift+click adds to selection
  (upstream gates this behind a disabled flag and uses Cmd+click with a
  sequential "paste stack" instead).
- Default popup shortcut Option+V; "paste automatically" on by default.
- Bundle ID `com.astrovini.bettermaccy`; app/product name `BetterMaccy`
  (a PRODUCT_NAME override — the Xcode target is still named "Maccy").
  Clipboard history lives in `~/Library/Application Support/BetterMaccy`
  (hardcoded in Storage.swift), separate from official Maccy so the two run
  side-by-side without sharing a history DB.
- Sparkle feed points at the fork's own appcast (validated via Apple
  code signing — same Developer ID team — so no EdDSA keys needed);
  automatic checks default to off. Primary update channel is
  `brew upgrade`.

## Troubleshooting

- **Notarization `Invalid`**: `xcrun notarytool log <submission-id>
  --keychain-profile maccy-notary` lists per-file errors. The script
  already handles the two we hit: Sparkle's nested binaries needing
  re-signing, and the `get-task-allow` entitlement from non-archive builds.
- **Paste not working after install**: grant Accessibility. For local
  ad-hoc dev builds (not brew installs), every rebuild changes the
  signature and silently invalidates the existing grant — remove and
  re-add BetterMaccy in System Settings → Privacy & Security → Accessibility.
  Notarized brew builds keep a stable signature, so this only affects
  dev builds.
