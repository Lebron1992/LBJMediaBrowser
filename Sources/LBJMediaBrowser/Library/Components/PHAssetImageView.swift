import SwiftUI

struct PHAssetImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageLoader = PHAssetImageLoader.shared

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

  var body: some View {
    let imageStatus = imageLoader.imageStatus(for: assetImage, targetSize: targetSize)
    ZStack {
      switch imageStatus {
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
    .onAppear {
      imageLoader.loadImage(for: assetImage, targetSize: targetSize)
    }
    .onDisappear {
      imageLoader.cancelLoading(for: assetImage, targetSize: targetSize)
    }
  }
}
