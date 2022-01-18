import Photos
import UIKit

extension PHImageManager: PHImageManagerType {

  func requestImage(
    for asset: PHAsset,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> PHImageRequestID {

    requestImage(
      for: asset,
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

  func requestImageData(
    for asset: PHAsset,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<Data, Error>) -> Void
  ) -> PHImageRequestID {
    requestImageDataAndOrientation(for: asset, options: options) { imageData, _, _, info in
      if let imageData = imageData {
        completion(.success(imageData))
      } else if let error = info?[PHImageErrorKey] as? Error {
        completion(.failure(error))
      } else {
        completion(.failure(NSError.unknownError))
      }
    }
  }

  func requestAVAsset(
    forVideo asset: PHAsset,
    options: PHVideoRequestOptions?,
    completion: @escaping (Result<URL, Error>) -> Void
  ) -> PHImageRequestID {
    requestAVAsset(
      forVideo: asset,
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
