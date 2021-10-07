import SwiftUI

extension LBJPagingMediaBrowser where Placeholder == MediaPlaceholderView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where Progress == PagingLoadingProgressView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where Failure == PagingMediaErrorView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: progress,
      failure: failure,
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Failure == PagingMediaErrorView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Progress == PagingLoadingProgressView,
Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Failure == PagingMediaErrorView,
Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Failure == PagingMediaErrorView,
Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView,
Content == PagingMediaResultView {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView,
Content == PagingMediaResultView {
  public init(browser: LBJPagingBrowser) {
    self.init(
      browser: browser,
      placeholder: { MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaResultView(result: $0) }
    )
  }
}
