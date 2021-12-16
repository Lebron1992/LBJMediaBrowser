import Photos
import UIKit
import AlamofireImage

final class PHAssetImageLoader {

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

  private(set) var taskCache: [String: ImageStatusTask] = [:]
  private(set) var requestIdCache: [String: PHImageRequestID] = [:]

  func imageStatus(
    for assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize = .thumbnail
  ) async -> MediaImageStatus {

    let cacheKey = assetImage.cacheKey(for: targetSize)

    // image did cache
    if let cachedImage = imageCache.image(withIdentifier: cacheKey) {
      return .loaded(cachedImage)
    }

    // in progress or failed
    if let cachedTask = taskCache[cacheKey] {
      let status: MediaImageStatus
      do {
        status = try await cachedTask.value
      } catch {
        status = .failed(error)
      }
      
      taskCache.removeValue(forKey: cacheKey)
      
      return status
    }

    // create task
    let requestTask: ImageStatusTask = Task.detached { [weak self] in
      return await withCheckedContinuation { continuation in

        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true

        let requestId = self?.manager.requestImage(
          for: assetImage.asset,
          targetSize: assetImage.targetSize(for: targetSize),
          contentMode: assetImage.contentMode(for: targetSize),
          options: options
        ) { result in
          self?.requestIdCache.removeValue(forKey: cacheKey)
          
          switch result {
          case .success(let image):
            continuation.resume(returning: .loaded(image))
          case .failure(let error):
            continuation.resume(returning: .failed(error))
          }
        }

        if let requestId = requestId {
          self?.requestIdCache[cacheKey] = requestId
        }
      }
    }

    taskCache[cacheKey] = requestTask

    let status: MediaImageStatus
    do {
      status = try await requestTask.value
      if case let .loaded(image) = status {
        imageCache.add(image, withIdentifier: cacheKey)
      }
    } catch {
      status = .failed(error)
    }
    
    taskCache.removeValue(forKey: cacheKey)
    
    return status
  }

  func cancelLoading(
    for assetImage: MediaPHAssetImage,
    targetSize: ImageTargetSize = .thumbnail
  ) {
    let cacheKey = assetImage.cacheKey(for: targetSize)

    if let cachedTask = taskCache[cacheKey] {
      cachedTask.cancel()
      taskCache.removeValue(forKey: cacheKey)
    }

    if let requestId = requestIdCache[cacheKey] {
      manager.cancelImageRequest(requestId)
      requestIdCache.removeValue(forKey: cacheKey)
    }
  }
}
