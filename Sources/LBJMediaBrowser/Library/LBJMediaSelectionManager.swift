import Foundation

public final class LBJMediaSelectionManager<SectionType: LBJMediaSectionType>: ObservableObject {

  /// 每个 section 中选中的媒体。The selected medias in sections.
  @Published
  public private(set) var selectedSectionMedias: [SectionType: [MediaType]] = [:]

  /// 媒体浏览器的选择模式。The selection mode for the media browser.
  public let selectionMode: SelectionMode

  /// 创建 `LBJMediaSelectionManager` 对象。Create `LBJMediaSelectionManager` object.
  ///   - selectionMode: 选择模式，默认禁用选择模式。The selection mode for the media browser, `.disabled` by default.
  public init(selectionMode: SelectionMode = .disabled) {
    self.selectionMode = selectionMode
  }
}

// MARK: - Handle Selection
extension LBJMediaSelectionManager {
  /// 选中给定 `section` 中的给定 `media`。
  /// Select the given media in the given section.
  public func select(_ media: MediaType, in section: SectionType) {
    guard
      mediaIsSelectable(media),
      isMediaSelected(media, in: section) == false
    else {
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
}

// MARK: - Getters
extension LBJMediaSelectionManager {
  /// 浏览器中的所有选中的媒体。All the selected medias in browser.
  public var allSelectedMedias: [MediaType] {
    selectedSectionMedias.reduce([]) { $0 + $1.value }
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

  /// 给定 section 中的所有选中的媒体。All the selected medias in the given section.
  public func selectedMedias(in section: SectionType) -> [MediaType] {
    selectedSectionMedias[section] ?? []
  }

  /// 给定 `section` 中的给定 `media` 的选中状态。The selection status of the given media in the given section.
  public func selectionStatus(for media: MediaType, in section: SectionType) -> SelectionStatus {
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

    return status
  }

  func mediaIsSelectable(_ media: MediaType) -> Bool {
    let lessMaxAllowed = allSelectedMedias.count < selectionMode.numberOfSelection
    switch selectionMode {
    case .disabled:
      return false
    case .image:
      return (media is MediaImageType) && lessMaxAllowed
    case .video:
      return (media is MediaVideoType) && lessMaxAllowed
    case .any:
      return lessMaxAllowed
    }
  }
}
