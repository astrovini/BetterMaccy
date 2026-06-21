import SwiftUI

private struct HoverSelectionModifier: ViewModifier {
  @Environment(AppState.self) private var appState
  var id: UUID
  // When false (click-to-select mode), hovering never changes the selection.
  var enabled: Bool

  func body(content: Content) -> some View {
    content.onHover { hovering in
      if hovering && enabled {
        if !appState.navigator.isKeyboardNavigating && !appState.navigator.isMultiSelectInProgress {
          appState.navigator.selectWithoutScrolling(id: id)
        } else {
          appState.navigator.hoverSelectionWhileKeyboardNavigating = id
        }
      }
    }
  }
}

extension View {
  func hoverSelectionId(_ id: UUID, enabled: Bool = true) -> some View {
    modifier(HoverSelectionModifier(id: id, enabled: enabled))
  }
}
