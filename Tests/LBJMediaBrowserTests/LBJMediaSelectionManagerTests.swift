import XCTest
@testable import LBJMediaBrowser

final class LBJMediaSelectionManagerTests: BaseTestCase {

  private let uiImageSection = TitledMediaSection.uiImageTemplate
  private let urlImageSection = TitledMediaSection.urlImageTemplate
  private let urlVideoSection = TitledMediaSection.urlVideoTemplate

  private var imageSelectionManager: LBJMediaSelectionManager<TitledMediaSection>!
  private var videoSelectionManager: LBJMediaSelectionManager<TitledMediaSection>!
  private var anySelectionManager: LBJMediaSelectionManager<TitledMediaSection>!
  private var disableSelectionManager: LBJMediaSelectionManager<TitledMediaSection>!

  override func setUp() {
    super.setUp()
    imageSelectionManager = LBJMediaSelectionManager(selectionMode: .image(max: 2))
    videoSelectionManager = LBJMediaSelectionManager(selectionMode: .video(max: 2))
    anySelectionManager = LBJMediaSelectionManager(selectionMode: .any(max: 2))
    disableSelectionManager = LBJMediaSelectionManager(selectionMode: .disabled)
  }

  func test_selectAndDeselectMedia() {
    let image = MediaUIImage.templates[0]
    imageSelectionManager.select(image, in: uiImageSection)

    XCTAssertTrue(
      imageSelectionManager.selectedSectionMedias[uiImageSection]!
        .contains(where: { $0.equalsTo(image) })
    )

    imageSelectionManager.deselect(image, in: uiImageSection)

    XCTAssertFalse(
      imageSelectionManager.selectedSectionMedias[uiImageSection]!
        .contains(where: { $0.equalsTo(image) })
    )
  }

  func test_isMediaSelected() {
    let image = MediaUIImage.templates[0]
    imageSelectionManager.select(image, in: uiImageSection)

    XCTAssertTrue(imageSelectionManager.isMediaSelected(image, in: uiImageSection))
    XCTAssertTrue(imageSelectionManager.isMediaSelected(image))
  }

  func test_allSelectedMedias() {
    let uiImage = MediaUIImage.templates[0]
    let urlImage = MediaURLImage.templates[0]

    imageSelectionManager.select(uiImage, in: uiImageSection)
    imageSelectionManager.select(urlImage, in: urlImageSection)

    XCTAssertEqual(imageSelectionManager.allSelectedMedias.count, 2)
    XCTAssertTrue(imageSelectionManager.allSelectedMedias[0].equalsTo(uiImage))
    XCTAssertTrue(imageSelectionManager.allSelectedMedias[1].equalsTo(urlImage))
  }

  func test_selectedMediasInSection() {
    let uiImage = MediaUIImage.templates[0]

    imageSelectionManager.select(uiImage, in: uiImageSection)

    let selectedMedias = imageSelectionManager.selectedMedias(in: uiImageSection)
    XCTAssertEqual(selectedMedias.count, 1)
    XCTAssertTrue(selectedMedias[0].equalsTo(uiImage))
  }

