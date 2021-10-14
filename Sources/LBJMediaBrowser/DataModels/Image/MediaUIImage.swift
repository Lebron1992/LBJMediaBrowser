import UIKit

/// 图片格式是 `UIImage` 的图片类型。
/// An image type with a `UIImage` object.
open class MediaUIImage: MediaImageType {

  public let id = UUID().uuidString

  /// `UIImage` 对象。
  /// an `UIImage` object.
  public let uiImage: UIImage

  /// 创建 `MediaUIImage` 对象。Creates a `MediaUIImage` object.
  /// - Parameter uiImage: `UIImage` 对象。an `UIImage` object.
  public init(uiImage: UIImage) {
    self.uiImage = uiImage
  }
}

// MARK: - Equatable
extension MediaUIImage: Equatable {
  public static func == (lhs: MediaUIImage, rhs: MediaUIImage) -> Bool {
    lhs.id == rhs.id &&
    lhs.uiImage == rhs.uiImage
  }
}

// MARK: - Templates
extension MediaUIImage {
  static let templates = (1...3)
    .compactMap { UIImage(named: "IMG_000\($0)", in: .module, compatibleWith: nil) }
    .map { MediaUIImage(uiImage: $0) }
}
