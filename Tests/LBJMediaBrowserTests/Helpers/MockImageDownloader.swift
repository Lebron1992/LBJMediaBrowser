import UIKit
import Alamofire
import AlamofireImage
@testable import LBJMediaBrowser

struct MockImageDownloader: ImageDownloaderType {

  private let imageDownloadProgress: Float?
  private let imageDownloadResponse: UIImage?
  private let imageDownloadError: Error?
  private let progressInterval: TimeInterval
  private let completionInterval: TimeInterval

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

  func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<Image, Error>) -> Void) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {
      if let image = imageDownloadResponse {
        completion(.success(image))
      } else if let error = imageDownloadError {
        completion(.failure(error))
      }
    }

    return UUID().uuidString
  }

  func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<Image, Error>) -> Void) -> String? {

    DispatchQueue.main.asyncAfter(deadline: .now() + progressInterval) {
      if let pgs = imageDownloadProgress {
        progress?(pgs)
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {
      if let image = imageDownloadResponse {
        completion(.success(image))
      } else if let error = imageDownloadError {
        completion(.failure(error))
      }
    }

    return UUID().uuidString
  }
}
