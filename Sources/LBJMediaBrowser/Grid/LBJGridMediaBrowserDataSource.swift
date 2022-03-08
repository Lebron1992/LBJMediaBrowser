import Combine
import SwiftUI

/// 一个为 `LBJGridMediaBrowser` 提供数据源的类型。A type that provide data source to `LBJGridMediaBrowser`.
public class LBJGridMediaBrowserDataSource<SectionType: LBJGridMediaBrowserSectionType>: ObservableObject {

  /// 所有网格浏览器的部分。 All the sections in grid browser.
  @Published
  public private(set) var sections: [SectionType]

  /// 每个 section 中选中的媒体。The selected medias in sections.
  @Published
  public private(set) var selectedSectionMedias: [SectionType: [MediaType]] = [:]

  let placeholderProvider: (MediaType) -> AnyView
  let progressProvider: (Float) -> AnyView
  let failureProvider: (Error) -> AnyView
  let contentProvider: (MediaLoadedResult) -> AnyView
  let sectionHeaderProvider: (SectionType) -> AnyView
  let selectionMode: SelectionMode
  let selectionOverlayProvider: (MediaType, SectionType, SelectionStatus) -> AnyView
  private(set) var pagingMediaBrowserProvider: ([MediaType], Int) -> AnyView

  /// 创建 `LBJGridMediaBrowserDataSource` 对象。Create `LBJGridMediaBrowserDataSource` object.
  /// - Parameters:
  ///   - sections: 所有网格浏览器的部分。 All the sections in grid browser.
  ///   - placeholderProvider: 自定义媒体处于未处理状态时的视图的闭包。A closure to custom the view when the media is in idle.
  ///   - progressProvider: 自定义媒体处于加载中的视图的闭包。A closure to custom the view when the media is in progress.
  ///   - failureProvider: 自定义媒体处于加载失败时的视图的闭包。A closure to custom the view when the media is in failure.
  ///   - contentProvider: 自定义媒体处于加载完成时的视图的闭包。A closure to custom the view when the media is in loaded.
  ///   - sectionHeaderProvider: 自定义 section header 的视图的闭包。A closure to custom the section header.
  ///   - selectionMode: 选择模式，默认禁用选择模式。The selection mode for the browser, `.disabled` by default.
  ///   - selectionOverlayProvider: 自定义媒体视图在不同选中状态下的覆盖层的闭包。A closure to custom the overlay for the media view in different status.
  ///   - pagingMediaBrowserProvider: 自定义点击跳转分页浏览的闭包。A closure to custom the paging media browser on tap item.
  public init(
    sections: [SectionType],
    placeholderProvider: ((MediaType) -> AnyView)? = nil,
    progressProvider: ((Float) -> AnyView)? = nil,
    failureProvider: ((Error) -> AnyView)? = nil,
    contentProvider: ((MediaLoadedResult) -> AnyView)? = nil,
    sectionHeaderProvider: ((SectionType) -> AnyView)? = nil,
    selectionMode: SelectionMode = .disabled,
    selectionOverlayProvider: ((MediaType, SectionType, SelectionStatus) -> AnyView)? = nil,
    pagingMediaBrowserProvider: (([MediaType], Int) -> AnyView)? = nil
  ) {
    self.sections = sections

    self.placeholderProvider = placeholderProvider ?? { _ in
      MediaPlaceholderView()
        .asAnyView()
    }

    self.progressProvider = progressProvider ?? {
      LoadingProgressView(
        progress: $0,
        size: LBJGridMediaBrowserConstant.progressSize
      )
        .asAnyView()
    }

    self.failureProvider = failureProvider ?? { _ in
      GridMediaErrorView()
        .asAnyView()
    }

    self.contentProvider = contentProvider ?? {
      GridMediaLoadedResultView(result: $0)
        .asAnyView()
    }

    self.sectionHeaderProvider = sectionHeaderProvider ?? { _ in
      EmptyView()
        .asAnyView()
    }

    self.selectionMode = selectionMode

    if selectionMode != .disabled {
      self.selectionOverlayProvider = selectionOverlayProvider ?? { media, section, status in
        GridSelectionOverlay(media: media, section: section, status: status)
          .foregroundColor(.blue)
          .asAnyView()
      }
    } else {
      self.selectionOverlayProvider = { _, _, _ in
        EmptyView().asAnyView()
      }
    }

    self.pagingMediaBrowserProvider = pagingMediaBrowserProvider ?? { medias, page in
      let browser = LBJPagingBrowser(medias: medias, currentPage: page)
      return LBJPagingMediaBrowser(browser: browser)
        .asAnyView()
    }
  }
}

