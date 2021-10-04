import SwiftUI

extension GridMediaURLImageView where
Placeholder == GridMediaPlaceholder,
Progress == MediaLoadingProgressView,
Failure == GridErrorView,
Content == GridMediaResultView {

  init(urlImage: MediaURLImage) {
    self.init(
      urlImage: urlImage,
      placeholder: { GridMediaPlaceholder() },
      progress: { MediaLoadingProgressView(progress: $0) },
      failure: { _ in GridErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}
