import SwiftUI

extension LBJGridMediaBrowser where Progress == MediaLoadingProgressView {
  public init(
    medias: [MediaType],
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      progress: { MediaLoadingProgressView(progress: $0) },
      failure: failure
    )
  }
}

extension LBJGridMediaBrowser where Failure == GridErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      medias: medias,
      progress: progress,
      failure: { _ in GridErrorView() }
    )
  }
}

extension LBJGridMediaBrowser where Progress == MediaLoadingProgressView, Failure == GridErrorView {
  public init(medias: [MediaType]) {
    self.init(
      medias: medias,
      progress: { MediaLoadingProgressView(progress: $0) },
      failure: { _ in GridErrorView() }
    )
  }
}
