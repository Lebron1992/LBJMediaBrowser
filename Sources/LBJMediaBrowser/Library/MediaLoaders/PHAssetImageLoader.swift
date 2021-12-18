import Photos
import AlamofireImage

final class PHAssetImageLoader: PHAssetLoader<MediaImageStatus> {

  static let shared = PHAssetImageLoader()

  let manager: PHImageManagerType
  let imageCache: AutoPurgingImageCache

  init(
    manager: PHImageManagerType = PHImageManager(),
    imageCache: AutoPurgingImageCache = .shared
  ) {
    self.manager = manager
    self.imageCache = imageCache
  }

  func loadImage(for assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) {
    let cacheKey = assetImage.cacheKey(for: targetSize)

    // image did cache
    if let cachedImage = imageCache.image(withIdentifier: cacheKey) {
      updateStatus(.loaded(cachedImage), forKey: cacheKey)
      return
    }

    // image is loading
    if isLoading(forKey: cacheKey) {
      return
    }

    // loading image
    requestQueue.async { [unowned self] in

      let options = PHImageRequestOptions()
      options.version = .original
      options.isNetworkAccessAllowed = true

      let requestId = manager.requestImage(
        for: assetImage.asset,
           targetSize: assetImage.targetSize(for: targetSize),
           contentMode: assetImage.contentMode(for: targetSize),
           options: options
      ) { [unowned self] result in

        removeRequestId(forKey: cacheKey)

        switch result {
        case .success(let image):
          updateStatus(.loaded(image), forKey: cacheKey)
          imageCache.add(image, withIdentifier: cacheKey)
        case .failure(let error):
          updateStatus(.failed(error), forKey: cacheKey)
        }
      }

      updateRequestId(requestId, forKey: cacheKey)
    }
  }

  func cancelLoading(for assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) {
    let cacheKey = assetImage.cacheKey(for: targetSize)

    if let requestId = requestIdCache[cacheKey] {
      manager.cancelImageRequest(requestId)
    }

    removeStatus(forKey: cacheKey)
    removeRequestId(forKey: cacheKey)
  }

  func imageStatus(for assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) -> MediaImageStatus {
    statusCache[assetImage.cacheKey(for: targetSize)] ?? .idle
  }
}
