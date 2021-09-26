import Photos
@testable import LBJMediaBrowser

extension MediaPHAssetVideo {
  static let mockTemplates: [MediaPHAssetVideo] = (1...3).map { id in
    return MediaPHAssetVideo(asset: .init(asset: MockPHAsset(id: id)))
  }
}
