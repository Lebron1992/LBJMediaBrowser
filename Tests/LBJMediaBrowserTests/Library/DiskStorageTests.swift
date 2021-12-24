import XCTest
@testable import LBJMediaBrowser

extension String: DataConvertible {
  public func toData() throws -> Data {
      return data(using: .utf8)!
  }
  public static func fromData(_ data: Data) throws -> String {
      return String(data: data, encoding: .utf8)!
  }
}

final class DiskStorageTests: BaseTestCase {

  typealias StringDiskStorage = DiskStorage<String>

  private let expirationDuration: TimeInterval = 6.0
  private var storage: StringDiskStorage!

  override func setUp() {
    super.setUp()
    let config = StringDiskStorage.Config(
      name: "DiskStorageTests.StringDiskStorage",
      sizeLimit: 6,
      expiration: .seconds(expirationDuration)
    )
    storage = try! StringDiskStorage(config: config)
  }

  override func tearDown() {
      try? storage?.removeAll(containsDirectory: true)
      super.tearDown()
  }

  func test_directoryUrl() {
    XCTAssertEqual(
      storage.directoryUrl.lastPathComponent,
      "com.lebron.LBJMediaBrowser.DiskStorage.DiskStorageTests.StringDiskStorage"
    )
  }

  func test_storeAndGetValue() throws {
    XCTAssertNil(try storage.value(forKey: "1"))
    try storage.store("1", forKey: "1")
    XCTAssertEqual(try storage.value(forKey: "1"), "1")
  }

  func test_storeValue_creationAndModificationDateGotUpdated() throws {
    let referenceDate = Date().addingTimeInterval(5)

    try storage.store("1", forKey: "1", referenceDate: referenceDate)
    let resourceValues = try storage.resourceValues(forKey: "1")

    XCTAssertEqual(
      resourceValues.creationDate,
      referenceDate
    )
    XCTAssertEqual(
      resourceValues.contentModificationDate,
      referenceDate.addingTimeInterval(expirationDuration)
    )
  }

  func test_valueForKey_returnNilIfExpired() throws {
    try storage.store("1", forKey: "1")
    XCTAssertNil(try storage.value(forKey: "1", referenceDate: Date().addingTimeInterval(expirationDuration + 1)))
  }

  func test_valueForKey_creationAndModificationDateGotUpdated() throws {
    let referenceDate = Date().addingTimeInterval(5)

    try storage.store("1", forKey: "1")
    let _ = try storage.value(forKey: "1", referenceDate: referenceDate)
    let resourceValues = try storage.resourceValues(forKey: "1")

    XCTAssertEqual(
      resourceValues.creationDate,
      referenceDate
    )
    XCTAssertEqual(
      resourceValues.contentModificationDate,
      referenceDate.addingTimeInterval(expirationDuration)
    )
  }

  func test_removeValue() throws {
    try storage.store("1", forKey: "1")
    XCTAssertEqual(try storage.value(forKey: "1"), "1")

    try storage.removeValue(forKey: "1")
    XCTAssertNil(try storage.value(forKey: "1"))
  }

  func test_removeExpiredValues() throws {
    let now = Date()
    try storage.store("1", forKey: "1")
    try storage.store("2", forKey: "2")
    try storage.store("3", forKey: "3", referenceDate: now.addingTimeInterval(2))

    let removed = try storage.removeExpiredValues(referenceDate: now.addingTimeInterval(expirationDuration + 1))
    XCTAssertEqual(removed.count, 2)
    XCTAssertEqual(try storage.value(forKey: "3"), "3")
  }

  func test_removeValuesToHalfSizeIfSizeExceeded() throws {
    let now = Date()

    for i in [1, 3, 5] {
      let s = "\(i)"
      try storage.store(s, forKey: s, referenceDate: now.addingTimeInterval(TimeInterval(i)))
    }

    for i in [2, 4, 6] {
      let s = "\(i)"
      try storage.store(s, forKey: s, referenceDate: now.addingTimeInterval(TimeInterval(i)))
    }

    for i in [7, 8, 9] {
      let s = "\(i)"
      try storage.store(s, forKey: s, referenceDate: now)
    }

    let removed = try storage.removeValuesToHalfSizeIfSizeExceeded()
    XCTAssertEqual(removed.count, 6)

    for i in [4, 5, 6] {
      let s = "\(i)"
      XCTAssertEqual(try storage.value(forKey: s), s)
    }

    for i in [1, 2, 3, 7, 8, 9] {
      let s = "\(i)"
      XCTAssertNil(try storage.value(forKey: s), s)
    }
  }

  func test_removeAll() throws {
    let count = 10

    for i in 0..<count {
      let s = String(i)
      try storage.store(s, forKey: s)
    }

    try storage.removeAll()

    print(try storage.persistedFileURLs(with: []))

    for i in 0..<count {
      let s = String(i)
      XCTAssertNil(try storage.value(forKey: s), s)
    }
  }

  func test_removeAll_containsDirectory() throws {
    try storage.store("1", forKey: "1")
    try storage.removeAll(containsDirectory: true)
    XCTAssertFalse(storage.config.fileManager.fileExists(atPath: storage.directoryUrl.path))
  }

  func test_removeAll_notContainsDirectory() throws {
    try storage.store("1", forKey: "1")
    try storage.removeAll(containsDirectory: false)
    XCTAssertTrue(storage.config.fileManager.fileExists(atPath: storage.directoryUrl.path))
  }

  func test_persistedFileURLs() throws {
    let count = 10

    for i in 0..<count {
      let s = String(i)
      try storage.store(s, forKey: s)
    }

    XCTAssertEqual(try storage.persistedFileURLs().count, count)
  }

  func test_totalSize() throws {
    let count: UInt = 10

    for i in 0..<count {
      let s = String(i)
      try storage.store(s, forKey: s)
    }

    XCTAssertEqual(try storage.totalSize(), count)
  }

  func test_FileMeta_isExpired() {
    let now = Date()
    let meta = StringDiskStorage.FileMeta(
      fileUrl: URL(string: "https://www.example.com/test.png")!,
      lastAccessDate: nil,
      expirationDate: now,
      fileSize: 1
    )
    XCTAssertTrue(meta.isExpired(referenceDate: now.addingTimeInterval(1)))
    XCTAssertFalse(meta.isExpired(referenceDate: now.addingTimeInterval(-1)))
  }
}
