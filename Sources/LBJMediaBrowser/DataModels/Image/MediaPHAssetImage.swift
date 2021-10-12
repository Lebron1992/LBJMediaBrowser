import Photos

public struct MediaPHAssetImage: MediaPHAssetImageType {
  
  public let id = UUID().uuidString
  public let asset: PHAsset
  public let targetSize: CGSize
  public let contentMode: PHImageContentMode
  public let thumbnailTargetSize: CGSize
  public let thumbnailContentMode: PHImageContentMode

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
    self.asset = asset
    self.targetSize = targetSize
    self.contentMode = contentMode
    self.thumbnailTargetSize = thumbnailTargetSize
    self.thumbnailContentMode = thumbnailContentMode
  }
}

extension MediaPHAssetImage {
  public enum Constant {
    public static let thumbnailTargetSize = CGSize(width: 160, height: 160)
  }
}
