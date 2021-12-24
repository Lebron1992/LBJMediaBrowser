import XCTest
@testable import LBJMediaBrowser

final class MD5StringTests: BaseTestCase {
  func test_md5() {
    XCTAssertEqual(
      "Hello".md5,
      "8b1a9953c4611296a827abf8c47804d7"
    )
  }
}
