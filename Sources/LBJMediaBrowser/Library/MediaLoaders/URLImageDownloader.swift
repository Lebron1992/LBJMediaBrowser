import Photos
import UIKit
import Alamofire
import AlamofireImage

final class URLImageDownloader: ImageDownloader {
  var startedDownloads: [String : Any] = [:]
}

extension URLImageDownloader: URLImageDownloaderType {

  public func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<UIImage, Error>) -> Void) -> String? {
   download(urlRequest, progress: nil, completion: completion)
  }

  public func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<UIImage, Error>) -> Void) -> String? {

    let receipt = download(
      urlRequest,
      cacheKey: nil,
      progress: { progress?(Float($0.completedUnitCount) / Float($0.totalUnitCount)) },
      completion: { response in
        switch response.result {
        case .success(let image):
          completion(.success(image))
        case .failure(let error):
          completion(.failure(error))
        }
      }
    )

    if let urlString = urlRequest.urlRequest?.url?.absoluteString {
      startedDownloads[urlString] = receipt
    }

    return receipt?.receiptID
  }

  func cancelRequest(forKey key: String) {
    guard let receipt = startedDownloads[key] as? RequestReceipt else {
      return
    }
    startedDownloads.removeValue(forKey: key)
    cancelRequest(with: receipt)
  }
}
