import XCTest
import AlamofireImage
@testable import LBJMediaBrowser

final class PHAssetVideoLoaderTests: BaseTestCase {
  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!
  private let mockAssetVideo = MediaPHAssetVideo(asset: PHAssetMock(id: 1, assetType: .video))

  private var uiImage: UIImage!
  private var videoLoader: PHAssetVideoLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
  }

  override func tearDown() {
     super.tearDown()
    videoLoader = nil
   }

  func test_videoStatus_gotVideoUrlAndThumbnail() async throws {
    createVideoLoader(url: videoUrl)

    let result = await videoLoader.videoStatus(for: mockAssetVideo)
    XCTAssertEqual(result, .loaded(previewImage: uiImage, videoUrl: videoUrl))
  }

  func test_imageStatus_videoUrlAndThumbnailDidCache() async {
    createVideoLoader(url: videoUrl)

    let _ = await videoLoader.videoStatus(for: mockAssetVideo)

    let cacheKey = mockAssetVideo.cacheKey
    XCTAssertEqual(
      videoLoader.imageCache.image(withIdentifier: cacheKey),
      uiImage
    )
    XCTAssertEqual(
      videoLoader.urlCache.url(withIdentifier: cacheKey),
      videoUrl
    )
  }

  func test_loadImage_gotCachedVideoUrlAndThumbnail() async throws {
    createVideoLoader(url: videoUrl, useCache: true)

    let result = try await TimeoutTask(seconds: 0.1) { [weak self] in
      await self!.videoLoader.videoStatus(for: self!.mockAssetVideo)
    }
    .value

    XCTAssertEqual(result, .loaded(previewImage: uiImage, videoUrl: videoUrl))
  }

  func test_loadImage_failed() async {
    createVideoLoader(error: NSError.unknownError)
    
    let result = await videoLoader.videoStatus(for: mockAssetVideo)
    XCTAssertEqual(result, .failed(NSError.unknownError))
  }

  func test_cancelLoading_cancelled() async {
    createVideoLoader(url: videoUrl)

    do {
      let _ = try await TimeoutTask(seconds: 0.5) { [weak self] in
        await self!.videoLoader.videoStatus(for: self!.mockAssetVideo)
      }
      .value
    } catch {
      let cacheKey = mockAssetVideo.cacheKey
      XCTAssertNotNil(videoLoader.taskCache[cacheKey])
      XCTAssertNotNil(videoLoader.requestIdCache[cacheKey])

      videoLoader.cancelLoading(for: mockAssetVideo)

      XCTAssertNil(videoLoader.taskCache[cacheKey])
      XCTAssertNil(videoLoader.requestIdCache[cacheKey])
    }
  }
}

private extension PHAssetVideoLoaderTests {
  func createVideoLoader(url: URL? = nil, error: Error? = nil, useCache: Bool = false) {
    let imageCache = AutoPurgingImageCache()
    let urlCache = LBJURLCache()
    
    if useCache, let url = url {
      let cacheKey = mockAssetVideo.cacheKey
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
