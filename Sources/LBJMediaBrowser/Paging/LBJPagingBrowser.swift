import Combine
import Photos
import SwiftUI
import UIKit

import Alamofire
import AlamofireImage

public final class LBJPagingBrowser: ObservableObject {

  public var playVideoOnAppear = false

  @Published
  public private(set) var currentPage: Int = 0

  @Published
  public private(set) var playingVideo: MediaVideoType?

  @Published
  public private(set) var mediaImageStatuses: [MediaId: MediaImageStatus] = [:]

  @Published
  public private(set) var mediaVideoStatuses: [MediaId: MediaVideoStatus] = [:]

  private let mediaLoadingQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.medialoadingqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  private(set) lazy var startedURLRequest: [URL: String] = [:]
  private(set) lazy var startedPHAssetRequest: [MediaId: PHImageRequestID] = [:]

  public private(set) var medias: [MediaType]
  private let imageDownloader: ImageDownloaderType
  private let phImageManager: PHImageManagerType

  public convenience init(medias: [MediaType], currentPage: Int = 0) {
    self.init(
      medias: medias,
      currentPage: currentPage,
      imageDownloader: CustomImageDownloader(),
      phImageManager: PHImageManager()
    )
  }

  init(
    medias: [MediaType],
    currentPage: Int = 0,
    imageDownloader: ImageDownloaderType = CustomImageDownloader(),
    phImageManager: PHImageManagerType = PHImageManager(),
    mediaImageStatuses: [MediaId: MediaImageStatus] = [:],
    mediaVideoStatuses: [MediaId: MediaVideoStatus] = [:]
  ) {
    self.medias = medias
    self.imageDownloader = imageDownloader
    self.phImageManager = phImageManager
    self.mediaImageStatuses = mediaImageStatuses
    self.mediaVideoStatuses = mediaVideoStatuses
    self.currentPage = validatedPage(currentPage)
  }

  // TODO: 手动改变 page 时，动画无效。原因是 medias 数据发生改变
  public func setCurrentPage(_ page: Int, animated: Bool = true) {
    guard currentPage != page else {
      return
    }

    playingVideo = media(at: page) as? MediaVideoType

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

  public func imageStatus(for image: MediaImageType) -> MediaImageStatus? {
    mediaImageStatuses[image.id]
  }

  public func videoStatus(for video: MediaVideoType) -> MediaVideoStatus? {
    mediaVideoStatuses[video.id]
  }
}

extension LBJPagingBrowser {

  // MARK: - Start Loading

