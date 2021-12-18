import XCTest
@testable import LBJMediaBrowser

final class MediaPHAssetImageTests: XCTestCase {
  private let mockAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))

  func test_cacheKey() {
    XCTAssertEqual(
      mockAssetImage.cacheKey(for: .thumbnail),
      "\(mockAssetImage.asset.localIdentifier)-\(mockAssetImage.thumbnailTargetSize)-\(mockAssetImage.thumbnailContentMode.stringRepresentation)"
    )

    XCTAssertEqual(
      mockAssetImage.cacheKey(for: .larger),
      "\(mockAssetImage.asset.localIdentifier)-\(mockAssetImage.targetSize)-\(mockAssetImage.contentMode.stringRepresentation)"
    )
  }

  func test_targetSize() {
    XCTAssertEqual(
      mockAssetImage.targetSize(for: .thumbnail),
      mockAssetImage.thumbnailTargetSize
    )

    XCTAssertEqual(
      mockAssetImage.targetSize(for: .larger),
      mockAssetImage.targetSize
    )
  }

  func test_contentMode() {
    XCTAssertEqual(
      mockAssetImage.contentMode(for: .thumbnail),
      mockAssetImage.thumbnailContentMode
    )

    XCTAssertEqual(
      mockAssetImage.contentMode(for: .larger),
      mockAssetImage.contentMode
    )
  }
}
