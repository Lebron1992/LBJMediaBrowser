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

  private lazy var imageDownloader = ImageDownloader()
  private lazy var phImageManager = PHImageManager()

  // TODO: 手动改变 page 时，动画无效。原因是 medias 数据发生改变
  public func setCurrentPage(_ page: Int, animated: Bool = true) {
    if animated {
      withAnimation {
        currentPage = validatedPage(page)
      }
    } else {
      currentPage = validatedPage(page)
    }

    loadMedia(at: currentPage)
  }
}

// MARK: - Loading Media
extension PagingBrowser {
  func loadMedia(at index: Int, withAdjacent with: Bool = true) {
    let preloadSize = with ? PagingBrowser.Constant.adjacentPreloadSize : 0
    let indicesToLoad = (index - preloadSize)...(index + preloadSize)

    indicesToLoad.forEach { indexToLoad in
      guard let media = media(at: indexToLoad) else {
        return
      }

      switch media {
      case let mediaImage as MediaImageType:
        if mediaImage.isLoading == false && mediaImage.isLoaded == false {
          // URL Image
          if let urlImage = media as? MediaURLImage {
            downloadUrlImage(urlImage, at: indexToLoad)
          }

          // PHAsset Image
          if let phAssetImage = media as? MediaPHAssetImage {
            fetchPHAssetImage(phAssetImage, at: indexToLoad)
          }
        }

      case let mediaVideo as MediaVideoType:
        if mediaVideo.isLoading == false && mediaVideo.isLoaded == false {
          // PHAsset Video
          if let assetVideo = media as? MediaPHAssetVideo {
            fetchPHAssetVideo(assetVideo, at: indexToLoad)
          }
        }
      default:
        break
      }
    }
  }

  private func downloadUrlImage(_ urlImage: MediaURLImage, at index: Int) {
    guard let url = URL(string: urlImage.url) else {
      updateMediaImageStatus(.failed(.invalidURL(urlImage.url)), forMediaAt: index)
      return
    }

    imageDownloader.download(
      URLRequest(url: url),
      progress: { [weak self] progress in
        let percentage = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
        self?.updateMediaImageStatus(.loading(percentage), forMediaAt: index)
      },
      completion: { [weak self] response in
        DispatchQueue.main.async {
          switch response.result {
          case .success(let image):
            self?.updateMediaImageStatus(.loaded(image), forMediaAt: index)
          case .failure(let error):
            self?.updateMediaImageStatus(.failed(.commonError(error)), forMediaAt: index)
          }
        }
      }
    )
  }

  private func fetchPHAssetImage(_ phAssetImage: MediaPHAssetImage, at index: Int) {
    let options = PHImageRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    phImageManager.requestImage(
      for: phAssetImage.asset,
      targetSize: phAssetImage.targetSize,
      contentMode: phAssetImage.contentMode,
      options: options
    ) { [weak self] image, info in

      DispatchQueue.main.async {
        if let image = image {
          self?.updateMediaImageStatus(.loaded(image), forMediaAt: index)
        } else if let error = info?[PHImageErrorKey] as? Error {
          self?.updateMediaImageStatus(.failed(.commonError(error)), forMediaAt: index)
        }
      }
    }
  }

  private func fetchPHAssetVideo(_ phAssetVideo: MediaPHAssetVideo, at index: Int) {
    let options = PHVideoRequestOptions()
    options.version = .original
    options.isNetworkAccessAllowed = true

    phImageManager.requestAVAsset(
      forVideo: phAssetVideo.asset,
      options: options
    ) { [weak self] asset, _, info in

      DispatchQueue.main.async {
        if let urlAsset = asset as? AVURLAsset {
          self?.updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: urlAsset.url), forMediaAt: index)
        } else if let error = info?[PHImageErrorKey] as? Error {
          self?.updateMediaImageStatus(.failed(.commonError(error)), forMediaAt: index)
        }
      }
    }
  }
}

// MARK: - Helper Methods
private extension PagingBrowser {

  func media(at index: Int) -> MediaType? {
    guard index >= 0 && index < medias.count else {
      return nil
    }
    return medias[index]
  }

  func updateMediaImageStatus(_ status: MediaImageStatus, forMediaAt index: Int) {
    guard let mediaImage = media(at: index) as? MediaImageStatusEditable else {
      return
    }
    medias[index] = mediaImage.status(status)
  }

  func updateMediaVideoStatus(_ status: MediaVideoStatus, forMediaAt index: Int) {
    guard let mediaVideo = media(at: index) as? MediaVideoStatusEditable else {
      return
    }
    medias[index] = mediaVideo.status(status)
  }

  func validatedPage(_ page: Int) -> Int {
    min(medias.count - 1, max(0, page))
  }
}

private extension PagingBrowser {
  enum Constant {
    static let adjacentPreloadSize = 2
  }
}
