# Changelog

Notable changes to BetterMaccy (a fork of [Maccy](https://github.com/p0deje/Maccy)).
Some fixes here patch pre-existing upstream behavior, so watch for them being
reverted on an upstream rebase.

## [2.8.0] — 2026-06-21

### Added

- **"Select item with" setting** (Settings → General; default "Hover").
  Chooses how the mouse selects items in the history list. **Hover** (the
  previous, unchanged behavior): hovering highlights an item and a single click
  pastes it. **Click**: hovering does nothing, a single click highlights an
  item, and a double click pastes it — handy if hover-to-select feels too
  twitchy. Keyboard navigation and Shift+click multi-select are identical in
  both modes. In Click mode, hovering a footer item (Clear, Quit, …) still
  highlights it but no longer clears the click-selected history item, so both
  stay highlighted. The single click reads the live click count (rather than
  pairing count:1/count:2 tap gestures) so highlighting stays instant instead of
  waiting out the double-click interval, and changing the setting applies
  immediately without restarting (`SelectionMode.swift`, `HistoryItemView.swift`,
  `HoverSelectionModifier.swift`, `ListItemView.swift`, `FooterItemView.swift`,
  `NavigationManager.swift`, `GeneralSettingsPane.swift`).

### Fixed

- **Severe hover/scroll lag with large clipboard items.** Hovering over a very
  large item (e.g. a copied log file with thousands of lines) caused the entire
  popup to stall. Three compounding issues all fired on every hover event: (1)
  `PreviewItemView` was always in the view hierarchy and re-rendered
  `item.text` (up to 10k chars via CoreText) even when the preview pane was
  completely closed; (2) `String.shortened(to:)` called `.count` first, which
  walked the entire string O(n) before truncating — for a 1 MB item that was
  ~1.25 M character walks per hover; (3) `HistoryItemDecorator.text` was a
  computed property repeating that work on every render. Fixed by: not rendering
  the slideout content when closed (`SlideoutView.swift`), fixing the
  `shortened(to:)` algorithm to O(maxLength) via `index(_:offsetBy:limitedBy:)`
  (`String+Shortened.swift`), and caching `text` on `HistoryItemDecorator` at
  init time.

## [2.7.1] — 2026-06-19

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

- **Clicking the preview text jumped the selection to the first entry.** The
  first click in the now-selectable preview pane pulled focus from the search
  field, which made SwiftUI write the search `Binding` back with its unchanged
  value. `searchQuery`'s `didSet` re-ran the filter on that no-op assignment,
  and an empty query re-selects the top item — so the selection (and preview)
  snapped to the first entry, but only on the first click after opening. Fixed
  by skipping the re-filter when the query hasn't actually changed
  (`History.swift`).
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
