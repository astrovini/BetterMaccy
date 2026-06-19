import SwiftUI

private struct HoverSelectionModifier: ViewModifier {
  @Environment(AppState.self) private var appState
  var id: UUID

  func body(content: Content) -> some View {
    content.onHover { hovering in
      guard hovering else { return }

      if !appState.navigator.isKeyboardNavigating && !appState.navigator.isMultiSelectInProgress {
        // When the preview is pinned open (manual mode + "Keep preview open"),
        // hovering a footer item should show the footer highlight but must not
        // clear the history selection — which would blank the preview. So
        // highlight the footer item only, leaving the list selection and preview
        // intact.
        if appState.preview.state.isOpen,
           appState.preview.staysOpenOnHover,
           let footerItem = appState.footer.items.first(where: { $0.id == id }) {
          appState.footer.selectedItem = footerItem
        } else {
          appState.navigator.selectWithoutScrolling(id: id)
        }
      } else {
        appState.navigator.hoverSelectionWhileKeyboardNavigating = id
      }
    }
  }
}

extension View {
  func hoverSelectionId(_ id: UUID) -> some View {
    modifier(HoverSelectionModifier(id: id))
  }
}
