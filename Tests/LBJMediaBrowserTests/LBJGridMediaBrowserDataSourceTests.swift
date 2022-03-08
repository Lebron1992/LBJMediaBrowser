import XCTest
@testable import LBJMediaBrowser

final class LBJGridMediaBrowserDataSourceTests: BaseTestCase {

  private let uiImageSection = TitledGridSection.uiImageTemplate
  private let urlImageSection = TitledGridSection.urlImageTemplate
  private let urlVideoSection = TitledGridSection.urlVideoTemplate

  private let newUrlImage = MediaURLImage(
    imageUrl: URL(string: "https://example.com/test.png")!,
    thumbnailUrl: URL(string: "https://example.com/test-thumbnail.png")!
  )

  private var multipleSectionDataSource: LBJGridMediaBrowserDataSource<TitledGridSection>!
  private var singleSectionDataSource: LBJGridMediaBrowserDataSource<SingleGridSection>!

  override func setUp() {
    super.setUp()
    multipleSectionDataSource = LBJGridMediaBrowserDataSource(
      sections: [uiImageSection, urlImageSection]
    )
    singleSectionDataSource = LBJGridMediaBrowserDataSource(
      medias: MediaUIImage.templates
    )
  }

  // MARK: - Manage Section

  func test_numberOfMedias() {
    XCTAssertEqual(multipleSectionDataSource.numberOfMedias, 13)
  }

  func test_numberOfSections() {
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
  }

  func test_numberOfMediasInSection() {
    XCTAssertEqual(multipleSectionDataSource.numberOfMedias(in: uiImageSection), 3)
    XCTAssertEqual(multipleSectionDataSource.numberOfMedias(in: urlImageSection), 10)
  }

  func test_mediasInSection() {
    XCTAssertEqual(
      multipleSectionDataSource.medias(in: uiImageSection) as! [MediaUIImage],
      MediaUIImage.templates
    )
    XCTAssertEqual(
      multipleSectionDataSource.medias(in: urlImageSection) as! [MediaURLImage],
      MediaURLImage.templates
    )
  }

  func test_mediaInSectionAtIndex() {
    XCTAssertEqual(
      multipleSectionDataSource.media(at: 0, in: uiImageSection) as! MediaUIImage,
      MediaUIImage.templates[0]
    )

    XCTAssertNil(multipleSectionDataSource.media(at: -1, in: uiImageSection))
    XCTAssertNil(multipleSectionDataSource.media(at: 4, in: uiImageSection))
  }

  func test_append() {
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
    multipleSectionDataSource.append(urlVideoSection)
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 3)
  }

  func test_append_ignoredExisting() {
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
    multipleSectionDataSource.append(uiImageSection)
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
  }

  func test_insertSection() {
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
    multipleSectionDataSource.insert(urlVideoSection, at: 1)

    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 3)
    XCTAssertEqual(
      multipleSectionDataSource.sections,
      [uiImageSection, urlVideoSection, urlImageSection]
    )
  }

  func test_insertSection_ignoredExisting() {
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
    multipleSectionDataSource.insert(uiImageSection, at: 1)
    XCTAssertEqual(multipleSectionDataSource.numberOfSections, 2)
  }

  func test_insertMediaInSection() {
    let section = multipleSectionDataSource.sections[1]
    XCTAssertEqual(section.medias.count, 10)

    multipleSectionDataSource.insert(newUrlImage, at: 0, in: section)

    XCTAssertEqual(
      multipleSectionDataSource.sections[1].medias.count,
      11
    )
    XCTAssertTrue(
      multipleSectionDataSource.sections[1].medias.first!.equalsTo(newUrlImage)
    )
  }

  func test_insertMediaInSection_ignoredExisting() {
    let section = multipleSectionDataSource.sections[1]
    XCTAssertEqual(section.medias.count, 10)

    multipleSectionDataSource.insert(section.medias[0], at: 0, in: section)

    XCTAssertEqual(
      multipleSectionDataSource.sections[1].medias.count,
      10
    )
  }

  func test_AppendMedias() {
    XCTAssertEqual(singleSectionDataSource.allMedias.count, 3)
    singleSectionDataSource.append(MediaURLImage.templates)
    XCTAssertEqual(singleSectionDataSource.allMedias.count, 13)
  }

  func test_insertMedia() {
    XCTAssertEqual(singleSectionDataSource.allMedias.count, 3)

    let newMedia = MediaURLImage.templates[0]
    singleSectionDataSource.insert(newMedia, at: 0)

    XCTAssertEqual(singleSectionDataSource.allMedias.count, 4)
    XCTAssertTrue(singleSectionDataSource.allMedias.first!.equalsTo(newMedia))
  }

  // MARK: - Handle Selection

  func test_selectAndDeselectMedia() {
    let image = MediaUIImage.templates[0]
    multipleSectionDataSource.select(image, in: uiImageSection)

    XCTAssertTrue(
      multipleSectionDataSource.selectedSectionMedias[uiImageSection]!
        .contains(where: { $0.equalsTo(image) })
    )

    multipleSectionDataSource.deselect(image, in: uiImageSection)

    XCTAssertFalse(
      multipleSectionDataSource.selectedSectionMedias[uiImageSection]!
        .contains(where: { $0.equalsTo(image) })
    )
  }

  func test_isMediaSelected() {
    let image = MediaUIImage.templates[0]
    multipleSectionDataSource.select(image, in: uiImageSection)

    XCTAssertTrue(multipleSectionDataSource.isMediaSelected(image, in: uiImageSection))
    XCTAssertTrue(multipleSectionDataSource.isMediaSelected(image))
  }

  func test_allSelectedMedias() {
    let uiImage = MediaUIImage.templates[0]
    let urlImage = MediaURLImage.templates[0]

    multipleSectionDataSource.select(uiImage, in: uiImageSection)
    multipleSectionDataSource.select(urlImage, in: urlImageSection)

    XCTAssertEqual(multipleSectionDataSource.allSelectedMedias.count, 2)
    XCTAssertTrue(multipleSectionDataSource.allSelectedMedias[0].equalsTo(uiImage))
    XCTAssertTrue(multipleSectionDataSource.allSelectedMedias[1].equalsTo(urlImage))
  }

  func test_selectedMediasInSection() {
    let uiImage = MediaUIImage.templates[0]

    multipleSectionDataSource.select(uiImage, in: uiImageSection)

    let selectedMedias = multipleSectionDataSource.selectedMedias(in: uiImageSection)
    XCTAssertEqual(selectedMedias.count, 1)
    XCTAssertTrue(selectedMedias[0].equalsTo(uiImage))
  }
}
