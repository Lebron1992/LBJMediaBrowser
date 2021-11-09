import SwiftUI

struct GridURLImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageDownloader = URLImageDownloader()

  private let urlImage: MediaURLImage
  private let placeholder: (MediaType) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    urlImage: MediaURLImage,
    @ViewBuilder placeholder: @escaping (MediaType) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.urlImage = urlImage
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content

    let url = urlImage.thumbnailUrl ?? urlImage.imageUrl
    imageDownloader.setImageUrl(url)
  }

  var body: some View {
    ZStack {
      switch imageDownloader.imageStatus {
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
        failure(error)
      }
    }
    .onAppear {
        imageDownloader.startDownload()
    }
    .onDisappear {
      imageDownloader.cancelDownload()
    }
  }
}

extension GridURLImageView where
Placeholder == MediaPlaceholderView,
Progress == LoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaLoadedResultView {

  init(urlImage: MediaURLImage) {
    self.init(
      urlImage: urlImage,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaLoadedResultView(result: $0) }
    )
  }
}

struct GridMediaURLImageView_Previews: PreviewProvider {
  static var previews: some View {
    GridURLImageView(urlImage: MediaURLImage.templates[0])
  }
}
