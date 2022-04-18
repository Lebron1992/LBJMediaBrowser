import Combine
import SwiftUI

/// 一个管理分页模式浏览的对象。
/// An object that manages the medias in paging browser.
public final class LBJPagingBrowser<SectionType: LBJMediaSectionType>: ObservableObject {

  /// 是否自动播放视频，默认是 `false`。
  /// Weather auto play a video, `false` by default.
  public var autoPlayVideo = false

  /// 当前页所在的索引。
  /// The index of the current page.
  @Published
  public private(set) var currentPage: Int = 0

  /// 分页浏览器的数据源。The data source of `LBJPagingMediaBrowser`.
  @Published
  public private(set) var dataSource: LBJPagingMediaBrowserDataSource<SectionType>

  /// 管理选择的对象。The object to manage selection.
  @Published
  public private(set) var selectionManager: LBJMediaSelectionManager<SectionType>

  private var observaleSubscriptions: AnyCancellable?

  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - dataSource: 分页浏览器的数据源。The data source of `LBJPagingMediaBrowser`.
  ///   - selectionManager: 管理选择的对象。The object to manage selection.
  ///   - currentPage: 当前页面的索引，默认是 `0`。The index of the current page, `0` by default.
  public init(
    dataSource: LBJPagingMediaBrowserDataSource<SectionType>,
    selectionManager: LBJMediaSelectionManager<SectionType> = .init(),
    currentPage: Int = 0
  ) {
    self.dataSource = dataSource
    self.selectionManager = selectionManager
    self.currentPage = validatedPage(currentPage)

    observaleSubscriptions = Publishers.Merge(dataSource.objectWillChange, selectionManager.objectWillChange)
      .sink { [weak self] in
      self?.objectWillChange.send()
    }
  }

  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  ///
  /// 此初始化函数在创建 `LBJGridMediaBrowserDataSource` 对象自定义 `pagingMediaBrowserProvider` 时使用。
  /// The initializer is specially used in `pagingMediaBrowserProvider` when creating `LBJGridMediaBrowserDataSource` object.
  ///
  /// - Parameters:
  ///   - gridBrowser: `LBJGridBrowser` 对象。The `LBJGridBrowser` object.
  ///   - currentPage: 当前页面的索引，默认是 `0`。The index of the current page, `0` by default.
  public convenience init(
    gridBrowser: LBJGridBrowser<SectionType>,
    currentPage: Int = 0
  ) {
    self.init(
      dataSource: .init(sections: gridBrowser.dataSource.sections),
      selectionManager: gridBrowser.selectionManager,
      currentPage: currentPage
    )
  }

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

  func validatedPage(_ page: Int) -> Int {
    min(dataSource.allMedias.count - 1, max(0, page))
  }
}

extension LBJPagingBrowser where SectionType == SingleMediaSection {
  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - selectionManager: 管理选择的对象。The object to manage selection.
  ///   - currentPage: 当前页面的索引，默认是 `0`。The index of the current page, `0` by default.
  public convenience init(
    medias: [MediaType],
    selectionManager: LBJMediaSelectionManager<SectionType> = .init(),
    currentPage: Int = 0
  ) {
    self.init(
      dataSource: .init(medias: medias),
      selectionManager: selectionManager,
      currentPage: currentPage
    )
  }
}
