import SwiftUI

private struct HoverSelectionModifier: ViewModifier {
  @Environment(AppState.self) private var appState
  var id: UUID
  // History rows (true) obey the selection-mode setting and skip hover-select in
  // click mode; footer / paste-stack rows (false) always hover-select. This flag
  // is constant per row type; the live mode is read from the cached navigator.
  var respectsSelectionMode: Bool

  func body(content: Content) -> some View {
    content.onHover { hovering in
      guard hovering else { return }
      if respectsSelectionMode && appState.navigator.selectionMode != .hover { return }

      if !appState.navigator.isKeyboardNavigating && !appState.navigator.isMultiSelectInProgress {
        appState.navigator.selectWithoutScrolling(id: id)
      } else {
        appState.navigator.hoverSelectionWhileKeyboardNavigating = id
      }
    }
  }
}

extension View {
  func hoverSelectionId(_ id: UUID, respectsSelectionMode: Bool = false) -> some View {
    modifier(HoverSelectionModifier(id: id, respectsSelectionMode: respectsSelectionMode))
  }
}
