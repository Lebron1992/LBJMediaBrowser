import UIKit

public typealias ImageDiskStorage = DiskStorage<UIImage>
public typealias ImageMemoryStorage = AutoPurgingMemoryStorage<UIImage>

public final class ImageCache {

  public static let shared = ImageCache()

  private let diskStorage: ImageDiskStorage?
  private let memoryStorage: ImageMemoryStorage

  private let ioQueue: DispatchQueue = {
    let name = String(format: "com.lebron.LBJMediaBrowser.ImageCache.ioQueue.\(UUID().uuidString)")
    return DispatchQueue(label: name, attributes: .concurrent)
  }()

  public init(diskStorage: ImageDiskStorage, memoryStorage: ImageMemoryStorage = .init()) {
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
    _ image: UIImage,
    forKey key: String,
    inMemory: Bool = true,
    inDisk: Bool = true,
    referenceDate: Date = Date()
  ) {
    if inMemory {
      memoryStorage.add(image, forKey: key)
    }
    if inDisk {
      ioQueue.async { [unowned self] in
        try? diskStorage?.store(image, forKey: key, referenceDate: referenceDate)
      }
    }
  }

  func image(
    forKey key: String,
    fromMemory: Bool = true,
    fromDsik: Bool = true,
    callbackQueue: CallbackQueue = .current,
    completion: @escaping (Result<UIImage, LBJMediaBrowserError>) -> Void
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
    completion: @escaping (Result<UIImage, LBJMediaBrowserError>) -> Void
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

  public func clearDiskCache(containsDirectory: Bool = false) {
    ioQueue.async { [unowned self] in
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

  public func clearExpiredDiskCache(referenceDate: Date = Date()) {
    ioQueue.async { [unowned self] in
      let _ = try? diskStorage?.removeExpiredValues(referenceDate: referenceDate)
    }
  }

  public func diskStorageSize() -> UInt {
    ioQueue.sync { [unowned self] in
      return (try? diskStorage?.totalSize()) ?? 0
    }
  }

  @objc
  private func appwillTerminate(noti: Notification) {
    let referenceDate = (noti.object as? Date) ?? Date()
    clearExpiredDiskCache(referenceDate: referenceDate)
    ioQueue.async { [unowned self] in
      let _ = try? diskStorage?.removeValuesToHalfSizeIfSizeExceeded()
    }
  }
}
