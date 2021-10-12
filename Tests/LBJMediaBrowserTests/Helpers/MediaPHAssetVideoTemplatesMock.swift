import Photos
@testable import LBJMediaBrowser

extension MediaPHAssetVideo {
  static let templatesMock: [MediaPHAssetVideo] = (1...3).map {
    .init(asset: PHAssetMock(id: $0, assetType: .video))
  }
}
