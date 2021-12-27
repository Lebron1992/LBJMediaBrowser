import Foundation

private let lock = NSLock()

struct SafeDictionary<Key: Hashable, Value> {

  private var dictionary: [Key: Value] = [:]

  subscript(key: Key) -> Value? {
    get {
      lock.lock()
      defer { lock.unlock() }
      return dictionary[key]
    }
    set {
      lock.lock()
      defer { lock.unlock() }
      dictionary[key] = newValue
    }
  }

  @discardableResult
  mutating func removeValue(forKey key: Key) -> Value? {
    lock.lock()
    defer { lock.unlock() }
    return dictionary.removeValue(forKey: key)
  }
}
