import Photos

public protocol MediaPHAssetImageType: MediaImageType {
  var asset: PHAsset { get }
  var targetSize: CGSize { get }
  var contentMode: PHImageContentMode { get }
  var thumbnailTargetSize: CGSize { get }
  var thumbnailContentMode: PHImageContentMode { get }
}
