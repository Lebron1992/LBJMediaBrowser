import Photos
import XCTest
@testable import LBJMediaBrowser
import AlamofireImage

final class PHAssetImageLoaderTests: BaseTestCase {

  private let mockStillAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))
  private var uiImage: UIImage!
  private var stillImageCacheKey: String!

  private let mockGifAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 2, assetType: .image, isGifImage: true))
  private var gifData: Data!
  private var gifImageCacheKey: String!

  private let targetSize: ImageTargetSize = .larger

  private let imageCache = ImageCache()
  private var imageLoader: PHAssetImageLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
    gifData = try! Data(contentsOf: url(forResource: "curry", withExtension: "gif"))

    stillImageCacheKey = mockStillAssetImage.cacheKey(for: targetSize)
    gifImageCacheKey = mockGifAssetImage.cacheKey(for: targetSize)
  }

  override func tearDown() {
    super.tearDown()
    imageLoader = nil
    imageCache.clearDiskCache(containsDirectory: true)
  }

  func test_loadStillImage_success() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockStillAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.stillImageCacheKey],
        .loaded(.still(self.uiImage))
      )
      self.imageLoader.imageCache?.image(forKey: self.stillImageCacheKey) { result in
        XCTAssertEqual(try? result.get(), .still(self.uiImage))
      }
    }
  }

  func test_loadGifImage_success() {
    createImageLoader(gifData: gifData)

    imageLoader.loadImage(for: mockGifAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.gifImageCacheKey],
        .loaded(.gif(self.gifData))
      )
      self.imageLoader.imageCache?.image(forKey: self.gifImageCacheKey) { result in
        XCTAssertEqual(try? result.get(), .gif(self.gifData))
      }
    }
  }

  func test_loadStillImage_useCachedImage() {
    createImageLoader(uiImage: uiImage, useCache: true)

    imageLoader.loadImage(for: mockStillAssetImage, targetSize: targetSize)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.stillImageCacheKey],
        .loaded(.still(self.uiImage))
      )
    }
  }

  func test_loadGifImage_useCachedImage() {
    createImageLoader(gifData: gifData, useCache: true)

    imageLoader.loadImage(for: mockGifAssetImage, targetSize: targetSize)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.gifImageCacheKey],
        .loaded(.gif(self.gifData))
      )
    }
  }

  func test_loadStillImage_failed() {
    createImageLoader(error: NSError.unknownError)

    imageLoader.loadImage(for: mockStillAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.stillImageCacheKey],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_loadGifImage_failed() {
    createImageLoader(error: NSError.unknownError, isGif: true)

    imageLoader.loadImage(for: mockGifAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.gifImageCacheKey],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_loadStillImage_requestId() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockStillAssetImage, targetSize: targetSize)

    // requestId did cache after started loading image
    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.requestIdCache[self.stillImageCacheKey],
        (self.mockStillAssetImage.asset as! PHAssetMock).id
      )
    }

    // requestId is removed after finished loading image
    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.requestIdCache[self.stillImageCacheKey])
    }
  }

  func test_loadGifImage_requestId() {
    createImageLoader(gifData: gifData)

    imageLoader.loadImage(for: mockGifAssetImage, targetSize: targetSize)

    // requestId did cache after started loading image
    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.requestIdCache[self.gifImageCacheKey],
        (self.mockGifAssetImage.asset as! PHAssetMock).id
      )
    }

    // requestId is removed after finished loading image
    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.requestIdCache[self.gifImageCacheKey])
    }
  }

  func test_cancelLoading_didCancel() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockStillAssetImage, targetSize: targetSize)

    wait(interval: 0.5) {
      self.imageLoader.cancelLoading(for: self.mockStillAssetImage, targetSize: self.targetSize)
    }

    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.statusCache[self.stillImageCacheKey])
      XCTAssertNil(self.imageLoader.requestIdCache[self.stillImageCacheKey])
    }
  }

  func test_cancelLoading_notResetLoadedStatus() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockStillAssetImage, targetSize: targetSize)

    wait(interval: 1.1) {
      self.imageLoader.cancelLoading(for: self.mockStillAssetImage, targetSize: self.targetSize)
      XCTAssertEqual(
        self.imageLoader.imageStatus(for: self.mockStillAssetImage, targetSize: self.targetSize),
        .loaded(.still(self.uiImage))
      )
    }
  }
}

private extension PHAssetImageLoaderTests {
  func createImageLoader(
    uiImage: UIImage? = nil,
    gifData: Data? = nil,
    error: Error? = nil,
    isGif: Bool = false,
    useCache: Bool = false
  ) {
    var mockAsset = mockStillAssetImage.asset as! PHAssetMock
    if gifData != nil || isGif {
      mockAsset = mockGifAssetImage.asset as! PHAssetMock
    }

    if useCache {
      if let uiImage = uiImage {
        imageCache.store(
          .still(uiImage),
          forKey: stillImageCacheKey
        )
      }
      if let gifData = gifData {
        imageCache.store(
          .gif(gifData),
          forKey: gifImageCacheKey
        )
      }
    }

    imageLoader = PHAssetImageLoader(
      manager: PHImageManagerMock(
        requestImageResults: [mockAsset: uiImage ?? gifData ?? error as Any]
      ),
      imageCache: imageCache
    )
  }
}
