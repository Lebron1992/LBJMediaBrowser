import XCTest
@testable import LBJMediaBrowser

final class AssetImageManagerTests: XCTestCase {

  private let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!

  private var manager: AssetImageManager!

  override func tearDown() {
    super.tearDown()
    manager = nil
  }

  func test_startRequestImage_requestId() {
    prepare_startRequestImage()

    XCTAssertNil(manager.requestId)

    manager.startRequestImage()

    wait(interval: 0.5) {
      XCTAssertNotNil(self.manager.requestId)
    }

    wait(interval: 1.1) {
      XCTAssertNil(self.manager.requestId)
    }
  }

  func test_startRequestImage_success() {
    prepare_startRequestImage(uiImage: uiImage)

    XCTAssertEqual(manager.imageStatus, .idle)

    manager.startRequestImage()

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.imageStatus, .loaded(self.uiImage))
    }
  }

  func test_startRequestImage_failed() {
    prepare_startRequestImage(error: NSError.unknownError)

    XCTAssertEqual(manager.imageStatus, .idle)

    manager.startRequestImage()

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.imageStatus, .failed(NSError.unknownError))
    }
  }

  func test_cancelRequest_requestCancelled() {
    prepare_startRequestImage(uiImage: uiImage)

    XCTAssertEqual(manager.imageStatus, .idle)

    manager.startRequestImage()
    wait(interval: 0.5) {
      self.manager.cancelRequest()
    }

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.imageStatus, .idle)
    }
  }

  func test_reset() {
    prepare_startRequestImage(uiImage: uiImage)

    XCTAssertEqual(manager.imageStatus, .idle)

    manager.startRequestImage()

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.imageStatus, .loaded(self.uiImage))
    }

    manager.reset()

    XCTAssertEqual(manager.imageStatus, .idle)
    XCTAssertNil(manager.requestId)
  }
}

private extension AssetImageManagerTests {
  func prepare_startRequestImage(uiImage: UIImage? = nil, error: Error? = nil) {
    let mockAsset = MockPHAsset(id: 1)
    manager = AssetImageManager(
      assetImage: .init(asset: .init(asset: mockAsset)),
      manager: MockPHImageManager(requestImageResults: [mockAsset: uiImage ?? error as Any])
    )
  }
}
