# Changelog

Notable changes to MaccyCustom (a fork of [Maccy](https://github.com/p0deje/Maccy)).
Some fixes here patch pre-existing upstream behavior, so watch for them being
reverted on an upstream rebase.

## [2.7.1] — Unreleased

### Added

- **Popup width setting** — Settings → Appearance now has a "Popup width" field
  (alongside the existing "Popup height"), so the popup width can be set without
  dragging. The configured size applies the next time the popup opens.
- **Select & copy text in the preview** — text in the preview pane is now
  selectable, so you can highlight and copy part of an item (⌘C) instead of
  only copying the whole entry. The copied snippet is added as a new clipboard
  entry (`PreviewItemView.swift`).
- **"Keep preview open on footer hover" setting** (Settings → Appearance; active
  when auto-open is off, default on). Keeps a manually-opened preview pinned so you can
  drag-select and copy text in it: hovering the footer no longer closes or
  blanks the preview, and the hovered footer item still highlights and stays
  clickable. Turn it off to restore the previous behavior where moving to the
  footer dismisses the preview (`FooterItemView.swift`,
  `HoverSelectionModifier.swift`, `AppearanceSettingsPane.swift`).

### Changed

- **Minimum popup size is now 250 × 210** (previously ~200 wide with no real
  height floor), enforced both for dragging and for the Appearance size fields.
  The default size remains 450 × 500.
- **Preview shortcut now defaults to ⌥Space** (was ⌃Space, which collides with
  the macOS "select previous input source" system shortcut on most Macs). Only
  affects fresh installs; existing users keep their stored shortcut
  (`KeyboardShortcuts.Name+Shortcuts.swift`).
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
- **In-popup keyboard shortcuts were swallowed system-wide once recorded.** The
  KeyboardShortcuts library registers every shortcut as a global hotkey whenever
  its value is set (first-launch defaults and each time it's recorded in
  Settings). In-popup shortcuts (handled via `KeyChord`) have no global handler,
  so once claimed they were eaten everywhere and never reached the popup — which
  is why the Preview shortcut did nothing, and why Favorite / Favorites view
  would break the moment they were re-recorded. The app only un-claimed a
  hand-maintained `[.delete, .pin]` list. Inverted the model: only `.popup` is
  global; every other shortcut is auto-unregistered at launch and re-unregistered
  whenever it changes (`AppDelegate.swift`,
  `KeyboardShortcuts.Name+Shortcuts.swift`).

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
