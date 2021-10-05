import AVKit
import SwiftUI

struct PagingVideoView<Placeholder: View, Failure: View, Content: View>: View {

  private let video: MediaVideoType
  private let placeholder: () -> Placeholder
  private let failure: (Error) -> Failure
  private let content: (MediaResult) -> Content

  init(
    video: MediaVideoType,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.video = video
    self.placeholder = placeholder
    self.failure = failure
    self.content = content
  }

  var body: some View {
    switch video.status {
    case .idle:
      placeholder()
    case .loaded(let previewImage, let videoUrl):
      content(.video(video: video, previewImage: previewImage, videoUrl: videoUrl))
    case .failed(let error):
      failure(error)
    }
  }
}

extension PagingVideoView where
Placeholder == MediaPlaceholderView,
Failure == PagingMediaErrorView,
Content == GridMediaResultView {

  init(video: MediaVideoType) {
    self.init(
      video: video,
      placeholder: { MediaPlaceholderView() },
      failure: { PagingMediaErrorView(error: $0) },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

struct PagingVideoView_Previews: PreviewProvider {
  static var previews: some View {
    let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    let video = MediaURLVideo(
      previewImageUrl: URL(string: "https://www.example.com/test.png")!,
      videoUrl: url,
      status: .loaded(previewImage: MediaUIImage.uiImages.first!.uiImage, videoUrl: url)
    )
    PagingVideoView(video: video)
      .environmentObject(PagingBrowser(medias: [video]))
  }
}
