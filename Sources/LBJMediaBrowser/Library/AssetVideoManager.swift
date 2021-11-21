import Photos
import UIKit
import AlamofireImage

final class AssetVideoManager: MediaLoader {

  private(set) var assetVideo: MediaPHAssetVideo?

  private let manager: PHImageManagerType
  private let thumbnailGenerator: ThumbnailGeneratorType

  let imageCache: AutoPurgingImageCache
  private(set) var cachedUrls: [String: URL]

  init(
    assetVideo: MediaPHAssetVideo? = nil,
    manager: PHImageManagerType = PHImageManager(),
    thumbnailGenerator: ThumbnailGeneratorType = ThumbnailGenerator(),
    imageCache: AutoPurgingImageCache = .shared,
    cachedUrls: [String: URL] = [:]
  ) {
    self.assetVideo = assetVideo
    self.manager = manager
    self.thumbnailGenerator = thumbnailGenerator
    self.imageCache = imageCache
    self.cachedUrls = cachedUrls
  }

  @Published
  private(set) var videoStatus: MediaVideoStatus = .idle

  private(set) var requestId: PHImageRequestID?

  private let requestQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.requestqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  func setAssetVideo(_ assetVideo: MediaPHAssetVideo) {
    if self.assetVideo != assetVideo {
      self.assetVideo = assetVideo
      cancelRequest()
      startRequestVideoUrl()
    } else if videoStatus.isLoaded == false {
      startRequestVideoUrl()
    }
  }

  func startRequestVideoUrl() {
    guard requestId == nil, let assetVideo = assetVideo else {
      return
    }

    if let cachedUrl = cachedUrls[assetVideo.cacheKey],
       let cachedImage = imageCache.image(withIdentifier: assetVideo.cacheKey) {
      videoStatus = .loaded(previewImage: cachedImage, videoUrl: cachedUrl)
      return
    }

    let options = PHVideoRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    requestQueue.async { [weak self] in
      guard let self = self else {
        return
      }

      self.requestId = self.manager.requestAVAsset(
        forVideo: assetVideo.asset,
        options: options
      ) { [weak self] result in

        guard let self = self else {
          return
        }

        self.requestId = nil

        var previewImage: UIImage?
        if case let .success(url) = result {
          previewImage = self.thumbnailGenerator.thumbnail(for: url)
        }

        DispatchQueue.main.async {
          switch result {
          case .success(let url):
            self.videoStatus = .loaded(previewImage: previewImage, videoUrl: url)
            if let previewImage = previewImage {
              self.cachedUrls[assetVideo.cacheKey] = url
              self.imageCache.add(previewImage, withIdentifier: assetVideo.cacheKey)
            }
          case .failure(let error):
            self.videoStatus = .failed(error)
          }
        }
      }
    }
  }

  func cancelRequest() {
    guard let requestId = requestId else {
      return
    }
    manager.cancelImageRequest(requestId)
  }

  // MARK: - Overrides

  override func startLoadingMedia() {
    startRequestVideoUrl()
  }
}
