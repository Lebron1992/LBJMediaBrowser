import Photos
import UIKit
@testable import LBJMediaBrowser

final class MockPHImageManager: PHImageManagerType {

  /// the value is UIImage or Error
  private let requestImageResults: [MockPHAsset: Any]?
  private let requestAVAssetURLResponse: URL?
  private let requestAVAssetError: Error?
  private let completionInterval: TimeInterval

  private var cancelledImageRequests: [PHImageRequestID] = []

  init(
    requestImageResults: [MockPHAsset: Any]? = nil,
    requestAVAssetURLResponse: URL? = nil,
    requestAVAssetError: Error? = nil,
    completionInterval: TimeInterval = 1
  ) {
    self.requestImageResults = requestImageResults
    self.requestAVAssetURLResponse = requestAVAssetURLResponse
    self.requestAVAssetError = requestAVAssetError
    self.completionInterval = completionInterval
  }

  func requestImage(
    for asset: PHAssetType,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> PHImageRequestID {
    let mockAsset = asset as! MockPHAsset

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledImageRequests.contains(mockAsset.id) == false else {
        return
      }

      if let image = self.requestImageResults?[mockAsset] as? UIImage {
        completion(.success(image))
      } else if let error = self.requestImageResults?[mockAsset] as? Error {
        completion(.failure(error))
      } else {
        completion(.failure(NSError.unknownError))
      }
    }

    return mockAsset.id
  }

  func requestAVAsset(
    forVideo asset: PHAssetType,
    options: PHVideoRequestOptions?,
    completion: @escaping (Result<URL, Error>) -> Void
  ) -> PHImageRequestID {
    let mockAsset = asset as! MockPHAsset

    DispatchQueue.main.asyncAfter(deadline: .now() + completionInterval) {

      guard self.cancelledImageRequests.contains(mockAsset.id) == false else {
        return
      }

      if let url = self.requestAVAssetURLResponse {
        completion(.success(url))
      } else if let error = self.requestAVAssetError {
        completion(.failure(error))
      } else {
        completion(.failure(NSError.unknownError))
      }
    }

    return mockAsset.id
  }

  func cancelImageRequest(_ requestID: PHImageRequestID) {
    cancelledImageRequests.append(requestID)
  }
}
