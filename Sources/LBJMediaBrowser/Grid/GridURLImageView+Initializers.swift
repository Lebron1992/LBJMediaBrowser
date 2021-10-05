import SwiftUI

extension GridURLImageView where
Placeholder == GridMediaPlaceholderView,
Progress == MediaLoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaResultView {

  init(urlImage: MediaURLImage) {
    self.init(
      urlImage: urlImage,
      placeholder: { GridMediaPlaceholderView() },
      progress: { MediaLoadingProgressView(progress: $0) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}
