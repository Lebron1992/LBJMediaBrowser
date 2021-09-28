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

  private let downloadQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.downlaodqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name)
  }()

  func startDownload() {
    guard receipt == nil else {
      return
    }

    downloadQueue.async { [weak self] in
      guard let self = self else {
        return
      }

      self.receipt = self.downloader.download(
        URLRequest(url: self.imageUrl),
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
