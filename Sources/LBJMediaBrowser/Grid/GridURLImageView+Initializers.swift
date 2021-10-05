import SwiftUI

extension GridURLImageView where
Placeholder == GridMediaPlaceholderView,
Progress == LoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaResultView {

  init(urlImage: MediaURLImage) {
    self.init(
      urlImage: urlImage,
      placeholder: { GridMediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}
