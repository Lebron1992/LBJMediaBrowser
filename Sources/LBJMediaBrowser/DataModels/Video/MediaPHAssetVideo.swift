import Photos

public struct MediaPHAssetVideo: MediaVideoStatusEditable {

  let asset: PHAsset

  public internal(set) var status: MediaVideoStatus = .idle

  public init(asset: PHAsset) {
    guard asset.mediaType == .video else {
      fatalError("[MediaPHAssetVideo] The `asset` should be a type of video.")
    }
    self.asset = asset
  }
}
