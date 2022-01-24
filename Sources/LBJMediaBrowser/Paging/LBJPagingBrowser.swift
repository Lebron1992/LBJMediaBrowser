import Combine
import SwiftUI

/// 一个管理分页模式浏览的对象。
/// An object that manages the medias paging browser.
public final class LBJPagingBrowser: ObservableObject {

  /// 是否自动播放视频，默认是 `true`。
  /// Weather auto play a video, `true` by default.
  public var autoPlayVideo = false

  /// 当前页所在的索引。
  /// The index of the current page.
  @Published
  public private(set) var currentPage: Int = 0

  /// 浏览器中所有的媒体。
  /// The medias in the browser.
  public private(set) var medias: [Media]

  /// 创建 LBJPagingBrowser 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - currentPage: 当前页的索引。The index of the current page.
  public init(medias: [Media], currentPage: Int = 0) {
    self.medias = medias
    self.currentPage = validatedPage(currentPage)
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

  /// 获取给定索引对应的媒体。Get the media for the given page.
  public func media(at page: Int) -> Media? {
    guard page >= 0 && page < medias.count else {
      return nil
    }
    return medias[page]
  }
}

// MARK: - Helper Methods
extension LBJPagingBrowser {
  func validatedPage(_ page: Int) -> Int {
    min(medias.count - 1, max(0, page))
  }
}
