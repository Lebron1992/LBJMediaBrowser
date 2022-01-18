import Photos
import UIKit

protocol PHImageManagerType {
  func requestImage(
    for asset: PHAsset,
    targetSize: CGSize,
    contentMode: PHImageContentMode,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<UIImage, Error>) -> Void
  ) -> PHImageRequestID

  func requestImageData(
    for asset: PHAsset,
    options: PHImageRequestOptions?,
    completion: @escaping (Result<Data, Error>) -> Void
  ) -> PHImageRequestID

  func requestAVAsset(
    forVideo asset: PHAsset,
    options: PHVideoRequestOptions?,
    completion: @escaping (Result<URL, Error>) -> Void
  ) -> PHImageRequestID

  func cancelImageRequest(_ requestID: PHImageRequestID)
}