  func test_selectionStatus() {
    let uiImage1 = MediaUIImage.templates[0]
    let uiImage2 = MediaUIImage.templates[1]
    let uiImage3 = MediaUIImage.templates[2]

    let urlVideo1 = MediaURLVideo.templates[0]
    let urlVideo2 = MediaURLVideo.templates[1]
    let urlVideo3 = MediaURLVideo.templates[2]

    // selectionMode = .image(max: 2)

    imageSelectionManager.select(uiImage1, in: uiImageSection)
    XCTAssertEqual(
      imageSelectionManager.selectionStatus(for: uiImage1, in: uiImageSection),
      .selected
    )
    XCTAssertEqual(
      imageSelectionManager.selectionStatus(for: uiImage2, in: uiImageSection),
      .unselected
    )
    XCTAssertEqual(
      imageSelectionManager.selectionStatus(for: urlVideo1, in: urlVideoSection),
      .disabled
    )

    imageSelectionManager.select(uiImage2, in: uiImageSection)
    XCTAssertEqual(
      imageSelectionManager.selectionStatus(for: uiImage2, in: uiImageSection),
      .selected
    )
    XCTAssertEqual(
      imageSelectionManager.selectionStatus(for: uiImage3, in: uiImageSection),
      .disabled
    )

    // selectionMode = .video(max: 2)

    videoSelectionManager.select(urlVideo1, in: urlVideoSection)
    XCTAssertEqual(
      videoSelectionManager.selectionStatus(for: urlVideo1, in: urlVideoSection),
      .selected
    )
    XCTAssertEqual(
      videoSelectionManager.selectionStatus(for: urlVideo2, in: urlVideoSection),
      .unselected
    )
    XCTAssertEqual(
      videoSelectionManager.selectionStatus(for: uiImage1, in: uiImageSection),
      .disabled
    )

    videoSelectionManager.select(urlVideo2, in: urlVideoSection)
    XCTAssertEqual(
      videoSelectionManager.selectionStatus(for: urlVideo2, in: urlVideoSection),
      .selected
    )
    XCTAssertEqual(
      videoSelectionManager.selectionStatus(for: urlVideo3, in: urlVideoSection),
      .disabled
    )

    // selectionMode = .any(max: 2)

    anySelectionManager.select(uiImage1, in: uiImageSection)
    XCTAssertEqual(
      anySelectionManager.selectionStatus(for: uiImage1, in: uiImageSection),
      .selected
    )
    XCTAssertEqual(
      anySelectionManager.selectionStatus(for: uiImage2, in: uiImageSection),
      .unselected
    )
    XCTAssertEqual(
      anySelectionManager.selectionStatus(for: urlVideo1, in: urlVideoSection),
      .unselected
    )

    // selectionMode = .disable
    disableSelectionManager.select(uiImage1, in: uiImageSection)
    disableSelectionManager.select(urlVideo1, in: urlVideoSection)
    XCTAssertEqual(
      disableSelectionManager.selectionStatus(for: uiImage1, in: uiImageSection),
      .disabled
    )
    XCTAssertEqual(
      disableSelectionManager.selectionStatus(for: urlVideo1, in: urlVideoSection),
      .disabled
    )
  }

  func test_mediaIsSelectable() {
    
    let uiImage1 = MediaUIImage.templates[0]
    let uiImage2 = MediaUIImage.templates[1]
    let uiImage3 = MediaUIImage.templates[2]
    
    let urlVideo1 = MediaURLVideo.templates[0]
    let urlVideo2 = MediaURLVideo.templates[1]
    let urlVideo3 = MediaURLVideo.templates[2]
    
    // selectionMode = .image(max: 2)
    
    XCTAssertTrue(imageSelectionManager.mediaIsSelectable(uiImage1))
    XCTAssertFalse(imageSelectionManager.mediaIsSelectable(urlVideo1))
    
    imageSelectionManager.select(uiImage1, in: uiImageSection)
    imageSelectionManager.select(uiImage2, in: uiImageSection)
    
    XCTAssertFalse(imageSelectionManager.mediaIsSelectable(uiImage3))
    
    // selectionMode = .video(max: 2)
    
    XCTAssertTrue(videoSelectionManager.mediaIsSelectable(urlVideo1))
    XCTAssertFalse(videoSelectionManager.mediaIsSelectable(uiImage1))
    
    videoSelectionManager.select(urlVideo1, in: urlVideoSection)
    videoSelectionManager.select(urlVideo2, in: urlVideoSection)
    
    XCTAssertFalse(videoSelectionManager.mediaIsSelectable(urlVideo3))
    
    // selectionMode = .any(max: 2)
    
    XCTAssertTrue(anySelectionManager.mediaIsSelectable(uiImage1))
    XCTAssertTrue(anySelectionManager.mediaIsSelectable(urlVideo1))
    
    anySelectionManager.select(uiImage1, in: uiImageSection)
    anySelectionManager.select(urlVideo1, in: urlVideoSection)
    
    XCTAssertFalse(anySelectionManager.mediaIsSelectable(uiImage2))
    XCTAssertFalse(anySelectionManager.mediaIsSelectable(urlVideo2))
    
    // selectionMode = .disable
    XCTAssertFalse(disableSelectionManager.mediaIsSelectable(uiImage1))
    XCTAssertFalse(disableSelectionManager.mediaIsSelectable(urlVideo1))
  }
}
