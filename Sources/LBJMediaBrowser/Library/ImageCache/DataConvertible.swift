import Foundation
import UIKit

/// 表示可以与 `Data` 进行转换的类型。
/// Represents types that can be converted to and from `Data`.
public protocol DataConvertible {
  func toData() throws -> Data
  static func fromData(_ data: Data) throws -> Self
}

extension UIImage: DataConvertible {
  public func toData() throws -> Data {
    guard let data = pngData() else {
      throw LBJMediaBrowserError.cacheError(reason: .cannotConvertUIImageToData(image: self))
    }
    return data
  }

  public static func fromData(_ data: Data) throws -> Self {
    guard let image = UIImage(data: data) else {
      throw LBJMediaBrowserError.cacheError(reason: .cannotCreateUIImageFromData(data: data))
    }
    return image as! Self
  }
}
