import UIKit
import Alamofire
import AlamofireImage
@testable import LBJMediaBrowser

final class MockImageDownloader: ImageDownloaderType {

  private let imageDownloadProgress: Float?
  private let imageDownloadResponse: UIImage?
  private let imageDownloadError: Error?
  private let progressInterval: TimeInterval
  private let completionInterval: TimeInterval

  private(set) var startedDownloads: [URL : Any] = [:]
  private var cancelledDownloads: [URL] = []

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

  func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<UIImage, Error>) -> Void) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!) == false else {
        return
      }

      if let image = self.imageDownloadResponse {
        completion(.success(image))
      } else if let error = self.imageDownloadError {
        completion(.failure(error))
      }
    }

    return UUID().uuidString
  }

  func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<UIImage, Error>) -> Void) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + progressInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!) == false else {
        return
      }

      if let pgs = self.imageDownloadProgress {
        progress?(pgs)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledDownloads.contains(urlRequest.urlRequest!.url!) == false else {
        return
      }

      if let image = self.imageDownloadResponse {
        completion(.success(image))
      } else if let error = self.imageDownloadError {
        completion(.failure(error))
      }
    }

    return UUID().uuidString
  }

  func cancelRequest(for url: URL) {
    cancelledDownloads.append(url)
  }
}
