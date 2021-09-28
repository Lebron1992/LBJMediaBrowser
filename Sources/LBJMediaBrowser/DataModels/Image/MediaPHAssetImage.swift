import Photos

public struct MediaPHAssetImage: MediaImageStatusEditable {

  let asset: PHAssetWrapper
  let targetSize: CGSize
  let contentMode: PHImageContentMode
  let thumbnailTargetSize: CGSize
  let thumbnailContentMode: PHImageContentMode

  public internal(set) var status: MediaImageStatus = .idle

  public init(
    asset: PHAsset,
    targetSize: CGSize = PHImageManagerMaximumSize,
    contentMode: PHImageContentMode = .aspectFit,
    thumbnailTargetSize: CGSize = Constant.thumbnailTargetSize,
    thumbnailContentMode: PHImageContentMode = .aspectFill
  ) {
    guard asset.mediaType == .image else {
      fatalError("[MediaPHAssetImage] The `asset` should be a type of image.")
    }
    self.asset = PHAssetWrapper(asset: asset)
    self.targetSize = targetSize
    self.contentMode = contentMode
    self.thumbnailTargetSize = thumbnailTargetSize
    self.thumbnailContentMode = thumbnailContentMode
  }

  // for test
  init(
    asset: PHAssetWrapper,
    targetSize: CGSize = PHImageManagerMaximumSize,
    contentMode: PHImageContentMode = .aspectFit,
    thumbnailTargetSize: CGSize = Constant.thumbnailTargetSize,
    thumbnailContentMode: PHImageContentMode = .aspectFill,
    status: MediaImageStatus = .idle
  ) {
    self.asset = asset
    self.targetSize = targetSize
    self.contentMode = contentMode
    self.thumbnailTargetSize = thumbnailTargetSize
    self.thumbnailContentMode = thumbnailContentMode
    self.status = status
  }
}

private extension MediaPHAssetImage {
  public enum Constant {
    public static let thumbnailTargetSize = CGSize(width: 160, height: 160)
  }
}
