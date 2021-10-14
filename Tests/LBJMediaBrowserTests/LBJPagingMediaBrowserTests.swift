import XCTest
@testable import LBJMediaBrowser

final class LBJPagingMediaBrowserTests: XCTestCase {

  private let mediaUIImage = MediaUIImage.templates[0]
  private let urlImage = MediaURLImage.templates[0]
  private let phAssetImage = MediaPHAssetImage.templatesMock[0]
  private let phAssetVideo = MediaPHAssetVideo.templatesMock[0]
  private let urlVideo = MediaURLVideo.templates[0]

  private let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!

  private var browser: LBJPagingBrowser!

  override func tearDown() {
    super.tearDown()
    browser = nil
  }

  func test_init_defaultCurrentPage() {
    browser = LBJPagingBrowser(medias: MediaUIImage.templates)
    XCTAssertEqual(browser.currentPage, 0)
  }

  func test_setCurrentPage_currentPageUpdated() {
    browser = LBJPagingBrowser(medias: MediaUIImage.templates)

    browser.setCurrentPage(1)
    XCTAssertEqual(browser.currentPage, 1)

    browser.setCurrentPage(2)
    XCTAssertEqual(browser.currentPage, 2)
  }

  func test_setCurrentPage_playingVideoUpdated() {
    browser = LBJPagingBrowser(medias: [mediaUIImage, urlVideo, urlImage])

    XCTAssertNil(browser.playingVideo)

    browser.setCurrentPage(1)
    XCTAssertEqual((browser.playingVideo as! MediaURLVideo), urlVideo)

    browser.setCurrentPage(2)
    XCTAssertNil(browser.playingVideo)
  }

