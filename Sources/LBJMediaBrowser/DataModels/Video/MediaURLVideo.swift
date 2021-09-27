import UIKit

public struct MediaURLVideo: MediaVideoStatusEditable {

  let previewImageUrl: URL?
  let videoUrl: URL

  public internal(set) var status: MediaVideoStatus = .idle

  public init(previewImageUrl: URL? = nil, videoUrl: URL) {
    self.previewImageUrl = previewImageUrl
    self.videoUrl = videoUrl
  }

  // for test
  init(previewImageUrl: URL? = nil, videoUrl: URL, status: MediaVideoStatus = .idle) {
    self.previewImageUrl = previewImageUrl
    self.videoUrl = videoUrl
    self.status = status
  }
}

extension MediaURLVideo {
  var isLoaded: Bool {
    switch status {
    case .loaded(let previewImgae, _):
      if previewImageUrl == nil {
        return true
      }
      return previewImgae != nil
    default:
      return false
    }
  }
}

// MARK: - Templates
extension MediaURLVideo {
  static let urlVideos: [MediaURLVideo] = {
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
