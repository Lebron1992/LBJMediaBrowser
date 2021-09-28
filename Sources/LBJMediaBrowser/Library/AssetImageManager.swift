import Photos

final class AssetImageManager: ObservableObject {

  private let asset: MediaPHAssetImage
  private let manager: PHImageManagerType

  init(assetImage: MediaPHAssetImage, manager: PHImageManagerType = PHImageManager()) {
    self.asset = assetImage
    self.manager = manager
  }

  @Published
  private(set) var imageStatus: MediaImageStatus = .idle

  private(set) var requestId: PHImageRequestID?

  func startRequestImage(imageType: ImageType = .thumbnail) {
    guard requestId == nil else {
      return
    }

    self.imageStatus = .loading(0)

    let targetSize = imageType.isThumbnail ? asset.thumbnailTargetSize : asset.targetSize
    let contentMode = imageType.isThumbnail ? asset.thumbnailContentMode : asset.contentMode

    let options = PHImageRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    requestId = manager.requestImage(
      for: asset.asset.asset,
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
