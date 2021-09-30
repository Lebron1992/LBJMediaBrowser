import SwiftUI

extension GridMediaURLImageView where Progress == EmptyView, Failure == EmptyView {
  init(urlImage: MediaURLImage) {
    self.init(
      urlImage: urlImage,
      progress: { _ in EmptyView() },
      failure: { _ in EmptyView() }
    )
  }
}
