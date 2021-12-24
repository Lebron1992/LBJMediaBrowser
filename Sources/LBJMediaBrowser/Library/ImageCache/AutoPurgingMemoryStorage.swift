import Foundation
import UIKit

final class AutoPurgingMemoryStorage<T: CacheSizeCalculable> {

  private let lock = NSLock()

  let memoryCapacity: UInt
  let preferredMemoryCapacityAfterPurge: UInt

  private var cachedObjects: [String: StorageObject<T>] = [:]
  private(set) var currentMemoryUsage: UInt = 0

  init(
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
