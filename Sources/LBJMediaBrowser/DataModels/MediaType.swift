import Foundation

/// 代表媒体的类型。
/// A type that represents a media.
public protocol MediaType {

  /// 是否与另外一个 media 相等。
  /// Whether the media equals to another media.
  func equalsTo(_ media: MediaType) -> Bool
}
