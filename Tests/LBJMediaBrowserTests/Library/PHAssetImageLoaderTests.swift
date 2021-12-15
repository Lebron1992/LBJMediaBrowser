import XCTest
import AlamofireImage
@testable import LBJMediaBrowser

final class PHAssetImageLoaderTests: BaseTestCase {
  private let mockAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))

  private var uiImage: UIImage!
  private var imageLoader: PHAssetImageLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
  }

  override func tearDown() {
     super.tearDown()
    imageLoader = nil
    AutoPurgingImageCache.shared
      .removeImage(withIdentifier: mockAssetImage.cacheKey(for: .thumbnail))
   }

  func test_loadImage_gotImage() async throws {
    createImageLoader(uiImage: uiImage)

    let result = try await imageLoader.uiImage(for: mockAssetImage)
    XCTAssertEqual(result, uiImage)
  }

  func test_loadImage_gotCachedImage() async throws {
    createImageLoader(uiImage: uiImage, useCache: true)

    let result = try await TimeoutTask(seconds: 0.1) { [weak self] in
      try await self!.imageLoader.uiImage(for: self!.mockAssetImage)
    }
    .value

    XCTAssertEqual(result, uiImage)
  }

  func test_loadImage_throwsError() async {
    createImageLoader(error: NSError.unknownError)

    do {
      let _ = try await imageLoader.uiImage(for: mockAssetImage)
    } catch {
      XCTAssertEqual(error as NSError, NSError.unknownError)
    }
  }

  func test_cancelLoading_cancelled() async {
    createImageLoader(uiImage: uiImage)

    do {
      let _ = try await TimeoutTask(seconds: 0.5) { [weak self] in
        try await self!.imageLoader.uiImage(for: self!.mockAssetImage)
      }
      .value
    } catch {
      let cacheKey = mockAssetImage.cacheKey(for: .thumbnail)
      XCTAssertNotNil(imageLoader.loadingStatusCache[cacheKey])
      XCTAssertNotNil(imageLoader.requestIdCache[cacheKey])

      imageLoader.cancelLoading(for: mockAssetImage)

      XCTAssertNil(imageLoader.loadingStatusCache[cacheKey])
      XCTAssertNil(imageLoader.requestIdCache[cacheKey])
    }
  }
}

private extension PHAssetImageLoaderTests {
  func createImageLoader(uiImage: UIImage? = nil, error: Error? = nil, useCache: Bool = false) {
    let mockAsset = mockAssetImage.asset as! PHAssetMock

    if useCache, let uiImage = uiImage {
      AutoPurgingImageCache.shared.add(
        uiImage,
        withIdentifier: mockAssetImage.cacheKey(for: .thumbnail)
      )
    }

    imageLoader = PHAssetImageLoader(
      manager: PHImageManagerMock(requestImageResults: [mockAsset: uiImage ?? error as Any])
    )
  }
}
