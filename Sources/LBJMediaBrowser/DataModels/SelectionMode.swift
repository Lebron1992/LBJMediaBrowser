import Foundation

/// 标识媒体浏览器的选择模式的常量。
/// Constants identifying the selection mode in the media browser.
public enum SelectionMode {

  /// 禁用选择模式。
  /// Disable the selection mode
  case disabled

  /// 只能选择图片，关联值是可选择图片的最大数量，`nil`表示无限制。
  /// Select the images ONLY, the associated value is the max selectable count of the images, `nil` means no limitation.
  case image(max: Int?)

  /// 只能选择视频，关联值是可选择视频的最大数量，`nil`表示无限制。
  /// Select the videos ONLY, the associated value is the max selectable count of the videos, `nil` means no limitation.
  case video(max: Int?)

  /// 可以选择任何媒体，关联值是可选择媒体的最大数量，`nil`表示无限制。
  /// Can select any medias, the associated value is the max selectable count of the medias, `nil` means no limitation.
  case any(max: Int?)

  var numberOfSelection: Int {
    switch self {
    case .disabled:        return 0
    case .image(let max): return max ?? .max
    case .video(let max): return max ?? .max
    case .any(let max):   return max ?? .max
    }
  }
}

extension SelectionMode: Equatable {}
