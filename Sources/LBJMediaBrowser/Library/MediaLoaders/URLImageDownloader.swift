import Photos
import UIKit
import Alamofire
import AlamofireImage

final class URLImageDownloader: ImageDownloader {
  var startedDownloads = SafeDictionary<String, Any>()
}

extension URLImageDownloader: URLImageDownloaderType {

  public func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    completion: @escaping (Result<ImageLoadedResult, Error>) -> Void
  ) -> String? {
    download(urlRequest, cacheKey: cacheKey, progress: nil, completion: completion)
  }

  public func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<ImageLoadedResult, Error>) -> Void
  ) -> String? {

    let receipt = download(
      urlRequest,
      cacheKey: nil,
      progress: { progress?(Float($0.completedUnitCount) / Float($0.totalUnitCount)) },
      completion: { response in

        switch response.result {
        case .success(let image):
          if let data = response.data, UIImage.isAnimatedImage(for: data) {
            completion(.success(.gif(data)))
          } else {
            completion(.success(.still(image)))
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
    )

    startedDownloads[cacheKey] = receipt

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
