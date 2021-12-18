import SwiftUI

struct URLImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageLoader = URLImageLoader.shared

  private let urlImage: MediaURLImage
  private let targetSize: ImageTargetSize
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    urlImage: MediaURLImage,
    targetSize: ImageTargetSize,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
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
    let imageStatus = imageLoader.imageStatus(for: urlImage, targetSize: targetSize)
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
        // TODO: handle retry
        failure(error)
      }
    }
    .onAppear {
      imageLoader.loadImage(for: urlImage, targetSize: targetSize)
    }
    .onDisappear {
      imageLoader.cancelLoading(for: urlImage, targetSize: targetSize)
    }
  }
}
