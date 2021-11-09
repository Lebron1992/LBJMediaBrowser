import XCTest
@testable import LBJMediaBrowser

final class URLImageDownloaderTests: XCTestCase {

  private let imageUrl = URL(string: "https://www.example.com/test.png")!
  private let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!

  private var downloader: URLImageDownloader!

  override func tearDown() {
    super.tearDown()
    downloader = nil
  }

  func test_setImageUrl_imageUrlDidSet() {
    downloader = URLImageDownloader(imageUrl: nil)
    XCTAssertNil(downloader.imageUrl)

    downloader.setImageUrl(imageUrl)

    XCTAssertEqual(downloader.imageUrl, imageUrl)
  }

  func test_setImageUrl_ignoredDuplicatedLoadedUrlImage() {
    prepare_startDownload(uiImage: uiImage)
    downloader.startDownload()

    wait(interval: 2.1) {
      // The first request completed, `receipt` is nil
      XCTAssertNil(self.downloader.receipt)

      self.downloader.setImageUrl(self.imageUrl)

      XCTAssertEqual(self.downloader.imageUrl, self.imageUrl)

      // no new request started, `receipt` is nil
      XCTAssertNil(self.downloader.receipt)
    }
  }

  func test_setAssetImage_startedNewRequest() {
    prepare_startDownload(uiImage: uiImage)
    downloader.startDownload()

    wait(interval: 2.1) {
      // The first request completed, `receipt` is nil
      XCTAssertNil(self.downloader.receipt)

      let newImageUrl = URL(string: "https://www.example.com/test1.png")!
      self.downloader.setImageUrl(newImageUrl)

      XCTAssertEqual(self.downloader.imageUrl, newImageUrl)

      // new request started, `receipt` is `newImageUrl.absoluteString`
      XCTAssertEqual(self.downloader.receipt, newImageUrl.absoluteString)
    }
  }

  func test_startDownload_requestId() {
    prepare_startDownload(uiImage: uiImage)

    XCTAssertNil(downloader.receipt)

    downloader.startDownload()

    wait(interval: 0.5) {
      XCTAssertNotNil(self.downloader.receipt)
    }

    wait(interval: 2.1) {
      XCTAssertNil(self.downloader.receipt)
    }
  }

  func test_startDownload_success() {
    let progress: Float = 0.5
    let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    prepare_startDownload(progress: progress, uiImage: uiImage)

    XCTAssertEqual(downloader.imageStatus, .idle)

    downloader.startDownload()

    wait(interval: 1.1) {
      XCTAssertEqual(self.downloader.imageStatus, .loading(progress))
    }

    wait(interval: 2.1) {
      XCTAssertEqual(self.downloader.imageStatus, .loaded(uiImage))
    }
  }

  func test_startDownload_failed() {
    prepare_startDownload(error: NSError.unknownError)

    XCTAssertEqual(downloader.imageStatus, .idle)

    downloader.startDownload()

    wait(interval: 2.1) {
      XCTAssertEqual(self.downloader.imageStatus, .failed(NSError.unknownError))
    }
  }

  func test_cancelDownload_downloadCancelled() {
    let progress: Float = 0.5
    let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    prepare_startDownload(progress: progress, uiImage: uiImage)

    XCTAssertEqual(downloader.imageStatus, .idle)

    downloader.startDownload()

    wait(interval: 1.1) {
      XCTAssertEqual(self.downloader.imageStatus, .loading(progress))
    }

    wait(interval: 1.2) {
      self.downloader.cancelDownload()
    }

    wait(interval: 2.1) {
      XCTAssertEqual(self.downloader.imageStatus, .idle)
    }
  }
}

private extension URLImageDownloaderTests {
  func prepare_startDownload(progress: Float? = nil, uiImage: UIImage? = nil, error: Error? = nil) {
    downloader = URLImageDownloader(
      imageUrl: URL(string: "https://www.example.com/test.png")!,
      downloader: ImageDownloaderMock(
        imageDownloadProgress: progress,
        imageDownloadResponse: uiImage,
        imageDownloadError: error
      )
    )
  }
}
