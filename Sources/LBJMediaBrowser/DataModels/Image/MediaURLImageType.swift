import Foundation

/// 代表图片格式是 `URL` 的图片类型。
/// A type that represents an image with a `URL` object .
public protocol MediaURLImageType: MediaImageType {

  /// 图片路径。
  /// The url of the image.
  var imageUrl: URL { get }

  /// 缩略图路径。
  /// The url of the thumbnail.
  var thumbnailUrl: URL? { get }
}
