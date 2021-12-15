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

  private(set) var loadingStatus: ImageLoadingStatus?

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
  ) async throws {
    let cacheKey = urlImage.cacheKey(for: targetSize)
    let imageUrl = urlImage.imageUrl(for: targetSize)

    // image did cache
    if let cachedImage = downloader.imageCache?.image(withIdentifier: cacheKey) {
      statusValue = .loaded(cachedImage)
    }

    // in progress or failed
    if let cachedStatus = loadingStatus {
      switch cachedStatus {
      case .inProgress(let task):
        let uiImage = try await task.value
        statusValue = .loaded(uiImage)
      case .failed(let error):
        statusValue = .failed(error)
      }
    }

    // create task
    let request: Task<UIImage, Error> = Task.detached { [weak self] in
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
              continuation.resume(returning: image)
            case .failure(let error):
              continuation.resume(throwing: error)
            }
          }
        )
      }
    }

    loadingStatus = .inProgress(request)

    do {
      let result = try await request.value
      downloader.imageCache?.add(result, withIdentifier: cacheKey)
      statusValue = .loaded(result)
    } catch {
      loadingStatus = .failed(error)
      statusValue = .failed(error)
    }
  }
  
  func cancelLoading(
    for urlImage: MediaURLImage,
    targetSize: ImageTargetSize = .larger
  ) {
    let cacheKey = urlImage.cacheKey(for: targetSize)
    downloader.cancelRequest(forKey: cacheKey)
    cancelTaskIfNeeded()
  }

  func resetStatus() {
    statusContinuation?.finish()
    statusContinuation = nil
    statusValue = .idle
    status = nil
  }

  private func cancelTaskIfNeeded() {
    guard
      let cachedStatus = loadingStatus,
      case let .inProgress(task) = cachedStatus
    else {
      return
    }
    task.cancel()
    loadingStatus = nil
  }
}
