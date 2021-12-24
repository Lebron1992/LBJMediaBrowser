import XCTest
@testable import LBJMediaBrowser

final class DateExtensionTests: BaseTestCase {

  func test_isPast() {
    let now = Date()
    XCTAssertTrue(now.addingTimeInterval(-1).isPast)
    XCTAssertFalse(now.addingTimeInterval(1).isPast)
  }

  func test_isFuture() {
    let now = Date()
    XCTAssertFalse(now.addingTimeInterval(-1).isFuture)
    XCTAssertTrue(now.addingTimeInterval(1).isFuture)
  }

  func test_isPast_withReferenceDate() {
    let now = Date()
    XCTAssertFalse(now.isPast(referenceDate: now.addingTimeInterval(-1)))
    XCTAssertTrue(now.isPast(referenceDate: now.addingTimeInterval(1)))
  }
}
