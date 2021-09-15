import Photos

public struct MediaPHAsset: MediaStatusEditable {

  let phAsset: PHAsset
  let targetSize: CGSize
  let contentMode: PHImageContentMode

  public internal(set) var status: MediaStatus = .idle

  public init(
    phAsset: PHAsset,
    targetSize: CGSize = PHImageManagerMaximumSize,
    contentMode: PHImageContentMode = .aspectFit
  ) {
    self.phAsset = phAsset
    self.targetSize = targetSize
    self.contentMode = contentMode
  }
}

// MARK: - Getters
extension MediaPHAsset {
  var isLoaded: Bool {
    switch status {
    case .loaded: return true
    default: return false
    }
  }
}