  func loadMedia(at page: Int, withAdjacent with: Bool = true) {
    guard isValidPage(page) else {
      return
    }

    let preloadSize = with ? LBJPagingBrowser.Constant.adjacentPreloadSize : 0
    let pagesToLoad = (page - preloadSize)...(page + preloadSize)

    pagesToLoad.forEach { pageToLoad in
      guard let media = media(at: pageToLoad) else {
        return
      }

      switch media {
      case let mediaImage as MediaImageType:
        if imageIsLoading(mediaImage) == false && imageIsLoaded(mediaImage) == false {

          // UIImage
          if let uiImage = media as? MediaUIImage {
            updateMediaImageStatus(.loaded(uiImage.uiImage), for: uiImage)
          }

          // URL Image
          if let urlImage = media as? MediaURLImage,
             startedURLRequest.keys.contains(urlImage.url) == false {
            downloadUrlImage(urlImage)
          }

          // PHAsset Image
          if let phAssetImage = media as? MediaPHAssetImage,
             startedPHAssetRequest.keys.contains(phAssetImage.id) == false {
            fetchPHAssetImage(phAssetImage)
          }
        }

      case let mediaVideo as MediaVideoType:
        if videoIsLoaded(mediaVideo) == false {
          // PHAsset Video
          if let assetVideo = media as? MediaPHAssetVideo,
             startedPHAssetRequest.keys.contains(assetVideo.id) == false {
            fetchPHAssetVideo(assetVideo)
          }
        }

        // URL Video
        if let urlVideo = media as? MediaURLVideo,
           urlVideoIsLoaded(urlVideo) == false {
          if let previewUrl = urlVideo.previewImageUrl {
            if startedURLRequest.keys.contains(previewUrl) == false {
              downloadUrlVideoPreview(urlVideo: urlVideo)
            }
          } else {
            updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlVideo.videoUrl), for: urlVideo)
          }
        }
      default:
        break
      }
    }
  }

  func downloadUrlImage(_ urlImage: MediaURLImage) {
    let receipt = imageDownloader.download(
      URLRequest(url: urlImage.url),
      progress: { [weak self] progress in
        self?.updateMediaImageStatus(.loading(progress), for: urlImage)
      },
      completion: { [weak self] result in
        DispatchQueue.main.async {
          switch result {
          case .success(let image):
            self?.updateMediaImageStatus(.loaded(image), for: urlImage)
          case .failure(let error):
            self?.updateMediaImageStatus(.failed(error), for: urlImage)
          }
        }
      }
    )

    startedURLRequest[urlImage.url] = receipt
  }

  func fetchPHAssetImage(_ phAssetImage: MediaPHAssetImage) {
    let options = PHImageRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    let requestId = phImageManager.requestImage(
      for: phAssetImage.asset,
      targetSize: phAssetImage.targetSize,
      contentMode: phAssetImage.contentMode,
      options: options
    ) { [weak self] result in

      DispatchQueue.main.async {
        switch result {
        case .success(let image):
          self?.updateMediaImageStatus(.loaded(image), for: phAssetImage)
        case .failure(let error):
          self?.updateMediaImageStatus(.failed(error), for: phAssetImage)
        }
      }
    }

    startedPHAssetRequest[phAssetImage.id] = requestId
  }

  func fetchPHAssetVideo(_ phAssetVideo: MediaPHAssetVideo) {
    let options = PHVideoRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    let requestId = phImageManager.requestAVAsset(
      forVideo: phAssetVideo.asset,
      options: options
    ) { [weak self] result in

      var previewImage: UIImage?
      if case let .success(url) = result {
        previewImage = generateThumbnailForPHAsset(with: url)
      }

      DispatchQueue.main.async {
        switch result {
        case .success(let url):
          self?.updateMediaVideoStatus(.loaded(previewImage: previewImage, videoUrl: url), for: phAssetVideo)
        case .failure(let error):
          self?.updateMediaVideoStatus(.failed(error), for: phAssetVideo)
        }
      }
    }

    startedPHAssetRequest[phAssetVideo.id] = requestId
  }

  func downloadUrlVideoPreview(urlVideo: MediaURLVideo) {
    guard let previewUrl = urlVideo.previewImageUrl else {
      updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlVideo.videoUrl), for: urlVideo)
      return
    }

    let receipt = imageDownloader.download(
      URLRequest(url: previewUrl),
      completion: { [weak self] result in
        DispatchQueue.main.async {
          switch result {
          case .success(let image):
            self?.updateMediaVideoStatus(.loaded(previewImage: image, videoUrl: urlVideo.videoUrl), for: urlVideo)
          case .failure:
            self?.updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlVideo.videoUrl), for: urlVideo)
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

      // UIImage
      if let uiImage = media as? MediaUIImage {
        mediaImageStatuses.removeValue(forKey: uiImage.id)
      }

      // URL Image
      if let urlImage = media as? MediaURLImage {
        startedURLRequest.removeValue(forKey: urlImage.url)
        mediaImageStatuses.removeValue(forKey: urlImage.id)
      }

      // PHAsset Image
      if let phAssetImage = media as? MediaPHAssetImage {
        startedPHAssetRequest.removeValue(forKey: phAssetImage.id)
        mediaImageStatuses.removeValue(forKey: phAssetImage.id)
      }

      // PHAsset Video
      if let assetVideo = media as? MediaPHAssetVideo {
        startedPHAssetRequest.removeValue(forKey: assetVideo.id)
        mediaVideoStatuses.removeValue(forKey: assetVideo.id)
      }

      // URL Video
      if let urlVideo = media as? MediaURLVideo {
        if let previewUrl = urlVideo.previewImageUrl {
          startedURLRequest.removeValue(forKey: previewUrl)
        }
        if let status = mediaVideoStatuses[urlVideo.id],
           case let .loaded(previewImage, videoUrl) = status,
         previewImage != nil {
          // remove previewImage ONLY when it exists
          updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: videoUrl), for: urlVideo)
        }
      }
    }
  }
}

// MARK: - Helper Methods
extension LBJPagingBrowser {

  func media(at page: Int) -> MediaType? {
    guard page >= 0 && page < medias.count else {
      return nil
    }
    return medias[page]
  }

  func updateMediaImageStatus(_ status: MediaImageStatus, for image: MediaImageType) {
    mediaImageStatuses[image.id] = status
  }

  func updateMediaVideoStatus(_ status: MediaVideoStatus, for video: MediaVideoType) {
    mediaVideoStatuses[video.id] = status
  }

  func imageIsLoading(_ image: MediaImageType) -> Bool {
    guard let status = mediaImageStatuses[image.id] else {
      return false
    }
    switch status {
    case .loading:
      return true
    default:
      return false
    }
  }

  func imageIsLoaded(_ image: MediaImageType) -> Bool {
    guard let status = mediaImageStatuses[image.id] else {
      return false
    }
    switch status {
    case .loaded:
      return true
    default:
      return false
    }
  }

  func videoIsLoaded(_ video: MediaVideoType) -> Bool {
    guard let status = mediaVideoStatuses[video.id] else {
      return false
    }
    switch status {
    case .loaded:
      return true
    default:
      return false
    }
  }

  func urlVideoIsLoaded(_ video: MediaURLVideoType) -> Bool {
    guard let status = mediaVideoStatuses[video.id] else {
      return false
    }
    switch status {
    case .loaded(let previewImgae, _):
      if video.previewImageUrl == nil {
        return true
      }
      return previewImgae != nil
    default:
      return false
    }
  }

  func validatedPage(_ page: Int) -> Int {
    min(medias.count - 1, max(0, page))
  }

  func isValidPage(_ page: Int) -> Bool {
    0..<medias.count ~= page
  }
}

extension LBJPagingBrowser {
  enum Constant {
    static let adjacentPreloadSize = 1
    static let adjacentAvoidCancelLoadingSize = 2
    static let adjacentCancelLoadingSize = 2
  }
}
