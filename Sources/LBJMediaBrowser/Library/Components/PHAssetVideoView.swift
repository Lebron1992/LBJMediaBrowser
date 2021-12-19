import SwiftUI

struct PHAssetVideoView<Placeholder: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var videoLoader = PHAssetVideoLoader.shared

  private let assetVideo: MediaPHAssetVideo
  private let maxThumbnailSize: CGSize
  private let placeholder: (Media) -> Placeholder
  private let failure: (_ error: Error, _ retry: @escaping () -> Void) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetVideo: MediaPHAssetVideo,
    maxThumbnailSize: CGSize,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder failure: @escaping (_ error: Error, _ retry: @escaping () -> Void) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.assetVideo = assetVideo
    self.maxThumbnailSize = maxThumbnailSize
    self.placeholder = placeholder
    self.failure = failure
    self.content = content
  }

  var body: some View {
    ZStack {
      switch videoStatus {
      case .idle:
        placeholder(assetVideo)

      case .loaded(let previewImage, let videoUrl):
        content(.video(
          video: assetVideo,
          previewImage: previewImage,
          videoUrl: videoUrl
        ))

      case .failed(let error):
        failure(error, loadUrl)
      }
    }
    .onAppear(perform: loadUrl)
    .onDisappear(perform: cancelLoading)
  }

  private var videoStatus: MediaVideoStatus {
    videoLoader.videoStatus(for: assetVideo, maxThumbnailSize: maxThumbnailSize)
  }

  private func loadUrl() {
    if videoStatus.isLoaded {
      return
    }
    videoLoader.loadUrl(for: assetVideo, maxThumbnailSize: maxThumbnailSize)
  }

  private func cancelLoading() {
    videoLoader.cancelLoading(for: assetVideo, maxThumbnailSize: maxThumbnailSize)
  }
}
