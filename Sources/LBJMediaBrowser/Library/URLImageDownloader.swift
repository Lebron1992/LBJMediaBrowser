import UIKit
import AlamofireImage

final class URLImageDownloader: ObservableObject {

  private(set) var imageUrl: URL?
  private let downloader: ImageDownloaderType

  init(imageUrl: URL? = nil, downloader: ImageDownloaderType = CustomImageDownloader.shared) {
    self.imageUrl = imageUrl
    self.downloader = downloader
  }

  @Published
  private(set) var imageStatus: MediaImageStatus = .idle

  private(set) var receipt: String?

  func setImageUrl(_ url: URL) {
    if imageUrl != url {
      imageUrl = url
      cancelDownload()
      startDownload()
    } else if (imageStatus.isLoading == false && imageStatus.isLoaded == false) {
      startDownload()
    }
  }

  func startDownload() {
    guard receipt == nil, let imageUrl = imageUrl else {
      return
    }

    receipt = downloader.download(
      URLRequest(url: imageUrl),
      progress: { [weak self] progress in
        DispatchQueue.main.async {
          self?.imageStatus = .loading(progress)
        }
      },
      completion: { [weak self] result in

        self?.receipt = nil

        DispatchQueue.main.async {
          switch result {
          case .success(let image):
            self?.imageStatus = .loaded(image)

          case .failure(let error):
            self?.imageStatus = .failed(error)
          }
        }
      }
    )
  }

  func cancelDownload() {
    if let imageUrl = imageUrl {
      downloader.cancelRequest(for: imageUrl)
    }
    imageStatus = .idle
    receipt = nil
  }
}
