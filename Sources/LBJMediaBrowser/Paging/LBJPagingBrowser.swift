import Combine
import SwiftUI

/// 一个管理分页模式浏览的对象。
/// An object that manages the medias paging browser.
public final class LBJPagingBrowser: ObservableObject {

  /// 是否自动播放视频，默认是 `false`。
  /// Weather auto play a video, `false` by default.
  public var autoPlayVideo = false

  /// 当前页所在的索引。
  /// The index of the current page.
  @Published
  public private(set) var currentPage: Int = 0

  public let dataSource: LBJPagingMediaBrowserDataSource

  public init(dataSource: LBJPagingMediaBrowserDataSource, currentPage: Int = 0) {
    self.dataSource = dataSource
    self.currentPage = validatedPage(currentPage)
  }

  /// 创建 LBJPagingBrowser 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - currentPage: 当前页的索引。The index of the current page.
  public convenience init(medias: [Media], currentPage: Int = 0) {
    self.init(dataSource: .init(medias: medias), currentPage: currentPage)
  }
}

// MARK: - Public Methods
extension LBJPagingBrowser {

  /// 设置当前页。Set the current page.
  /// - Parameters:
  ///   - page: 当前页的索引。The index of the current page.
  ///   - animated: 是否需要动画，默认是 `true`。Weather animate the page changes, `true` by default.
  public func setCurrentPage(_ page: Int, animated: Bool = true) {
    guard currentPage != page else {
      return
    }

    if animated {
      withAnimation {
        currentPage = validatedPage(page)
      }
    } else {
      currentPage = validatedPage(page)
    }
  }
}

// MARK: - Helper Methods
extension LBJPagingBrowser {
  func validatedPage(_ page: Int) -> Int {
    min(dataSource.medias.count - 1, max(0, page))
  }
}
