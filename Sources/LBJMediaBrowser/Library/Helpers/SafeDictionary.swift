import Foundation

struct SafeDictionary<Key: Hashable, Value> {

  private var dictionary: [Key: Value] = [:]
  private let lock = NSLock()

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
    dictionary.removeValue(forKey: key)
  }
}
