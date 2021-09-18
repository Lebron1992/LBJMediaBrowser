import Combine
import Photos
import SwiftUI
import UIKit

import Alamofire
import AlamofireImage

public final class PagingBrowser: ObservableObject {

  @Published
  public private(set) var currentPage: Int = 0

  @Published
  private(set) var medias: [MediaType]

  public init(medias: [MediaType], currentPage: Int = 0) {
    self.medias = medias
    self.currentPage = validatedPage(currentPage)
  }

  private let mediaLoadingQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.medialoadingqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  private lazy var imageDownloader = ImageDownloader()
  private lazy var phImageManager = PHImageManager()

  private lazy var startedURLRequest: [URL: RequestReceipt] = [:]
  private lazy var startedPHAssetRequest: [PHAsset: PHImageRequestID] = [:]

  // TODO: 手动改变 page 时，动画无效。原因是 medias 数据发生改变
  public func setCurrentPage(_ page: Int, animated: Bool = true) {
    guard currentPage != page else {
      return
    }

    cancelLoadingMediaExceptPageAndAdjacent(page: currentPage)

    if animated {
      withAnimation {
        currentPage = validatedPage(page)
      }
    } else {
      currentPage = validatedPage(page)
    }

    mediaLoadingQueue.async { [weak self] in
      guard let self = self else { return }
      self.loadMedia(at: self.currentPage)
    }
  }
}

extension PagingBrowser {

  // MARK: - Start Loading

