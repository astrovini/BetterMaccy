# Changelog

Notable changes to MaccyCustom (a fork of [Maccy](https://github.com/p0deje/Maccy)).
Some fixes here patch pre-existing upstream behavior, so watch for them being
reverted on an upstream rebase.

## [2.7.1] — Unreleased

### Added

- **Popup width setting** — Settings → Appearance now has a "Popup width" field
  (alongside the existing "Popup height"), so the popup width can be set without
  dragging. The configured size applies the next time the popup opens.

### Changed

- **Minimum popup size is now 250 × 210** (previously ~200 wide with no real
  height floor), enforced both for dragging and for the Appearance size fields.
  The default size remains 450 × 500.

### Fixed

- **Couldn't shrink the popup again after widening it (pre-existing).** The list
  content is pinned to an exact width, which `NSHostingView` propagated as the
  window's minimum size — so every time the popup was widened the floor ratcheted
  up and it could never be made narrower again. Fixed by decoupling the window's
  minimum size from the SwiftUI content (`sizingOptions = []`) plus an explicit
  `contentMinSize`; the configured width now applies on open instead of being
  capped to the previous frame width (`FloatingPanel.swift`).
- **Right side of the popup ignored the mouse / appeared to freeze (with the
  preview closed).** The closed preview/slideout pane still laid out at its
  200pt minimum width and, on macOS 26, the clipped overflow kept receiving
  hit-testing — an invisible "ghost" pane sat over the right ~200pt of the list
  and swallowed mouse hover. Fixed by disabling hit-testing on the slideout
  while it's closed (`SlideoutView.swift`).

## [2.7.0] — 2026-06-18

### Added

- **Favorites view** — a separate list of items you mark as favorites, distinct
  from pins.
  - Toolbar star toggles between Recents and Favorites; the popup always reopens
    on Recents, and search filters within the current view.
  - Mark/unmark the selected item(s) with the per-row star or the keyboard.
  - Favorites are kept regardless of the history size limit and survive **Clear**
    (Clear All still removes them).
  - Shortcuts, rebindable in Settings → General: **⌥F** toggles the view,
    **⌥⇧F** marks/unmarks the selection.
