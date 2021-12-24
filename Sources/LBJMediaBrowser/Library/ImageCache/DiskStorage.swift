import Foundation

final class DiskStorage<T: DataConvertible> {

  let config: Config
  let directoryUrl: URL

  init(config: Config) throws {
    self.config = config

    guard let cacheDirectory = config.fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask).first
    else {
      throw LBJMediaBrowserError.cacheError(reason: .cannotCreateCacheDirectory)
    }

    let directoryUrl = cacheDirectory.appendingPathComponent(
      "com.lebron.LBJMediaBrowser.DiskStorage.\(config.name)",
      isDirectory: true
    )

    if config.fileManager.fileExists(atPath: directoryUrl.path) == false {
      try config.fileManager.createDirectory(
        at: directoryUrl,
        withIntermediateDirectories: true,
        attributes: nil
      )
    }

    self.directoryUrl = directoryUrl
  }

  // MARK: - Store & Get Value

  func store(_ value: T, forKey key: String, referenceDate: Date = Date()) throws {
    let data = try value.toData()
    let fileUrl = cacheFileUrl(forKey: key)

    try data.write(to: fileUrl)

    do {
      try updateCreationAndModificationDateForFile(at: fileUrl, referenceDate: referenceDate)
    } catch {
      try? config.fileManager.removeItem(at: fileUrl)
    }
  }

  func value(forKey key: String, referenceDate: Date = Date()) throws -> T? {
    let fileUrl = cacheFileUrl(forKey: key)

    guard config.fileManager.fileExists(atPath: fileUrl.path) else {
      return nil
    }

    let meta = try FileMeta(fileUrl: fileUrl, resourceKeys: [.contentModificationDateKey])

    if meta.isExpired(referenceDate: referenceDate) {
      return nil
    }

    let data = try Data(contentsOf: fileUrl)
    let obj = try T.fromData(data)

    try? updateCreationAndModificationDateForFile(at: fileUrl, referenceDate: referenceDate)

    return obj
  }

  func persistedFileURLs(with propertyKeys: [URLResourceKey] = []) throws -> [URL] {
    config.fileManager.enumerator(
      at: directoryUrl,
      includingPropertiesForKeys: propertyKeys,
      options: .skipsHiddenFiles
    )?
      .allObjects as? [URL] ?? []
  }

  func totalSize() throws -> UInt {
    let propertyKeys: [URLResourceKey] = [.fileSizeKey]

    let totalSize: UInt = try persistedFileURLs(with: propertyKeys)
      .reduce(0) {
        let meta = try? FileMeta(fileUrl: $1, resourceKeys: Set(propertyKeys))
        return $0 + (meta?.fileSize ?? 0)
      }

    return totalSize
  }

  func resourceValues(forKey key: String) throws -> URLResourceValues {
    let fileUrl = cacheFileUrl(forKey: key)
    return try fileUrl.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
  }

  // MARK: - Remove Value

  func removeValue(forKey key: String) throws {
    let fileUrl = cacheFileUrl(forKey: key)
    try removeFile(at: fileUrl)
  }

  func removeFile(at url: URL) throws {
    try config.fileManager.removeItem(at: url)
  }

  @discardableResult
  func removeExpiredValues(referenceDate: Date = Date()) throws -> [URL] {
    let propertyKeys: [URLResourceKey] = [.contentModificationDateKey]

    let expiredFiles = try persistedFileURLs(with: propertyKeys)
      .filter {
        let meta = try? FileMeta(fileUrl: $0, resourceKeys: Set(propertyKeys))
        return meta?.isExpired(referenceDate: referenceDate) ?? true
      }

    try expiredFiles.forEach { try removeFile(at: $0) }

    return expiredFiles
  }

  @discardableResult
  func removeValuesToHalfSizeIfSizeExceeded() throws -> [URL] {

    // no limit
    if config.sizeLimit == 0 { return [] }

    // not exceeded
    var size = try totalSize()
    if size < config.sizeLimit { return [] }

    // remove exceeded values

    let propertyKeys: [URLResourceKey] = [
      .creationDateKey,
      .fileSizeKey
    ]

    var pendings: [FileMeta] = try persistedFileURLs(with: propertyKeys)
      .compactMap { try? FileMeta(fileUrl: $0, resourceKeys: Set(propertyKeys)) }
      .sorted { lhs, rhs in
        if let lAccessDate = lhs.lastAccessDate, let rAccessDate = rhs.lastAccessDate {
          return lAccessDate > rAccessDate
        }
        return false
      }

    var removed: [URL] = []
    let targetSize = config.sizeLimit / 2
    while size > targetSize, let meta = pendings.popLast() {
      size -= meta.fileSize
      try removeFile(at: meta.fileUrl)
      removed.append(meta.fileUrl)
    }

    return removed
  }

  func removeAll(containsDirectory: Bool = false) throws {
    try config.fileManager.removeItem(at: directoryUrl)

    guard containsDirectory == false,
          config.fileManager.fileExists(atPath: directoryUrl.path) == false
    else {
      return
    }

    try config.fileManager.createDirectory(
      at: directoryUrl,
      withIntermediateDirectories: true,
      attributes: nil
    )
  }

  // MARK: - Private

  private func updateCreationAndModificationDateForFile(at url: URL, referenceDate: Date = Date()) throws {
    let attrs: [FileAttributeKey: Any] = [
      .creationDate: referenceDate,
      .modificationDate: config.expiration.expirationDateSince(referenceDate)
    ]
    try config.fileManager.setAttributes(attrs, ofItemAtPath: url.path)
  }

  private func cacheFileUrl(forKey key: String) -> URL {
    let fileName = cacheFileName(forKey: key)
    return directoryUrl.appendingPathComponent(fileName, isDirectory: false)
  }

  private func cacheFileName(forKey key: String) -> String {
    key.md5
  }
}

// MARK: - FileMeta
extension DiskStorage {
  /// Store some metadata for a file.
  /// We consider `contentModificationDate` as `expirationDate`,  `creationDate` as `lastAccessDate`.
  struct FileMeta {
    let fileUrl: URL
    let lastAccessDate: Date?
    let expirationDate: Date?
    let fileSize: UInt

    init(fileUrl: URL, resourceKeys: Set<URLResourceKey>) throws {
      let meta = try fileUrl.resourceValues(forKeys: resourceKeys)
        self.init(
          fileUrl: fileUrl,
          lastAccessDate: meta.creationDate,
          expirationDate: meta.contentModificationDate,
          fileSize: UInt(meta.fileSize ?? 0)
        )
    }

    init(
      fileUrl: URL,
      lastAccessDate: Date?,
      expirationDate: Date?,
      fileSize: UInt
    ) {
      self.fileUrl = fileUrl
      self.lastAccessDate = lastAccessDate
      self.expirationDate = expirationDate
      self.fileSize = fileSize
    }

    func isExpired(referenceDate: Date) -> Bool {
      expirationDate?.isPast(referenceDate: referenceDate) ?? true
    }
  }
}

// MARK: - Config
extension DiskStorage {
  struct Config {
    let name: String
    let fileManager: FileManager
    let sizeLimit: UInt
    let expiration: StorageExpiration

    init(
      name: String,
      fileManager: FileManager = .default,
      sizeLimit: UInt = 0,
      expiration: StorageExpiration = .days(7)
    ) {
      self.name = name
      self.fileManager = fileManager
      self.sizeLimit = sizeLimit
      self.expiration = expiration
    }
  }
}
