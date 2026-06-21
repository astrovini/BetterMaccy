import Defaults
import SwiftUI

struct HistoryItemView: View {
  @Bindable var item: HistoryItemDecorator
  var previous: HistoryItemDecorator?
  var next: HistoryItemDecorator?
  var index: Int

  private var visualIndex: Int? {
    if appState.navigator.isMultiSelectInProgress && item.selectionIndex >= 0 {
      return item.selectionIndex
    }
    return nil
  }

  private var selectionAppearance: SelectionAppearance {
    let previousSelected = previous?.isSelected ?? false
    let nextSelected = next?.isSelected ?? false
    switch (previousSelected, nextSelected) {
    case (true, false):
      return .topConnection
    case (false, true):
      return .bottomConnection
    case (true, true):
      return .topBottomConnection
    default:
      return .none
    }
  }

  @Environment(AppState.self) private var appState

  var body: some View {
    ListItemView(
      id: item.id,
      selectionId: item.id,
      appIcon: item.applicationImage,
      image: item.thumbnailImage,
      accessoryImage: item.thumbnailImage != nil ? nil : ColorImage.from(item.title),
      attributedTitle: item.attributedTitle,
      shortcuts: item.shortcuts,
      isSelected: item.isSelected,
      selectionIndex: visualIndex,
      selectionAppearance: selectionAppearance,
      isFavorited: item.isFavorited,
      showFavoriteToggle: item.isSelected || item.isFavorited,
      onToggleFavorite: {
        Task { appState.history.toggleFavorite(item) }
      },
      respectsSelectionMode: true
    ) {
      Text(verbatim: item.displayTitle)
    }
    .onAppear {
      item.ensureThumbnailImage()
    }
    .onTapGesture {
      handleTap()
    }
  }

  // One tap gesture covers both modes, reading the live mode from the cached
  // navigator flag so a setting change applies instantly. A single gesture
  // (rather than paired count:1/count:2) keeps the click instant — pairing them
  // makes SwiftUI wait out the double-click interval before selecting.
  private func handleTap() {
    if NSEvent.modifierFlags.contains(.shift) && appState.multiSelectionEnabled {
      appState.navigator.addToSelection(item: item)
    } else if appState.navigator.selectionMode == .click
                && (NSApp.currentEvent?.clickCount ?? 1) < 2 {
      // Click mode, single click: highlight only.
      appState.navigator.selectFromMouseClick(item: item)
    } else {
      // Hover mode (single click) or click mode (double click): paste.
      Task { appState.history.select(item) }
    }
  }
}
