import SwiftUI

struct PHAssetImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageLoader = PHAssetImageLoader.shared

  private let assetImage: MediaPHAssetImage
  private let targetSize: ImageTargetSize
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (_ error: Error, _ retry: @escaping () -> Void) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (_ error: Error, _ retry: @escaping () -> Void) -> Failure,
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
        failure(error, loadImage)
      }
    }
    .onAppear(perform: loadImage)
    .onDisappear(perform: cancelLoading)
  }

  private var imageStatus: MediaImageStatus {
    imageLoader.imageStatus(for: assetImage, targetSize: targetSize)
  }

  private func loadImage() {
    if imageStatus.isLoadingOrLoaded {
      return
    }
    imageLoader.loadImage(for: assetImage, targetSize: targetSize)
  }

  private func cancelLoading() {
    imageLoader.cancelLoading(for: assetImage, targetSize: targetSize)
  }
}
