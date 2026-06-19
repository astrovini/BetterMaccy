import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  static let popup = Self("popup", default: Shortcut(.v, modifiers: [.option]))
  static let pin = Self("pin", default: Shortcut(.p, modifiers: [.option]))
  static let favorite = Self("favorite", default: Shortcut(.f, modifiers: [.option, .shift]))
  static let favoritesView = Self("favoritesView", default: Shortcut(.f, modifiers: [.option]))
  static let delete = Self("delete", default: Shortcut(.delete, modifiers: [.option]))
  static let togglePreview = Self("togglePreview", default: Shortcut(.space, modifiers: [.control]))

  /// Every shortcut the app defines. Keep this in sync when adding new shortcuts.
  static let allShortcuts: [Self] = [.popup, .pin, .favorite, .favoritesView, .delete, .togglePreview]

  /// Shortcuts that fire system-wide. Only `.popup` opens Maccy from any app;
  /// every other shortcut is handled inside the popup window (see `KeyChord`), so
  /// it must NOT be registered as a global hotkey. The KeyboardShortcuts library
  /// otherwise claims the key combo system-wide with no handler attached and
  /// silently swallows the keystroke everywhere — which is what broke the
  /// in-popup shortcuts. See `AppDelegate.disableInPopupGlobalHotkeys`.
  static let globalShortcuts: [Self] = [.popup]

  /// Shortcuts handled inside the popup window. These must never be registered as
  /// global hotkeys.
  static var inPopupShortcuts: [Self] { allShortcuts.filter { !globalShortcuts.contains($0) } }
}
