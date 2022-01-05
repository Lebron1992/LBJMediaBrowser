import UIKit
import AlamofireImage

final class URLImageLoader: MediaLoader<MediaImageStatus, String> {

  let downloader: URLImageDownloaderType
  let imageCache: ImageCache?

  init(
    downloader: URLImageDownloaderType = URLImageDownloader(),
    imageCache: ImageCache?
  ) {
    self.downloader = downloader
    self.imageCache = imageCache
  }

  func loadImage(for urlImage: MediaURLImage, targetSize: ImageTargetSize) {
    let cacheKey = urlImage.cacheKey(for: targetSize)

    guard let imageCache = imageCache else {
      downloadImage(for: urlImage, targetSize: targetSize)
      return
    }

    imageCache.image(forKey: cacheKey) { [unowned self] result in
      if let image = try? result.get() {
        updateStatus(.loaded(image), forKey: cacheKey)
      } else {
        downloadImage(for: urlImage, targetSize: targetSize)
      }
    }
  }

  private func downloadImage(for urlImage: MediaURLImage, targetSize: ImageTargetSize) {
    let cacheKey = urlImage.cacheKey(for: targetSize)

    guard isLoading(forKey: cacheKey) == false else { return }

    requestQueue.async { [unowned self] in
      let requestId = downloader.download(
        URLRequest(url: urlImage.imageUrl(for: targetSize)),
        cacheKey: cacheKey,
        progress: { [unowned self] progress in
          updateStatus(.loading(progress), forKey: cacheKey)
        },
        completion: { [unowned self] result in

          removeRequestId(forKey: cacheKey)

          switch result {
          case .success(let image):
            updateStatus(.loaded(image), forKey: cacheKey)
            imageCache?.store(image, forKey: cacheKey)
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

    if let currentStatus = imageStatus(for: urlImage, targetSize: targetSize),
       currentStatus.isLoaded == false {
      removeStatus(forKey: cacheKey)
    }

    removeRequestId(forKey: cacheKey)
  }

  func imageStatus(for urlImage: MediaURLImage, targetSize: ImageTargetSize) -> MediaImageStatus? {
    statusCache[urlImage.cacheKey(for: targetSize)]
  }
}
