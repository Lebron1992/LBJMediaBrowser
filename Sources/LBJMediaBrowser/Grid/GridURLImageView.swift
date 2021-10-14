import SwiftUI

struct GridURLImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageDownloader: URLImageDownloader

  private let urlImage: MediaURLImage
  private let placeholder: () -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    urlImage: MediaURLImage,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    let url = urlImage.thumbnailUrl ?? urlImage.imageUrl
    self.imageDownloader = URLImageDownloader(imageUrl: url)
    self.urlImage = urlImage
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

  var body: some View {
    switch imageDownloader.imageStatus {
    case .idle:
      placeholder()
        .onAppear {
          imageDownloader.startDownload()
        }

    case .loading(let progress):
      if progress > 0 && progress < 1 {
        self.progress(progress)
          .onDisappear {
            imageDownloader.cancelDownload()
          }
      } else {
        Color.clear
      }

    case .loaded(let uiImage):
      content(.image(image: urlImage, uiImage: uiImage))
        .onDisappear {
          imageDownloader.reset()
        }

    case .failed(let error):
      failure(error)
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
      placeholder: { MediaPlaceholderView() },
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
