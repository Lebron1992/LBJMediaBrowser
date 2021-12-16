import XCTest
import AlamofireImage
@testable import LBJMediaBrowser

final class URLImageLoaderTests: BaseTestCase {
  private let urlImage = MediaURLImage(imageUrl: URL(string: "https://www.example.com/test.png")!)

  private var uiImage: UIImage!
  private var imageLoader: URLImageLoader!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
  }

  override func tearDown() {
     super.tearDown()
    imageLoader = nil
   }

  func test_loadImage_gotImage() async throws {
    createImageLoader(progress: 0.5, uiImage: uiImage)
    
    async let loadImage: Void = await imageLoader.loadImage(for: urlImage)
    async let statuses = TimeoutTask(seconds: 2.1) { [weak self] in
      await self?.imageLoader.status?
        .prefix(2)
        .reduce(into: []) { result, status in
          result.append(status)
        }
    }
      .value

    let (statusesResult, _) = try await (statuses, loadImage)

    XCTAssertEqual(
      statusesResult,
      [.loading(0.5), .loaded(uiImage)]
    )
  }

  func test_imageStatus_imageDidCache() async throws {
    createImageLoader(uiImage: uiImage)

    let _ = try await TimeoutTask(seconds: 2.1) { [weak self] in
      await self?.imageLoader.loadImage(for: self!.urlImage)
    }
      .value

    XCTAssertEqual(
      imageLoader.downloader.imageCache?.image(withIdentifier: urlImage.cacheKey(for: .larger)),
      uiImage
    )
  }

  func test_loadImage_gotCachedImage() async throws {
    createImageLoader(uiImage: uiImage, error: nil, useCache: true)

    async let loadImage: Void = await imageLoader.loadImage(for: urlImage)
    async let statuses = TimeoutTask(seconds: 0.1) { [weak self] in
      await self?.imageLoader.status?
        .prefix(1)
        .reduce(into: []) { result, status in
          result.append(status)
        }
    }
      .value

    let (statusesResult, _) = try await (statuses, loadImage)

    XCTAssertEqual(
      statusesResult,
      [.loaded(uiImage)]
    )
  }

  func test_loadImage_failed() async throws {
    createImageLoader(progress: 0.5, error: NSError.unknownError)

    async let loadImage: Void = await imageLoader.loadImage(for: urlImage)
    async let statuses = TimeoutTask(seconds: 2.1) { [weak self] in
      await self?.imageLoader.status?
        .prefix(2)
        .reduce(into: []) { result, status in
          result.append(status)
        }
    }
      .value

    let (statusesResult, _) = try await (statuses, loadImage)

    XCTAssertEqual(
      statusesResult,
      [.loading(0.5), .failed(NSError.unknownError)]
    )
  }

  func test_cancelLoading_cancelled() async {
    createImageLoader(progress: 0.5, uiImage: uiImage)

    do {
      let _ = try await TimeoutTask(seconds: 0.5) { [weak self] in
        await self!.imageLoader.loadImage(for: self!.urlImage)
      }
      .value
    } catch {
      let cacheKey = urlImage.cacheKey(for: .larger)
      let downloader = imageLoader.downloader as! ImageDownloaderMock

      XCTAssertNotNil(downloader.startedDownloads[cacheKey])
      XCTAssertNotNil(imageLoader.downloadTask)

      imageLoader.cancelLoading(for: urlImage)

      XCTAssertNil(downloader.startedDownloads[cacheKey])
      XCTAssertNil(imageLoader.downloadTask)
    }
  }
}

private extension URLImageLoaderTests {
  func createImageLoader(progress: Float? = nil, uiImage: UIImage? = nil, error: Error? = nil, useCache: Bool = false) {
    let downloader = ImageDownloaderMock(
      imageDownloadProgress: progress,
      imageDownloadResponse: uiImage,
      imageDownloadError: error
    )

    if useCache, let uiImage = uiImage {
      downloader.imageCache?.add(
        uiImage,
        withIdentifier: urlImage.cacheKey(for: .larger)
      )
    }

    imageLoader = URLImageLoader(downloader: downloader)
    imageLoader.setUp()
  }
}
