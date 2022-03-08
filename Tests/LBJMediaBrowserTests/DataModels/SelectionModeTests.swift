import XCTest
@testable import LBJMediaBrowser

final class SelectionModeTests: XCTestCase {

  func test_numberOfSelection() {
    XCTAssertEqual(
      SelectionMode.disabled.numberOfSelection,
      0
    )

    XCTAssertEqual(
      SelectionMode.image(max: nil).numberOfSelection,
      .max
    )
    XCTAssertEqual(
      SelectionMode.image(max: 5).numberOfSelection,
      5
    )

    XCTAssertEqual(
      SelectionMode.video(max: nil).numberOfSelection,
      .max
    )
    XCTAssertEqual(
      SelectionMode.video(max: 5).numberOfSelection,
      5
    )

    XCTAssertEqual(
      SelectionMode.any(max: nil).numberOfSelection,
      .max
    )
    XCTAssertEqual(
      SelectionMode.any(max: 5).numberOfSelection,
      5
    )
  }
}
