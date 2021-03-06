import Photos
import UIKit

/// 图片格式是 `PHAsset` 的图片类型。
/// An image type with a `PHAsset` object whose `mediaType` is `image`.
open class MediaPHAssetImage: MediaImage {

  /// `mediaType` 是 `image` 的 `PHAsset` 对象。
  /// A `PHAsset` object whose `mediaType` is `image`.
  public let asset: PHAsset

  /// 要返回的图片的目标大小。
  /// The target size of image to be returned.
  public let targetSize: CGSize

  /// 用于使图片与所请求大小的纵横比相匹配的选项。
  /// An option for how to fit the image to the aspect ratio of the requested size.
  public let contentMode: PHImageContentMode

  /// 要返回的缩略图的目标大小。
  /// The target size of thumbnail to be returned.
  public let thumbnailTargetSize: CGSize

  /// 用于使缩略图与所请求大小的纵横比相匹配的选项。
  /// An option for how to fit the thumbnail to the aspect ratio of the requested size.
  public let thumbnailContentMode: PHImageContentMode

  /// 创建 `MediaPHAssetImage` 对象。Creates a `MediaPHAssetImage` object.
  /// - Parameters:
  ///   - asset: `mediaType` 是 `image` 的 `PHAsset` 对象。A `PHAsset` object whose `mediaType` is `image`.
  ///   - targetSize: 要返回的图片的目标大小。The target size of image to be returned.
  ///   - contentMode: 用于使图片与所请求大小的纵横比相匹配的选项。An option for how to fit the image to the aspect ratio of the requested size.
  ///   - thumbnailTargetSize: 要返回的缩略图的目标大小。The target size of thumbnail to be returned.
  ///   - thumbnailContentMode: 用于使缩略图与所请求大小的纵横比相匹配的选项。An option for how to fit the thumbnail to the aspect ratio of the requested size.
  public init(
    asset: PHAsset,
    targetSize: CGSize = UIScreen.main.bounds.size * UIScreen.main.scale,
    contentMode: PHImageContentMode = .aspectFit,
    thumbnailTargetSize: CGSize = Constant.thumbnailTargetSize,
    thumbnailContentMode: PHImageContentMode = .aspectFill
  ) {
    guard asset.mediaType == .image else {
      fatalError("[MediaPHAssetImage] The `asset` should be a type of image.")
    }
    self.asset = asset
    self.targetSize = targetSize
    self.contentMode = contentMode
    self.thumbnailTargetSize = thumbnailTargetSize
    self.thumbnailContentMode = thumbnailContentMode
  }
}

// MARK: - Helper Methods
extension MediaPHAssetImage {
  func cacheKey(for targetSize: ImageTargetSize) -> String {
    let size = self.targetSize(for: targetSize)
    let contentMode = contentMode(for: targetSize)
    return "\(asset.localIdentifier)-\(size)-\(contentMode.stringRepresentation)"
  }

  func targetSize(for targetSize: ImageTargetSize) -> CGSize {
      targetSize.isThumbnail ? thumbnailTargetSize : self.targetSize
    }

    func contentMode(for targetSize: ImageTargetSize) -> PHImageContentMode {
      targetSize.isThumbnail ? thumbnailContentMode : contentMode
    }
}

// MARK: - Equatable
extension MediaPHAssetImage {
  public static func == (lhs: MediaPHAssetImage, rhs: MediaPHAssetImage) -> Bool {
    lhs.id == rhs.id &&
    lhs.asset == rhs.asset &&
    lhs.targetSize == rhs.targetSize &&
    lhs.contentMode == rhs.contentMode &&
    lhs.thumbnailTargetSize == rhs.thumbnailTargetSize &&
    lhs.thumbnailContentMode == rhs.thumbnailContentMode
  }
}

extension MediaPHAssetImage {
  public enum Constant {
    public static let thumbnailTargetSize = CGSize(width: 160, height: 160)
  }
}
