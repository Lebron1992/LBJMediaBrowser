import XCTest
@testable import LBJMediaBrowser

final class AssetImageManagerTests: XCTestCase {

  private let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!

  private var manager: AssetImageManager!

  override func tearDown() {
    super.tearDown()
    manager = nil
  }

  func test_setAssetImage_assetImageDidSet() {
    manager = AssetImageManager(assetImage: nil)
    XCTAssertNil(manager.assetImage)

    let assetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))
    manager.setAssetImage(assetImage)

    XCTAssertEqual(manager.assetImage, assetImage)
  }

  func test_setAssetImage_ignoredDuplicatedLoadedAssetImage() {
    let assetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))

    prepare_startRequestImage(assetImage: assetImage, uiImage: uiImage)
    manager.startRequestImage()

    wait(interval: 1.1) {
      // The first request completed, `requestId` is nil
      XCTAssertNil(self.manager.requestId)

      self.manager.setAssetImage(assetImage)

      XCTAssertEqual(self.manager.assetImage, assetImage)

      // no new request started, `requestId` is nil
      XCTAssertNil(self.manager.requestId)
    }
  }

  func test_setAssetImage_startedNewRequest() {
    prepare_startRequestImage()
    manager.startRequestImage()

    wait(interval: 1.1) {
      // The first request completed, `requestId` is nil
      XCTAssertNil(self.manager.requestId)

      let assetImage = MediaPHAssetImage(asset: PHAssetMock(id: 2, assetType: .image))
      self.manager.setAssetImage(assetImage)

      XCTAssertEqual(self.manager.assetImage, assetImage)

      // new request started, `requestId` is `assetImage.id`
      XCTAssertEqual(self.manager.requestId, 2)
    }
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
  func prepare_startRequestImage(assetImage: MediaPHAssetImage? = nil, uiImage: UIImage? = nil, error: Error? = nil) {
    let mockAsset = PHAssetMock(id: 1, assetType: .image)
    let finalAssetImage = assetImage ?? MediaPHAssetImage(asset: mockAsset)
    let finalMockAsset = finalAssetImage.asset as! PHAssetMock
    manager = AssetImageManager(
      assetImage: finalAssetImage,
      manager: PHImageManagerMock(requestImageResults: [finalMockAsset: uiImage ?? error as Any])
    )
  }
}
