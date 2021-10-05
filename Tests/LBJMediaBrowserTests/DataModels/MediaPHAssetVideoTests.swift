import XCTest
@testable import LBJMediaBrowser

final class MediaPHAssetVideoTests: XCTestCase {
  func test_isTheSameAs() {
    let v1 = MediaPHAssetVideo(asset: .init(id: "1", asset: MockPHAsset(id: 1)))
    let v2 = MediaPHAssetVideo(asset: .init(id: "2", asset: MockPHAsset(id: 2)))
    XCTAssertTrue(v1.isTheSameAs(v1))
    XCTAssertFalse(v1.isTheSameAs(v2))
  }
}
