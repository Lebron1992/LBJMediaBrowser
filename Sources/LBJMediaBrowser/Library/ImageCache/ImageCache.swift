import UIKit

/// 一个可以把图片缓存到磁盘中的类型。Represents a storage type that can cache images  on disk.
public typealias ImageDiskStorage = DiskStorage<ImageLoadedResult>

/// 一个可以把图片缓存到内存中的类型。Represents a storage type that can cache images in memory.
public typealias ImageMemoryStorage = AutoPurgingMemoryStorage<ImageLoadedResult>

/// `ImageCache` 是一个由 `ImageDiskStorage` 和 `ImageMemoryStorage` 组成的图片缓存系统。
/// `ImageCache` is an image cache system which is composed by a `ImageDiskStorage` and a `ImageMemoryStorage`.
public final class ImageCache {

  /// 共享的 `ImageCache` 单例。
  /// A shared singleton `ImageCache` object.
  public static let shared = ImageCache()

  private let diskStorage: ImageDiskStorage?
  private let memoryStorage: ImageMemoryStorage

  private let ioQueue: DispatchQueue = {
    let name = String(format: "com.lebron.LBJMediaBrowser.ImageCache.ioQueue.\(UUID().uuidString)")
    return DispatchQueue(label: name, attributes: .concurrent)
  }()

  /// 创建 `ImageCache` 对象。
  /// Creates an `ImageCache` object.
  /// - Parameters:
  ///   - diskStorage: `ImageDiskStorage` 对象。An `ImageDiskStorage` object.
  ///   - memoryStorage: `ImageMemoryStorage` 对象。An `ImageMemoryStorage` object.
  public init(diskStorage: ImageDiskStorage?, memoryStorage: ImageMemoryStorage) {
    self.diskStorage = diskStorage
    self.memoryStorage = memoryStorage
    commonInit()
  }

  init() {
    diskStorage = try? ImageDiskStorage(config: .init(name: "ImageCache"))
    memoryStorage = .init()
    commonInit()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func commonInit() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appwillTerminate(noti:)),
      name: UIApplication.willTerminateNotification,
      object: nil
    )
  }

  func store(
    _ image: ImageLoadedResult,
    forKey key: String,
    inMemory: Bool = true,
    inDisk: Bool = true,
    referenceDate: Date = Date()
  ) {
    if inMemory {
      memoryStorage.add(image, forKey: key)
    }
    if inDisk {
      ioQueue.async(flags: .barrier) { [unowned self] in
        try? diskStorage?.store(image, forKey: key, referenceDate: referenceDate)
      }
    }
  }

  func image(
    forKey key: String,
    fromMemory: Bool = true,
    fromDsik: Bool = true,
    callbackQueue: CallbackQueue = .current,
    completion: @escaping (Result<ImageLoadedResult, LBJMediaBrowserError>) -> Void
  ) {
    if fromMemory && fromDsik {
      if let image = memoryStorage.value(forKey: key) {
        callbackQueue.execute { completion(.success(image)) }
        return
      }
      asyncGetImageFromDisk(forKey: key, callbackQueue: callbackQueue, completion: completion)
      return
    }

    if fromMemory {
      if let image = memoryStorage.value(forKey: key) {
        callbackQueue.execute { completion(.success(image)) }
      } else {
        callbackQueue.execute {
          completion(.failure(.cacheError(
          reason: .cannotGetValueForKey(key: key, errorDescription: "Can't find image from memory for key: \(key)")
        )))
        }
      }
      return
    }

    if fromDsik {
      asyncGetImageFromDisk(forKey: key, callbackQueue: callbackQueue, completion: completion)
    }
  }

  private func asyncGetImageFromDisk(
    forKey key: String,
    callbackQueue: CallbackQueue = .current,
    completion: @escaping (Result<ImageLoadedResult, LBJMediaBrowserError>) -> Void
  ) {
    ioQueue.async { [unowned self] in
      do {
        if let image = try diskStorage?.value(forKey: key) {
          callbackQueue.execute { completion(.success(image)) }
        } else {
          callbackQueue.execute {
            completion(.failure(.cacheError(
              reason: .cannotGetValueForKey(key: key, errorDescription: "Can't read file for key: \(key)")
            )))
          }
        }
      } catch {
        callbackQueue.execute {
          completion(.failure(.cacheError(
            reason: .cannotGetValueForKey(key: key, errorDescription: error.localizedDescription)
          )))
        }
      }
    }
  }

  /// 清理磁盘缓存。
  /// Clears the disk cache.
  public func clearDiskCache() {
    clearDiskCache(containsDirectory: false)
  }

  func clearDiskCache(containsDirectory: Bool = false) {
    ioQueue.async(flags: .barrier) { [unowned self] in
      try? diskStorage?.removeAll(containsDirectory: containsDirectory)
    }
  }

  func isDiskCacheRemoved(containsDirectory: Bool) -> Bool {
    guard let diskStorage = diskStorage else {
      fatalError("`diskStorage` is nil")
    }

    let isDirectoryExist = diskStorage.config.fileManager
      .fileExists(atPath: diskStorage.directoryUrl.path)

    if containsDirectory {
      return isDirectoryExist == false
    } else {
      do {
        return (try diskStorage.persistedFileURLs().isEmpty) && isDirectoryExist
      } catch {
        return false
      }
    }
  }

  /// 清理过期的缓存。
  /// Clears the expired disk cache.
  public func clearExpiredDiskCache() {
    clearExpiredDiskCache(referenceDate: Date())
  }

  func clearExpiredDiskCache(referenceDate: Date = Date()) {
    ioQueue.async(flags: .barrier) { [unowned self] in
      let _ = try? diskStorage?.removeExpiredValues(referenceDate: referenceDate)
    }
  }

  /// 获取磁盘缓存的大小。
  /// Get the cache size on disk.
  /// - Returns: 磁盘缓存的大小，单位是 byte。The cache size in bytes on disk.
  public func diskStorageSize() -> UInt {
    ioQueue.sync { [unowned self] in
      return (try? diskStorage?.totalSize()) ?? 0
    }
  }

  @objc
  private func appwillTerminate(noti: Notification) {
    let referenceDate = (noti.object as? Date) ?? Date()
    clearExpiredDiskCache(referenceDate: referenceDate)
    ioQueue.async(flags: .barrier) { [unowned self] in
      let _ = try? diskStorage?.removeValuesToHalfSizeIfSizeExceeded()
    }
  }
}
