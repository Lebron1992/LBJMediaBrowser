import SwiftUI

struct URLVideoView<Placeholder: View, Content: View>: View {

  private let urlVideo: MediaURLVideo
  private let imageTargetSize: ImageTargetSize
  private let placeholder: (Media) -> Placeholder
  private let content: (MediaLoadedResult) -> Content

  init(
    urlVideo: MediaURLVideo,
    imageTargetSize: ImageTargetSize,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.urlVideo = urlVideo
    self.imageTargetSize = imageTargetSize
    self.placeholder = placeholder
    self.content = content
  }
  
  var body: some View {
    if let previewUrl = urlVideo.previewImageUrl {
      URLImageView(
        urlImage: .init(imageUrl: previewUrl),
        targetSize: imageTargetSize,
        placeholder: { _ in placeholder(urlVideo) },
        progress: { _ in EmptyView() },
        failure: { _, _ in
          content(.video(
            video: urlVideo,
            previewImage: nil,
            videoUrl: urlVideo.videoUrl
          ))
        },
        content: { mediaResult in
          if case let .image(_, imageResult) = mediaResult {
            content(.video(
              video: urlVideo,
              previewImage: imageResult.stillImage,
              videoUrl: urlVideo.videoUrl
            ))
          }
        }
      )
    } else {
      content(.video(
        video: urlVideo,
        previewImage: nil,
        videoUrl: urlVideo.videoUrl
      ))
    }
  }
}
