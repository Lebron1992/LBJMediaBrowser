import UIKit

/// 表示可以计算其内存开销的类型。
/// Represents types whose size in memory can be calculated.
public protocol CacheSizeCalculable {
  var cacheSize: UInt { get }
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
