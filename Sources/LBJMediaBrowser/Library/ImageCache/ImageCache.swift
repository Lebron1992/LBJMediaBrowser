import UIKit

typealias ImageDiskStorage = DiskStorage<UIImage>
typealias ImageMemoryStorage = AutoPurgingMemoryStorage<UIImage>

final class ImageCache {

  static let shared = ImageCache()

  private let diskStorage: ImageDiskStorage?
  private let memoryStorage: ImageMemoryStorage

  init(diskStorage: ImageDiskStorage, memoryStorage: ImageMemoryStorage = .init()) {
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
      try? diskStorage?.store(image, forKey: key, referenceDate: referenceDate)
    }
  }

  func image(
    forKey key: String,
    fromMemory: Bool = true,
    fromDsik: Bool = true
  ) -> UIImage? {
    if fromMemory && fromDsik {
      return memoryStorage.value(forKey: key) ?? (try? diskStorage?.value(forKey: key))
    }
    if fromMemory {
      return memoryStorage.value(forKey: key)
    }
    if fromDsik {
      return try? diskStorage?.value(forKey: key)
    }
    return nil
  }

  func clearDiskCache(containsDirectory: Bool = false) throws {
    try diskStorage?.removeAll(containsDirectory: containsDirectory)
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

  func clearExpiredDiskCache(referenceDate: Date = Date()) throws {
    try diskStorage?.removeExpiredValues(referenceDate: referenceDate)
  }

  func diskStorageSize() -> UInt {
    (try? diskStorage?.totalSize()) ?? 0
  }

  @objc
  private func appwillTerminate(noti: Notification) {
    let referenceDate = (noti.object as? Date) ?? Date()
    try? clearExpiredDiskCache(referenceDate: referenceDate)
    let _ = try? diskStorage?.removeValuesToHalfSizeIfSizeExceeded()
  }
}
