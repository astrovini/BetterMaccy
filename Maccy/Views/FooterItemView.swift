import SwiftUI

struct FooterItemView: View {
  @Bindable var item: FooterItem
  @Environment(AppState.self) private var appState

  var body: some View {
    ConfirmationView(item: item) {
      ListItemView(id: item.id, selectionId: item.id, shortcuts: item.shortcuts, isSelected: item.isSelected) {
        Text(LocalizedStringKey(item.title))
      }
    }
    .onHover { hovering in
      // Hovering the footer dismisses the preview, unless it's pinned open
      // (manual mode + "Keep preview open" setting). See `staysOpenOnHover`.
      if hovering && appState.preview.state.isOpen && !appState.preview.staysOpenOnHover {
        appState.preview.togglePreview()
      }
    }
  }
}