extension LBJGridMediaBrowserDataSource where SectionType == SingleGridSection {

  /// 创建 `LBJGridMediaBrowserDataSource` 对象。Create `LBJGridMediaBrowserDataSource` object.
  /// - Parameters:
  ///   - medias: 所有网格浏览器的媒体。 All the  medias in grid browser.
  ///   - placeholderProvider: 自定义媒体处于未处理状态时的视图的闭包。A closure to custom the view when the media is in idle.
  ///   - progressProvider: 自定义媒体处于加载中的视图的闭包。A closure to custom the view when the media is in progress.
  ///   - failureProvider: 自定义媒体处于加载失败时的视图的闭包。A closure to custom the view when the media is in failure.
  ///   - contentProvider: 自定义媒体处于加载完成时的视图的闭包。A closure to custom the view when the media is in loaded.
  ///   - sectionHeaderProvider: 自定义 section header 的视图的闭包。A closure to custom the section header.
  ///   - selectionMode: 选择模式，默认禁用选择模式。The selection mode for the browser, `.disabled` by default.
  ///   - selectionOverlayProvider: 自定义媒体视图在不同选中状态下的覆盖层的闭包。A closure to custom the overlay for the media view in different status.
  ///   - pagingMediaBrowserProvider: 自定义点击跳转分页浏览的闭包。A closure to custom the paging media browser on tap item.
  public convenience init(
    medias: [MediaType],
    placeholderProvider: ((MediaType) -> AnyView)? = nil,
    progressProvider: ((Float) -> AnyView)? = nil,
    failureProvider: ((Error) -> AnyView)? = nil,
    contentProvider: ((MediaLoadedResult) -> AnyView)? = nil,
    sectionHeaderProvider: ((SectionType) -> AnyView)? = nil,
    selectionMode: SelectionMode = .disabled,
    selectionOverlayProvider: ((MediaType, SectionType, SelectionStatus) -> AnyView)? = nil,
    pagingMediaBrowserProvider: (([MediaType], Int) -> AnyView)? = nil
  ) {
    self.init(
      sections: [SingleGridSection(medias: medias)],
      placeholderProvider: placeholderProvider,
      progressProvider: progressProvider,
      failureProvider: failureProvider,
      contentProvider: contentProvider,
      sectionHeaderProvider: sectionHeaderProvider,
      selectionMode: selectionMode,
      selectionOverlayProvider: selectionOverlayProvider,
      pagingMediaBrowserProvider: pagingMediaBrowserProvider
    )
  }

  /// 添加媒体（只适用于只有一个 section）。
  /// Append medias (ONLY available when data source has one `SingleGridSection`).
  public func append(_ medias: [MediaType]) {
    guard sections.count == 1 else {
      fatalError("The dataSource should ONLY contains a section of `SingleGridSection`.")
    }
    sections[0].append(medias)
  }

  /// 插入媒体（只适用于只有一个 `SingleGridSection`）。
  /// Insert a media (ONLY available when data source has one `SingleGridSection`).
  public func insert(_ media: MediaType, at index: Int) {
    guard sections.count == 1 else {
      fatalError("The dataSource should ONLY contains a section of `SingleGridSection`.")
    }
    sections[0].insert(media, at: index)
  }
}

// MARK: - Handle Selection
extension LBJGridMediaBrowserDataSource {
  /// 选中给定 `section` 中的给定 `media`。
  /// Select the given media in the given section.
  public func select(_ media: MediaType, in section: SectionType) {
    guard isMediaSelected(media, in: section) == false else {
      return
    }
    var mediasInSection = selectedSectionMedias[section] ?? []
    mediasInSection.append(media)
    selectedSectionMedias[section] = mediasInSection
  }

