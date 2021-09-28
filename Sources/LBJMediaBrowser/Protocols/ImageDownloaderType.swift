import UIKit
import Alamofire
import AlamofireImage

protocol ImageDownloaderType {
  var startedDownloads: [URL: Any] { get }

  func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<UIImage, Error>) -> Void) -> String?

  func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<UIImage, Error>) -> Void) -> String?

  func cancelRequest(for url: URL)
}
