import UIKit
import Alamofire
import AlamofireImage
@testable import LBJMediaBrowser

final class ImageDownloaderMock: URLImageDownloaderType {

  private let imageDownloadProgress: Float?
  private let imageDownloadResponse: UIImage?
  private let imageDownloadError: Error?
  private let progressInterval: TimeInterval
  private let completionInterval: TimeInterval

  private(set) var startedDownloads = SafeDictionary<String, Any>()
  private var cancelledDownloads: [String] = []

  init(
    imageDownloadProgress: Float? = nil,
    imageDownloadResponse: UIImage? = nil,
    imageDownloadError: Error? = nil,
    progressInterval: TimeInterval = 0.5,
    completionInterval: TimeInterval = 1
  ) {
    self.imageDownloadProgress = imageDownloadProgress
    self.imageDownloadResponse = imageDownloadResponse
    self.imageDownloadError = imageDownloadError
    self.progressInterval = progressInterval
    self.completionInterval = completionInterval
  }

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    completion: @escaping (Result<ImageLoadedResult, Error>) -> Void
  ) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!.absoluteString) == false else {
        return
      }

      if let image = self.imageDownloadResponse {
        completion(.success(.still(image)))
      } else if let error = self.imageDownloadError {
        completion(.failure(error))
      }
    }

    return cacheKey
  }

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<ImageLoadedResult, Error>) -> Void
  ) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + progressInterval) {

      guard self.cancelledDownloads.contains(cacheKey) == false else {
        return
      }

      if let pgs = self.imageDownloadProgress {
        progress?(pgs)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledDownloads.contains(cacheKey) == false else {
        return
      }

      if let image = self.imageDownloadResponse {
        completion(.success(.still(image)))
      } else if let error = self.imageDownloadError {
        completion(.failure(error))
      }
    }

    return cacheKey
  }

  func cancelRequest(forKey key: String) {
    cancelledDownloads.append(key)
  }
}
