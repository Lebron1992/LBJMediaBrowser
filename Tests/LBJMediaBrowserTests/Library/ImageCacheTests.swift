import XCTest
@testable import LBJMediaBrowser

final class ImageCacheTests: BaseTestCase {

  private let expirationDuration: TimeInterval = 6.0
  private var imageCountInDisk = 6

  private var imageCountInMemory = 4
  private var preferredMemoryImageCountAfterPurge = 3

  private var uiImage: UIImage!
  private var imageSizeInFile: UInt!

  private var cache: ImageCache!

  override func setUp() {
    super.setUp()

    uiImage = image(forResource: "unicorn", withExtension: "png")
    imageSizeInFile = 43864

    let config = ImageDiskStorage.Config(
      name: "DiskStorageTests.StringDiskStorage",
      sizeLimit: imageSizeInFile * UInt(imageCountInDisk),
      expiration: .seconds(expirationDuration)
    )
    let diskStorage = try! ImageDiskStorage(config: config)

    let memoryStorage = ImageMemoryStorage(
      memoryCapacity: uiImage.cacheSize * UInt(imageCountInMemory),
      preferredMemoryCapacityAfterPurge: uiImage.cacheSize * UInt(preferredMemoryImageCountAfterPurge)
    )

    cache = ImageCache(diskStorage: diskStorage, memoryStorage: memoryStorage)
  }

  override func tearDown() {
    try? cache.clearDiskCache(containsDirectory: true)
    super.tearDown()
  }

  func test_storeAndGetImage_inMemory() {
    cache.store(uiImage, forKey: "1", inMemory: true, inDisk: false)
    XCTAssertEqual(cache.image(forKey: "1", fromMemory: true, fromDsik: false), uiImage)
    XCTAssertNil(cache.image(forKey: "1", fromMemory: false, fromDsik: true))
  }

  func test_storeAndGetImage_inDisk() {
    cache.store(uiImage, forKey: "1", inMemory: false, inDisk: true)
    XCTAssertEqual(cache.image(forKey: "1", fromMemory: false, fromDsik: true)?.cacheSize, uiImage.cacheSize)
    XCTAssertNil(cache.image(forKey: "1", fromMemory: true, fromDsik: false))
  }

  func test_storeAndGetImage_inMemoryDisk() {
    cache.store(uiImage, forKey: "1", inMemory: true, inDisk: true)
    XCTAssertEqual(cache.image(forKey: "1", fromMemory: true, fromDsik: false), uiImage)
    XCTAssertEqual(cache.image(forKey: "1", fromMemory: false, fromDsik: true)?.cacheSize, uiImage.cacheSize)
  }

  func test_clearDiskCache_containsDirectory() throws {
    cache.store(uiImage, forKey: "1")
    XCTAssertFalse(cache.isDiskCacheRemoved(containsDirectory: true))

    try cache.clearDiskCache(containsDirectory: true)
    XCTAssertTrue(cache.isDiskCacheRemoved(containsDirectory: true))
  }

  func test_clearDiskCache_notContainsDirectory() throws {
    cache.store(uiImage, forKey: "1")
    XCTAssertFalse(cache.isDiskCacheRemoved(containsDirectory: false))

    try cache.clearDiskCache(containsDirectory: false)
    XCTAssertTrue(cache.isDiskCacheRemoved(containsDirectory: false))
  }

  func test_clearExpiredDiskCache() throws {
    let now = Date()
    cache.store(uiImage, forKey: "1", inMemory: false, referenceDate: now)
    cache.store(uiImage, forKey: "2", inMemory: false, referenceDate: now.addingTimeInterval(2))
    cache.store(uiImage, forKey: "3", inMemory: false, referenceDate: now.addingTimeInterval(4))

    try cache.clearExpiredDiskCache(referenceDate: now.addingTimeInterval(expirationDuration + 3))

    XCTAssertNil(cache.image(forKey: "1"))
    XCTAssertNil(cache.image(forKey: "2"))
    XCTAssertNotNil(cache.image(forKey: "3"))
  }

  func test_diskStorageSize() {
    cache.store(uiImage, forKey: "1")
    cache.store(uiImage, forKey: "2")
    XCTAssertEqual(cache.diskStorageSize(), UInt(imageSizeInFile * 2))
  }

  func test_appwillTerminate() {
    let now = Date()
    cache.store(uiImage, forKey: "1", inMemory: false, referenceDate: now)
    cache.store(uiImage, forKey: "2", inMemory: false, referenceDate: now.addingTimeInterval(2))

    for i in 4...10 {
      cache.store(uiImage, forKey: "\(i)", inMemory: false, referenceDate: now.addingTimeInterval(TimeInterval(i)))
    }

    NotificationCenter.default.post(
      name: UIApplication.willTerminateNotification,
      object: now.addingTimeInterval(3),
      userInfo: nil
    )

    XCTAssertNil(cache.image(forKey: "1"))
    XCTAssertNil(cache.image(forKey: "2"))

    for i in 4...7 {
      XCTAssertNil(cache.image(forKey: "\(i)"))
    }

    for i in 8...10 {
      XCTAssertNotNil(cache.image(forKey: "\(i)"))
    }
  }
}
