import XCTest
@testable import LBJMediaBrowser

final class LBJPagingMediaBrowserDataSourceTests: BaseTestCase {

  private var dataSource: LBJPagingMediaBrowserDataSource!

  override func setUp() {
    super.setUp()
    dataSource = LBJPagingMediaBrowserDataSource(medias: MediaUIImage.templates)
  }

  func test_numberOfMedias() {
    XCTAssertEqual(dataSource.numberOfMedias, 3)
  }

  func test_mediaAtIndex() {
    XCTAssertEqual(
      dataSource.media(at: 0) as! MediaUIImage,
      MediaUIImage.templates[0]
    )
    XCTAssertNil(dataSource.media(at: -1))
    XCTAssertNil(dataSource.media(at: 4))
  }

  func test_append() {
    let newMedia = MediaURLImage.templates[0]
    dataSource.append(newMedia)
    XCTAssertTrue(dataSource.medias.last!.equalsTo(newMedia))
  }

  func test_append_ignoredExisting() {
    XCTAssertEqual(dataSource.numberOfMedias, 3)
    dataSource.append(MediaUIImage.templates.last!)
    XCTAssertEqual(dataSource.numberOfMedias, 3)
  }

  func test_insertBefore() {
    let newMedia = MediaURLImage.templates[0]
    XCTAssertEqual(dataSource.numberOfMedias, 3)
    dataSource.insert(newMedia, before: dataSource.medias[2])

    XCTAssertEqual(dataSource.numberOfMedias, 4)
    XCTAssertTrue(dataSource.medias[2].equalsTo(newMedia))
  }

  func test_insertBefore_ignoredExisting() {
    XCTAssertEqual(dataSource.numberOfMedias, 3)
    dataSource.insert(dataSource.medias[2], before: dataSource.medias[2])
    XCTAssertEqual(dataSource.numberOfMedias, 3)
  }

  func test_insertAfter() {
    let newMedia = MediaURLImage.templates[0]
    XCTAssertEqual(dataSource.numberOfMedias, 3)

    dataSource.insert(newMedia, after: dataSource.medias[1])

    XCTAssertEqual(dataSource.numberOfMedias, 4)
    XCTAssertTrue(dataSource.medias[2].equalsTo(newMedia))
  }

  func test_insertAfter_ignoredExisting() {
    XCTAssertEqual(dataSource.numberOfMedias, 3)
    dataSource.insert(dataSource.medias[1], after: dataSource.medias[1])
    XCTAssertEqual(dataSource.numberOfMedias, 3)
  }
}
