import SwiftUI

struct PHAssetVideoView<Placeholder: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var videoLoader = PHAssetVideoLoader.shared

  private let assetVideo: MediaPHAssetVideo
  private let placeholder: (Media) -> Placeholder
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetVideo: MediaPHAssetVideo,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.assetVideo = assetVideo
    self.placeholder = placeholder
    self.failure = failure
    self.content = content
  }

  var body: some View {
    let status = videoLoader.videoStatus(for: assetVideo)
    ZStack {
      switch status {
      case .idle:
        placeholder(assetVideo)

      case .loaded(let previewImage, let videoUrl):
        content(.video(
          video: assetVideo,
          previewImage: previewImage,
          videoUrl: videoUrl
        ))

      case .failed(let error):
        // TODO: handle retry
        failure(error)
      }
    }
    .onAppear {
      videoLoader.loadUrl(for: assetVideo)
    }
    .onDisappear {
      videoLoader.cancelLoading(for: assetVideo)
    }
  }
}
