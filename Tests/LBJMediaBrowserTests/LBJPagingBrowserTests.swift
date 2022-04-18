import XCTest
@testable import LBJMediaBrowser

final class LBJPagingBrowserTests: BaseTestCase {

  private let mediaUIImage = MediaUIImage.templates[0]
  private let urlImage = MediaURLImage.templates[0]
  private let phAssetImage = MediaPHAssetImage.templatesMock[0]
  private let phAssetVideo = MediaPHAssetVideo.templatesMock[0]
  private let urlVideo = MediaURLVideo.templates[0]

  private var uiImage: UIImage!
  private let videoUrl = URL(string: "https://www.example.com/test.mp4")!

  private var browser: LBJPagingBrowser<SingleMediaSection>!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")
  }

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
}
