import Foundation
import UIKit

/// `AutoPurgingMemoryStorage` 是一个在内存中的缓存，
/// 用于存储遵循 `CacheSizeCalculable` 协议的对象，最大存储容量为给定的内存容量。
/// 当达到内存容量时，缓存按上次访问日期排序，然后持续清除最旧的对象，直到满足清除后的内存容量。
/// 每次通过缓存访问对象时，都会更新对象的内部访问日期。
/// The `AutoPurgingMemoryStorage` is an in-memory cache used to store the objects that
/// conforms to `CacheSizeCalculable` protocol up to a given memory capacity. When
/// the memory capacity is reached, the cache is sorted by last access date, then the oldest object is continuously
/// purged until the preferred memory usage after purge is met. Each time a object is accessed through the cache, the
/// internal access date of the object is updated.
public final class AutoPurgingMemoryStorage<T: CacheSizeCalculable> {

  private let lock = NSLock()

  let memoryCapacity: UInt
  let preferredMemoryCapacityAfterPurge: UInt

  private var cachedObjects: [String: StorageObject<T>] = [:]
  private(set) var currentMemoryUsage: UInt = 0

  /// 使用给定的缓存容量和清除后的缓存容量创建 `AutoPurgingMemoryStorage` 对象。
  /// Creates a `AutoPurgingMemoryStorage` object with the given memory capacity and preferred memory capacity
  /// after purge limit.
  /// - Parameters:
  ///   - memoryCapacity: 最大缓存容量，单位是 `byte`，默认是 `100MB`。The max memory capacity in bytes. `100 MB` by default。
  ///   - preferredMemoryCapacityAfterPurge: 清除后的缓存容量，单位是 `byte`，默认是 `80MB`。The preferred memory capacity after purge in bytes. `80 MB` by default.
  public init(
    memoryCapacity: UInt = 100_000_000,
    preferredMemoryCapacityAfterPurge: UInt = 80_000_000
  ) {
    self.memoryCapacity = memoryCapacity
    self.preferredMemoryCapacityAfterPurge = preferredMemoryCapacityAfterPurge

    precondition(
      memoryCapacity >= preferredMemoryCapacityAfterPurge,
      "The `memoryCapacity` must be greater than or equal to `preferredMemoryCapacityAfterPurge`"
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(removeAllValues),
      name: UIApplication.didReceiveMemoryWarningNotification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func add(_ value: T, forKey key: String) {
    lock.lock()
    defer { lock.unlock() }

    let newObject = StorageObject(value, key: key)

    if let lastCachedObject = cachedObjects[key] {
      currentMemoryUsage -= lastCachedObject.accessValue().cacheSize
    }

    cachedObjects[key] = newObject
    currentMemoryUsage += value.cacheSize

    if currentMemoryUsage > memoryCapacity {

      var pendings = cachedObjects
        .map { $1 }
        .sorted { $0.lastAccessDate > $1.lastAccessDate }

      let bytesToPurge = currentMemoryUsage - preferredMemoryCapacityAfterPurge
      var bytesPurged = UInt(0)
      while bytesToPurge > bytesPurged, let cachedObject = pendings.popLast() {
        cachedObjects.removeValue(forKey: cachedObject.key)
        bytesPurged += cachedObject.accessValue().cacheSize
      }

      currentMemoryUsage -= bytesPurged
    }
  }

  func value(forKey key: String) -> T? {
    lock.lock()
    defer { lock.unlock() }

    var value: T?

    if let cachedObject = cachedObjects[key] {
      value = cachedObject.accessValue()
    }

    return value
  }

  @discardableResult
  func removeValue(forKey key: String) -> T? {
    lock.lock()
    defer { lock.unlock() }

    var removed: T?

    if let value = cachedObjects.removeValue(forKey: key)?.accessValue() {
      currentMemoryUsage -= value.cacheSize
      removed = value
    }

    return removed
  }

  @discardableResult @objc
  func removeAllValues() -> Bool {
    lock.lock()
    defer { lock.unlock() }

    var removed = false

    if !cachedObjects.isEmpty {
      cachedObjects.removeAll()
      currentMemoryUsage = 0
      removed = true
    }

    return removed
  }
}

private extension AutoPurgingMemoryStorage {
  class StorageObject<T: CacheSizeCalculable> {
    private let value: T
    let key: String
    var lastAccessDate: Date

    init(_ value: T, key: String) {
      self.value = value
      self.key = key
      lastAccessDate = Date()
    }

    func accessValue() -> T {
      lastAccessDate = Date()
      return value
    }
  }
}
