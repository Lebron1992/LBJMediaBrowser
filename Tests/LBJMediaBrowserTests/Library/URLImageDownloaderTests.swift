import XCTest
import AlamofireImage
@testable import LBJMediaBrowser

final class URLImageLoaderTests: BaseTestCase {

  private let mockUrlImage = MediaURLImage(
    imageUrl: URL(string: "https://www.example.com/test.png")!,
    thumbnailUrl: URL(string: "https://www.example.com/thumbnail.png")!
  )
  private let targetSize: ImageTargetSize = .larger
  private let progress: Float = 0.5

  private let imageCache = ImageCache()
  private var cacheKey: String!
  private var uiImage: UIImage!
  private var imageLoader: URLImageLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
    cacheKey = mockUrlImage.cacheKey(for: targetSize)
  }

  override func tearDown() {
    super.tearDown()
    imageLoader = nil
    imageCache.clearDiskCache(containsDirectory: true)
  }

  func test_loadImage_success() {
    createImageLoader(progress: progress, uiImage: uiImage)

    imageLoader.loadImage(for: mockUrlImage, targetSize: targetSize)

    wait(interval: 0.6) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .loading(self.progress)
      )
    }

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

    imageLoader.loadImage(for: mockUrlImage, targetSize: targetSize)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .loaded(.still(self.uiImage))
      )
    }
  }

  func test_loadImage_failed() {
    createImageLoader(error: NSError.unknownError)

    imageLoader.loadImage(for: mockUrlImage, targetSize: targetSize)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_loadImage_requestId() {
    createImageLoader(uiImage: uiImage)

    imageLoader.loadImage(for: mockUrlImage, targetSize: targetSize)

    // requestId did cache after started loading image
    wait(interval: 0.1) {
      XCTAssertEqual(
        self.imageLoader.requestIdCache[self.cacheKey],
        self.cacheKey
      )
    }

    // requestId is removed after finished loading image
    wait(interval: 1.1) {
      XCTAssertNil(self.imageLoader.requestIdCache[self.cacheKey])
    }
  }

  func test_cancelLoading_didCancel() {
    createImageLoader(progress: progress, uiImage: uiImage)

    imageLoader.loadImage(for: mockUrlImage, targetSize: targetSize)

    wait(interval: 0.6) {
      XCTAssertEqual(
        self.imageLoader.statusCache[self.cacheKey],
        .loading(self.progress)
      )
      XCTAssertNotNil(self.imageLoader.requestIdCache[self.cacheKey])
    }

    wait(interval: 0.1) {
      self.imageLoader.cancelLoading(for: self.mockUrlImage, targetSize: self.targetSize)
    }

    wait(interval: 0.4) {
      XCTAssertNil(self.imageLoader.statusCache[self.cacheKey])
      XCTAssertNil(self.imageLoader.requestIdCache[self.cacheKey])
    }
  }

  func test_cancelLoading_notResetLoadedStatus() {
    createImageLoader(progress: progress, uiImage: uiImage)

    imageLoader.loadImage(for: mockUrlImage, targetSize: targetSize)

    wait(interval: 1.1) {
      self.imageLoader.cancelLoading(for: self.mockUrlImage, targetSize: self.targetSize)
      XCTAssertEqual(
        self.imageLoader.imageStatus(for: self.mockUrlImage, targetSize: self.targetSize),
        .loaded(.still(self.uiImage))
      )
    }
  }
}

private extension URLImageLoaderTests {
  func createImageLoader(progress: Float? = nil, uiImage: UIImage? = nil, error: Error? = nil, useCache: Bool = false) {

    if useCache, let uiImage = uiImage {
      imageCache.store(.still(uiImage), forKey: mockUrlImage.cacheKey(for: targetSize))
    }

    imageLoader = URLImageLoader(
      downloader: ImageDownloaderMock(
        imageDownloadProgress: progress,
        imageDownloadResponse: uiImage,
        imageDownloadError: error
      ),
      imageCache: imageCache
    )
  }
}
