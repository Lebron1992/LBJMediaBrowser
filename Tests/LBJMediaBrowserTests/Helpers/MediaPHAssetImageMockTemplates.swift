import Photos
@testable import LBJMediaBrowser

extension MediaPHAssetImage {
  static let mockTemplates: [MediaPHAssetImage] = (1...3).map { id in
    return MediaPHAssetImage(
      asset: .init(asset: MockPHAsset(id: id)),
      targetSize: PHImageManagerMaximumSize,
      contentMode: .aspectFit
    )
  }
}
