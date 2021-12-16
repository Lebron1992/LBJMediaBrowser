import SwiftUI

struct URLImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  private let imageLoader = URLImageLoader()

  private let urlImage: MediaURLImage
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    urlImage: MediaURLImage,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.urlImage = urlImage
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
    .onDisappear {
      updateStatus(.idle)
      imageLoader.cancelLoading(for: urlImage)
    }
    .task(loadImage)
  }

  @Sendable
  func loadImage() {
    imageLoader.setUp()
    
    Task {
      await imageLoader.loadImage(for: urlImage)
    }

    Task {
      guard let status = imageLoader.status else {
        return
      }
      for await s in status {
        await updateStatus(s)
      }
    }
  }
}
