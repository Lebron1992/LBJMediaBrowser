import UIKit

/// 标识图片状态的常量。
/// Constants identifying the status of an image.
public enum MediaImageStatus {

  /// 图片处于未处理状态。
  /// The image is idle.
  case idle

  /// 图片处于正在加载状态，关联值是加载进度（范围是 0~1）。
  /// The image is in loading. The associated value is the progress (The range is 0~1).
  case loading(Float)

  /// 图片加载完成，关联值是 `UIImage` 对象。
  /// The image is loaded. The associated value is an `UIImage` object.
  case loaded(UIImage)

  /// 图片加载失败，关键值是加载失败的原因。
  /// Failed to load the image. The associated value is the reason why failed to load the image.
  case failed(Error)

  var isLoading: Bool {
    switch self {
    case .loading:
      return true
    default:
      return false
    }
  }

  var isLoaded: Bool {
    switch self {
    case .loaded:
      return true
    default:
      return false
    }
  }

  var isLoadingOrLoaded: Bool {
    isLoading || isLoaded
  }
}

extension MediaImageStatus: Equatable {
  public static func == (lhs: MediaImageStatus, rhs: MediaImageStatus) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (.loading(let lf), .loading(let rf)):
      return lf == rf
    case (loaded(let li), .loaded(let ri)):
      return li == ri
    case (.failed(let le), .failed(let re)):
      return le.localizedDescription == re.localizedDescription
    default:
      return false
    }
  }
}
