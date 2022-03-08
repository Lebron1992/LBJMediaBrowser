import UIKit
import LBJImagePreviewer

/// 图片格式是 gif 的图片类型。
/// An image type that represents a gif image.
open class MediaGifImage: MediaImageType {

  /// gif 图片的来源。The gif image source.
  public let source: Source

  /// 创建 `MediaGifImage` 对象。Creates a `MediaGifImage` object.
  /// - Parameter source: gif 图片的来源。The gif image source.
  public init(source: Source) {
    self.source = source
  }

  var stillImage: UIImage? {
    if let data = gifData {
      return UIImage(data: data)
    }
    return nil
  }

  var gifData: Data? {
    switch source {
    case .bundle(let name, let bundle):
      if let url = bundle.url(forResource: name, withExtension: "gif") {
        return try? Data(contentsOf: url)
      }
      return nil
    case .data(let data):
      return data
    }
  }

  public func equalsTo(_ media: MediaType) -> Bool {
    guard let other = media as? MediaGifImage else {
      return false
    }
    return source == other.source
  }
}

extension MediaGifImage {
  /// 标识 gif 图片来源的常量。Constants identifying the source of a gif image.
  public enum Source: Equatable {

    /// gif 图片来源是 `Bundle`。The source of a gif image is a `Bundle` object.
    /// - name: gif 图片名字。The name of a gif image.
    /// - bundle: gif 图片所在的 `Bundle`。The `Bundle` where a gif image in.
    case bundle(name: String, bundle: Bundle)

    /// gif 图片来源是 `Data`。The source of a gif image is a `Data` object.
    /// - Data: 动态图片的数据。The data of a gif image.
    case data(Data)
  }
}
