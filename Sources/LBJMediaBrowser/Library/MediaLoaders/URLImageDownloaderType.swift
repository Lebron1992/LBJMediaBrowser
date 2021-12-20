import UIKit
import Alamofire
import AlamofireImage

protocol URLImageDownloaderType {
  var startedDownloads: SafeDictionary<String, Any> { get }

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String?

  func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String?

  func cancelRequest(forKey key: String)
}
