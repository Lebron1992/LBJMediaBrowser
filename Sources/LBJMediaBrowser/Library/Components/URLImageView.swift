import SwiftUI

struct URLImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @EnvironmentObject
  private var imageLoader: URLImageLoader

  private let urlImage: MediaURLImage
  private let targetSize: ImageTargetSize
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (_ error: Error, _ retry: @escaping () -> Void) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    urlImage: MediaURLImage,
    targetSize: ImageTargetSize,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (_ error: Error, _ retry: @escaping () -> Void) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.urlImage = urlImage
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
        placeholder(urlImage)

      case .loading(let progress):
        if progress > 0 && progress < 1 {
          self.progress(progress)
        } else {
          placeholder(urlImage)
        }

      case .loaded(let uiImage):
        content(.image(image: urlImage, uiImage: uiImage))

      case .failed(let error):
        failure(error, loadImage)
      }
    }
    .onAppear(perform: loadImage)
    .onDisappear(perform: cancelLoading)
  }

  private var imageStatus: MediaImageStatus {
    imageLoader.imageStatus(for: urlImage, targetSize: targetSize)
  }

  private func loadImage() {
    if imageStatus.isLoadingOrLoaded {
      return
    }
    imageLoader.loadImage(for: urlImage, targetSize: targetSize)
  }

  private func cancelLoading() {
    imageLoader.cancelLoading(for: urlImage, targetSize: targetSize)
  }
}
