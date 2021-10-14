import Combine
import Photos
import SwiftUI
import UIKit

import Alamofire
import AlamofireImage

/// 一个管理分页模式浏览的对象。
/// An object that manages the medias paging browser.
public final class LBJPagingBrowser: ObservableObject {

  /// 是否自动播放视频，默认是 `true`。
  /// Weather auto play a video, `true` by default.
  public var autoPlayVideo = false

  /// 当前页所在的索引。
  /// The index of the current page.
  @Published
  public private(set) var currentPage: Int = 0

  /// 正在播放的视频，如果当前浏览的是视频，返回当前视频，否则返回 `nil`。
  /// The playing video. If the current page displaying a video, return the video, nil otherwise.
  @Published
  public private(set) var playingVideo: MediaVideoType?

  @Published
  private(set) var mediaImageStatuses: [MediaId: MediaImageStatus]

  @Published
  private(set) var mediaVideoStatuses: [MediaId: MediaVideoStatus]

  private let mediaLoadingQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.medialoadingqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  private(set) lazy var startedURLRequest: [URL: String] = [:]
  private(set) lazy var startedPHAssetRequest: [MediaId: PHImageRequestID] = [:]

  public private(set) var medias: [MediaType]
  private let imageDownloader: ImageDownloaderType
  private let phImageManager: PHImageManagerType

  /// 创建 LBJPagingBrowser 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - currentPage: 当前页的索引。The index of the current page.
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
  /// 设置当前页。Set the current page.
  /// - Parameters:
  ///   - page: 当前页的索引。The index of the current page.
  ///   - animated: 是否需要动画，默认是 `true`。Weather animate the page changes, `true` by default.
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
             startedURLRequest.keys.contains(urlImage.imageUrl) == false {
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
      URLRequest(url: urlImage.imageUrl),
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

    startedURLRequest[urlImage.imageUrl] = receipt
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
        startedURLRequest.removeValue(forKey: urlImage.imageUrl)
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

  func imageStatus(for image: MediaImageType) -> MediaImageStatus? {
    mediaImageStatuses[image.id]
  }

  func videoStatus(for video: MediaVideoType) -> MediaVideoStatus? {
    mediaVideoStatuses[video.id]
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
