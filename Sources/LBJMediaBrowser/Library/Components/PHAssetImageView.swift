import SwiftUI

struct PHAssetImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  private let assetImage: MediaPHAssetImage
  private let targetSize: ImageTargetSize
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.assetImage = assetImage
    self.targetSize = targetSize
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

  @State
  private var status: MediaImageStatus = .idle

  @MainActor
  private func updateStatus(_ status: MediaImageStatus) {
    self.status = status
  }

  var body: some View {
    ZStack {
      switch status {
      case .idle:
        placeholder(assetImage)

      case .loading(let progress):
        if progress > 0 && progress < 1 {
          self.progress(progress)
        } else {
          placeholder(assetImage)
        }

      case .loaded(let uiImage):
        content(.image(image: assetImage, uiImage: uiImage))

      case .failed(let error):
        // TODO: handle retry
        failure(error)
      }
    }
    .onDisappear {
      updateStatus(.idle)
      PHAssetImageLoader.shared.cancelLoading(for: assetImage, targetSize: targetSize)
    }
    .task {
      let status = await PHAssetImageLoader.shared.imageStatus(for: assetImage, targetSize: targetSize)
      updateStatus(status)
    }
  }
}
