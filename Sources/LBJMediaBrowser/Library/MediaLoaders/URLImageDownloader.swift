import Photos
import UIKit
import Alamofire
import AlamofireImage

final class URLImageDownloader: ImageDownloader {
  var startedDownloads: [String : Any] = [:]
}

extension URLImageDownloader: URLImageDownloaderType {

  public func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String? {
    download(urlRequest, cacheKey: cacheKey, progress: nil, completion: completion)
  }

  public func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String? {

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

    safelyUpdateReceipt(receipt, forKey: cacheKey)

    return receipt?.receiptID
  }

  func cancelRequest(forKey key: String) {
    guard let receipt = startedDownloads[key] as? RequestReceipt else {
      return
    }
    safelyUpdateReceipt(nil, forKey: key)
    cancelRequest(with: receipt)
  }

  private static let lock = NSLock()

  private func safelyUpdateReceipt(_ receipt: RequestReceipt?, forKey key: String) {
    Self.lock.lock()
    defer {
      Self.lock.unlock()
    }

    if let receipt = receipt {
      startedDownloads[key] = receipt
    } else {
      startedDownloads.removeValue(forKey: key)
    }
  }
}
