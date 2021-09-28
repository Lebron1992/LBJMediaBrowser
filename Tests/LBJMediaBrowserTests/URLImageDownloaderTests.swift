import XCTest
@testable import LBJMediaBrowser

final class URLImageDownloaderTests: XCTestCase {

  private let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!

  private var downloader: URLImageDownloader!

  override func tearDown() {
    super.tearDown()
    downloader = nil
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

  func test_reset() {
    let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    prepare_startDownload(uiImage: uiImage)

    XCTAssertEqual(downloader.imageStatus, .idle)

    downloader.startDownload()

    wait(interval: 2.1) {
      XCTAssertEqual(self.downloader.imageStatus, .loaded(uiImage))
    }

    downloader.reset()

    XCTAssertEqual(downloader.imageStatus, .idle)
    XCTAssertNil(downloader.receipt)
  }
}

private extension URLImageDownloaderTests {
  func prepare_startDownload(progress: Float? = nil, uiImage: UIImage? = nil, error: Error? = nil) {
    downloader = URLImageDownloader(
      imageUrl: URL(string: "https://www.example.com/test.png")!,
      downloader: MockImageDownloader(
        imageDownloadProgress: progress,
        imageDownloadResponse: uiImage,
        imageDownloadError: error
      )
    )
  }
}
