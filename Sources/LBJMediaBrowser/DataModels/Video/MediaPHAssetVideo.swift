import Photos

/// 代表视频格式是 `PHAsset` 的视频类型。
/// A video type with a `PHAsset` object whose `mediaType` is `video`.
open class MediaPHAssetVideo: MediaVideo {

  /// `mediaType` 是 `video` 的 `PHAsset` 对象。
  /// A  `PHAsset` object whose `mediaType` is `video`.
  public let asset: PHAsset

  /// 创建 `MediaPHAssetVideo` 对象。Creates a `MediaPHAssetVideo` object.
  /// - Parameter asset: `mediaType` 是 `video` 的 `PHAsset` 对象。A  `PHAsset` object whose `mediaType` is `video`.
  public init(asset: PHAsset) {
    guard asset.mediaType == .video else {
      fatalError("[MediaPHAssetVideo] The `asset` should be a type of video.")
    }
    self.asset = asset
  }
}

extension MediaPHAssetVideo {
  func cacheKey(forMaxThumbnailSize size: CGSize) -> String {
    "\(asset.localIdentifier)-\(size)"
  }
}

extension MediaPHAssetVideo: Equatable {
  public static func == (lhs: MediaPHAssetVideo, rhs: MediaPHAssetVideo) -> Bool {
    lhs.id == rhs.id &&
    lhs.asset == rhs.asset
  }
}
