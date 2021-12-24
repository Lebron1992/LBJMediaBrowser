import XCTest
@testable import LBJMediaBrowser

extension String: CacheSizeCalculable {
  public var cacheSize: UInt {
    UInt(count)
  }
}

final class AutoPurgingMemoryStorageTests: BaseTestCase {

  typealias StringMemoryStorage = AutoPurgingMemoryStorage<String>

  private let memoryCapacity: UInt = 8
  private let preferredMemoryCapacityAfterPurge: UInt = 6

  private var storage: StringMemoryStorage!

  override func setUp() {
    super.setUp()
    storage = StringMemoryStorage(
      memoryCapacity: memoryCapacity,
      preferredMemoryCapacityAfterPurge: preferredMemoryCapacityAfterPurge
    )
  }

  func test_defaultInit() {
    storage = StringMemoryStorage()
    XCTAssertEqual(storage.memoryCapacity, 100_000_000)
    XCTAssertEqual(storage.preferredMemoryCapacityAfterPurge, 80_000_000)
  }

  func test_addAndGetValue() {
    storage.add("1", forKey: "1")
    XCTAssertEqual(storage.value(forKey: "1"), "1")
  }

  func test_addValue_currentMemoryUsageGotUpdated() {
    storage.add("1", forKey: "1")
    XCTAssertEqual(storage.currentMemoryUsage, 1)

    storage.add("11", forKey: "1")
    XCTAssertEqual(storage.currentMemoryUsage, 2)

    storage.add("2", forKey: "2")
    XCTAssertEqual(storage.currentMemoryUsage, 3)
  }

  func test_addValue_memoryUsageAutoPurged() {
    // storage is full
    for i in 0..<memoryCapacity {
      let s = String(i)
      storage.add(s, forKey: s)
    }

    // add another one to trigger auto purge
    let string = "\(memoryCapacity)"
    storage.add(string, forKey: string)

    XCTAssertEqual(storage.currentMemoryUsage, preferredMemoryCapacityAfterPurge)

    for i in 3..<(memoryCapacity + 1) {
      let s = String(i)
      XCTAssertEqual(storage.value(forKey: s), s)
    }
  }

  func test_removeValue() {
    storage.add("1", forKey: "1")
    storage.add("2", forKey: "2")

    storage.removeValue(forKey: "1")

    XCTAssertNil(storage.value(forKey: "1"))
    XCTAssertEqual(storage.value(forKey: "2"), "2")
  }

  func test_removeValue_currentMemoryUsageGotUpdated() {
    storage.add("1", forKey: "1")
    storage.add("2", forKey: "2")
    XCTAssertEqual(storage.currentMemoryUsage, 2)

    storage.removeValue(forKey: "1")
    XCTAssertEqual(storage.currentMemoryUsage, 1)
  }

  func test_removeAllValues() {
    for i in 0..<memoryCapacity {
      let s = String(i)
      storage.add(s, forKey: s)
    }
    XCTAssertEqual(storage.currentMemoryUsage, memoryCapacity)

    storage.removeAllValues()
    XCTAssertEqual(storage.currentMemoryUsage, 0)

    for i in 0..<memoryCapacity {
      XCTAssertNil(storage.value(forKey: "\(i)"))
    }
  }

  func test_receiveMemoryWarningNotification() {
    for i in 0..<memoryCapacity {
      let s = String(i)
      storage.add(s, forKey: s)
    }
    XCTAssertEqual(storage.currentMemoryUsage, memoryCapacity)

    let notification = Notification(
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil, userInfo: nil
    )
    NotificationCenter.default.post(notification)

    XCTAssertEqual(storage.currentMemoryUsage, 0)

    for i in 0..<memoryCapacity {
      XCTAssertNil(storage.value(forKey: "\(i)"))
    }
  }
}
