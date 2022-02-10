import Combine
import SwiftUI

public class LBJPagingMediaBrowserDataSource: ObservableObject {

  /// 浏览器中所有的媒体。
  /// All the medias in the browser.
  @Published
  public private(set) var medias: [Media]

  let placeholderProvider: (Media) -> AnyView
  let progressProvider: (Float) -> AnyView
  let failureProvider: (_ error: Error, _ retry: @escaping () -> Void) -> AnyView
  let contentProvider: (MediaLoadedResult) -> AnyView

  public init(
    medias: [Media],
    placeholderProvider: ((Media) -> AnyView)? = nil,
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
        .asAnyView()
    }
  }
}

// MARK: - Manage Medias
extension LBJPagingMediaBrowserDataSource {
  public var numberOfMedias: Int {
    medias.count
  }

  public func media(at index: Int) -> Media? {
    (0..<medias.count) ~= index ? medias[index] : nil
  }

  public func append(_ media: Media) {
    guard medias.contains(media) == false else { return }
    medias.append(media)
  }

  public func insert(_ media: Media, before: Media) {
    guard
      medias.contains(media) == false,
      let beforeIndex = medias.firstIndex(of: before)
    else {
      return
    }
    medias.insert(media, at: beforeIndex)
  }

  public func insert(_ media: Media, after: Media) {
    guard
      medias.contains(media) == false,
      let afterIndex = medias.firstIndex(of: after)
    else {
      return
    }
    medias.insert(media, at: afterIndex + 1)
  }
}
