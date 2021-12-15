import XCTest
@testable import LBJMediaBrowser

final class MediaURLImageTests: XCTestCase {
  private let urlImage = MediaURLImage(
    imageUrl: URL(string: "https://www.example.com/test.png")!,
    thumbnailUrl: URL(string: "https://www.example.com/test-thumbnail.png")!
  )

  func test_cacheKey() {
    XCTAssertEqual(
      urlImage.cacheKey(for: .thumbnail),
      urlImage.thumbnailUrl!.absoluteString
    )
    
    XCTAssertEqual(
      urlImage.cacheKey(for: .larger),
      urlImage.imageUrl.absoluteString
    )
  }
  
  func test_imageUrl() {
    XCTAssertEqual(
      urlImage.imageUrl(for: .thumbnail),
      urlImage.thumbnailUrl
    )
    
    XCTAssertEqual(
      urlImage.imageUrl(for: .larger),
      urlImage.imageUrl
    )
  }
}
