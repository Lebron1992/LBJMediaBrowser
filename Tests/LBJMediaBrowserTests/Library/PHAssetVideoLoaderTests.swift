import Photos
import XCTest
@testable import LBJMediaBrowser
import AlamofireImage

final class PHAssetVideoLoaderTests: BaseTestCase {

  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!
  private let mockAssetVideo = MediaPHAssetVideo(asset: PHAssetMock(id: 1, assetType: .video))
  private var cacheKey: String!

  private var uiImage: UIImage!
  private var videoLoader: PHAssetVideoLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
    cacheKey = mockAssetVideo.cacheKey
  }

  override func tearDown() {
    super.tearDown()
    videoLoader = nil
  }

  func test_loadUrl_success() {
    createVideoLoader(uiImage: uiImage, url: videoUrl)

    videoLoader.loadUrl(for: mockAssetVideo)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.videoLoader.statusCache[self.cacheKey],
        .loaded(previewImage: self.uiImage, videoUrl: self.videoUrl)
      )
      XCTAssertEqual(
        self.videoLoader.imageCache.image(withIdentifier: self.cacheKey),
        self.uiImage
      )
      XCTAssertEqual(
        self.videoLoader.urlCache.url(withIdentifier: self.cacheKey),
        self.videoUrl
      )
    }
  }

  func test_loadUrl_useCachedImage() {
    createVideoLoader(uiImage: uiImage, url: videoUrl, useCache: true)

    videoLoader.loadUrl(for: mockAssetVideo)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.videoLoader.statusCache[self.cacheKey],
        .loaded(previewImage: self.uiImage, videoUrl: self.videoUrl)
      )
    }
  }

  func test_loadUrl_failed() {
    createVideoLoader(error: NSError.unknownError)

    videoLoader.loadUrl(for: mockAssetVideo)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.videoLoader.statusCache[self.cacheKey],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_loadUrl_requestId() {
    createVideoLoader(uiImage: uiImage, url: videoUrl)

    videoLoader.loadUrl(for: mockAssetVideo)

    // requestId did cache after started loading image
    wait(interval: 0.1) {
      XCTAssertEqual(
        self.videoLoader.requestIdCache[self.cacheKey],
        (self.mockAssetVideo.asset as! PHAssetMock).id
      )
    }

    // requestId is removed after finished loading image
    wait(interval: 1.1) {
      XCTAssertNil(self.videoLoader.requestIdCache[self.cacheKey])
    }
  }

  func test_cancelLoading() {
    createVideoLoader(uiImage: uiImage, url: videoUrl)

    videoLoader.loadUrl(for: mockAssetVideo)

    wait(interval: 0.5) {
      self.videoLoader.cancelLoading(for: self.mockAssetVideo)
    }

    wait(interval: 1.1) {
      XCTAssertNil(self.videoLoader.statusCache[self.cacheKey])
      XCTAssertNil(self.videoLoader.requestIdCache[self.cacheKey])
    }
  }
}

private extension PHAssetVideoLoaderTests {
  func createVideoLoader(uiImage: UIImage? = nil, url: URL? = nil, error: Error? = nil, useCache: Bool = false) {
    let imageCache = AutoPurgingImageCache()
    let urlCache = LBJURLCache()

    if useCache, let uiImage = uiImage, let url = url {
      imageCache.add(uiImage, withIdentifier: cacheKey)
      urlCache.add(url, withIdentifier: cacheKey)
    }

    videoLoader = PHAssetVideoLoader(
      manager: PHImageManagerMock(requestAVAssetURLResponse: url, requestAVAssetError: error),
      thumbnailGenerator: ThumbnailGeneratorMock(uiImage),
      imageCache: imageCache,
      urlCache: urlCache
    )
  }
}
