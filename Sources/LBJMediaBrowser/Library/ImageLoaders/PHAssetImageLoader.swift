import Photos
import UIKit
import AlamofireImage

final class PHAssetImageLoader {

  static let shared = PHAssetImageLoader()

  private let manager: PHImageManagerType
  private let imageCache: AutoPurgingImageCache

  init(
    manager: PHImageManagerType = PHImageManager(),
    imageCache: AutoPurgingImageCache = .shared
  ) {
    self.manager = manager
    self.imageCache = imageCache
  }

  private(set) var loadingStatusCache: [String: ImageLoadingStatus] = [:]
  private(set) var requestIdCache: [String: PHImageRequestID] = [:]

  func uiImage(
    for assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize = .thumbnail
  ) async throws -> UIImage {

    let cacheKey = assetImage.cacheKey(for: targetSize)

    // image did cache
    if let cachedImage = imageCache.image(withIdentifier: cacheKey) {
      return cachedImage
    }

    // in progress or failed
    if let cachedStatus = loadingStatusCache[cacheKey] {
      switch cachedStatus {
      case .inProgress(let task):
        return try await task.value
      case .failed(let error):
        throw error
      }
    }

    // create task
    let request: Task<UIImage, Error> = Task.detached { [weak self] in
      return try await withCheckedThrowingContinuation { continuation in

        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true

        let requestId = self?.manager.requestImage(
          for: assetImage.asset,
          targetSize: assetImage.targetSize(for: targetSize),
          contentMode: assetImage.contentMode(for: targetSize),
          options: options
        ) { result in
          switch result {
          case .success(let image):
            continuation.resume(returning: image)
          case .failure(let error):
            continuation.resume(throwing: error)
          }

          self?.requestIdCache.removeValue(forKey: cacheKey)
        }

        if let requestId = requestId {
          self?.requestIdCache[cacheKey] = requestId
        }
      }
    }

    loadingStatusCache[cacheKey] = .inProgress(request)

    do {
      let result = try await request.value
      imageCache.add(result, withIdentifier: cacheKey)
      return result
    } catch {
      loadingStatusCache[cacheKey] = .failed(error)
      throw error
    }
  }

  func cancelLoading(
    for assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize = .thumbnail
  ) {
    let cacheKey = assetImage.cacheKey(for: targetSize)

    if let cachedStatus = loadingStatusCache[cacheKey],
      case let .inProgress(task) = cachedStatus {
      task.cancel()
      loadingStatusCache.removeValue(forKey: cacheKey)
    }

    if let requestId = requestIdCache[cacheKey] {
      manager.cancelImageRequest(requestId)
      requestIdCache.removeValue(forKey: cacheKey)
    }
  }
}
