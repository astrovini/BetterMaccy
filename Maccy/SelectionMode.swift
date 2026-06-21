import Defaults
import Foundation

// Controls how the mouse highlights/activates items in the history list.
// `.hover` (default, upstream behavior): hover highlights, single click pastes.
// `.click`: single click highlights, double click pastes, hover does nothing.
// Keyboard navigation is unaffected by this setting.
enum SelectionMode: String, CaseIterable, Identifiable, CustomStringConvertible, Defaults.Serializable {
  case hover
  case click

  var id: Self { self }

  var description: String {
    switch self {
    case .hover:
      return NSLocalizedString("SelectionModeHover", tableName: "GeneralSettings", comment: "")
    case .click:
      return NSLocalizedString("SelectionModeClick", tableName: "GeneralSettings", comment: "")
    }
  }
}
