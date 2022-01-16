import Photos
import XCTest
@testable import LBJMediaBrowser
import AlamofireImage

final class PHAssetImageLoaderTests: BaseTestCase {

  private let mockAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))
  private let targetSize: ImageTargetSize = .larger
  private var cacheKey: String!

  private let imageCache = ImageCache()
  private var uiImage: UIImage!
  private var imageLoader: PHAssetImageLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
    cacheKey = mockAssetImage.cacheKey(for: targetSize)
  }

  override func tearDown() {
    super.tearDown()
    imageLoader = nil
    imageCache.clearDiskCache(containsDirectory: true)
  }

  func test_loadImage_success() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .loaded(.still(self.uiImage))
      )
      self.imageLoader.imageCache?.image(forKey: self.cacheKey) { result in
        XCTAssertEqual(try? result.get(), .still(self.uiImage))
      }
    }
  }

  func test_loadImage_useCachedImage() {
    createImageLoader(uiImage: uiImage, useCache: true)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .loaded(.still(self.uiImage))
      )
    }
  }

  func test_loadImage_failed() {
    createImageLoader(error: NSError.unknownError)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_loadImage_requestId() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    // requestId did cache after started loading image
    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.requestIdCache[self.cacheKey],
        (self.mockAssetImage.asset as! PHAssetMock).id
      )
    }

    // requestId is removed after finished loading image
    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.requestIdCache[self.cacheKey])
    }
  }

  func test_cancelLoading_didCancel() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 0.5) {
      self.imageLoader.cancelLoading(for: self.mockAssetImage, targetSize: self.targetSize)
    }

    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.statusCache[self.cacheKey])
      XCTAssertNil(self.imageLoader.requestIdCache[self.cacheKey])
    }
  }

  func test_cancelLoading_notResetLoadedStatus() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      self.imageLoader.cancelLoading(for: self.mockAssetImage, targetSize: self.targetSize)
      XCTAssertEqual(
        self.imageLoader.imageStatus(for: self.mockAssetImage, targetSize: self.targetSize),
        .loaded(.still(self.uiImage))
      )
    }
  }
}

private extension PHAssetImageLoaderTests {
  func createImageLoader(uiImage: UIImage? = nil, error: Error? = nil, useCache: Bool = false) {
    let mockAsset = mockAssetImage.asset as! PHAssetMock

    if useCache, let uiImage = uiImage {
      imageCache.store(
        .still(uiImage),
        forKey: mockAssetImage.cacheKey(for: targetSize)
      )
    }

    imageLoader = PHAssetImageLoader(
      manager: PHImageManagerMock(requestImageResults: [mockAsset: uiImage ?? error as Any]),
      imageCache: imageCache
    )
  }
}
