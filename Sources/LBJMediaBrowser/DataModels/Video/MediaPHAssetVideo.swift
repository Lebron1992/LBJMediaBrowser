import Photos

public struct MediaPHAssetVideo: MediaPHAssetVideoType {

  public let id = UUID().uuidString
  public let asset: PHAsset

  public init(asset: PHAsset) {
    guard asset.mediaType == .video else {
      fatalError("[MediaPHAssetVideo] The `asset` should be a type of video.")
    }
    self.asset = asset
  }
}

extension MediaPHAssetVideo: Equatable { }
