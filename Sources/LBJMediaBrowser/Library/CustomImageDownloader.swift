import Photos
import UIKit
import Alamofire
import AlamofireImage

final class CustomImageDownloader: ImageDownloader {
  static let shared = CustomImageDownloader(imageCache: AutoPurgingImageCache.shared)

  var startedDownloads: [String : Any] = [:]
}

extension CustomImageDownloader: ImageDownloaderType {

  public func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String? {
    download(urlRequest, cacheKey: cacheKey, progress: nil) { result in
      switch result {
      case .success(let image):
        completion(.success(image))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func download(
    _ urlRequest: URLRequestConvertible,
    cacheKey: String?,
    progress: ((Float) -> Void)?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> String? {
    let cacheKey = urlRequest.urlRequest?.url?.absoluteString ?? ""

    let receipt = download(
      urlRequest,
      cacheKey: cacheKey,
      progress: { progress?(Float($0.completedUnitCount) / Float($0.totalUnitCount)) },
      completion: { [weak self] response in

        switch response.result {
        case .success(let image):
          completion(.success(image))
        case .failure(let error):
          completion(.failure(error))
        }
        
        self?.startedDownloads.removeValue(forKey: cacheKey)
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
