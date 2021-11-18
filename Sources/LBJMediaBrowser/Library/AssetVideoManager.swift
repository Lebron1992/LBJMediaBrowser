import Photos
import UIKit

final class AssetVideoManager: MediaLoader {

  private let assetVideo: MediaPHAssetVideo
  private let manager: PHImageManagerType

  init(assetVideo: MediaPHAssetVideo, manager: PHImageManagerType = PHImageManager()) {
    self.assetVideo = assetVideo
    self.manager = manager
  }

  @Published
  private(set) var videoStatus: MediaVideoStatus = .idle

  private(set) var requestId: PHImageRequestID?

  private let requestQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.requestqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  func startRequestVideoUrl() {
    guard requestId == nil else {
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
        forVideo: self.assetVideo.asset,
        options: options
      ) { [weak self] result in

        self?.requestId = nil

        var previewImage: UIImage?
        if case let .success(url) = result {
          previewImage = generateThumbnailForPHAsset(with: url)
        }

        DispatchQueue.main.async {
          switch result {
          case .success(let url):
            self?.videoStatus = .loaded(previewImage: previewImage, videoUrl: url)
          case .failure(let error):
            self?.videoStatus = .failed(error)
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
