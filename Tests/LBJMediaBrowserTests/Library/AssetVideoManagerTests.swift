import XCTest
@testable import LBJMediaBrowser

final class AssetVideoManagerTests: XCTestCase {

  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!

  private var manager: AssetVideoManager!

  override func tearDown() {
    super.tearDown()
    manager = nil
  }

  func test_startRequestVideoUrl_requestId() {
    prepare_startRequestVideoUrl(url: videoUrl)

    XCTAssertNil(manager.requestId)

    manager.startRequestVideoUrl()

    wait(interval: 0.5) {
      XCTAssertNotNil(self.manager.requestId)
    }

    wait(interval: 3) {
      XCTAssertNil(self.manager?.requestId)
    }
  }

  func test_startRequestVideoUrl_success() {
    prepare_startRequestVideoUrl(url: videoUrl)

    XCTAssertEqual(manager.videoStatus, .idle)

    manager.startRequestVideoUrl()

    wait(interval: 3) {
      XCTAssertEqual(
        self.manager.videoStatus,
        .loaded(previewImage: nil, videoUrl: self.videoUrl)
      )
    }
  }

  func test_startRequestVideoUrl_failed() {
    prepare_startRequestVideoUrl(error: NSError.unknownError)

    XCTAssertEqual(manager.videoStatus, .idle)

    manager.startRequestVideoUrl()

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.videoStatus, .failed(NSError.unknownError))
    }
  }

  func test_cancelRequest_requestCancelled() {
    prepare_startRequestVideoUrl(url: videoUrl)

    XCTAssertEqual(manager.videoStatus, .idle)

    manager.startRequestVideoUrl()
    wait(interval: 0.5) {
      self.manager.cancelRequest()
    }

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.videoStatus, .idle)
    }
  }
}

private extension AssetVideoManagerTests {
  func prepare_startRequestVideoUrl(url: URL? = nil, error: Error? = nil) {
    let mockAsset = MockPHAsset(id: 1)
    manager = AssetVideoManager(
      assetVideo: .init(asset: .init(asset: mockAsset)),
      manager: MockPHImageManager(requestAVAssetURLResponse: url, requestAVAssetError: error)
    )
  }
}
