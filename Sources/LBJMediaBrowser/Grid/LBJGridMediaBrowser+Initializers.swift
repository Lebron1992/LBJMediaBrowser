import SwiftUI

extension LBJGridMediaBrowser where Placeholder == MediaPlaceholderView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - progress: 用于自定义媒体处于加载中的视图的代码块。A block to custom the view when the media in progress.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where Progress == LoadingProgressView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where Failure == GridMediaErrorView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: progress,
      failure: { _ in GridMediaErrorView() },
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: progress,
      failure: failure,
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == LoadingProgressView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Failure == GridMediaErrorView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - progress: 用于自定义媒体处于加载中的视图的代码块。A block to custom the view when the media in progress.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: { _ in GridMediaErrorView() },
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - progress: 用于自定义媒体处于加载中的视图的代码块。A block to custom the view when the media in progress.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: failure,
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Progress == LoadingProgressView,
Failure == GridMediaErrorView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Progress == LoadingProgressView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Failure == GridMediaErrorView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - progress: 用于自定义媒体处于加载中的视图的代码块。A block to custom the view when the media in progress.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: progress,
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == LoadingProgressView,
Failure == GridMediaErrorView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - content: 用于自定义媒体处于加载完成时的视图的代码块。A block to custom the view when the media in loaded.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: content,
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == LoadingProgressView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - failure: 用于自定义媒体处于加载失败时的视图的代码块。A block to custom the view when the media in failure.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder failure: @escaping (Error) -> Failure,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: failure,
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Failure == GridMediaErrorView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - progress: 用于自定义媒体处于加载中的视图的代码块。A block to custom the view when the media in progress.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder progress: @escaping (Float) -> Progress,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: progress,
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Progress == LoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于自定义媒体处于未处理状态时的视图的代码块。A block to custom the view when the media in idle.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: placeholder,
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}

extension LBJGridMediaBrowser where
Placeholder == MediaPlaceholderView,
Progress == LoadingProgressView,
Failure == GridMediaErrorView,
Content == GridMediaLoadedResultView {
  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - pagingMediaBrowser: 用于自定义点击跳转分页浏览的代码块。A block to custom the paging media browser on tap item.
  public init(
    medias: [Media],
    pagingMediaBrowser: ((Int) -> AnyView)? = nil
  ) {
    self.init(
      medias: medias,
      placeholder: { _ in MediaPlaceholderView() },
      progress: { LoadingProgressView(progress: $0, size: LBJGridMediaBrowserConstant.progressSize) },
      failure: { _ in GridMediaErrorView() },
      content: { GridMediaLoadedResultView(result: $0) },
      pagingMediaBrowser: pagingMediaBrowser
    )
  }
}
