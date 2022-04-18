import Foundation

/// 媒体浏览器的 section 类型。The section type in grid browser.
public typealias LBJMediaSectionType = MediaSection & Equatable & Hashable & Identifiable

/// 代表媒体浏览器中的 section 类型。
/// A type that represents a section in the media browser.
public protocol MediaSection {
  /// section 中的媒体。The medias in the section.
  var medias: [MediaType] { get set }

  /// 当前 section 是否包含给定的 `media`。
  /// Whether the section contains the given `media`.
  func contains(_ media: MediaType) -> Bool
}

extension MediaSection {
  public func contains(_ media: MediaType) -> Bool {
    medias.contains { $0.equalsTo(media) }
  }
}

// MARK: - SingleMediaSection

/// 如果使用媒体数组初始化 `LBJGridMediaBrowserDataSource` 或者 `LBJPagingMediaBrowserDataSource` 对象，那么数据源中就只有一个默认的 `SingleMediaSection`。
/// The ONLY default section in `LBJGridMediaBrowserDataSource` or `LBJPagingMediaBrowserDataSource` if you initialize the data souce with a medias array.
public struct SingleMediaSection: MediaSection, Identifiable {

  public let id = UUID().uuidString
  public var medias: [MediaType]

  mutating func append(_ newMedias: [MediaType]) {
    medias.append(contentsOf: newMedias)
  }

  mutating func insert(_ media: MediaType, at index: Int) {
    medias.insert(media, at: index)
  }
}

extension SingleMediaSection: Equatable {
  public static func == (lhs: SingleMediaSection, rhs: SingleMediaSection) -> Bool {
    lhs.id == rhs.id
  }
}

extension SingleMediaSection: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - TitledMediaSection

/// 有标题的 section。A type of `GridSection` with a title.
public struct TitledMediaSection: MediaSection {

  /// section 的标题。The section title.
  public let title: String
  public var medias: [MediaType]

  /// 创建 `TitledMediaSection` 对象。Creates a `TitledMediaSection` object.
  /// - Parameters:
  ///   - title: section 的标题。The section title.
  ///   - medias: section 中的媒体。The medias in the section.
  public init(title: String, medias: [MediaType]) {
    self.title = title
    self.medias = medias
  }
}

extension TitledMediaSection: Identifiable {
  public var id: String {
    title
  }
}

extension TitledMediaSection: Equatable {
  public static func == (lhs: TitledMediaSection, rhs: TitledMediaSection) -> Bool {
    lhs.title == rhs.title
  }
}

extension TitledMediaSection: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(title)
  }
}

extension TitledMediaSection {
  static let uiImageTemplate = TitledMediaSection(title: "UIImages", medias: MediaUIImage.templates)
  static let urlImageTemplate = TitledMediaSection(title: "URLImages", medias: MediaURLImage.templates)
  static let urlVideoTemplate = TitledMediaSection(title: "URLVideos", medias: MediaURLVideo.templates)
  static let templates = [uiImageTemplate, urlImageTemplate, urlVideoTemplate]
}
