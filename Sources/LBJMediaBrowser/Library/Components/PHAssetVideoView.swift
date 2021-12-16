import SwiftUI

struct PHAssetVideoView<Placeholder: View, Failure: View, Content: View>: View {

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
  
  @State
  private var status: MediaVideoStatus = .idle

  @MainActor
  private func updateStatus(_ status: MediaVideoStatus) {
    self.status = status
  }

  var body: some View {
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
    .onDisappear {
      updateStatus(.idle)
      PHAssetVideoLoader.shared.cancelLoading(for: assetVideo)
    }
    .task {
      let status = await PHAssetVideoLoader.shared.videoStatus(for: assetVideo)
      updateStatus(status)
    }
  }
}
