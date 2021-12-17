import Photos
import AlamofireImage

final class AssetImageManager: MediaLoader {

  private(set) var assetImage: MediaPHAssetImage?
  private let manager: PHImageManagerType
  let imageCache: AutoPurgingImageCache

  init(
    assetImage: MediaPHAssetImage? = nil,
    manager: PHImageManagerType = PHImageManager(),
    imageCache: AutoPurgingImageCache = .shared
  ) {
    self.assetImage = assetImage
    self.manager = manager
    self.imageCache = imageCache
  }

  @Published
  private(set) var imageStatus: MediaImageStatus = .idle

  private(set) var requestId: PHImageRequestID?

  private let requestQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.requestqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  func setAssetImage(_ assetImage: MediaPHAssetImage, targetSize: ImageTargetSize) {
    if self.assetImage != assetImage {
      self.assetImage = assetImage
      cancelRequest()
      startRequestImage(targetSize: targetSize)
    } else if (imageStatus.isLoading == false && imageStatus.isLoaded == false) {
      startRequestImage(targetSize: targetSize)
    }
  }

  func startRequestImage(targetSize: ImageTargetSize = .thumbnail) {
    guard requestId == nil, let assetImage = assetImage else {
      return
    }

    let cacheKey = assetImage.cacheKey(for: targetSize)
    if let cachedImage = imageCache.image(withIdentifier: cacheKey) {
      imageStatus = .loaded(cachedImage)
      return
    }

    imageStatus = .loading(0)

    let options = PHImageRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    requestQueue.async { [weak self] in
      guard let self = self else {
        return
      }

      self.requestId = self.manager.requestImage(
        for: assetImage.asset,
        targetSize: assetImage.targetSize(for: targetSize),
        contentMode: assetImage.contentMode(for: targetSize),
        options: options
      ) { [weak self] result in

        self?.requestId = nil

        DispatchQueue.main.async {
          switch result {
          case .success(let image):
            self?.imageStatus = .loaded(image)
            self?.imageCache.add(image, withIdentifier: cacheKey)
          case .failure(let error):
            self?.imageStatus = .failed(error)
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
    reset()
  }

  func reset() {
    imageStatus = .idle
    requestId = nil
  }

  // MARK: - Overrides

  override func startLoadingMedia() {
    startRequestImage()
  }
}
