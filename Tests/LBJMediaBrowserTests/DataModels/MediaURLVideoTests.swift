import XCTest
@testable import LBJMediaBrowser

final class MediaURLVideoTests: XCTestCase {
  func test_isTheSameAs() {
    let v1 = MediaURLVideo(
      previewImageUrl: .init(string: "https://www.example.com/test1.png"),
      videoUrl: .init(string: "https://www.example.com/test1.mp4")!
    )
    let v2 = MediaURLVideo(
      previewImageUrl: .init(string: "https://www.example.com/test2.png"),
      videoUrl: .init(string: "https://www.example.com/test2.mp4")!
    )
    XCTAssertTrue(v1.isTheSameAs(v1))
    XCTAssertFalse(v1.isTheSameAs(v2))
  }
}
