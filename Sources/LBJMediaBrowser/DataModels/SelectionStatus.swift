import Foundation

/// 标识媒体选中状态的常量。
/// Constants identifying the selection status of a media.
public enum SelectionStatus {

  /// 媒体禁止选中。
  /// The media can not be selected.
  case disabled

  /// 媒体未选中。
  /// The media is not selected.
  case unselected

  /// 媒体已选中。
  /// The media is selected.
  case selected

  /// 是否是禁止选中状态。
  /// Whether the media can not be selected.
  public var isDisabled: Bool {
    self == .disabled
  }

  /// 是否是已选中状态。
  /// Whether the media is selected.
  public var isSelected: Bool {
    self == .selected
  }
}
