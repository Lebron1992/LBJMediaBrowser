import Combine
import SwiftUI

/// 一个管理网格模式浏览的对象。
/// An object that manages the medias in grid browser.
public final class LBJGridBrowser<SectionType: LBJMediaSectionType>: ObservableObject {

  /// 网格浏览器的数据源。The data source of `LBJGridMediaBrowser`.
  @Published
  public private(set) var dataSource: LBJGridMediaBrowserDataSource<SectionType>

  /// 管理选择的对象。The object to manage selection.
  @Published
  public private(set) var selectionManager: LBJMediaSelectionManager<SectionType>

  private var observaleSubscriptions: AnyCancellable?

  /// 创建 `LBJGridBrowser` 对象。Creates a `LBJGridBrowser` object.
  /// - Parameters:
  ///   - dataSource: 网格浏览器的数据源。The data source of `LBJGridMediaBrowser`.
  ///   - selectionManager: 管理选择的对象。The object to manage selection.
  public init(
    dataSource: LBJGridMediaBrowserDataSource<SectionType>,
    selectionManager: LBJMediaSelectionManager<SectionType> = .init()
  ) {
    self.dataSource = dataSource
    self.selectionManager = selectionManager

    observaleSubscriptions = Publishers.Merge(dataSource.objectWillChange, selectionManager.objectWillChange)
      .sink { [weak self] in
      self?.objectWillChange.send()
    }
  }

  deinit {
    observaleSubscriptions?.cancel()
  }
}

extension LBJGridBrowser where SectionType == SingleMediaSection {
  /// 创建 `LBJGridBrowser` 对象。Creates a `LBJGridBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - selectionManager: 管理选择的对象。The object to manage selection.
  public convenience init(
    medias: [MediaType],
    selectionManager: LBJMediaSelectionManager<SectionType> = .init()
  ) {
    self.init(dataSource: .init(medias: medias), selectionManager: selectionManager)
  }
}
