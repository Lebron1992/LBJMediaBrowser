import Photos

final class AssetImageManager: ObservableObject {

  private(set) var assetImage: MediaPHAssetImage?
  private let manager: PHImageManagerType

  init(assetImage: MediaPHAssetImage? = nil, manager: PHImageManagerType = PHImageManager()) {
    self.assetImage = assetImage
    self.manager = manager
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

    imageStatus = .loading(0)

    let targetSize = imageType.isThumbnail ? assetImage.thumbnailTargetSize : assetImage.targetSize
    let contentMode = imageType.isThumbnail ? assetImage.thumbnailContentMode : assetImage.contentMode

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
