import UIKit

/// 代表视频格式是 `URL` 的视频类型。
/// A video type with a `URL` object.
open class MediaURLVideo: MediaVideo {

  /// 视频路径。
  /// The url of the video.
  public let videoUrl: URL

  /// 预览图路径。
  /// The url of the  preview image.
  public let previewImageUrl: URL?

  /// 创建 `MediaURLVideo` 对象。Creates a `MediaURLVideo` object.
  /// - Parameters:
  ///   - videoUrl: 视频路径。The url of the video.
  ///   - previewImageUrl: 预览图路径。The url of the  preview image.
  public init(videoUrl: URL, previewImageUrl: URL? = nil) {
    self.videoUrl = videoUrl
    self.previewImageUrl = previewImageUrl
  }
}

extension MediaURLVideo: Equatable {
  public static func == (lhs: MediaURLVideo, rhs: MediaURLVideo) -> Bool {
    lhs.id == rhs.id &&
    lhs.videoUrl == rhs.videoUrl &&
    lhs.previewImageUrl == rhs.previewImageUrl
  }
}

// MARK: - Templates
extension MediaURLVideo {
  static let templates: [MediaURLVideo] = {
    var videos = [
      "BigBuckBunny",
      "ElephantsDream",
      "ForBiggerBlazes",
      "ForBiggerEscapes",
      "ForBiggerJoyrides",
      "ForBiggerMeltdowns",
      "Sintel"
    ]
      .map { name -> MediaURLVideo in
        let prefix = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample"
        return MediaURLVideo(
          videoUrl: URL(string: "\(prefix)/\(name).mp4")!,
          previewImageUrl: URL(string: "\(prefix)/images/\(name).jpg")!
        )
      }

    videos.append(.init(
      videoUrl: Bundle.module.url(forResource: "ForBiggerFun", withExtension: "mp4")!,
      previewImageUrl: nil
    ))

    return videos
  }()
}
