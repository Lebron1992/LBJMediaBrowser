import XCTest
@testable import LBJMediaBrowser

final class LBJGridMediaBrowserDataSourceTests: BaseTestCase {

  private var dataSource: LBJGridMediaBrowserDataSource<GridSectionTemplate>!

  override func setUp() {
    super.setUp()
    dataSource = LBJGridMediaBrowserDataSource(
      sections: [.uiImage, .urlImage]
    )
  }

  func test_numberOfMedias() {
    XCTAssertEqual(dataSource.numberOfMedias, 13)
  }

  func test_numberOfSections() {
    XCTAssertEqual(dataSource.numberOfSections, 2)
  }

  func test_numberOfMediasInSection() {
    XCTAssertEqual(dataSource.numberOfMedias(in: .uiImage), 3)
    XCTAssertEqual(dataSource.numberOfMedias(in: .urlImage), 10)
  }

  func test_mediasInSection() {
    XCTAssertEqual(
      dataSource.medias(in: .uiImage) as! [MediaUIImage],
      MediaUIImage.templates
    )
    XCTAssertEqual(
      dataSource.medias(in: .urlImage) as! [MediaURLImage],
      MediaURLImage.templates
    )
  }

  func test_mediaInSectionAtIndex() {
    XCTAssertEqual(
      dataSource.media(at: 0, in: .uiImage) as! MediaUIImage,
      MediaUIImage.templates[0]
    )

    XCTAssertNil(dataSource.media(at: -1, in: .uiImage))
    XCTAssertNil(dataSource.media(at: 4, in: .uiImage))
  }

  func test_append() {
    XCTAssertEqual(dataSource.numberOfSections, 2)
    dataSource.append(.urlVideo)
    XCTAssertEqual(dataSource.numberOfSections, 3)
  }

  func test_append_ignoredExisting() {
    XCTAssertEqual(dataSource.numberOfSections, 2)
    dataSource.append(.uiImage)
    XCTAssertEqual(dataSource.numberOfSections, 2)
  }

  func test_insertBefore() {
    XCTAssertEqual(dataSource.numberOfSections, 2)
    dataSource.insert(.urlVideo, before: .urlImage)

    XCTAssertEqual(dataSource.numberOfSections, 3)
    XCTAssertEqual(
      dataSource.sections,
      [GridSectionTemplate.uiImage, GridSectionTemplate.urlVideo, GridSectionTemplate.urlImage]
    )
  }

  func test_insertBefore_ignoredExisting() {
    XCTAssertEqual(dataSource.numberOfSections, 2)
    dataSource.insert(.uiImage, before: .urlImage)
    XCTAssertEqual(dataSource.numberOfSections, 2)
  }

  func test_insertAfter() {
    XCTAssertEqual(dataSource.numberOfSections, 2)

    dataSource.insert(.urlVideo, after: .uiImage)

    XCTAssertEqual(dataSource.numberOfSections, 3)
    XCTAssertEqual(
      dataSource.sections,
      [GridSectionTemplate.uiImage, GridSectionTemplate.urlVideo, GridSectionTemplate.urlImage]
    )
  }

  func test_insertAfter_ignoredExisting() {
    XCTAssertEqual(dataSource.numberOfSections, 2)
    dataSource.insert(.uiImage, after: .urlImage)
    XCTAssertEqual(dataSource.numberOfSections, 2)
  }
}