  func test_loadMediaAtFirstPage_firstTwoMediasLoaded_whenAdjacentPreloadSizeIsOne() {
    XCTAssertEqual(LBJPagingBrowser.Constant.adjacentPreloadSize, 1)

    prepare_loadMediaAtPage()
    browser.loadMedia(at: 0)

    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.phAssetImage.id],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.urlVideo.id],
        nil
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.phAssetVideo.id],
        nil
      )
    }
  }

  func test_loadMediaAtCenterPage_centerThreeMediasLoaded_whenAdjacentPreloadSizeIsOne() {
    XCTAssertEqual(LBJPagingBrowser.Constant.adjacentPreloadSize, 1)

    prepare_loadMediaAtPage()
    browser.loadMedia(at: 1)

    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.phAssetImage.id],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.urlVideo.id],
        .loaded(previewImage: self.uiImage, videoUrl: self.urlVideo.videoUrl)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.phAssetVideo.id],
        nil
      )
    }
  }

  func test_loadMediaAtLastPage_lastTwoMediasLoaded_whenAdjacentPreloadSizeIsOne() {
    XCTAssertEqual(LBJPagingBrowser.Constant.adjacentPreloadSize, 1)

    prepare_loadMediaAtPage()
    browser.loadMedia(at: 3)

    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        nil
      )
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.phAssetImage.id],
        nil
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.urlVideo.id],
        .loaded(previewImage: self.uiImage, videoUrl: self.urlVideo.videoUrl)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.phAssetVideo.id],
        .loaded(previewImage: nil, videoUrl: self.videoUrl)
      )
    }
  }

  func test_cancelLoadingMediaExceptPageAndAdjacent_whenAdjacentAvoidCancelLoadingSizeIsTwo() {
    var mediaImageStatuses: [MediaId: MediaImageStatus] = [:]
    var mediaVideoStatuses: [MediaId: MediaVideoStatus] = [:]

    let urlImages = [
      "https://i.picsum.photos/id/249/1000/2000.jpg?hmac=LuHPEUVkziRf9usKW97DBxEzcifzgiCiRtm8vuJNZ9Q",
      "https://i.picsum.photos/id/17/1000/1000.jpg?hmac=5FRnLOBphDqiw_x9GZSSzNW0nfUgQ7kAVZdigKUxZvg"
    ]
      .map { MediaURLImage(imageUrl: URL(string: $0)!) }
    urlImages.forEach { mediaImageStatuses[$0.id] = .loaded(uiImage) }

    let phAssetImage = MediaPHAssetImage(asset: PHAssetMock(id: 1, assetType: .image))
    mediaImageStatuses[phAssetImage.id] = .loaded(uiImage)

    let phAssetVideo = MediaPHAssetVideo(asset: PHAssetMock(id: 2, assetType: .video))
    mediaVideoStatuses[phAssetVideo.id] = .loaded(previewImage: nil, videoUrl: videoUrl)

    let urlVideos = ["BigBuckBunny", "ElephantsDream", "ForBiggerBlazes"]
      .map { name -> MediaURLVideo in
        let prefix = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"
        let videoUrl = URL(string: "\(prefix)/\(name).mp4")!
        let urlVideo = MediaURLVideo(
          videoUrl: videoUrl,
          previewImageUrl: URL(string: "\(prefix)/images/\(name).jpg")!
        )
        mediaVideoStatuses[urlVideo.id] = .loaded(previewImage: uiImage, videoUrl: videoUrl)
        return urlVideo
      }

    let medias = [urlImages, [phAssetImage], [phAssetVideo], urlVideos]
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)

    browser = LBJPagingBrowser(
      medias: medias,
      currentPage: 0,
      mediaImageStatuses: mediaImageStatuses,
      mediaVideoStatuses: mediaVideoStatuses
    )
    browser.cancelLoadingMediaExceptPageAndAdjacent(page: 3)

    //   0     1  2  3  4  5     6
    //  nil   ----loaded----    nil
    wait(interval: 1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[urlImages[0].id],
        nil
      )
      XCTAssertEqual(
        self.browser.mediaImageStatuses[urlImages[1].id],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.browser.mediaImageStatuses[phAssetImage.id],
        .loaded(self.uiImage)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[phAssetVideo.id],
        .loaded(previewImage: nil, videoUrl: self.videoUrl)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[urlVideos[0].id],
        .loaded(previewImage: self.uiImage, videoUrl: urlVideos[0].videoUrl)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[urlVideos[1].id],
        .loaded(previewImage: self.uiImage, videoUrl: urlVideos[1].videoUrl)
      )
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[urlVideos[2].id],
        .loaded(previewImage: nil, videoUrl: urlVideos[2].videoUrl)
      )
    }
  }

  func test_downloadUrlImage_startedURLRequestGotUpdated() {
    prepare_downloadUrlImage()

    XCTAssertNil(browser.startedURLRequest[urlImage.imageUrl])

    browser.downloadUrlImage(urlImage)

    XCTAssertNotNil(browser.startedURLRequest[urlImage.imageUrl])
  }

  func test_downloadUrlImage_success() {
    prepare_downloadUrlImage(image: uiImage)

    browser.downloadUrlImage(urlImage)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .loading(0.5)
      )
    }
    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .loaded(self.uiImage)
      )
    }
  }

  func test_downloadUrlImage_failed() {
    prepare_downloadUrlImage(error: NSError.unknownError)

    browser.downloadUrlImage(urlImage)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .loading(0.5)
      )
    }
    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_fetchPHAssetImage_startedPHAssetRequestGotUpdated() {
    prepare_fetchPHAssetImage(error: NSError.unknownError)

    XCTAssertNil(browser.startedPHAssetRequest[phAssetImage.id])

    browser.fetchPHAssetImage(phAssetImage)

    XCTAssertNotNil(browser.startedPHAssetRequest[phAssetImage.id])
  }

  func test_fetchPHAssetImage_success() {
    prepare_fetchPHAssetImage(image: uiImage)

    browser.fetchPHAssetImage(phAssetImage)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.phAssetImage.id],
        .loaded(self.uiImage)
      )
    }
  }

  func test_fetchPHAssetImage_failed() {
    prepare_fetchPHAssetImage(error: NSError.unknownError)

    browser.fetchPHAssetImage(phAssetImage)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.phAssetImage.id],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_downloadUrlVideoPreview_startedURLRequestGotUpdated() {
    prepare_downloadUrlVideoPreview()

    XCTAssertNil(browser.startedURLRequest[urlVideo.previewImageUrl!])

    browser.downloadUrlVideoPreview(urlVideo: urlVideo)

    XCTAssertNotNil(browser.startedURLRequest[urlVideo.previewImageUrl!])
  }

  func test_downloadUrlVideoPreviewWithoutPreviewURL_success() {
    let videoToDownload = MediaURLVideo(
      videoUrl: URL(string: "https://www.example.com/test.mp4")!,
      previewImageUrl: nil
    )
    browser = LBJPagingBrowser(
      medias: [videoToDownload],
      currentPage: 0,
      imageDownloader: ImageDownloaderMock()
    )

    browser.downloadUrlVideoPreview(urlVideo: videoToDownload)

    wait(interval: 0.1) {
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[videoToDownload.id],
        .loaded(previewImage: nil, videoUrl: videoToDownload.videoUrl)
      )
    }
  }

  func test_downloadUrlVideoPreviewWithPreviewURL_success() {
    prepare_downloadUrlVideoPreview(image: uiImage)

    browser.downloadUrlVideoPreview(urlVideo: urlVideo)

    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.urlVideo.id],
        .loaded(previewImage: self.uiImage, videoUrl: self.urlVideo.videoUrl)
      )
    }
  }

  func test_downloadUrlVideoPreview_failed() {
    prepare_downloadUrlVideoPreview(error: NSError.unknownError)

    browser.downloadUrlVideoPreview(urlVideo: urlVideo)

    wait(interval: 2.1) {
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.urlVideo.id],
        .loaded(previewImage: nil, videoUrl: self.urlVideo.videoUrl)
      )
    }
  }

  func test_fetchPHAssetVideo_startedPHAssetRequestGotUpdated() {
    prepare_fetchPHAssetVideo(error: NSError.unknownError)

    XCTAssertNil(browser.startedPHAssetRequest[phAssetVideo.id])

    browser.fetchPHAssetVideo(phAssetVideo)

    XCTAssertNotNil(browser.startedPHAssetRequest[phAssetVideo.id])
  }

  func test_fetchPHAssetVideo_success() {
    let url = URL(string: "https://www.example.com/test.mp4")!
    prepare_fetchPHAssetVideo(url: url)

    browser.fetchPHAssetVideo(phAssetVideo)

    wait(interval: 5) {
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.phAssetVideo.id],
        .loaded(previewImage: nil, videoUrl: url)
      )
    }
  }

  func test_fetchPHAssetVideo_failed() {
    prepare_fetchPHAssetVideo(error: NSError.unknownError)

    browser.fetchPHAssetVideo(phAssetVideo)

    wait(interval: 1.1) {
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.phAssetVideo.id],
        .failed(NSError.unknownError)
      )
    }
  }

  func test_mediaAtPage() {
    browser = LBJPagingBrowser(medias: MediaUIImage.templates)
    XCTAssertNil(browser.media(at: -1))
    XCTAssertNil(browser.media(at: 3))
    XCTAssertEqual(
      browser.media(at: 1) as? MediaUIImage,
      MediaUIImage.templates[1]
    )
  }

  func test_updateMediaImageStatus() {
    browser = LBJPagingBrowser(medias: [urlImage])
    XCTAssertEqual(
      browser.mediaImageStatuses[urlImage.id],
      nil
    )

    browser.updateMediaImageStatus(.loading(0.5), for: urlImage)
    wait(interval: 1) {
      XCTAssertEqual(
        self.browser.mediaImageStatuses[self.urlImage.id],
        .loading(0.5)
      )
    }
  }

  func test_updateMediaVideoStatus() {
    browser = LBJPagingBrowser(medias: [urlVideo])
    XCTAssertEqual(
      browser.mediaVideoStatuses[urlVideo.id],
      nil
    )

    browser.updateMediaVideoStatus(
      .loaded(previewImage: nil, videoUrl: urlVideo.videoUrl),
      for: urlVideo
    )

    wait(interval: 1) {
      XCTAssertEqual(
        self.browser.mediaVideoStatuses[self.urlVideo.id],
        .loaded(previewImage: nil, videoUrl: self.urlVideo.videoUrl)
      )
    }
  }

  func test_imageStatusForImage_returnNil() {
    browser = LBJPagingBrowser(medias: [urlImage])
    XCTAssertNil(browser.imageStatus(for: urlImage))
  }

  func test_imageStatusForImage_statusGotReturned() {
    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .loaded(uiImage)]
    )
    XCTAssertEqual(browser.imageStatus(for: urlImage), .loaded(uiImage))
  }

  func test_videoStatusForVideo_returnNil() {
    browser = LBJPagingBrowser(medias: [urlVideo])
    XCTAssertNil(browser.videoStatus(for: urlVideo))
  }

  func test_videoStatusForVideo_statusGotReturned() {
    browser = LBJPagingBrowser(
      medias: [urlVideo],
      mediaVideoStatuses: [urlVideo.id: .loaded(previewImage: uiImage, videoUrl: urlVideo.videoUrl)]
    )
    XCTAssertEqual(
      browser.videoStatus(for: urlVideo),
      .loaded(previewImage: uiImage, videoUrl: urlVideo.videoUrl)
    )
  }

  func test_imageIsLoading() {
    browser = LBJPagingBrowser(medias: [urlImage])
    XCTAssertFalse(browser.imageIsLoading(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .idle]
    )
    XCTAssertFalse(browser.imageIsLoading(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .loading(0.5)]
    )
    XCTAssertTrue(browser.imageIsLoading(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .loaded(uiImage)]
    )
    XCTAssertFalse(browser.imageIsLoading(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .failed(NSError.unknownError)]
    )
    XCTAssertFalse(browser.imageIsLoading(urlImage))
  }

  func test_imageIsLoaded() {
    browser = LBJPagingBrowser(medias: [urlImage])
    XCTAssertFalse(browser.imageIsLoaded(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .idle]
    )
    XCTAssertFalse(browser.imageIsLoaded(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .loading(0.5)]
    )
    XCTAssertFalse(browser.imageIsLoaded(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .loaded(uiImage)]
    )
    XCTAssertTrue(browser.imageIsLoaded(urlImage))

    browser = LBJPagingBrowser(
      medias: [urlImage],
      mediaImageStatuses: [urlImage.id: .failed(NSError.unknownError)]
    )
    XCTAssertFalse(browser.imageIsLoaded(urlImage))
  }

  func test_videoIsLoaded() {
    browser = LBJPagingBrowser(medias: [phAssetVideo])
    XCTAssertFalse(browser.videoIsLoaded(phAssetVideo))

    browser = LBJPagingBrowser(
      medias: [phAssetVideo],
      mediaVideoStatuses: [phAssetVideo.id: .idle]
    )
    XCTAssertFalse(browser.videoIsLoaded(phAssetVideo))

    browser = LBJPagingBrowser(
      medias: [phAssetVideo],
      mediaVideoStatuses: [phAssetVideo.id: .loaded(previewImage: uiImage, videoUrl: videoUrl)]
    )
    XCTAssertTrue(browser.videoIsLoaded(phAssetVideo))

    browser = LBJPagingBrowser(
      medias: [phAssetVideo],
      mediaVideoStatuses: [phAssetVideo.id: .failed(NSError.unknownError)]
    )
    XCTAssertFalse(browser.videoIsLoaded(phAssetVideo))
  }

  func test_urlVideoIsLoaded() {
    browser = LBJPagingBrowser(medias: [urlVideo])
    XCTAssertFalse(browser.urlVideoIsLoaded(urlVideo))

    browser = LBJPagingBrowser(
      medias: [urlVideo],
      mediaVideoStatuses: [urlVideo.id: .idle]
    )
    XCTAssertFalse(browser.urlVideoIsLoaded(urlVideo))

    browser = LBJPagingBrowser(
      medias: [urlVideo],
      mediaVideoStatuses: [urlVideo.id: .loaded(previewImage: nil, videoUrl: urlVideo.videoUrl)]
    )
    XCTAssertFalse(browser.urlVideoIsLoaded(urlVideo))

    browser = LBJPagingBrowser(
      medias: [urlVideo],
      mediaVideoStatuses: [urlVideo.id: .loaded(previewImage: uiImage, videoUrl: urlVideo.videoUrl)]
    )
    XCTAssertTrue(browser.urlVideoIsLoaded(urlVideo))

    let video = MediaURLVideo(videoUrl: videoUrl, previewImageUrl: nil)
    browser = LBJPagingBrowser(
      medias: [video],
      mediaVideoStatuses: [video.id: .loaded(previewImage: nil, videoUrl: urlVideo.videoUrl)]
    )
    XCTAssertTrue(browser.urlVideoIsLoaded(video))

    browser = LBJPagingBrowser(
      medias: [phAssetVideo],
      mediaVideoStatuses: [urlVideo.id: .failed(NSError.unknownError)]
    )
    XCTAssertFalse(browser.urlVideoIsLoaded(urlVideo))
  }

  func test_validatedPage() {
    browser = LBJPagingBrowser(medias: MediaUIImage.templates)

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
    browser = LBJPagingBrowser(medias: MediaUIImage.templates)

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
    let imageDownloader = ImageDownloaderMock(imageDownloadResponse: uiImage)
    let phManager = PHImageManagerMock(
      requestImageResults: [phAssetImage.asset as! PHAssetMock: uiImage],
      requestAVAssetURLResponse: videoUrl
    )

    browser = LBJPagingBrowser(
      medias: [urlImage, phAssetImage, urlVideo, phAssetVideo],
      currentPage: 0,
      imageDownloader: imageDownloader,
      phImageManager: phManager
    )
  }

  func prepare_downloadUrlImage(image: UIImage? = nil, error: Error? = nil) {
    let downloader = ImageDownloaderMock(
      imageDownloadProgress: 0.5,
      imageDownloadResponse: image,
      imageDownloadError: error
    )
    browser = LBJPagingBrowser(
      medias: MediaURLImage.templates,
      currentPage: 0,
      imageDownloader: downloader
    )
  }

  func prepare_downloadUrlVideoPreview(image: UIImage? = nil, error: Error? = nil) {
    let downloader = ImageDownloaderMock(
      imageDownloadResponse: image,
      imageDownloadError: error
    )
    browser = LBJPagingBrowser(
      medias: MediaURLVideo.templates,
      currentPage: 0,
      imageDownloader: downloader
    )
  }

  func prepare_fetchPHAssetImage(image: UIImage? = nil, error: Error? = nil) {

    var result: [PHAssetMock: Any] = [:]
    MediaPHAssetImage.templatesMock.forEach { mockAssetImage in
      let mockAsset = mockAssetImage.asset as! PHAssetMock
      if let image = image {
        result[mockAsset] = image
      } else if let error = error {
        result[mockAsset] = error
      }
    }

    let mockPHManager = PHImageManagerMock(requestImageResults: result)
    browser = LBJPagingBrowser(
      medias: MediaPHAssetImage.templatesMock,
      currentPage: 0,
      phImageManager: mockPHManager
    )
  }

  func prepare_fetchPHAssetVideo(url: URL? = nil, error: Error? = nil) {
    let mockPHManager = PHImageManagerMock(
      requestAVAssetURLResponse: url,
      requestAVAssetError: error
    )
    browser = LBJPagingBrowser(
      medias: MediaPHAssetVideo.templatesMock,
      currentPage: 0,
      phImageManager: mockPHManager
    )
  }
}
