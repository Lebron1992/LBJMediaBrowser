import SwiftUI

struct PHAssetImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @EnvironmentObject
  private var imageLoader: PHAssetImageLoader

  private let assetImage: MediaPHAssetImage
  private let targetSize: ImageTargetSize
  private let placeholder: (MediaType) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (_ error: Error, _ retry: @escaping () -> Void) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize,
    @ViewBuilder placeholder: @escaping (MediaType) -> Placeholder,
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

      case .loaded(let result):
        switch result {
        case .still(let uIImage):
          content(.stillImage(image: assetImage, uiImage: uIImage))
        case .gif(let data):
          content(.gifImage(image: assetImage, data: data))
        }

      case .failed(let error):
        failure(error, loadImage)
      }
    }
    .onAppear(perform: loadImage)
    .onDisappear(perform: cancelLoading)
  }

  private var imageStatus: MediaImageStatus {
    switch targetSize {
    case .thumbnail:
      return imageLoader.imageStatus(for: assetImage, targetSize: .thumbnail) ?? .idle
    case .larger:
      let largerStatus = imageLoader.imageStatus(for: assetImage, targetSize: .larger)
      let thumbStatus = imageLoader.imageStatus(for: assetImage, targetSize: .thumbnail)

      if let largerResult = largerStatus?.loadedResult {
        return .loaded(largerResult)
      }

      if let thumbResult = thumbStatus?.loadedResult {
        return .loaded(thumbResult)
      }

      return largerStatus ?? .idle
    }
  }

  private func loadImage() {
    let status = imageLoader.imageStatus(for: assetImage, targetSize: targetSize) ?? .idle
    if status.isLoadingOrLoaded == false {
      imageLoader.loadImage(for: assetImage, targetSize: targetSize)
    }
  }

  private func cancelLoading() {
    imageLoader.cancelLoading(for: assetImage, targetSize: targetSize)
  }
}
