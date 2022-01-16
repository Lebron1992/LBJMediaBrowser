import XCTest
@testable import LBJMediaBrowser

final class MediaGifImageTests: BaseTestCase {

  private var gifData: Data!
  private var bundleGifImage: MediaGifImage!
  private var dataGifImage: MediaGifImage!

  override func setUp() {
    super.setUp()

    let url = url(forResource: "curry", withExtension: "gif")
    gifData = try! Data(contentsOf: url)

    bundleGifImage = .init(source: .bundle(name: "curry", bundle: .module))
    dataGifImage = .init(source: .data(gifData))
  }

  func test_stillImage() {
    XCTAssertEqual(
      bundleGifImage.stillImage?.pngData(),
      UIImage(data: gifData)?.pngData()
    )
    XCTAssertEqual(
      dataGifImage.stillImage?.pngData(),
      UIImage(data: gifData)?.pngData()
    )
  }

  func test_gifData() {
    XCTAssertEqual(
      bundleGifImage.gifData,
      gifData
    )
    XCTAssertEqual(
      dataGifImage.gifData,
      gifData
    )
  }
}
