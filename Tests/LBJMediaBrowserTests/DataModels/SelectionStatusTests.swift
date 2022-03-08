import XCTest
@testable import LBJMediaBrowser

final class SelectionStatusTests: XCTestCase {

  func test_isDisabled() {
    XCTAssertTrue(SelectionStatus.disabled.isDisabled)
    XCTAssertFalse(SelectionStatus.unselected.isDisabled)
    XCTAssertFalse(SelectionStatus.selected.isDisabled)
  }

  func test_isSelected() {
    XCTAssertFalse(SelectionStatus.disabled.isSelected)
    XCTAssertFalse(SelectionStatus.unselected.isSelected)
    XCTAssertTrue(SelectionStatus.selected.isSelected)
  }
}
