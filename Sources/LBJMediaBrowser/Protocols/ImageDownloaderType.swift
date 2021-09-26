import Alamofire
import AlamofireImage

protocol ImageDownloaderType {
  func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<Image, Error>) -> Void) -> String?

  func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<Image, Error>) -> Void) -> String?
}

extension ImageDownloader: ImageDownloaderType {

  public func download(_ urlRequest: URLRequestConvertible, completion: @escaping (Result<Image, Error>) -> Void) -> String? {

    let receipt = download(urlRequest, cacheKey: nil, progress: nil, completion: { response in
      switch response.result {
      case .success(let image):
        completion(.success(image))
      case .failure(let error):
        completion(.failure(error))
      }
    })

    return receipt?.receiptID
  }

  public func download(_ urlRequest: URLRequestConvertible, progress: ((Float) -> Void)?, completion: @escaping (Result<Image, Error>) -> Void) -> String? {

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

    return receipt?.receiptID
  }

}
