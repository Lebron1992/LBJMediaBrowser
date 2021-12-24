import XCTest
@testable import LBJMediaBrowser

final class StorageExpirationTests: BaseTestCase {
  func test_expirationDateSince() {
    let now = Date()
    XCTAssertEqual(
      StorageExpiration.never.expirationDateSince(now),
      .distantFuture
    )
    XCTAssertEqual(
      StorageExpiration.seconds(10).expirationDateSince(now),
      now.addingTimeInterval(10)
    )
    XCTAssertEqual(
      StorageExpiration.days(1).expirationDateSince(now),
      now.addingTimeInterval(TimeConstants.secondsInOneDay)
    )

    let newDate = now.addingTimeInterval(100)
    XCTAssertEqual(
      StorageExpiration.date(newDate).expirationDateSince(now),
      newDate
    )
  }
}
