import XCTest
@testable import LBJMediaBrowser

final class ImageCacheTests: BaseTestCase {

  private let expirationDuration: TimeInterval = 6.0
  private var imageCountInDisk = 6

  private var imageCountInMemory = 4
  private var preferredMemoryImageCountAfterPurge = 3

  private var uiImage: UIImage!

  private var cache: ImageCache!

  override func setUp() {
    super.setUp()

    uiImage = image(forResource: "unicorn", withExtension: "png")

    let config = ImageDiskStorage.Config(
      name: "DiskStorageTests.StringDiskStorage",
      sizeLimit: uiImage.cacheSize * UInt(imageCountInDisk),
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
    cache.clearDiskCache(containsDirectory: true)
    super.tearDown()
  }

  func test_storeAndGetImage_inMemory() {
    cache.store(.still(uiImage), forKey: "1", inMemory: true, inDisk: false)

    wait(interval: 0.5) { [unowned self] in
      cache.image(forKey: "1", fromMemory: true, fromDsik: false) { [unowned self] result in
        XCTAssertEqual(try! result.get(), .still(uiImage))
      }
      cache.image(forKey: "1", fromMemory: false, fromDsik: true) { result in
        XCTAssertNil(try? result.get())
      }
    }
  }

  func test_storeAndGetImage_inDisk() {
    cache.store(.still(uiImage), forKey: "1", inMemory: false, inDisk: true)

    wait(interval: 0.5) { [unowned self] in
      cache.image(forKey: "1", fromMemory: false, fromDsik: true) { [unowned self] result in
        XCTAssertEqual((try! result.get()).cacheSize, uiImage.cacheSize)
      }
      cache.image(forKey: "1", fromMemory: true, fromDsik: false) { result in
        XCTAssertNil(try? result.get())
      }
    }
  }

  func test_storeAndGetImage_inMemoryDisk() {
    cache.store(.still(uiImage), forKey: "1", inMemory: true, inDisk: true)

    wait(interval: 0.5) { [unowned self] in
      cache.image(forKey: "1", fromMemory: true, fromDsik: false) { [unowned self] result in
        XCTAssertEqual(try! result.get(), .still(uiImage))
      }
      cache.image(forKey: "1", fromMemory: false, fromDsik: true) { [unowned self] result in
        XCTAssertEqual((try! result.get()).cacheSize, uiImage.cacheSize)
      }
    }
  }

  func test_clearDiskCache_containsDirectory() throws {
    cache.store(.still(uiImage), forKey: "1")
    XCTAssertFalse(cache.isDiskCacheRemoved(containsDirectory: true))

    wait(interval: 0.5) { [unowned self] in
      cache.clearDiskCache(containsDirectory: true)
    }

    wait(interval: 0.5) { [unowned self] in
      XCTAssertTrue(cache.isDiskCacheRemoved(containsDirectory: true))
    }
  }

  func test_clearDiskCache_notContainsDirectory() throws {
    cache.store(.still(uiImage), forKey: "1")
    wait(interval: 0.5) { [unowned self] in
      XCTAssertFalse(cache.isDiskCacheRemoved(containsDirectory: false))
    }

    cache.clearDiskCache(containsDirectory: false)
    wait(interval: 0.5) { [unowned self] in
      XCTAssertTrue(cache.isDiskCacheRemoved(containsDirectory: false))
    }
  }

  func test_clearExpiredDiskCache() throws {
    let now = Date()
    cache.store(.still(uiImage), forKey: "1", inMemory: false, referenceDate: now)
    cache.store(.still(uiImage), forKey: "2", inMemory: false, referenceDate: now.addingTimeInterval(2))
    cache.store(.still(uiImage), forKey: "3", inMemory: false, referenceDate: now.addingTimeInterval(4))

    wait(interval: 0.5) { [unowned self] in
      cache.clearExpiredDiskCache(referenceDate: now.addingTimeInterval(expirationDuration + 3.5))
    }

    wait(interval: 0.5) { [unowned self] in
      cache.image(forKey: "1") { result in
        XCTAssertNil(try? result.get())
      }
      cache.image(forKey: "2") { result in
        XCTAssertNil(try? result.get())
      }
      cache.image(forKey: "3") { result in
        XCTAssertNotNil(try? result.get())
      }
    }
  }

  func test_diskStorageSize() {
    cache.store(.still(uiImage), forKey: "1")
    cache.store(.still(uiImage), forKey: "2")

    wait(interval: 0.5) { [unowned self] in
      XCTAssertEqual(cache.diskStorageSize(), UInt(uiImage.cacheSize * 2))
    }
  }

  func test_appwillTerminate() {
    let now = Date()
    cache.store(.still(uiImage), forKey: "1", inMemory: false, referenceDate: now)
    cache.store(.still(uiImage), forKey: "2", inMemory: false, referenceDate: now.addingTimeInterval(2))

    for i in 4...10 {
      cache.store(.still(uiImage), forKey: "\(i)", inMemory: false, referenceDate: now.addingTimeInterval(TimeInterval(i)))
    }

    wait(interval: 0.5) {
      NotificationCenter.default.post(
        name: UIApplication.willTerminateNotification,
        object: now.addingTimeInterval(3),
        userInfo: nil
      )
    }

    wait(interval: 0.5) { [unowned self] in

      cache.image(forKey: "1", callbackQueue: .main) { result in
        XCTAssertNil(try? result.get())
      }
      cache.image(forKey: "2", callbackQueue: .main) { result in
        XCTAssertNil(try? result.get())
      }

      for i in 4...7 {
        cache.image(forKey: "\(i)", callbackQueue: .main) { result in
          XCTAssertNil(try? result.get())
        }
      }

      for i in 8...10 {
        cache.image(forKey: "\(i)", callbackQueue: .main) { result in
          XCTAssertNotNil(try! result.get())
        }
      }
    }
  }
}
