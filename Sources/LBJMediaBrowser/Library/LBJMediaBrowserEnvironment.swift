import Foundation

public class LBJMediaBrowserEnvironment: ObservableObject {
  public let imageCache: ImageCache?

  let assetImageLoader: PHAssetImageLoader
  let assetVideoLoader: PHAssetVideoLoader
  let urlImageLoader: URLImageLoader

  public init(imageCache: ImageCache? = .shared) {
    self.imageCache = imageCache
    self.assetImageLoader = .init(imageCache: imageCache)
    self.assetVideoLoader = .init(imageCache: imageCache)
    self.urlImageLoader = .init(imageCache: imageCache)
  }
}
