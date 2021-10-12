import Photos

final class AssetImageManager: ObservableObject {

  private let assetImage: MediaPHAssetImageType
  private let manager: PHImageManagerType

  init(assetImage: MediaPHAssetImageType, manager: PHImageManagerType = PHImageManager()) {
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

  func startRequestImage(imageType: ImageType = .thumbnail) {
    guard requestId == nil else {
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
        for: self.assetImage.asset,
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
