import Photos

public struct MediaPHAssetVideo: MediaVideoStatusEditable {

  let asset: PHAssetWrapper

  public internal(set) var status: MediaVideoStatus = .idle

  public init(asset: PHAsset) {
    guard asset.mediaType == .video else {
      fatalError("[MediaPHAssetVideo] The `asset` should be a type of video.")
    }
    self.asset = PHAssetWrapper(asset: asset)
  }

  // for test
  init(asset: PHAssetWrapper, status: MediaVideoStatus = .idle) {
    self.asset = asset
    self.status = status
  }
}

extension MediaPHAssetVideo {
  // We don't implement `Equatable` to make sure SwiftUI can trigger view update after `status` changed
  func isTheSameAs(_ another: MediaPHAssetVideo) -> Bool {
    asset.id == another.asset.id
  }
}
