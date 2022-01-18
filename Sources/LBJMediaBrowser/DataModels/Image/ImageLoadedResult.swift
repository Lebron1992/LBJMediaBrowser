import UIKit

/// 标识 `MediaImage` 成功加载完成的结果的常量。
/// Constants identifying the loaded result of the `MediaImage`.
public enum ImageLoadedResult {

  /// 静态图片。Still image.
  /// - UIImage: 静态图片的 `UIImage` 对象。The `UIImage` object of a still image.
  case still(UIImage)

  /// 动态图片。Gif image.
  /// - Data: 动态图片的数据。The data of a gif image.
  case gif(Data)

  /// 加载成功的 `MediaImage` 的静态形式图片。
  public var stillImage: UIImage? {
    switch self {
    case .still(let uiImage):
      return uiImage
    case .gif(let data):
      return UIImage(data: data)
    }
  }
}

extension ImageLoadedResult: Equatable {
  public static func == (lhs: ImageLoadedResult, rhs: ImageLoadedResult) -> Bool {
    switch (lhs, rhs) {
    case (.still(let li), .still(let ri)):
      return li.pngData() == ri.pngData()
    case (.gif(let ld), .gif(let rd)):
      return ld == rd
    default:
      return false
    }
  }
}

// MARK: - DataConvertible

extension ImageLoadedResult: DataConvertible {
  public func toData() throws -> Data {
    switch self {
    case .still(let uiImage):
      guard let data = uiImage.pngData() else {
        throw LBJMediaBrowserError.cacheError(reason: .cannotConvertUIImageToData(image: uiImage))
      }
      return data
    case .gif(let data):
      return data
    }
  }

  public static func fromData(_ data: Data) throws -> ImageLoadedResult {
    if UIImage.isAnimatedImage(for: data) {
      return .gif(data)
    } else if let image = UIImage(data: data) {
      return .still(image)
    } else {
      throw LBJMediaBrowserError.cacheError(reason: .cannotConvertDataToImage)
    }
  }
}

// MARK: - CacheSizeCalculable

extension ImageLoadedResult: CacheSizeCalculable {
  public var cacheSize: UInt {
    switch self {
    case .still(let uiImage):
      return uiImage.cacheSize
    case .gif(let data):
      return UInt(data.count)
    }
  }
}

extension UIImage: CacheSizeCalculable {
  public var cacheSize: UInt {
    let size = CGSize(width: size.width * scale, height: size.height * scale)

    let bytesPerPixel: CGFloat = 4.0
    let bytesPerRow = size.width * bytesPerPixel
    let totalBytes = UInt(bytesPerRow) * UInt(size.height)

    return totalBytes
  }
}
