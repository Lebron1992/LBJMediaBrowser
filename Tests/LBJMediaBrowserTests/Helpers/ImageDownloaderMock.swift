import UIKit
import Alamofire
import AlamofireImage
@testable import LBJMediaBrowser

final class ImageDownloaderMock: ImageDownloaderType {

  private let imageDownloadProgress: Float?
  private let imageDownloadResponse: UIImage?
  private let imageDownloadError: Error?
  private let progressInterval: TimeInterval
  private let completionInterval: TimeInterval

  let imageCache: ImageRequestCache? = AutoPurgingImageCache()
  private(set) var startedDownloads: [String : Any] = [:]
  private var cancelledDownloads: [String] = []

  init(
    imageDownloadProgress: Float? = nil,
    imageDownloadResponse: UIImage? = nil,
    imageDownloadError: Error? = nil,
    progressInterval: TimeInterval = 1,
    completionInterval: TimeInterval = 2
  ) {
    self.imageDownloadProgress = imageDownloadProgress
    self.imageDownloadResponse = imageDownloadResponse
    self.imageDownloadError = imageDownloadError
    self.progressInterval = progressInterval
    self.completionInterval = completionInterval
  }

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!.absoluteString) == false else {
        return
      }

      if let image = self.imageDownloadResponse {
        completion(.success(image))
      } else if let error = self.imageDownloadError {
        completion(.failure(error))
      }
    }

    let urlString = urlRequest.urlRequest?.url?.absoluteString

    if let urlString = urlString {
      startedDownloads[urlString] = urlString
    }

    return urlString
  }

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String?,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + progressInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!.absoluteString) == false else {
        return
      }

      if let pgs = self.imageDownloadProgress {
        progress?(pgs)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!.absoluteString) == false else {
        return
      }

      if let image = self.imageDownloadResponse {
        completion(.success(image))
      } else if let error = self.imageDownloadError {
        completion(.failure(error))
      }
    }

    let urlString = urlRequest.urlRequest?.url?.absoluteString

    if let urlString = urlString {
      startedDownloads[urlString] = urlString
    }

    return urlString
  }

  func cancelRequest(forKey key: String) {
    cancelledDownloads.append(key)
    startedDownloads.removeValue(forKey: key)
  }
}
