import UIKit

/// 标识视频状态的常量。
/// Constants identifying the status of a video.
public enum MediaVideoStatus {

  /// 视频处于未处理状态。
  /// The video is idle.
  case idle

  /// 视频加载完成。
  /// The video is loaded.
  /// - previewImage: 视频封面图片。The thumbnail of the video.
  /// - videoUrl: 视频路径。The url of the video.
  case loaded(previewImage: UIImage?, videoUrl: URL)

  /// 视频加载失败，关键值是加载失败的原因。
  /// Failed to load the video. The associated value is the reason why failed to load the video.
  case failed(Error)
}

extension MediaVideoStatus {
  var isLoaded: Bool {
    switch self {
    case .loaded:
      return true
    default:
      return false
    }
  }
}

extension MediaVideoStatus: Equatable {
  public static func == (lhs: MediaVideoStatus, rhs: MediaVideoStatus) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (loaded(let li, let lv), .loaded(let ri, let rv)):
      return li == ri && lv == rv
    case (.failed(let le), .failed(let re)):
      return le.localizedDescription == re.localizedDescription
    default:
      return false
    }
  }
}
