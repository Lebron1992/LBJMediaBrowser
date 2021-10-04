import SwiftUI

struct GridPHAssetVideoView<Placeholder: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var videoManager: AssetVideoManager

  private let assetVideo: MediaPHAssetVideo
  private let placeholder: () -> Placeholder
  private let failure: (Error) -> Failure
  private let content: (MediaResult) -> Content

  init(
    assetVideo: MediaPHAssetVideo,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    videoManager = AssetVideoManager(assetVideo: assetVideo)
    self.assetVideo = assetVideo
    self.placeholder = placeholder
    self.failure = failure
    self.content = content
  }

  var body: some View {
    switch videoManager.videoStatus {
    case .idle:
      placeholder()
        .onAppear {
          videoManager.startRequestVideoUrl()
        }

    case .loaded(let previewImage, let videoUrl):
      content(.video(
        video: assetVideo,
        previewImage: previewImage,
        videoUrl: videoUrl
      ))

    case .failed(let error):
      failure(error)
    }
  }
}
