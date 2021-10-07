import XCTest
@testable import LBJMediaBrowser

final class LBJPagingMediaBrowserTests: XCTestCase {

  private let urlImage = MediaURLImage.urlImages.first!
  private let phAssetImage = MediaPHAssetImage.mockTemplates.first!
  private let phAssetVideo = MediaPHAssetVideo.mockTemplates.first!
  private let urlVideo = MediaURLVideo.urlVideos.first!

  private let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!

  private var browser: LBJPagingBrowser!

  override func tearDown() {
    super.tearDown()
    browser = nil
  }

  func test_init_defaultCurrentPage() {
    browser = LBJPagingBrowser(medias: MediaUIImage.uiImages)
    XCTAssertEqual(browser.currentPage, 0)
  }

  func test_setCurrentPage_currentPageUpdated() {
    browser = LBJPagingBrowser(medias: MediaUIImage.uiImages)

    browser.setCurrentPage(1)
    XCTAssertEqual(browser.currentPage, 1)

    browser.setCurrentPage(2)
    XCTAssertEqual(browser.currentPage, 2)
  }

  func test_setCurrentPage_playingVideoUpdated() {
    let video = MediaURLVideo.urlVideos[0]
    browser = LBJPagingBrowser(medias: [
      MediaUIImage.uiImages[0],
      video,
      MediaURLImage.urlImages[0]
    ])

    XCTAssertNil(browser.playingVideo)

    browser.setCurrentPage(1)
    XCTAssertTrue((browser.playingVideo as! MediaURLVideo).isTheSameAs(video))

    browser.setCurrentPage(2)
    XCTAssertNil(browser.playingVideo)
  }

