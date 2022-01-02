import Foundation

/// 媒体浏览器所用到的所有全局变量和单例的集合。
/// A collection of all global variables and singletons that the media browser wants access to.
public class LBJMediaBrowserEnvironment {

  /// 负责图片缓存的对象。
  /// An object that manages the image cache for the media browser.
  public let imageCache: ImageCache?

  let assetImageLoader: PHAssetImageLoader
  let assetVideoLoader: PHAssetVideoLoader
  let urlImageLoader: URLImageLoader

  /// 使用给定的 `imageCache` 创建 `LBJMediaBrowserEnvironment` 对象。
  /// Creates a `LBJMediaBrowserEnvironment` object using the  given `imageCache`.
  /// - Parameter imageCache: `ImageCache` 对象，默认是 `.shared`，如果不需要缓存图片，传入 `nil`。An `ImageCache` object, `.shared` by default, set it to `nil` if you don't want to cache images.
  public init(imageCache: ImageCache? = .shared) {
    self.imageCache = imageCache
    self.assetImageLoader = .init(imageCache: imageCache)
    self.assetVideoLoader = .init(imageCache: imageCache)
    self.urlImageLoader = .init(imageCache: imageCache)
  }
}
