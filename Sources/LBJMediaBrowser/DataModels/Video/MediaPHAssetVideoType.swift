import Photos

/// 代表视频格式是 `PHAsset` 的视频类型。
/// A type that represents a video with a `PHAsset` object whose `mediaType` is `video` .
public protocol MediaPHAssetVideoType: MediaVideoType {

  /// `mediaType` 是 `video` 的 `PHAsset` 对象。
  /// A  `PHAsset` object whose `mediaType` is `video`.
  var asset: PHAsset { get }
}
