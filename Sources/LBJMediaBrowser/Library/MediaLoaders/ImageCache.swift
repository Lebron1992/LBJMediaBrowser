import Photos
import UIKit
import AlamofireImage

extension AutoPurgingImageCache {
  static let shared = AutoPurgingImageCache(memoryCapacity: 200_000_000, preferredMemoryUsageAfterPurge: 180_000_000)
}
