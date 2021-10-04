import SwiftUI

extension LBJGridMediaBrowser where Placeholder == GridMediaPlaceholder {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: progress,
      failure: failure,
      content: content
    )
  }
}

extension LBJGridMediaBrowser where Progress == MediaLoadingProgressView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: content
    )
  }
}

extension LBJGridMediaBrowser where Failure == GridErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: progress,
      failure: { _ in GridErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: progress,
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Progress == MediaLoadingProgressView {
  public init(
    medias: [MediaType],
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Failure == GridErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: progress,
      failure: { _ in GridErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: progress,
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Progress == MediaLoadingProgressView,
Failure == GridErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Progress == MediaLoadingProgressView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Failure == GridErrorView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: progress,
      failure: { _ in GridErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Progress == MediaLoadingProgressView,
Failure == GridErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Progress == MediaLoadingProgressView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Failure == GridErrorView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: progress,
      failure: { _ in GridErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Progress == MediaLoadingProgressView,
Failure == GridErrorView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholder,
Progress == MediaLoadingProgressView,
Failure == GridErrorView,
Content == GridMediaResultView {
  public init(medias: [MediaType]) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholder() },
      progress: { MediaLoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}