  func loadMedia(at page: Int, withAdjacent with: Bool = true) {
    guard isValidPage(page) else {
      return
    }

    let preloadSize = with ? PagingBrowser.Constant.adjacentPreloadSize : 0
    let pagesToLoad = (page - preloadSize)...(page + preloadSize)

    pagesToLoad.forEach { pageToLoad in
      guard let media = media(at: pageToLoad) else {
        return
      }

      switch media {
      case let mediaImage as MediaImageType:
        if mediaImage.isLoading == false && mediaImage.isLoaded == false {
          // URL Image
          if let urlImage = media as? MediaURLImage,
             startedURLRequest.keys.contains(urlImage.url) == false {
            downloadUrlImage(urlImage, at: pageToLoad)
          }

          // PHAsset Image
          if let phAssetImage = media as? MediaPHAssetImage,
             startedPHAssetRequest.keys.contains(phAssetImage.asset) == false {
            fetchPHAssetImage(phAssetImage, at: pageToLoad)
          }
        }

      case let mediaVideo as MediaVideoType:
        if mediaVideo.isLoaded == false {
          // PHAsset Video
          if let assetVideo = media as? MediaPHAssetVideo,
             startedPHAssetRequest.keys.contains(assetVideo.asset) == false {
            fetchPHAssetVideo(assetVideo, at: pageToLoad)
          }
        }

        // URL Video
        if let urlVideo = media as? MediaURLVideo,
           urlVideo.isLoaded == false {
          if let previewUrl = urlVideo.previewImageUrl {
            if startedURLRequest.keys.contains(previewUrl) == false {
              downloadUrlVideoPreview(urlVideo: urlVideo, at: pageToLoad)
            }
          } else {
            updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlVideo.videoUrl), forMediaAt: pageToLoad)
          }
        }
      default:
        break
      }
    }
  }

  private func downloadUrlImage(_ urlImage: MediaURLImage, at page: Int) {
    let receipt = imageDownloader.download(
      URLRequest(url: urlImage.url),
      progress: { [weak self] progress in
        let percentage = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
        self?.updateMediaImageStatus(.loading(percentage), forMediaAt: page)
      },
      completion: { [weak self] response in
        DispatchQueue.main.async {
          switch response.result {
          case .success(let image):
            self?.updateMediaImageStatus(.loaded(image), forMediaAt: page)
          case .failure(let error):
            self?.updateMediaImageStatus(.failed(error), forMediaAt: page)
          }
        }
      }
    )

    startedURLRequest[urlImage.url] = receipt
  }

  private func fetchPHAssetImage(_ phAssetImage: MediaPHAssetImage, at page: Int) {
    let options = PHImageRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    let requestId = phImageManager.requestImage(
      for: phAssetImage.asset,
      targetSize: phAssetImage.targetSize,
      contentMode: phAssetImage.contentMode,
      options: options
    ) { [weak self] image, info in

      DispatchQueue.main.async {
        if let image = image {
          self?.updateMediaImageStatus(.loaded(image), forMediaAt: page)
        } else if let error = info?[PHImageErrorKey] as? Error {
          self?.updateMediaImageStatus(.failed(error), forMediaAt: page)
        }
      }
    }

    startedPHAssetRequest[phAssetImage.asset] = requestId
  }

  private func fetchPHAssetVideo(_ phAssetVideo: MediaPHAssetVideo, at page: Int) {
    let options = PHVideoRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    let requestId = phImageManager.requestAVAsset(
      forVideo: phAssetVideo.asset,
      options: options
    ) { [weak self] asset, _, info in

      DispatchQueue.main.async {
        if let urlAsset = asset as? AVURLAsset {
          self?.updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlAsset.url), forMediaAt: page)
        } else if let error = info?[PHImageErrorKey] as? Error {
          self?.updateMediaVideoStatus(.failed(error), forMediaAt: page)
        }
      }
    }

    startedPHAssetRequest[phAssetVideo.asset] = requestId
  }

  private func downloadUrlVideoPreview(urlVideo: MediaURLVideo, at page: Int) {
    guard let previewUrl = urlVideo.previewImageUrl else {
      updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlVideo.videoUrl), forMediaAt: page)
      return
    }

    let receipt = imageDownloader.download(
      URLRequest(url: previewUrl),
      completion: { [weak self] response in
        DispatchQueue.main.async {
          switch response.result {
          case .success(let image):
            self?.updateMediaVideoStatus(.loaded(previewImage: image, videoUrl: urlVideo.videoUrl), forMediaAt: page)
          case .failure:
            self?.updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlVideo.videoUrl), forMediaAt: page)
          }
        }
      }
    )

    startedURLRequest[previewUrl] = receipt
  }

  // MARK: - Cancel Loading

  func cancelLoadingMediaExceptPageAndAdjacent(page: Int) {
    guard isValidPage(page) else {
      return
    }

    let cancelSize = Constant.adjacentCancelLoadingSize
    let avoidCancelSize = Constant.adjacentAvoidCancelLoadingSize
    let leftBound = (page - avoidCancelSize) - 1
    let rightBound = (page + avoidCancelSize) + 1

    var pagesToCancel: [Int] = []
    if leftBound >= 0 {
      let lowerBound = max(0, leftBound - cancelSize)
      pagesToCancel.append(contentsOf: lowerBound...leftBound)
    }
    if rightBound < medias.count {
      let upperBound = min(rightBound + cancelSize + 1, medias.count)
      pagesToCancel.append(contentsOf: rightBound..<upperBound)
    }

    pagesToCancel.forEach { pageToCancel in
      guard let media = media(at: pageToCancel) else {
        return
      }

      // URL Image
      if let urlImage = media as? MediaURLImage {
        startedURLRequest.removeValue(forKey: urlImage.url)
        if urlImage.isIdle == false {
          updateMediaImageStatus(.idle, forMediaAt: pageToCancel)
        }
      }

      // PHAsset Image
      if let phAssetImage = media as? MediaPHAssetImage {
        startedPHAssetRequest.removeValue(forKey: phAssetImage.asset)
        if phAssetImage.isIdle == false {
          updateMediaImageStatus(.idle, forMediaAt: pageToCancel)
        }
      }

      // PHAsset Video
      if let assetVideo = media as? MediaPHAssetVideo {
        startedPHAssetRequest.removeValue(forKey: assetVideo.asset)
        if assetVideo.isIdle == false {
          updateMediaVideoStatus(.idle, forMediaAt: pageToCancel)
        }
      }

      // URL Video
      if let urlVideo = media as? MediaURLVideo {
        if let previewUrl = urlVideo.previewImageUrl {
          startedURLRequest.removeValue(forKey: previewUrl)
        }
        if case let .loaded(previewImage, videoUrl) = urlVideo.status,
         previewImage != nil {
          updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: videoUrl), forMediaAt: pageToCancel)
        }
      }
    }
  }
}

// MARK: - Helper Methods
private extension PagingBrowser {

  func media(at page: Int) -> MediaType? {
    guard page >= 0 && page < medias.count else {
      return nil
    }
    return medias[page]
  }

  func updateMediaImageStatus(_ status: MediaImageStatus, forMediaAt page: Int) {
    guard let mediaImage = media(at: page) as? MediaImageStatusEditable else {
      return
    }
    medias[page] = mediaImage.status(status)
  }

  func updateMediaVideoStatus(_ status: MediaVideoStatus, forMediaAt page: Int) {
    guard let mediaVideo = media(at: page) as? MediaVideoStatusEditable else {
      return
    }
    medias[page] = mediaVideo.status(status)
  }

  func validatedPage(_ page: Int) -> Int {
    min(medias.count - 1, max(0, page))
  }

  func isValidPage(_ page: Int) -> Bool {
    0..<medias.count ~= page
  }
}

private extension PagingBrowser {
  enum Constant {
    static let adjacentPreloadSize = 1
    static let adjacentAvoidCancelLoadingSize = 2
    static let adjacentCancelLoadingSize = 2
  }
}
