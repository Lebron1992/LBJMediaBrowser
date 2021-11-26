import SwiftUI

struct PHAssetVideoView<Placeholder: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var videoManager = AssetVideoManager()

  private let assetVideo: MediaPHAssetVideo
  private let placeholder: (MediaType) -> Placeholder
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetVideo: MediaPHAssetVideo,
    @ViewBuilder placeholder: @escaping (MediaType) -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.assetVideo = assetVideo
    self.placeholder = placeholder
    self.failure = failure
    self.content = content
    self.videoManager.setAssetVideo(assetVideo)
  }

  var body: some View {
    switch videoManager.videoStatus {
    case .idle:
      placeholder(assetVideo)
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
        .environmentObject(videoManager as MediaLoader)
    }
  }
}
