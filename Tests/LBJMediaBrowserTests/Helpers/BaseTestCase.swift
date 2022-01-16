import XCTest

private let lock = NSLock()

class BaseTestCase: XCTestCase {
  func url(forResource fileName: String, withExtension ext: String) -> URL {
    return Bundle.module.url(forResource: fileName, withExtension: ext)!
  }

  func image(forResource fileName: String, withExtension ext: String) -> UIImage {
    let resourceURL = url(forResource: fileName, withExtension: ext)
    let data = try! Data(contentsOf: resourceURL)
    lock.lock()
    let image = UIImage(data: data)
    lock.unlock()
    return image!
  }
}