  func test_loadMediaAtFirstPage_firstTwoMediasLoaded_whenAdjacentPreloadSizeIsOne() {
    XCTAssertEqual(LBJPagingBrowser.Constant.adjacentPreloadSize, 1)

    prepare_loadMediaAtPage()
    browser.loadMedia(at: 0)

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias[0] as! MediaURLImage).status,
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        (self.browser.medias[1] as! MediaPHAssetImage).status,
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        (self.browser.medias[2] as! MediaPHAssetVideo).status,
        .idle
      )
      XCTAssertFalse((self.browser.medias[3] as! MediaURLVideo).isLoaded)
    }
  }

  func test_loadMediaAtCenterPage_centerThreeMediasLoaded_whenAdjacentPreloadSizeIsOne() {
    XCTAssertEqual(LBJPagingBrowser.Constant.adjacentPreloadSize, 1)

    prepare_loadMediaAtPage()
    browser.loadMedia(at: 1)

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias[0] as! MediaURLImage).status,
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        (self.browser.medias[1] as! MediaPHAssetImage).status,
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        (self.browser.medias[2] as! MediaPHAssetVideo).status,
        .loaded(previewImage: nil, videoUrl: self.videoUrl)
      )
      XCTAssertFalse((self.browser.medias[3] as! MediaURLVideo).isLoaded)
    }
  }

  func test_loadMediaAtLastPage_lastTwoMediasLoaded_whenAdjacentPreloadSizeIsOne() {
    XCTAssertEqual(LBJPagingBrowser.Constant.adjacentPreloadSize, 1)

    prepare_loadMediaAtPage()
    browser.loadMedia(at: 3)

    wait(interval: 2.1) {
      XCTAssertEqual(
        (self.browser.medias[0] as! MediaURLImage).status,
        .idle
      )
      XCTAssertEqual(
        (self.browser.medias[1] as! MediaPHAssetImage).status,
        .idle
      )
      XCTAssertEqual(
        (self.browser.medias[2] as! MediaPHAssetVideo).status,
        .loaded(previewImage: nil, videoUrl: self.videoUrl)
      )
      XCTAssertEqual(
        (self.browser.medias[3] as! MediaURLVideo).status,
        .loaded(previewImage: self.uiImage, videoUrl: self.urlVideo.videoUrl)
      )
    }
  }

  func test_cancelLoadingMediaExceptPageAndAdjacent_whenAdjacentAvoidCancelLoadingSizeIsTwo() {
    let urlImages = [
      "https://i.picsum.photos/id/249/1000/2000.jpg?hmac=LuHPEUVkziRf9usKW97DBxEzcifzgiCiRtm8vuJNZ9Q",
      "https://i.picsum.photos/id/17/1000/1000.jpg?hmac=5FRnLOBphDqiw_x9GZSSzNW0nfUgQ7kAVZdigKUxZvg"
    ]
      .map { MediaURLImage(url: URL(string: $0)!, status: .loaded(uiImage)) }

    let phAssetImage = MediaPHAssetImage(
      asset: .init(asset: MockPHAsset(id: 1)),
      status: .loaded(uiImage)
    )

    let phAssetVideo = MediaPHAssetVideo(
      asset: .init(asset: MockPHAsset(id: 2)),
      status: .loaded(previewImage: nil, videoUrl: videoUrl)
    )

    let urlVideos = ["BigBuckBunny", "ElephantsDream", "ForBiggerBlazes"]
      .map { name -> MediaURLVideo in
        let prefix = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"
        let videoUrl = URL(string: "\(prefix)/\(name).mp4")!
        return MediaURLVideo(
          previewImageUrl: URL(string: "\(prefix)/images/\(name).jpg")!,
          videoUrl: videoUrl,
          status: .loaded(previewImage: uiImage, videoUrl: videoUrl)
        )
      }

    let medias = [urlImages, [phAssetImage], [phAssetVideo], urlVideos]
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)

    browser = LBJPagingBrowser(medias: medias, currentPage: 0)
    browser.cancelLoadingMediaExceptPageAndAdjacent(page: 3)

    //   0     1  2  3  4  5     6
    //  idle   ----loaded----   idle
    XCTAssertEqual(
      (browser.medias[0] as! MediaURLImage).status,
      .idle
    )
    XCTAssertEqual(
      (browser.medias[1] as! MediaURLImage).status,
      .loaded(uiImage)
    )
    XCTAssertEqual(
      (browser.medias[2] as! MediaPHAssetImage).status,
      .loaded(uiImage)
    )
    XCTAssertEqual(
      (browser.medias[3] as! MediaPHAssetVideo).status,
      .loaded(previewImage: nil, videoUrl: videoUrl)
    )
    XCTAssertEqual(
      (browser.medias[4] as! MediaURLVideo).status,
      .loaded(previewImage: uiImage, videoUrl: urlVideos[0].videoUrl)
    )
    XCTAssertEqual(
      (browser.medias[5] as! MediaURLVideo).status,
      .loaded(previewImage: uiImage, videoUrl: urlVideos[1].videoUrl)
    )
    XCTAssertEqual(
      (browser.medias[6] as! MediaURLVideo).status,
      .loaded(previewImage: nil, videoUrl: urlVideos[2].videoUrl)
    )
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
    browser = LBJPagingBrowser(medias: [videoToDownload], currentPage: 0, imageDownloader: downloader)

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

  func test_fetchPHAssetVideo_startedPHAssetRequestGotUpdated() {
    prepare_fetchPHAssetVideo(error: NSError.unknownError)
    let assetToFetch = MediaPHAssetVideo.mockTemplates.first!

    XCTAssertNil(browser.startedPHAssetRequest[assetToFetch.asset.id])

    browser.fetchPHAssetVideo(assetToFetch, at: 0)

    XCTAssertNotNil(browser.startedPHAssetRequest[assetToFetch.asset.id])
  }

  func test_fetchPHAssetVideo_success() {
    let url = URL(string: "https://www.example.com/test.mp4")!
    prepare_fetchPHAssetVideo(url: url)
    let assetToFetch = MediaPHAssetVideo.mockTemplates.first!

    browser.fetchPHAssetVideo(assetToFetch, at: 0)

    wait(interval: 3) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaPHAssetVideo).status,
        .loaded(previewImage: nil, videoUrl: url)
      )
    }
  }

  func test_fetchPHAssetVideo_failed() {
    prepare_fetchPHAssetVideo(error: NSError.unknownError)
    let assetToFetch = MediaPHAssetVideo.mockTemplates.first!

    browser.fetchPHAssetVideo(assetToFetch, at: 0)

    wait(interval: 1.1) {
      XCTAssertEqual(
        (self.browser.medias.first as! MediaPHAssetVideo).status,
        .failed(NSError.unknownError)
      )
    }
  }

  func test_mediaAtPage() {
    browser = LBJPagingBrowser(medias: MediaUIImage.uiImages)
    XCTAssertNil(browser.media(at: -1))
    XCTAssertNil(browser.media(at: 3))
    XCTAssertEqual(
      browser.media(at: 1) as? MediaUIImage,
      MediaUIImage.uiImages[1]
    )
  }

  func test_updateMediaImageStatus() {
    browser = LBJPagingBrowser(medias: MediaURLImage.urlImages)
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

    browser = LBJPagingBrowser(medias: [video])
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
    browser = LBJPagingBrowser(medias: MediaUIImage.uiImages)

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
    browser = LBJPagingBrowser(medias: MediaUIImage.uiImages)

    XCTAssertFalse(browser.isValidPage(-1))
    XCTAssertTrue(browser.isValidPage(0))
    XCTAssertTrue(browser.isValidPage(1))
    XCTAssertTrue(browser.isValidPage(2))
    XCTAssertFalse(browser.isValidPage(3))
  }

  func test_constants() {
    XCTAssertEqual(
      LBJPagingBrowser.Constant.adjacentPreloadSize,
      1
    )
    XCTAssertEqual(
      LBJPagingBrowser.Constant.adjacentAvoidCancelLoadingSize,
      2
    )
    XCTAssertEqual(
      LBJPagingBrowser.Constant.adjacentCancelLoadingSize,
      2
    )
  }
}

