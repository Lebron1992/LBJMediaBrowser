import UIKit

/// 代表视频格式是 `URL` 的视频类型。
/// A video type with a `URL` object.
public struct MediaURLVideo: MediaURLVideoType {

  public let id = UUID().uuidString
  public let videoUrl: URL
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

extension MediaURLVideo: Equatable { }

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
        let prefix = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"
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
