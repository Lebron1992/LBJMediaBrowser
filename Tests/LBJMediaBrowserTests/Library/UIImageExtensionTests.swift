import XCTest
@testable import LBJMediaBrowser

final class UIImageExtensionTests: BaseTestCase {

  func test_isAnimatedImage() {
    let stillImageData = try! Data(contentsOf: url(forResource: "unicorn", withExtension: "png"))
    XCTAssertFalse(UIImage.isAnimatedImage(for: stillImageData))

    let gifImageData = try! Data(contentsOf: url(forResource: "curry", withExtension: "gif"))
    XCTAssertTrue(UIImage.isAnimatedImage(for: gifImageData))
  }
}
