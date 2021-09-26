import XCTest
@testable import LBJMediaBrowser

final class LBJPagingMediaBrowserTests: XCTestCase {

  private var browser: PagingBrowser!

  override func tearDown() {
    super.tearDown()
    browser = nil
  }

  func test_init_defaultCurrentPage() {
    browser = PagingBrowser(medias: MediaUIImage.uiImages)
    XCTAssertEqual(browser.currentPage, 0)
  }

  func test_setCurrentPage_currentPageUpdated() {
    browser = PagingBrowser(medias: MediaUIImage.uiImages)

    browser.setCurrentPage(1)
    XCTAssertEqual(browser.currentPage, 1)

    browser.setCurrentPage(2)
    XCTAssertEqual(browser.currentPage, 2)
  }

  func test_downloadUrlImage_startedURLRequestGotUpdated() {
    prepare_downloadUrlImage()
    let imageToDownload = MediaURLImage.urlImages.first!

    XCTAssertNil(browser.startedURLRequest[imageToDownload.url])

    browser.downloadUrlImage(imageToDownload, at: 0)

    XCTAssertNotNil(browser.startedURLRequest[imageToDownload.url])
  }

  func test_downloadUrlImage_success() {
    let image = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    prepare_downloadUrlImage(image: image)

    browser.downloadUrlImage(MediaURLImage.urlImages.first!, at: 0)

    wait(interval: 1.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLImage).status,
        .loading(0.5)
      )
    }

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLImage).status,
        .loaded(image)
      )
    }
  }

  func test_downloadUrlImage_failed() {
    prepare_downloadUrlImage(error: NSError.unknownError)

    browser.downloadUrlImage(MediaURLImage.urlImages.first!, at: 0)

    wait(interval: 1.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLImage).status,
        .loading(0.5)
      )
    }

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLImage).status,
        .failed(NSError.unknownError)
      )
    }
  }

  func test_fetchPHAssetImage_startedPHAssetRequestGotUpdated() {
    prepare_fetchPHAssetImage(error: NSError.unknownError)
    let assetToFetch = MediaPHAssetImage.mockTemplates.first!

    XCTAssertNil(browser.startedPHAssetRequest[assetToFetch.asset.id])

    browser.fetchPHAssetImage(assetToFetch, at: 0)

    XCTAssertNotNil(browser.startedPHAssetRequest[assetToFetch.asset.id])
  }

  func test_fetchPHAssetImage_success() {
    let image = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    prepare_fetchPHAssetImage(image: image)
    let assetToFetch = MediaPHAssetImage.mockTemplates.first!

    browser.fetchPHAssetImage(assetToFetch, at: 0)

    wait(interval: 1.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaPHAssetImage).status,
        .loaded(image)
      )
    }
  }

  func test_fetchPHAssetImage_failed() {
    prepare_fetchPHAssetImage(error: NSError.unknownError)
    let assetToFetch = MediaPHAssetImage.mockTemplates.first!

    browser.fetchPHAssetImage(assetToFetch, at: 0)

    wait(interval: 1.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaPHAssetImage).status,
        .failed(NSError.unknownError)
      )
    }
  }

  func test_downloadUrlVideoPreview_startedURLRequestGotUpdated() {
    prepare_downloadUrlVideoPreview()
    let videoToDownload = MediaURLVideo.urlVideos.first!

    XCTAssertNil(browser.startedURLRequest[videoToDownload.previewImageUrl!])

    browser.downloadUrlVideoPreview(urlVideo: videoToDownload, at: 0)

    XCTAssertNotNil(browser.startedURLRequest[videoToDownload.previewImageUrl!])
  }

  func test_downloadUrlVideoPreviewWithoutPreviewURL_success() {
    let videoToDownload = MediaURLVideo(
      previewImageUrl: nil,
      videoUrl: URL(string: "https://www.example.com/test.mp4")!
    )
    let downloader = MockImageDownloader()
    browser = PagingBrowser(medias: [videoToDownload], currentPage: 0, imageDownloader: downloader)

    browser.downloadUrlVideoPreview(urlVideo: videoToDownload, at: 0)

    wait(interval: 0.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLVideo).status,
        .loaded(previewImage: nil, videoUrl: videoToDownload.videoUrl)
      )
    }
  }

  func test_downloadUrlVideoPreviewWithPreviewURL_success() {
    let image = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    let videoToDownload = MediaURLVideo.urlVideos.first!
    prepare_downloadUrlVideoPreview(image: image)

    browser.downloadUrlVideoPreview(urlVideo: videoToDownload, at: 0)

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLVideo).status,
        .loaded(previewImage: image, videoUrl: videoToDownload.videoUrl)
      )
    }
  }

  func test_downloadUrlVideoPreview_failed() {
    prepare_downloadUrlVideoPreview(error: NSError.unknownError)
    let videoToDownload = MediaURLVideo.urlVideos.first!

    browser.downloadUrlVideoPreview(urlVideo: videoToDownload, at: 0)

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaURLVideo).status,
        .loaded(previewImage: nil, videoUrl: videoToDownload.videoUrl)
      )
    }
  }

  func test_mediaAtPage() {
    browser = PagingBrowser(medias: MediaUIImage.uiImages)
    XCTAssertNil(browser.media(at: -1))
    XCTAssertNil(browser.media(at: 3))
    XCTAssertEqual(
      browser.media(at: 1) as? MediaUIImage,
      MediaUIImage.uiImages[1]
    )
  }

  func test_updateMediaImageStatus() {
    browser = PagingBrowser(medias: MediaURLImage.urlImages)
    XCTAssertEqual(
      (browser.medias[0] as! MediaURLImage).status,
      .idle
    )

    browser.updateMediaImageStatus(.loading(0.5), forMediaAt: 0)
    XCTAssertEqual(
      (browser.medias[0] as! MediaURLImage).status,
      .loading(0.5)
    )
  }

  func test_updateMediaVideoStatus() {
    let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    let video = MediaURLVideo(previewImageUrl: nil, videoUrl: url)

    browser = PagingBrowser(medias: [video])
    XCTAssertEqual(
      (browser.medias[0] as! MediaURLVideo).status,
      .idle
    )

    browser.updateMediaVideoStatus(.loaded(previewImage: nil, videoUrl: url), forMediaAt: 0)
    XCTAssertEqual(
      (browser.medias[0] as! MediaURLVideo).status,
      .loaded(previewImage: nil, videoUrl: url)
    )
  }

  func test_validatedPage() {
    browser = PagingBrowser(medias: MediaUIImage.uiImages)

    XCTAssertEqual(
      browser.validatedPage(-1),
      0
    )
    XCTAssertEqual(
      browser.validatedPage(0),
      0
    )
    XCTAssertEqual(
      browser.validatedPage(1),
      1
    )
    XCTAssertEqual(
      browser.validatedPage(2),
      2
    )
    XCTAssertEqual(
      browser.validatedPage(3),
      2
    )
  }

  func test_isValidPage() {
    browser = PagingBrowser(medias: MediaUIImage.uiImages)

    XCTAssertFalse(browser.isValidPage(-1))
    XCTAssertTrue(browser.isValidPage(0))
    XCTAssertTrue(browser.isValidPage(1))
    XCTAssertTrue(browser.isValidPage(2))
    XCTAssertFalse(browser.isValidPage(3))
  }

  func test_constants() {
    XCTAssertEqual(
      PagingBrowser.Constant.adjacentPreloadSize,
      1
    )
    XCTAssertEqual(
      PagingBrowser.Constant.adjacentAvoidCancelLoadingSize,
      2
    )
    XCTAssertEqual(
      PagingBrowser.Constant.adjacentCancelLoadingSize,
      2
    )
  }
}

