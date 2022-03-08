import Combine
import SwiftUI

/// 一个为 `LBJPagingMediaBrowser` 提供数据源的类型。A type that provide data source to `LBJPagingMediaBrowser`.
public class LBJPagingMediaBrowserDataSource: ObservableObject {

  /// 浏览器中所有的媒体。All the medias in the browser.
  @Published
  public private(set) var medias: [MediaType]

  let placeholderProvider: (MediaType) -> AnyView
  let progressProvider: (Float) -> AnyView
  let failureProvider: (_ error: Error, _ retry: @escaping () -> Void) -> AnyView
  let contentProvider: (MediaLoadedResult) -> AnyView

  /// 创建 `LBJPagingMediaBrowserDataSource` 对象。Create `LBJPagingMediaBrowserDataSource` object.
  /// - Parameters:
  ///   - medias: 浏览器中所有的媒体。All the medias in the browser.
  ///   - placeholderProvider: 自定义媒体处于未处理状态时的视图的闭包。A closure to custom the view when the media is in idle.
  ///   - progressProvider: 自定义媒体处于加载中的视图的闭包。A closure to custom the view when the media is in progress.
  ///   - failureProvider: 自定义媒体处于加载失败时的视图的闭包。A closure to custom the view when the media is in failure.
  ///   - contentProvider: 自定义媒体处于加载完成时的视图的闭包。A closure to custom the view when the media is in loaded.
  public init(
    medias: [MediaType],
    placeholderProvider: ((MediaType) -> AnyView)? = nil,
    progressProvider: ((Float) -> AnyView)? = nil,
    failureProvider: ((_ error: Error, _ retry: @escaping () -> Void) -> AnyView)? = nil,
    contentProvider: ((MediaLoadedResult) -> AnyView)? = nil
  ) {
    self.medias = medias

    self.placeholderProvider = placeholderProvider ?? { _ in
      MediaPlaceholderView()
        .asAnyView()
    }

    self.progressProvider = progressProvider ?? {
      PagingLoadingProgressView(progress: $0)
        .asAnyView()
    }

    self.failureProvider = failureProvider ?? {
      PagingMediaErrorView(error: $0, retry: $1)
        .asAnyView()
    }

    self.contentProvider = contentProvider ?? {
      PagingMediaLoadedResultView(result: $0)
        .background(Color.black)
        .asAnyView()
    }
  }
}

// MARK: - Manage Medias
extension LBJPagingMediaBrowserDataSource {
  /// 浏览器中的所有媒体的个数。The count of the medias in browser.
  public var numberOfMedias: Int {
    medias.count
  }

  /// 获取给定索引的媒体。The media in the given index.
  public func media(at index: Int) -> MediaType? {
    (0..<medias.count) ~= index ? medias[index] : nil
  }

  /// 添加给定的媒体。Append the given media.
  public func append(_ media: MediaType) {
    guard medias.contains(where: { $0.equalsTo(media) }) == false else { return }
    medias.append(media)
  }

  /// 在指定的媒体前面插入新的媒体。Insert the new media before the specified media.
  /// - Parameters:
  ///   - media: 要插入的媒体。The new media to be inserted.
  ///   - before: 在此媒体前插入。The new media is inserted before this media.
  public func insert(_ media: MediaType, before: MediaType) {
    guard
      medias.contains(where: { $0.equalsTo(media) }) == false,
      let beforeIndex = medias.firstIndex(where: { $0.equalsTo(before) })
    else {
      return
    }
    medias.insert(media, at: beforeIndex)
  }

  /// 在指定的媒体后面插入新的媒体。Insert the new media after the specified media.
  /// - Parameters:
  ///   - media: 要插入的媒体。The new media to be inserted.
  ///   - before: 在此媒体后插入。The new media is inserted after this media.
  public func insert(_ media: MediaType, after: MediaType) {
    guard
      medias.contains(where: { $0.equalsTo(media) }) == false,
      let afterIndex = medias.firstIndex(where: { $0.equalsTo(after) })
    else {
      return
    }
    medias.insert(media, at: afterIndex + 1)
  }
}