// MARK: - Helper Methods
private extension LBJPagingMediaBrowserTests {

  func prepare_loadMediaAtPage() {
    let imageDownloader = MockImageDownloader(imageDownloadResponse: uiImage)
    let phManager = MockPHImageManager(
      requestImageResults: [phAssetImage.asset.asset as! MockPHAsset: uiImage],
      requestAVAssetURLResponse: videoUrl
    )

    browser = LBJPagingBrowser(
      medias: [urlImage, phAssetImage, phAssetVideo, urlVideo],
      currentPage: 0,
      imageDownloader: imageDownloader,
      phImageManager: phManager
    )
  }

  func prepare_downloadUrlImage(image: UIImage? = nil, error: Error? = nil) {
    let downloader = MockImageDownloader(imageDownloadProgress: 0.5, imageDownloadResponse: image, imageDownloadError: error)
    browser = LBJPagingBrowser(medias: MediaURLImage.urlImages, currentPage: 0, imageDownloader: downloader)
  }

  func prepare_downloadUrlVideoPreview(image: UIImage? = nil, error: Error? = nil) {
    let downloader = MockImageDownloader(imageDownloadResponse: image, imageDownloadError: error)
    browser = LBJPagingBrowser(medias: MediaURLVideo.urlVideos, currentPage: 0, imageDownloader: downloader)
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
    browser = LBJPagingBrowser(medias: MediaPHAssetImage.mockTemplates, currentPage: 0, phImageManager: mockPHManager)
  }

  func prepare_fetchPHAssetVideo(url: URL? = nil, error: Error? = nil) {
    let mockPHManager = MockPHImageManager(requestAVAssetURLResponse: url, requestAVAssetError: error)
    browser = LBJPagingBrowser(medias: MediaPHAssetVideo.mockTemplates, currentPage: 0, phImageManager: mockPHManager)
  }
}
