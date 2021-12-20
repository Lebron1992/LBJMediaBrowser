import XCTest
@testable import LBJMediaBrowser

final class MediaImageStatusTests: XCTestCase {
  func test_isLoading() {
    XCTAssertFalse(MediaImageStatus.idle.isLoading)
    XCTAssertTrue(MediaImageStatus.loading(0.5).isLoading)
    XCTAssertFalse(MediaImageStatus.loaded(UIImage()).isLoading)
    XCTAssertFalse(MediaImageStatus.failed(NSError.unknownError).isLoading)
  }

  func test_isLoaded() {
    XCTAssertFalse(MediaImageStatus.idle.isLoaded)
    XCTAssertFalse(MediaImageStatus.loading(0.5).isLoaded)
    XCTAssertTrue(MediaImageStatus.loaded(UIImage()).isLoaded)
    XCTAssertFalse(MediaImageStatus.failed(NSError.unknownError).isLoaded)
  }

  func test_isLoadingOrLoaded() {
    XCTAssertFalse(MediaImageStatus.idle.isLoadingOrLoaded)
    XCTAssertTrue(MediaImageStatus.loading(0.5).isLoadingOrLoaded)
    XCTAssertTrue(MediaImageStatus.loaded(UIImage()).isLoadingOrLoaded)
    XCTAssertFalse(MediaImageStatus.failed(NSError.unknownError).isLoadingOrLoaded)
  }
}
