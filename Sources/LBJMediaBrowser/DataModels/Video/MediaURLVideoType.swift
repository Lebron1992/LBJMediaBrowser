import Foundation

/// 代表视频格式是 `URL` 的视频类型。
/// A type that represents a video with a `URL` object.
public protocol MediaURLVideoType: MediaVideoType {

  /// 视频路径。
  /// The url of the video.
  var videoUrl: URL { get }

  /// 预览图路径。
  /// The url of the  preview image.
  var previewImageUrl: URL? { get }
}
