import UIKit

public struct MediaURLVideo: MediaURLVideoType {

  public let id = UUID().uuidString
  public let previewImageUrl: URL?
  public let videoUrl: URL

  public init(previewImageUrl: URL? = nil, videoUrl: URL) {
    self.previewImageUrl = previewImageUrl
    self.videoUrl = videoUrl
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
          previewImageUrl: URL(string: "\(prefix)/images/\(name).jpg")!,
          videoUrl: URL(string: "\(prefix)/\(name).mp4")!
        )
      }

    videos.append(.init(
      previewImageUrl: nil,
      videoUrl: Bundle.module.url(forResource: "ForBiggerFun", withExtension: "mp4")!
    ))

    return videos
  }()
}
