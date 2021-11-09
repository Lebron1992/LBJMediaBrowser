import Photos
import UIKit
import Alamofire
import AlamofireImage

final class CustomImageDownloader: ImageDownloader {
  static let shared = CustomImageDownloader()

  var startedDownloads: [URL : Any] = [:]
}

extension CustomImageDownloader: ImageDownloaderType {

  public func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<UIImage, Error>) -> Void) -> String? {

    let receipt = download(urlRequest, cacheKey: nil, progress: nil, completion: { response in
      switch response.result {
      case .success(let image):
        completion(.success(image))
      case .failure(let error):
        completion(.failure(error))
      }
    })

    if let url = urlRequest.urlRequest?.url {
      startedDownloads[url] = receipt
    }

    return receipt?.receiptID
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

    if let url = urlRequest.urlRequest?.url {
      startedDownloads[url] = receipt
    }

    return receipt?.receiptID
  }

  func cancelRequest(for url: URL) {
    guard let receipt = startedDownloads[url] as? RequestReceipt else {
      return
    }
    startedDownloads.removeValue(forKey: url)
    cancelRequest(with: receipt)
  }
}
