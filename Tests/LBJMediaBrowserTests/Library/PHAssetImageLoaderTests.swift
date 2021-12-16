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

  func test_imageStatus_gotImage() async {
    createImageLoader(uiImage: uiImage)

    let result = await imageLoader.imageStatus(for: mockAssetImage)
    XCTAssertEqual(result, .loaded(uiImage))
  }

  func test_imageStatus_imageDidCache() async {
    createImageLoader(uiImage: uiImage)

    let _ = await imageLoader.imageStatus(for: mockAssetImage)
    XCTAssertEqual(
      imageLoader.imageCache.image(withIdentifier: mockAssetImage.cacheKey(for: .thumbnail)),
      uiImage
    )
  }

  func test_imageStatus_gotCachedImage() async throws {
    createImageLoader(uiImage: uiImage, useCache: true)

    let result = try await TimeoutTask(seconds: 0.1) { [weak self] in
      await self!.imageLoader.imageStatus(for: self!.mockAssetImage)
    }
    .value

    XCTAssertEqual(result, .loaded(uiImage))
  }

  func test_imageStatus_failed() async {
    createImageLoader(error: NSError.unknownError)
    
    let result = await imageLoader.imageStatus(for: mockAssetImage)
    XCTAssertEqual(result, .failed(NSError.unknownError))
  }

  func test_cancelLoading_cancelled() async {
    createImageLoader(uiImage: uiImage)

    do {
      let _ = try await TimeoutTask(seconds: 0.5) { [weak self] in
        await self!.imageLoader.imageStatus(for: self!.mockAssetImage)
      }
      .value
    } catch {
      let cacheKey = mockAssetImage.cacheKey(for: .thumbnail)
      XCTAssertNotNil(imageLoader.taskCache[cacheKey])
      XCTAssertNotNil(imageLoader.requestIdCache[cacheKey])

      imageLoader.cancelLoading(for: mockAssetImage)

      XCTAssertNil(imageLoader.taskCache[cacheKey])
      XCTAssertNil(imageLoader.requestIdCache[cacheKey])
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
        withIdentifier: mockAssetImage.cacheKey(for: .thumbnail)
      )
    }

    imageLoader = PHAssetImageLoader(
      manager: PHImageManagerMock(requestImageResults: [mockAsset: uiImage ?? error as Any]),
      imageCache: imageCache
    )
  }
}
