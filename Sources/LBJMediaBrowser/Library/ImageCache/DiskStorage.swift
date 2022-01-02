import Foundation

/// `DiskStorage` 可以把遵循 `DataConvertible` 协议的对象存到磁盘中。
/// The `DiskStorage` is an disk cache used to store the objects that conforms to `DataConvertible` protocol.
public final class DiskStorage<T: DataConvertible> {

  let config: Config
  let directoryUrl: URL

  /// 使用给定的 `Config` 创建 `DiskStorage` 对象。
  /// Creates a `DiskStorage` object with the given `Config` object.
  /// - Parameters:
  ///   - config: 缓存设置的对象。The `Config` object for disk.
  public init(config: Config) throws {
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
  /// 表示磁盘缓存设置的类型。
  /// Represents the config info for `DiskStorage`.
  public struct Config {

    /// 用于存储文件夹名称的一部分，两个具有相同 `name` 的存储将共享磁盘中的同一文件夹。
    /// The name of disk storage which is used as a part of storage folder name.
    /// Two storages with the same `name` would share the same folder in disk.
    public let name: String

    /// 用于管理磁盘文件的 `FileManager` 的对象，默认是 `FileManager.default`。
    /// The `FileManager` used to manage files on disk. `FileManager.default` by default.
    public let fileManager: FileManager

    /// 磁盘缓存的总大小限制，单位是 `byte`，`0` 表示没有限制，默认是 `0`。
    /// The file size limit on disk in bytes. 0 means no limit. `0` by default.
    public let sizeLimit: UInt

    /// 文件的过期类型，默认是 `.days(7)`。
    /// The file expiration type. `.days(7)` by default.
    public let expiration: StorageExpiration

    /// 创建磁盘缓存设置。
    /// Creates a `Config` object.
    /// - Parameters:
    ///   - name: 用于存储文件夹名称的一部分，两个具有相同 `name` 的存储将共享磁盘中的同一文件夹。The name of disk storage which is used as a part of storage folder name. Two storages with the same `name` would share the same folder in disk.
    ///   - fileManager: 用于管理磁盘文件的 `FileManager` 的对象，默认是 `FileManager.default`。The `FileManager` used to manage files on disk. `FileManager.default` by default.
    ///   - sizeLimit: 磁盘缓存的总大小限制，单位是 `byte`，`0` 表示没有限制，默认是 `0`。The file size limit on disk in bytes. 0 means no limit. `0` by default.
    ///   - expiration: 文件的过期类型，默认是 `.days(7)`。The file expiration type. `.days(7)` by default.
    public init(
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
