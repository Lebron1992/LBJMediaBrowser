import Photos
import UIKit

protocol PHImageManagerType {
  func requestImage(
    for asset: PHAssetType,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> PHImageRequestID

  func requestAVAsset(
    forVideo asset: PHAssetType,
    options: PHVideoRequestOptions?,
    completion: @escaping (Result<URL, Error>) -> Void
  ) -> PHImageRequestID

  func cancelImageRequest(_ requestID: PHImageRequestID)
}

extension PHImageManager: PHImageManagerType {

  func requestImage(
    for asset: PHAssetType,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> PHImageRequestID {

    requestImage(
      for: asset as! PHAsset,
      targetSize: targetSize,
      contentMode: contentMode,
      options: options
    ) { image, info in

      if let image = image {
        completion(.success(image))
      } else if let error = info?[PHImageErrorKey] as? Error {
        completion(.failure(error))
      } else {
        completion(.failure(NSError.unknownError))
      }
    }
  }

  func requestAVAsset(
    forVideo asset: PHAssetType,
    options: PHVideoRequestOptions?,
    completion: @escaping (Result<URL, Error>) -> Void
  ) -> PHImageRequestID {
    requestAVAsset(
      forVideo: asset as! PHAsset,
      options: options
    ) { asset, _, info in

      if let urlAsset = asset as? AVURLAsset {
        completion(.success(urlAsset.url))
      } else if let error = info?[PHImageErrorKey] as? Error {
        completion(.failure(error))
      } else {
        completion(.failure(NSError.unknownError))
      }
    }
  }
}
