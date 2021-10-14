import SwiftUI
import LBJImagePreviewer

struct PagingImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @EnvironmentObject
  private var browser: LBJPagingBrowser

  let image: MediaImageType
  private let placeholder: () -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    image: MediaImageType,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.image = image
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

  var body: some View {
    if let status = browser.imageStatus(for: image) {
      switch status {
      case .idle:
        placeholder()
      case .loading(let progress):
        self.progress(progress)
      case .loaded(let uiImage):
        content(.image(image: image, uiImage: uiImage))
      case .failed(let error):
        failure(error)
      }
    } else {
      placeholder()
    }
  }
}

extension PagingImageView where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView,
Content == PagingMediaLoadedResultView {

  init(image: MediaImageType) {
    self.init(
      image: image,
      placeholder: { MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

#if DEBUG
struct PagingMediaView_Previews: PreviewProvider {
  static var previews: some View {
    PagingImageView(image: MediaUIImage.templates[0])
  }
}
#endif
