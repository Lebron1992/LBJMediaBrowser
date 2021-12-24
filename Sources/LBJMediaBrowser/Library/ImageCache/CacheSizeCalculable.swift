import UIKit

protocol CacheSizeCalculable {
  var cacheSize: UInt { get }
}

extension UIImage: CacheSizeCalculable {
  var cacheSize: UInt {
    let size = CGSize(width: size.width * scale, height: size.height * scale)

    let bytesPerPixel: CGFloat = 4.0
    let bytesPerRow = size.width * bytesPerPixel
    let totalBytes = UInt(bytesPerRow) * UInt(size.height)

    return totalBytes
  }
}
