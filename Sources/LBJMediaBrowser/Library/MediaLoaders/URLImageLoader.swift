import UIKit
import AlamofireImage

final class URLImageLoader {

  let downloader: ImageDownloaderType

  private(set) var status: AsyncStream<MediaImageStatus>?
  private var statusValue: MediaImageStatus = .idle {
    didSet {
      statusContinuation?.yield(statusValue)
    }
  }
  private var statusContinuation: AsyncStream<MediaImageStatus>.Continuation?

  private(set) var downloadTask: ImageStatusTask?

  init(downloader: ImageDownloaderType = CustomImageDownloader.shared) {
    self.downloader = downloader
  }

  func setUp() {
    resetStatus()
    status = AsyncStream<MediaImageStatus> { continuation in
      statusContinuation = continuation
    }
  }

  deinit {
    statusContinuation?.finish()
  }

  func loadImage(
    for urlImage: MediaURLImage,
    targetSize: ImageTargetSize = .larger
  ) async {
    let cacheKey = urlImage.cacheKey(for: targetSize)
    let imageUrl = urlImage.imageUrl(for: targetSize)

    // image did cache
    if let cachedImage = downloader.imageCache?.image(withIdentifier: cacheKey) {
      statusValue = .loaded(cachedImage)
      return
    }

    // in progress or failed
    if let task = downloadTask {
      do {
        let status = try await task.value
        statusValue = status
      } catch {
        statusValue = .failed(error)
      }
      downloadTask = nil
      return
    }

    // create task
    downloadTask = Task.detached { [weak self] in
      return try await withCheckedThrowingContinuation { continuation in

        self?.downloader.download(
          URLRequest(url: imageUrl),
          cacheKey: cacheKey,
          progress: { progress in
            self?.statusValue = .loading(progress)
          },
          completion: { result in
            switch result {
            case .success(let image):
              continuation.resume(returning: .loaded(image))
            case .failure(let error):
              continuation.resume(returning: .failed(error))
            }
          }
        )
      }
    }

    do {
      let status = try await downloadTask!.value
      if case let .loaded(image) = status {
        downloader.imageCache?.add(image, withIdentifier: cacheKey)
      }
      statusValue = status
    } catch {
      statusValue = .failed(error)
    }

    downloadTask = nil
  }
  
  func cancelLoading(
    for urlImage: MediaURLImage,
    targetSize: ImageTargetSize = .larger
  ) {
    let cacheKey = urlImage.cacheKey(for: targetSize)
    downloader.cancelRequest(forKey: cacheKey)
    cancelTask()
  }

  func resetStatus() {
    statusContinuation?.finish()
    statusContinuation = nil
    statusValue = .idle
    status = nil
  }

  private func cancelTask() {
    downloadTask?.cancel()
    downloadTask = nil
  }
}
