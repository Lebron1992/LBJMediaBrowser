import UIKit
import Alamofire
import AlamofireImage

protocol URLImageDownloaderType {
  var startedDownloads: [String: Any] { get }

  func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<UIImage, Error>) -> Void) -> String?

  func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<UIImage, Error>) -> Void) -> String?

  func cancelRequest(forKey key: String)
}
