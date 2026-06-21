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

  @Default(.selectionMode) private var selectionMode
  @Environment(AppState.self) private var appState

  var body: some View {
    listItem
      .onAppear {
        item.ensureThumbnailImage()
      }
  }

  @ViewBuilder
  private var listItem: some View {
    let view = ListItemView(
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
      hoverToSelect: selectionMode == .hover
    ) {
      Text(verbatim: item.displayTitle)
    }

    switch selectionMode {
    case .hover:
      // Hover highlights; a single click pastes.
      view.onTapGesture {
        if isMultiSelectClick {
          appState.navigator.addToSelection(item: item)
        } else {
          paste()
        }
      }
    case .click:
      // A single click highlights; a double click pastes. A single tap gesture
      // (reading the live click count) is used instead of separate count:1 /
      // count:2 gestures so the highlight is instant — pairing the two makes
      // SwiftUI wait out the double-click interval before the single tap fires.
      view.onTapGesture {
        if isMultiSelectClick {
          appState.navigator.addToSelection(item: item)
        } else if (NSApp.currentEvent?.clickCount ?? 1) >= 2 {
          paste()
        } else {
          appState.navigator.selectFromMouseClick(item: item)
        }
      }
    }
  }

  private var isMultiSelectClick: Bool {
    NSEvent.modifierFlags.contains(.shift) && appState.multiSelectionEnabled
  }

  private func paste() {
    Task { appState.history.select(item) }
  }
}
