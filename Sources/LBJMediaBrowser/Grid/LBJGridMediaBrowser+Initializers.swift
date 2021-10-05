import SwiftUI

extension LBJGridMediaBrowser where Placeholder == GridMediaPlaceholderView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: content
    )
  }
}

extension LBJGridMediaBrowser where Progress == LoadingProgressView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: content
    )
  }
}

extension LBJGridMediaBrowser where Failure == GridMediaErrorView {
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
      failure: { _ in GridMediaErrorView() },
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
Placeholder == GridMediaPlaceholderView,
Progress == LoadingProgressView {
  public init(
    medias: [MediaType],
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholderView,
Failure == GridMediaErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: progress,
      failure: { _ in GridMediaErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholderView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Progress == LoadingProgressView,
Failure == GridMediaErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Progress == LoadingProgressView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Failure == GridMediaErrorView,
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
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholderView,
Progress == LoadingProgressView,
Failure == GridMediaErrorView {
  public init(
    medias: [MediaType],
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: content
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholderView,
Progress == LoadingProgressView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholderView,
Failure == GridMediaErrorView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: progress,
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Progress == LoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaResultView {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == GridMediaPlaceholderView,
Progress == LoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaResultView {
  public init(medias: [MediaType]) {
    self.init(
      medias: medias,
      placeholder: { GridMediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaResultView(result: $0) }
    )
  }
}
