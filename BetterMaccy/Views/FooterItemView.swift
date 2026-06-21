import SwiftUI

struct FooterItemView: View {
  @Bindable var item: FooterItem
  @Environment(AppState.self) private var appState

  // In click mode the footer must not route hover through the navigator's
  // selection (that would clear the click-selected history item). It highlights
  // from this local hover state instead, so the history item and the hovered
  // footer item can both stay highlighted. Hover mode is unchanged — there the
  // navigator drives the footer highlight via `item.isSelected`.
  @State private var isHovered = false

  private var showsLocalHover: Bool {
    appState.navigator.selectionMode == .click && isHovered
  }

  var body: some View {
    ConfirmationView(item: item) {
      ListItemView(
        id: item.id,
        selectionId: item.id,
        shortcuts: item.shortcuts,
        isSelected: item.isSelected || showsLocalHover,
        respectsSelectionMode: true
      ) {
        Text(LocalizedStringKey(item.title))
      }
    }
    .onHover { hovering in
      isHovered = hovering
      // Hovering the footer dismisses the preview, unless it's pinned open
      // (manual mode + "Keep preview open" setting). See `staysOpenOnHover`.
      if hovering && appState.preview.state.isOpen && !appState.preview.staysOpenOnHover {
        appState.preview.togglePreview()
      }
    }
  }
}