  /// 取消选中给定 `section` 中的给定 `media`。
  /// Deselect the given media in the given section.
  public func deselect(_ media: MediaType, in section: SectionType) {
    var mediasInSection = selectedSectionMedias[section] ?? []
    mediasInSection.removeAll { $0.equalsTo(media) }
    selectedSectionMedias[section] = mediasInSection
  }

  /// 给定 `section` 中的给定 `media` 是否选中。
  /// Whether the given media is selected in the given section.
  public func isMediaSelected(_ media: MediaType, in section: SectionType) -> Bool {
    selectedSectionMedias[section]?.contains { $0.equalsTo(media) } ?? false
  }

  /// 给定的 `media` 是否选中。
  /// Whether the given media is selected.
  public func isMediaSelected(_ media: MediaType) -> Bool {
    allSelectedMedias.contains { $0.equalsTo(media) }
  }

  func selectionOverlay(for media: MediaType, in section: SectionType) -> AnyView {
    guard selectionMode.numberOfSelection > 0 else {
      return EmptyView().asAnyView()
    }

    let isSelected = isMediaSelected(media, in: section)

    let status: SelectionStatus
    if isSelected {
      status = .selected

    } else if allSelectedMedias.count >= selectionMode.numberOfSelection {
      status = .disabled

    } else {
      switch selectionMode {
      case .disabled:
        status = .disabled
      case .image:
        status = media is MediaImageType ? .unselected : .disabled
      case .video:
        status = media is MediaVideoType ? .unselected : .disabled
      case .any:
        status = .unselected
      }
    }

    return selectionOverlayProvider(media, section, status)
  }
}

// MARK: - Manage Sections
extension LBJGridMediaBrowserDataSource {

  /// 浏览器中的所有媒体。All the medias in browser.
  public var allMedias: [MediaType] {
    sections.reduce([]) { $0 + $1.medias }
  }

  /// 浏览器中的所有选中的媒体。All the selected medias in browser.
  public var allSelectedMedias: [MediaType] {
    sections
      .map { selectedMedias(in: $0) }
      .reduce([], +)
  }

  /// 浏览器中的所有媒体的个数。The count of the medias in browser.
  public var numberOfMedias: Int {
    sections.reduce(0) { $0 + $1.medias.count }
  }

  /// 浏览器中的 sections 的个数。The count of the sections in browser.
  public var numberOfSections: Int {
    sections.count
  }

  /// 获取给定 section 中的媒体数组。The medias in the given section.
  public func medias(in section: SectionType) -> [MediaType] {
    sections.first(where: { $0 == section })?.medias ?? []
  }

  /// 给定 section 中的所有选中的媒体。All the selected medias in the given section.
  public func selectedMedias(in section: SectionType) -> [MediaType] {
    selectedSectionMedias[section] ?? []
  }

  /// 获取给定 section 中的媒体的个数。The count of the medias in the given section.
  public func numberOfMedias(in section: SectionType) -> Int {
    medias(in: section).count
  }

  /// 获取给定 section 和索引的媒体。The media in the given section and index.
  public func media(at index: Int, in section: SectionType) -> MediaType? {
    let mediasInSection = medias(in: section)
    return (0..<mediasInSection.count) ~= index ? mediasInSection[index] : nil
  }

  /// 获取给定媒体在所有媒体中数组中的索引。The index of the given media in all medias.
  public func indexInAllMedias(for media: MediaType) -> Int? {
    allMedias.firstIndex { $0.equalsTo(media) }
  }

  /// 添加给定的 section。Append the given section.
  public func append(_ section: SectionType) {
    guard sections.contains(section) == false else { return }
    sections.append(section)
  }

  /// 在给定的索引插入新的 section。Insert the new section at the given index.
  public func insert(_ section: SectionType, at index: Int) {
    guard sections.contains(section) == false else {
      return
    }
    sections.insert(section, at: index)
  }

  /// 在给定的 section 和索引插入新的媒体。Insert the new media at the given section and index.
  public func insert(_ media: MediaType, at index: Int, in section: SectionType) {
    guard
      let sectionIndex = sections.firstIndex(of: section),
      sections[sectionIndex].medias.contains(where: { $0.equalsTo(media) })  == false
    else {
      return
    }
    var newSection = sections[sectionIndex]
    newSection.medias.insert(media, at: index)
    sections[sectionIndex] = newSection
  }
}
