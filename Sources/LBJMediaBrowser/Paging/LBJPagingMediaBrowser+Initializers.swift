import SwiftUI

extension LBJPagingMediaBrowser where Placeholder == MediaPlaceholderView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where Progress == PagingLoadingProgressView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
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
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
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

extension LBJPagingMediaBrowser where Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: progress,
      failure: failure,
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Failure == PagingMediaErrorView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
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
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Failure == PagingMediaErrorView,
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: content
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: failure,
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Failure == PagingMediaErrorView,
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder progress: @escaping (Float) -> Progress
  ) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView,
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder
  ) {
    self.init(
      browser: browser,
      placeholder: placeholder,
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}

extension LBJPagingMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == PagingLoadingProgressView,
Failure == PagingMediaErrorView,
Content == PagingMediaLoadedResultView {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that  manages the media paging browser.
  public init(browser: LBJPagingBrowser) {
    self.init(
      browser: browser,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { PagingLoadingProgressView(progress: $0) },
      failure: { PagingMediaErrorView(error: $0) },
      content: { PagingMediaLoadedResultView(result: $0) }
    )
  }
}
