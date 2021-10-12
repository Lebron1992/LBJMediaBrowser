import Photos
@testable import LBJMediaBrowser

extension MediaPHAssetImage {
  static let templatesMock: [MediaPHAssetImage] = (1...3).map {
    .init(asset: PHAssetMock(id: $0, assetType: .image))
  }
}