// MARK: - Helper Methods
private extension LBJPagingMediaBrowserTests {

  func prepare_downloadUrlImage(image: UIImage? = nil, error: Error? = nil) {
    let downloader = MockImageDownloader(imageDownloadProgress: 0.5, imageDownloadResponse: image, imageDownloadError: error)
    browser = PagingBrowser(medias: MediaURLImage.urlImages, currentPage: 0, imageDownloader: downloader)
  }

  func prepare_downloadUrlVideoPreview(image: UIImage? = nil, error: Error? = nil) {
    let downloader = MockImageDownloader(imageDownloadResponse: image, imageDownloadError: error)
    browser = PagingBrowser(medias: MediaURLVideo.urlVideos, currentPage: 0, imageDownloader: downloader)
  }

  func prepare_fetchPHAssetImage(image: UIImage? = nil, error: Error? = nil) {

    var result: [MockPHAsset: Any] = [:]
    MediaPHAssetImage.mockTemplates.forEach { mockAssetImage in
      let mockAsset = mockAssetImage.asset.asset as! MockPHAsset
      if let image = image {
        result[mockAsset] = image
      } else if let error = error {
        result[mockAsset] = error
      }
    }

    let mockPHManager = MockPHImageManager(requestImageResults: result)
    browser = PagingBrowser(medias: MediaPHAssetImage.mockTemplates, currentPage: 0, phImageManager: mockPHManager)
  }
}
