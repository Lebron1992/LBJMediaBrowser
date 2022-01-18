import Photos
import UIKit
import AlamofireImage

final class PHAssetImageLoader: MediaLoader<MediaImageStatus, PHImageRequestID> {

  let manager: PHImageManagerType
  let imageCache: ImageCache?

  init(
    manager: PHImageManagerType = PHImageManager(),
    imageCache: ImageCache?
  ) {
    self.manager = manager
    self.imageCache = imageCache
  }

  func loadImage(for assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) {
    let cacheKey = assetImage.cacheKey(for: targetSize)

    guard let imageCache = imageCache else {
      requestImage(for: assetImage, targetSize: targetSize)
      return
    }

    imageCache.image(forKey: cacheKey) { [unowned self] result in
      if let image = try? result.get() {
        updateStatus(.loaded(image), forKey: cacheKey)
      } else {
        requestImage(for: assetImage, targetSize: targetSize)
      }
    }
  }

  private func requestImage(for assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) {
    let cacheKey = assetImage.cacheKey(for: targetSize)

    guard isLoading(forKey: cacheKey) == false else { return }

    requestQueue.async { [unowned self] in

      let options = PHImageRequestOptions()
      options.version = .original
      options.isNetworkAccessAllowed = true

      let requestId: PHImageRequestID
      if assetImage.asset.isGif {
        requestId = manager.requestImageData(
          for: assetImage.asset,
          options: options
        ) { [unowned self] result in
          removeRequestId(forKey: cacheKey)

          switch result {
          case .success(let data):
            if UIImage.isAnimatedImage(for: data) {
              updateStatus(.loaded(.gif(data)), forKey: cacheKey)
              imageCache?.store(.gif(data), forKey: cacheKey)

            } else if let image = UIImage(data: data) {
              updateStatus(.loaded(.still(image)), forKey: cacheKey)
              imageCache?.store(.still(image), forKey: cacheKey)

            } else {
              updateStatus(.failed(LBJMediaBrowserError.loadMediaError(reason: .cannotConvertDataToImage)), forKey: cacheKey)
            }
          case .failure(let error):
            updateStatus(.failed(error), forKey: cacheKey)
          }
        }
      } else {
        requestId = manager.requestImage(
          for: assetImage.asset,
             targetSize: assetImage.targetSize(for: targetSize),
             contentMode: assetImage.contentMode(for: targetSize),
             options: options
        ) { [unowned self] result in

          removeRequestId(forKey: cacheKey)

          switch result {
          case .success(let image):
            updateStatus(.loaded(.still(image)), forKey: cacheKey)
            imageCache?.store(.still(image), forKey: cacheKey)
          case .failure(let error):
            updateStatus(.failed(error), forKey: cacheKey)
          }
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

    if let currentStatus = imageStatus(for: assetImage, targetSize: targetSize),
       currentStatus.isLoaded == false {
      removeStatus(forKey: cacheKey)
    }

    removeRequestId(forKey: cacheKey)
  }

  func imageStatus(for assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) -> MediaImageStatus? {
    statusCache[assetImage.cacheKey(for: targetSize)]
  }
}
