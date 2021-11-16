import Photos

final class AssetImageManager: ObservableObject {

  private(set) var assetImage: MediaPHAssetImage?
  private let manager: PHImageManagerType
  let imageCache: AutoPurgingPHAssetImageCache

  init(
    assetImage: MediaPHAssetImage? = nil,
    manager: PHImageManagerType = PHImageManager(),
    imageCache: AutoPurgingPHAssetImageCache = .shared
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

  func setAssetImage(_ assetImage: MediaPHAssetImage) {
    if self.assetImage != assetImage {
      self.assetImage = assetImage
      cancelRequest()
      startRequestImage()
    } else if (imageStatus.isLoading == false && imageStatus.isLoaded == false) {
      startRequestImage()
    }
  }

  func startRequestImage(imageType: ImageType = .thumbnail) {
    guard requestId == nil, let assetImage = assetImage else {
      return
    }

    let targetSize = imageType.isThumbnail ? assetImage.thumbnailTargetSize : assetImage.targetSize
    let contentMode = imageType.isThumbnail ? assetImage.thumbnailContentMode : assetImage.contentMode
    let request = PHAssetImageRequest(asset: assetImage.asset, targetSize: targetSize, contentMode: contentMode)

    if let cachedImage = imageCache.image(for: request) {
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
        targetSize: targetSize,
        contentMode: contentMode,
        options: options
      ) { [weak self] result in

        self?.requestId = nil

        DispatchQueue.main.async {
          switch result {
          case .success(let image):
            self?.imageStatus = .loaded(image)
            self?.imageCache.add(image, for: request)
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
}

extension AssetImageManager {
  enum ImageType {
    case thumbnail
    case full

    var isThumbnail: Bool {
      self == .thumbnail
    }
  }
}
