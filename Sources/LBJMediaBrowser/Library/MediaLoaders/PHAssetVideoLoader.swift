import Photos
import UIKit
import AlamofireImage

final class PHAssetVideoLoader {
  
  static let shared = PHAssetVideoLoader()

  private let manager: PHImageManagerType
  private let thumbnailGenerator: ThumbnailGeneratorType

  let imageCache: AutoPurgingImageCache
  let urlCache: LBJURLCache

  init(
    manager: PHImageManagerType = PHImageManager(),
    thumbnailGenerator: ThumbnailGeneratorType = ThumbnailGenerator(),
    imageCache: AutoPurgingImageCache = .shared,
    urlCache: LBJURLCache = .shared
  ) {
    self.manager = manager
    self.thumbnailGenerator = thumbnailGenerator
    self.imageCache = imageCache
    self.urlCache = urlCache
  }

  private(set) var taskCache: [String: VideoStatusTask] = [:]
  private(set) var requestIdCache: [String: PHImageRequestID] = [:]

  func videoStatus(for assetVideo: MediaPHAssetVideo) async -> MediaVideoStatus {
    let cacheKey = assetVideo.cacheKey

    // image did cache
    if let cachedUrl = urlCache.url(withIdentifier: cacheKey),
       let cachedImage = imageCache.image(withIdentifier: cacheKey) {
      return .loaded(previewImage: cachedImage, videoUrl: cachedUrl)
    }
    
    // in progress or failed
    if let cachedTask = taskCache[cacheKey] {
      let status: MediaVideoStatus
      do {
        status = try await cachedTask.value
      } catch {
        status = .failed(error)
      }
      
      taskCache.removeValue(forKey: cacheKey)
      
      return status
    }
    
    // create task
    let requestTask: VideoStatusTask = Task.detached { [weak self] in
      return await withCheckedContinuation { continuation in
        
        let options = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        
        let requestId = self?.manager.requestAVAsset(
          forVideo: assetVideo.asset,
          options: options
        ) { [weak self] result in
          self?.requestIdCache.removeValue(forKey: cacheKey)
          
          var previewImage: UIImage?
          if case let .success(url) = result {
            previewImage = self?.thumbnailGenerator.thumbnail(for: url)
          }
          
          switch result {
          case .success(let url):
            continuation.resume(returning: .loaded(previewImage: previewImage, videoUrl: url))
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
    
    do {
      let status = try await requestTask.value
      
      if case let .loaded(previewImage, videoUrl) = status,
         let previewImage = previewImage {
          urlCache.add(videoUrl, withIdentifier: assetVideo.cacheKey)
          imageCache.add(previewImage, withIdentifier: assetVideo.cacheKey)
      }
      taskCache.removeValue(forKey: cacheKey)
      
      return status
    } catch {
      taskCache.removeValue(forKey: cacheKey)
      return .failed(error)
    }
  }

  func cancelLoading(for assetVideo: MediaPHAssetVideo) {
    let cacheKey = assetVideo.cacheKey
    
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

extension PHAssetVideoLoader {
  typealias VideoStatusTask = Task<MediaVideoStatus, Error>
}
