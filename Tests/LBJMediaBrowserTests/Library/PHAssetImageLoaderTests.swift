import Photos
import XCTest
@testable import LBJMediaBrowser
import AlamofireImage

final class PHAssetImageLoaderTests: BaseTestCase {

  private let mockAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))
  private let targetSize: ImageTargetSize = .larger
  private var cacheKey: String!

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
  }

  func test_loadImage_success() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.imageStatusCache[self.cacheKey],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.imageLoader.imageCache.image(withIdentifier: self.cacheKey),
        self.uiImage
      )
    }
  }

  func test_loadImage_useCachedImage() {
    createImageLoader(uiImage: uiImage, useCache: true)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.imageStatusCache[self.cacheKey],
        .loaded(self.uiImage)
      )
    }
  }

  func test_loadImage_failed() {
    createImageLoader(error: NSError.unknownError)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.imageStatusCache[self.cacheKey],
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

  func test_cancelLoading() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockAssetImage, targetSize: targetSize)

    wait(interval: 0.5) {
      self.imageLoader.cancelLoading(for: self.mockAssetImage, targetSize: self.targetSize)
    }

    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.imageStatusCache[self.cacheKey])
      XCTAssertNil(self.imageLoader.requestIdCache[self.cacheKey])
    }
  }

}

private extension PHAssetImageLoaderTests {
  func createImageLoader(uiImage: UIImage? = nil, error: Error? = nil, useCache: Bool = false) {
    let mockAsset = mockAssetImage.asset as! PHAssetMock
    let imageCache = AutoPurgingImageCache()

    if useCache, let uiImage = uiImage {
      imageCache.add(
        uiImage,
        withIdentifier: mockAssetImage.cacheKey(for: targetSize)
      )
    }

    imageLoader = PHAssetImageLoader(
      manager: PHImageManagerMock(requestImageResults: [mockAsset: uiImage ?? error as Any]),
      imageCache: imageCache
    )
  }
}
