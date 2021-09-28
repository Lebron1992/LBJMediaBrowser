import UIKit
import AlamofireImage

final class URLImageDownloader: ObservableObject {

  private let imageUrl: URL
  private let downloader: ImageDownloaderType

  init(imageUrl: URL, downloader: ImageDownloaderType = CustomImageDownloader()) {
    self.imageUrl = imageUrl
    self.downloader = downloader
  }

  @Published
  private(set) var imageStatus: MediaImageStatus = .idle

  private(set) var receipt: String?

  func startDownload() {
    guard receipt == nil else {
      return
    }

    receipt = downloader.download(
      URLRequest(url: imageUrl),
      progress: { [weak self] in self?.imageStatus = .loading($0) },
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
    downloader.cancelRequest(for: imageUrl)
    reset()
  }

  func reset() {
    imageStatus = .idle
    receipt = nil
  }
}
