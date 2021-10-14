import UIKit

/// 代表图片格式是 `UIImage` 的图片类型。
/// A type that represents an image with a `UIImage` object .
public protocol MediaUIImageType: MediaImageType {

  /// `UIImage` 对象。
  /// an `UIImage` object.
  var uiImage: UIImage { get }
}
