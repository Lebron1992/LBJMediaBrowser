import UIKit
import AlamofireImage

final class URLImageLoader: MediaLoader<MediaImageStatus, String> {

  static let shared = URLImageLoader()

  let downloader: URLImageDownloaderType
  let imageCache: AutoPurgingImageCache

  init(
    downloader: URLImageDownloaderType = URLImageDownloader(),
    imageCache: AutoPurgingImageCache = .shared
  ) {
    self.downloader = downloader
    self.imageCache = imageCache
  }

  func loadImage(for urlImage: MediaURLImage, targetSize: ImageTargetSize) {
    let cacheKey = urlImage.cacheKey(for: targetSize)

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

      let requestId = downloader.download(
        URLRequest(url: urlImage.imageUrl(for: targetSize)),
        progress: { [unowned self] progress in
          updateStatus(.loading(progress), forKey: cacheKey)
        },
        completion: { [unowned self] result in

          removeRequestId(forKey: cacheKey)

          switch result {
          case .success(let image):
            updateStatus(.loaded(image), forKey: cacheKey)
            imageCache.add(image, withIdentifier: cacheKey)
          case .failure(let error):
            updateStatus(.failed(error), forKey: cacheKey)
          }
        })

      if let requestId = requestId {
        updateRequestId(requestId, forKey: cacheKey)
      }
    }
  }

  func cancelLoading(for urlImage: MediaURLImage, targetSize: ImageTargetSize) {
    let cacheKey = urlImage.cacheKey(for: targetSize)

    if let requestId = requestIdCache[cacheKey] {
      downloader.cancelRequest(forKey: requestId)
    }

    removeStatus(forKey: cacheKey)
    removeRequestId(forKey: cacheKey)
  }

  func imageStatus(for urlImage: MediaURLImage, targetSize: ImageTargetSize) -> MediaImageStatus {
    statusCache[urlImage.cacheKey(for: targetSize)] ?? .idle
  }
}
