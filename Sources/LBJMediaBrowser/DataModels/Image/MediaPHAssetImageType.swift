import Photos

/// 代表图片格式是 `PHAsset` 的图片类型。
/// A type that represents an image with a `PHAsset` object whose `mediaType` is `image`.
public protocol MediaPHAssetImageType: MediaImageType {

  /// `mediaType` 是 `image` 的 `PHAsset` 对象。
  /// A `PHAsset` object whose `mediaType` is `image`.
  var asset: PHAsset { get }

  /// 要返回的图片的目标大小。
  /// The target size of image to be returned.
  var targetSize: CGSize { get }

  /// 用于使图片与所请求大小的纵横比相匹配的选项。
  /// An option for how to fit the image to the aspect ratio of the requested size.
  var contentMode: PHImageContentMode { get }

  /// 要返回的缩略图的目标大小。
  /// The target size of thumbnail to be returned.
  var thumbnailTargetSize: CGSize { get }

  /// 用于使缩略图与所请求大小的纵横比相匹配的选项。
  /// An option for how to fit the thumbnail to the aspect ratio of the requested size.
  var thumbnailContentMode: PHImageContentMode { get }
}
