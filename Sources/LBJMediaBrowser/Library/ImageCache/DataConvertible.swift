import Foundation
import UIKit

/// 表示可以与 `Data` 进行转换的类型。
/// Represents types that can be converted to and from `Data`.
public protocol DataConvertible {
  func toData() throws -> Data
  static func fromData(_ data: Data) throws -> Self
}
