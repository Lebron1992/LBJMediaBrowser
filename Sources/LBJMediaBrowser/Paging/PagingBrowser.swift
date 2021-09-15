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
      guard
        let media = media(at: indexToLoad),
        (media is MediaUIImage) == false
      else {
        return
      }

      // URL Image
      if let urlImage = media as? MediaURLImage {
        downloadUrlImage(urlImage, at: indexToLoad)
      }

      // PHAsset Image
      if let phAssetImage = media as? MediaPHAsset {
        fetchPHAssetImageIfNeeded(phAssetImage, at: indexToLoad)
      }
    }
  }

  private func downloadUrlImage(_ urlImage: MediaURLImage, at index: Int) {
    guard let url = URL(string: urlImage.url) else {
      updateMediaStatus(.failed(.invalidURL(urlImage.url)), forMediaAt: index)
      return
    }

    imageDownloader.download(
      URLRequest(url: url),
      progress: { [weak self] progress in
        let percentage = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
        self?.updateMediaStatus(.loading(percentage), forMediaAt: index)
      },
      completion: { [weak self] response in
        DispatchQueue.main.async {
          switch response.result {
          case .success(let image):
            self?.updateMediaStatus(.loaded(image), forMediaAt: index)
          case .failure(let error):
            self?.updateMediaStatus(.failed(.commonError(error)), forMediaAt: index)
          }
        }
      }
    )
  }

  private func fetchPHAssetImageIfNeeded(_ phAssetImage: MediaPHAsset, at index: Int) {
    guard phAssetImage.isLoaded == false else {
      return
    }

    let options = PHImageRequestOptions()
    options.version = .original

    phImageManager.requestImage(
      for: phAssetImage.phAsset,
      targetSize: phAssetImage.targetSize,
      contentMode: phAssetImage.contentMode,
      options: options
    ) { [weak self] image, info in

      if let image = image {
        self?.updateMediaStatus(.loaded(image), forMediaAt: index)
      } else if let error = info?[PHImageErrorKey] as? Error {
        self?.updateMediaStatus(.failed(.commonError(error)), forMediaAt: index)
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

  func updateMediaStatus(_ status: MediaStatus, forMediaAt index: Int) {
    guard let media = media(at: index) else {
      return
    }
    if let mediaEditable = media as? MediaStatusEditable {
      medias[index] = mediaEditable.status(status)
    }
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
