import Foundation
import UIKit

enum LBJMediaBrowserError {
  case cacheError(reason: CacheErrorReason)
  case loadMediaError(reason: LoadMediaErrorReason)
}

extension LBJMediaBrowserError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .cacheError(let reason):
      return reason.errorDescription
    case .loadMediaError(let reason):
      return reason.errorDescription
    }
  }
}

extension LBJMediaBrowserError {
  enum CacheErrorReason {
    case cannotConvertUIImageToData(image: UIImage)
    case cannotCreateUIImageFromData(data: Data)
    case cannotConvertDataToImage
    case cannotStoreValue(value: DataConvertible, errorDescription: String)
    case cannotGetValueForKey(key: String, errorDescription: String)
    case cannotCreateCacheDirectory

    var errorDescription: String {
      switch self {
      case .cannotConvertUIImageToData(let image):
        return "Can't convert to data for the image: \(image)"
      case .cannotCreateUIImageFromData(let data):
        return "Can't create UIImage with data: \(data)"
      case .cannotConvertDataToImage:
        return "Can't convert data to image"
      case .cannotStoreValue(let value, let errorDescription):
        return "Can't store the value: \(value), \(errorDescription)"
      case .cannotGetValueForKey(let key, let errorDescription):
        return "Can't get value for key: \(key), \(errorDescription)"
      case .cannotCreateCacheDirectory:
        return "Can't create the caches directory"
      }
    }
  }
}

extension LBJMediaBrowserError {
  enum LoadMediaErrorReason {
    case cannotConvertDataToImage

    var errorDescription: String {
      switch self {
      case .cannotConvertDataToImage:
        return "Can't convert data to image"
      }
    }
  }
}
