import Foundation
import UIKit

enum LBJMediaBrowserError {
  case cacheError(reason: CacheErrorReason)
}

extension LBJMediaBrowserError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .cacheError(let reason):
      return reason.errorDescription
    }
  }
}

extension LBJMediaBrowserError {
  enum CacheErrorReason {
    case cannotConvertUIImageToData(image: UIImage)
    case cannotCreateUIImageFromData(data: Data)
    case cannotCreateCacheDirectory
  }
}

extension LBJMediaBrowserError.CacheErrorReason {
  var errorDescription: String? {
    switch self {
    case .cannotConvertUIImageToData(let image):
      return "Can't convert to data for the image: \(String(describing: image))"
    case .cannotCreateUIImageFromData(let data):
      return "Can't create UIImage with data: \(String(describing: data))"
    case .cannotCreateCacheDirectory:
      return "Can't create the caches directory"
    }
  }
}
