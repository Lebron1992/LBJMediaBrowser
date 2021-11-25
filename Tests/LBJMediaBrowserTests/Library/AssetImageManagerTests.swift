import Photos
import XCTest
@testable import LBJMediaBrowser
import AlamofireImage

final class AssetImageManagerTests: BaseTestCase {

  private let mockAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))

  private var uiImage: UIImage!
  private var manager: AssetImageManager!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
  }

  override func tearDown() {
    super.tearDown()
    manager = nil
  }

  func test_setAssetImage_assetImageDidSet() {
    manager = AssetImageManager(assetImage: nil)
    XCTAssertNil(manager.assetImage)

    manager.setAssetImage(mockAssetImage, targetType: .thumbnail)

    XCTAssertEqual(manager.assetImage, mockAssetImage)
  }

  func test_setAssetImage_ignoredDuplicatedLoadedAssetImage() {
    prepare_startRequestImage(assetImage: mockAssetImage, uiImage: uiImage)
    manager.startRequestImage()

    wait(interval: 1.1) {
      // The first request completed, `requestId` is nil
      XCTAssertNil(self.manager.requestId)

      self.manager.setAssetImage(self.mockAssetImage, targetType: .thumbnail)

      XCTAssertEqual(self.manager.assetImage, self.mockAssetImage)

      // no new request started, `requestId` is nil
      XCTAssertNil(self.manager.requestId)
    }
  }

  func test_setAssetImage_startedNewRequest() {
    prepare_startRequestImage(assetImage: mockAssetImage, uiImage: uiImage)
    manager.startRequestImage()

    wait(interval: 3) {
      // The first request completed, `requestId` is nil
      XCTAssertNil(self.manager.requestId)

      let assetImage = MediaPHAssetImage(asset: PHAssetMock(id: 2, assetType: .image))
      self.manager.setAssetImage(assetImage, targetType: .thumbnail)

      XCTAssertEqual(self.manager.assetImage, assetImage)

      // new request started, `requestId` is `assetImage.asset.id`
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

  func test_startRequestImage_imageDidCache() {
    let mockAsset = PHAssetMock(id: 1, assetType: .image)
    let targetSize = CGSize(width: 100, height: 100)
    let contentMode = PHImageContentMode.aspectFill
    let assetImage = MediaPHAssetImage(asset: mockAsset, targetSize: targetSize, contentMode: contentMode)

    prepare_startRequestImage(assetImage: assetImage, uiImage: uiImage)

    manager.startRequestImage(targetType: .full)

    wait(interval: 1.1) {
      XCTAssertEqual(self.manager.imageStatus, .loaded(self.uiImage))
      XCTAssertEqual(
        self.manager.imageCache.image(withIdentifier: assetImage.cacheKey(for: .full)),
        self.uiImage
      )
    }
  }

  func test_startRequestImage_useCachedImage() {
    let imageCache = AutoPurgingImageCache()
    let assetImage = MediaPHAssetImage(
      asset: PHAssetMock(id: 1, assetType: .image),
      targetSize: .init(width: 100, height: 100),
      contentMode: .aspectFill
    )

    imageCache.add(uiImage, withIdentifier: assetImage.cacheKey(for: .full))
    manager = AssetImageManager(assetImage: assetImage, imageCache: imageCache)

    manager.startRequestImage(targetType: .full)

    XCTAssertEqual(manager.imageStatus, .loaded(uiImage))
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
