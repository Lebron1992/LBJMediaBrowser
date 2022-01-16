import Photos
import UIKit
import AlamofireImage

final class PHAssetVideoLoader: MediaLoader<MediaVideoStatus, PHImageRequestID> {

  private let manager: PHImageManagerType
  private let thumbnailGenerator: ThumbnailGeneratorType

  let imageCache: ImageCache?
  private(set) var urlCache: SafeDictionary<String, URL>

  init(
    manager: PHImageManagerType = PHImageManager(),
    thumbnailGenerator: ThumbnailGeneratorType = ThumbnailGenerator(),
    imageCache: ImageCache?,
    urlCache: SafeDictionary<String, URL> = .init()
  ) {
    self.manager = manager
    self.thumbnailGenerator = thumbnailGenerator
    self.imageCache = imageCache
    self.urlCache = urlCache
  }

  func loadUrl(for assetVideo: MediaPHAssetVideo, maxThumbnailSize: CGSize) {
    let cacheKey = assetVideo.cacheKey(forMaxThumbnailSize: maxThumbnailSize)

    if let imageCache = imageCache {
      imageCache.image(forKey: cacheKey) { [unowned self] result in

        if let cachedResult = try? result.get() {

          if let cachedUrl = urlCache[cacheKey] {
            updateStatus(.loaded(previewImage: cachedResult.stillImage, videoUrl: cachedUrl), forKey: cacheKey)
          } else {
            requestAVAsset(for: assetVideo, maxThumbnailSize: maxThumbnailSize, previousCachedImage: cachedResult.stillImage)
          }

        } else {
          requestAVAsset(for: assetVideo, maxThumbnailSize: maxThumbnailSize)
        }
      }

    } else {
      requestAVAsset(for: assetVideo, maxThumbnailSize: maxThumbnailSize)
    }
  }

  private func requestAVAsset(
    for assetVideo: MediaPHAssetVideo,
    maxThumbnailSize: CGSize,
    previousCachedImage: UIImage? = nil
  ) {
    let cacheKey = assetVideo.cacheKey(forMaxThumbnailSize: maxThumbnailSize)

    guard isLoading(forKey: cacheKey) == false else { return }

    requestQueue.async { [unowned self] in

      let options = PHVideoRequestOptions()
      options.version = .original
      options.isNetworkAccessAllowed = true

      let requestId = manager.requestAVAsset(
        forVideo: assetVideo.asset,
        options: options
      ) { [unowned self] result in

        removeRequestId(forKey: cacheKey)

        var previewImage = previousCachedImage
        if case let .success(url) = result,
           previewImage == nil {
          previewImage = thumbnailGenerator.thumbnail(for: url, maximumSize: maxThumbnailSize)
        }

        switch result {
        case .success(let url):
          updateStatus(.loaded(previewImage: previewImage, videoUrl: url), forKey: cacheKey)

          if let previewImage = previewImage {
            urlCache[cacheKey] = url
            imageCache?.store(.still(previewImage), forKey: cacheKey)
          }

        case .failure(let error):
          updateStatus(.failed(error), forKey: cacheKey)
        }
      }

      updateRequestId(requestId, forKey: cacheKey)
    }
  }

  func cancelLoading(for assetVideo: MediaPHAssetVideo, maxThumbnailSize: CGSize) {
    let cacheKey = assetVideo.cacheKey(forMaxThumbnailSize: maxThumbnailSize)

    if let requestId = requestIdCache[cacheKey] {
      manager.cancelImageRequest(requestId)
    }

    let currentStatus = videoStatus(for: assetVideo, maxThumbnailSize: maxThumbnailSize)
    if currentStatus.isLoaded == false {
      removeStatus(forKey: cacheKey)
    }

    removeRequestId(forKey: cacheKey)
  }

  func videoStatus(for assetVideo: MediaPHAssetVideo, maxThumbnailSize: CGSize) -> MediaVideoStatus {
    let cacheKey = assetVideo.cacheKey(forMaxThumbnailSize: maxThumbnailSize)
    return statusCache[cacheKey] ?? .idle
  }
}
