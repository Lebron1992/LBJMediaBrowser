import UIKit
import Alamofire
import AlamofireImage

protocol ImageDownloaderType {

  var imageCache: ImageRequestCache? { get }

  var startedDownloads: [String: Any] { get }

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String?

  @discardableResult
  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String?,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String?

  func cancelRequest(forKey key: String)
}
