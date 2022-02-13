import Foundation

/// 代表媒体的类型。
/// A type that represents a media.
open class Media {

  /// 媒体的唯一标识。
  /// The id of the media.
  public let id = UUID().uuidString
}

extension Media: Equatable {
  public static func == (lhs: Media, rhs: Media) -> Bool {
    lhs.id == rhs.id
  }
}
