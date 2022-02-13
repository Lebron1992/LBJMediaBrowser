import Foundation

/// 代表在 `LBJGridMediaBrowser` 中的 section 类型。
/// A type that represents a section in `LBJGridMediaBrowser`.
public protocol GridSection {
  /// section 中的媒体。The medias in the section.
  var medias: [Media] { get set }
}

// MARK: - SingleGridSection

/// 如果使用媒体数组初始化 `LBJGridMediaBrowserDataSource` 对象，那么数据源中就只有一个默认的 `SingleGridSection`。
/// The ONLY default section in `LBJGridMediaBrowserDataSource` if you initialize the data souce with a medias array.
public struct SingleGridSection: GridSection, Identifiable {

  public let id = UUID().uuidString
  public var medias: [Media]

  mutating func append(_ newMedias: [Media]) {
    medias.append(contentsOf: newMedias)
  }

  mutating func insert(_ media: Media, at index: Int) {
    medias.insert(media, at: index)
  }
}

extension SingleGridSection: Equatable {
  public static func == (lhs: SingleGridSection, rhs: SingleGridSection) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - TitledGridSection
/// 有标题的 section。A type of `GridSection` with a title.
public struct TitledGridSection: GridSection {

  /// section 的标题。The section title.
  public let title: String
  public var medias: [Media]

  /// 创建 `TitledGridSection` 对象。Creates a `TitledGridSection` object.
  /// - Parameters:
  ///   - title: section 的标题。The section title.
  ///   - medias: section 中的媒体。The medias in the section.
  public init(title: String, medias: [Media]) {
    self.title = title
    self.medias = medias
  }
}

extension TitledGridSection: Identifiable {
  public var id: String {
    title
  }
}

extension TitledGridSection: Equatable {
  public static func == (lhs: TitledGridSection, rhs: TitledGridSection) -> Bool {
    lhs.title == rhs.title
  }
}

extension TitledGridSection {
  static let uiImageTemplate = TitledGridSection(title: "UIImages", medias: MediaUIImage.templates)
  static let urlImageTemplate = TitledGridSection(title: "URLImages", medias: MediaURLImage.templates)
  static let urlVideoTemplate = TitledGridSection(title: "URLVideos", medias: MediaURLVideo.templates)
  static let templates = [uiImageTemplate, urlImageTemplate, urlVideoTemplate]
}
