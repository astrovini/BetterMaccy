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

      // `onHover` fires *during* the SwiftUI layout pass when programmatic
      // scrolling drags rows under a stationary cursor (e.g. holding Option+V to
      // cycle the list). Mutating observed navigator state synchronously here
      // re-enters the in-flight layout transaction, which can fail to converge
      // and spin the main thread at 100% CPU — an unrecoverable whole-app freeze
      // (captured in a cpu_resource DiagnosticReport, 2026-06-22). Defer the
      // mutation to the next runloop turn so it lands outside the layout pass,
      // and skip redundant stash writes.
      DispatchQueue.main.async {
        if !appState.navigator.isKeyboardNavigating && !appState.navigator.isMultiSelectInProgress {
          appState.navigator.selectWithoutScrolling(id: id)
        } else if appState.navigator.hoverSelectionWhileKeyboardNavigating != id {
          appState.navigator.hoverSelectionWhileKeyboardNavigating = id
        }
      }
    }
  }
}

extension View {
  func hoverSelectionId(_ id: UUID, respectsSelectionMode: Bool = false) -> some View {
    modifier(HoverSelectionModifier(id: id, respectsSelectionMode: respectsSelectionMode))
  }
}
