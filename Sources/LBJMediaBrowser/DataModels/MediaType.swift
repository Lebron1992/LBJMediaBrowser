public typealias MediaId = String

/// 代表媒体的类型。
/// A type that represents a media.
public protocol MediaType {

  /// 媒体的唯一标识。
  /// The id of the media.
  var id: MediaId { get }
}
