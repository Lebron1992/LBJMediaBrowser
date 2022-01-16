import UIKit

extension UIImage {
  static func isAnimatedImage(for data: Data) -> Bool {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
      return false
    }
    return CGImageSourceGetCount(source) > 1
  }
}
