@testable import LBJMediaBrowser

extension PHAssetImageRequest {
  static let template = PHAssetImageRequest(
    asset: PHAssetMock(id: 1, assetType: .image),
    targetSize: .init(width: 100, height: 100),
    contentMode: .aspectFill
  )
}
