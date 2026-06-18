import KeyboardShortcuts

extension KeyboardShortcuts.Name {
  static let popup = Self("popup", default: Shortcut(.v, modifiers: [.option]))
  static let pin = Self("pin", default: Shortcut(.p, modifiers: [.option]))
  static let favorite = Self("favorite", default: Shortcut(.f, modifiers: [.option, .shift]))
  static let favoritesView = Self("favoritesView", default: Shortcut(.f, modifiers: [.option]))
  static let delete = Self("delete", default: Shortcut(.delete, modifiers: [.option]))
  static let togglePreview = Self("togglePreview", default: Shortcut(.space, modifiers: [.control]))
}
