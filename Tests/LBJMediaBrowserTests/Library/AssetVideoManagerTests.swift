import XCTest
@testable import LBJMediaBrowser
import AlamofireImage

final class AssetVideoManagerTests: BaseTestCase {

  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!
  private let mockAssetVideo = MediaPHAssetVideo(asset: PHAssetMock(id: 1, assetType: .video))

  private var uiImage: UIImage!
  private var manager: AssetVideoManager!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
  }

  override func tearDown() {
    super.tearDown()
    manager = nil
  }

  func testSetAssetVideo_assetVideoDidSet() {
    manager = AssetVideoManager(assetVideo: nil)
    XCTAssertNil(manager.assetVideo)

    manager.setAssetVideo(mockAssetVideo)

    XCTAssertEqual(manager.assetVideo, mockAssetVideo)
  }

  func test_setAssetVideo_ignoredDuplicatedLoadedAssetVideo() {
    prepare_startRequestVideoUrl(assetVideo: mockAssetVideo, url: videoUrl)
    manager.startRequestVideoUrl()

    wait(interval: 3) {
      // The first request completed, `requestId` is nil
      XCTAssertNil(self.manager.requestId)

      self.manager.setAssetVideo(self.mockAssetVideo)

      XCTAssertEqual(self.manager.assetVideo, self.mockAssetVideo)

      // no new request started, `requestId` is nil
      XCTAssertNil(self.manager.requestId)
    }
  }

  func test_setAssetVideo_startedNewRequest() {
    prepare_startRequestVideoUrl(assetVideo: mockAssetVideo, url: videoUrl)
    manager.startRequestVideoUrl()

    wait(interval: 3) {
      // The first request completed, `requestId` is nil
      XCTAssertNil(self.manager.requestId)

      let assetVideo = MediaPHAssetVideo(asset: PHAssetMock(id: 2, assetType: .video))
      self.manager.setAssetVideo(assetVideo)

      XCTAssertEqual(self.manager.assetVideo, assetVideo)

      // new request started, `requestId` is `assetVideo.asset.id`
      XCTAssertEqual(self.manager.requestId, 2)
    }
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
        .loaded(previewImage: self.uiImage, videoUrl: self.videoUrl)
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

  func test_startRequestVideoUrl_imageAndUrlDidCache() {
    prepare_startRequestVideoUrl(assetVideo: mockAssetVideo, url: videoUrl)
    manager.startRequestVideoUrl()

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.manager.imageCache.image(withIdentifier: self.mockAssetVideo.cacheKey),
        self.uiImage
      )
      XCTAssertEqual(
        self.manager.cachedUrls[self.mockAssetVideo.cacheKey],
        self.videoUrl
      )
    }
  }

  func test_startRequestVideoUrl_useCachedImageAndUrl() {
    let imageCache = AutoPurgingImageCache()
    imageCache.add(uiImage, withIdentifier: mockAssetVideo.cacheKey)
    manager = AssetVideoManager(
      assetVideo: mockAssetVideo,
      imageCache: imageCache,
      cachedUrls: [mockAssetVideo.cacheKey: videoUrl]
    )

    manager.startRequestVideoUrl()

    XCTAssertEqual(manager.videoStatus, .loaded(previewImage: uiImage, videoUrl: videoUrl))
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
  func prepare_startRequestVideoUrl(assetVideo: MediaPHAssetVideo? = nil, url: URL? = nil, error: Error? = nil) {
    let finalAssetVideo = assetVideo ?? self.mockAssetVideo
    manager = AssetVideoManager(
      assetVideo: finalAssetVideo,
      manager: PHImageManagerMock(requestAVAssetURLResponse: url, requestAVAssetError: error),
      thumbnailGenerator: ThumbnailGeneratorMock(uiImage)
    )
  }
}
