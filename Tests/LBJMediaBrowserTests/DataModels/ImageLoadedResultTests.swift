import XCTest
@testable import LBJMediaBrowser

final class ImageLoadedResultTests: BaseTestCase {
  
  private var uiImage: UIImage!
  private var gifData: Data!

  override func setUp() {
    super.setUp()
    uiImage = image(forResource: "unicorn", withExtension: "png")

    let url = url(forResource: "curry", withExtension: "gif")
    gifData = try! Data(contentsOf: url)
  }

  func test_stillImage() {
    XCTAssertEqual(
      ImageLoadedResult.still(uiImage).stillImage,
      uiImage
    )
    XCTAssertEqual(
      ImageLoadedResult.gif(gifData).stillImage?.pngData(),
      UIImage(data: gifData)?.pngData()
    )
  }

  func test_equatable() {
    XCTAssertEqual(
      ImageLoadedResult.still(uiImage),
      ImageLoadedResult.still(uiImage)
    )
    XCTAssertNotEqual(
      ImageLoadedResult.still(uiImage),
      ImageLoadedResult.still(UIImage())
    )

    XCTAssertEqual(
      ImageLoadedResult.gif(gifData),
      ImageLoadedResult.gif(gifData)
    )
    XCTAssertNotEqual(
      ImageLoadedResult.gif(gifData),
      ImageLoadedResult.gif(uiImage.pngData()!)
    )

    XCTAssertNotEqual(
      ImageLoadedResult.still(uiImage),
      ImageLoadedResult.gif(gifData)
    )
  }

  func test_toData() throws {
    XCTAssertEqual(
      try ImageLoadedResult.still(uiImage).toData(),
      uiImage.pngData()
    )
    XCTAssertEqual(
      try ImageLoadedResult.gif(gifData).toData(),
      gifData
    )
  }

  func test_fromData() throws {
    var result = try ImageLoadedResult.fromData(uiImage.pngData()!)
    XCTAssertEqual(result, .still(uiImage))

    result = try ImageLoadedResult.fromData(gifData)
    XCTAssertEqual(result, .gif(gifData))
  }
}
