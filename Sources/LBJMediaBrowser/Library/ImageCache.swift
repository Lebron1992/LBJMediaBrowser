import Photos
import UIKit
import AlamofireImage

// MARK: - PHAssetImageRequest

struct PHAssetImageRequest {
  let asset: PHAsset
  let targetSize: CGSize
  let contentMode: PHImageContentMode
}

// MARK: - PHAssetImageCache

// Refers to https://github.com/Alamofire/AlamofireImage/blob/master/Source/ImageCache.swift

protocol PHAssetImageCache: ImageCache {
  func add(_ image: UIImage, for request: PHAssetImageRequest, withIdentifier identifier: String?)

  func removeImage(for request: PHAssetImageRequest, withIdentifier identifier: String?) -> Bool

  func image(for request: PHAssetImageRequest, withIdentifier identifier: String?) -> UIImage?
}

class AutoPurgingPHAssetImageCache: PHAssetImageCache {

  static let shared = AutoPurgingPHAssetImageCache()

  private let memoryCapacity: UInt64
  private let preferredMemoryUsageAfterPurge: UInt64

  private let synchronizationQueue: DispatchQueue
  private var cachedImages: [String: CachedImage]
  private var currentMemoryUsage: UInt64

  init(
    memoryCapacity: UInt64 = 100_000_000,
    preferredMemoryUsageAfterPurge: UInt64 = 60_000_000
  ) {
    self.memoryCapacity = memoryCapacity
    self.preferredMemoryUsageAfterPurge = preferredMemoryUsageAfterPurge

    precondition(
      memoryCapacity >= preferredMemoryUsageAfterPurge,
      "The `memoryCapacity` must be greater than or equal to `preferredMemoryUsageAfterPurge`"
    )

    cachedImages = [:]
    currentMemoryUsage = 0

    synchronizationQueue = {
      let name = String(format: "com.lebron.lbjmediabrowser.autopurgingimagecache-%08x%08x", arc4random(), arc4random())
      return DispatchQueue(label: name, attributes: .concurrent)
    }()

    let notification = UIApplication.didReceiveMemoryWarningNotification
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(AutoPurgingImageCache.removeAllImages),
      name: notification,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: Add UIImage to Cache

  func add(_ image: UIImage, for request: PHAssetImageRequest, withIdentifier identifier: String? = nil) {
    let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
    add(image, withIdentifier: requestIdentifier)
  }

  func add(_ image: UIImage, withIdentifier identifier: String) {
    synchronizationQueue.async(flags: [.barrier]) {
      let cachedImage = CachedImage(image, identifier: identifier)

      if let previousCachedImage = self.cachedImages[identifier] {
        self.currentMemoryUsage -= previousCachedImage.totalBytes
      }

      self.cachedImages[identifier] = cachedImage
      self.currentMemoryUsage += cachedImage.totalBytes
    }

    synchronizationQueue.async(flags: [.barrier]) {
      if self.currentMemoryUsage > self.memoryCapacity {
        let bytesToPurge = self.currentMemoryUsage - self.preferredMemoryUsageAfterPurge

        var sortedImages = self.cachedImages.map { $1 }

        sortedImages.sort {
          let date1 = $0.lastAccessDate
          let date2 = $1.lastAccessDate

          return date1.timeIntervalSince(date2) < 0.0
        }

        var bytesPurged = UInt64(0)

        for cachedImage in sortedImages {
          self.cachedImages.removeValue(forKey: cachedImage.identifier)
          bytesPurged += cachedImage.totalBytes

          if bytesPurged >= bytesToPurge {
            break
          }
        }

        self.currentMemoryUsage -= bytesPurged
      }
    }
  }

  // MARK: Remove UIImage from Cache

  @discardableResult
  func removeImage(for request: PHAssetImageRequest, withIdentifier identifier: String?) -> Bool {
    let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
    return removeImage(withIdentifier: requestIdentifier)
  }

  @discardableResult
  func removeImages(matching request: PHAssetImageRequest) -> Bool {
    let requestIdentifier = imageCacheKey(for: request, withIdentifier: nil)
    var removed = false

    synchronizationQueue.sync(flags: [.barrier]) {
      for key in self.cachedImages.keys where key.hasPrefix(requestIdentifier) {
        if let cachedImage = self.cachedImages.removeValue(forKey: key) {
          self.currentMemoryUsage -= cachedImage.totalBytes
          removed = true
        }
      }
    }

    return removed
  }

  @discardableResult
  func removeImage(withIdentifier identifier: String) -> Bool {
    var removed = false

    synchronizationQueue.sync(flags: [.barrier]) {
      if let cachedImage = self.cachedImages.removeValue(forKey: identifier) {
        self.currentMemoryUsage -= cachedImage.totalBytes
        removed = true
      }
    }

    return removed
  }

  @discardableResult @objc
  func removeAllImages() -> Bool {
    var removed = false

    synchronizationQueue.sync(flags: [.barrier]) {
      if !self.cachedImages.isEmpty {
        self.cachedImages.removeAll()
        self.currentMemoryUsage = 0

        removed = true
      }
    }

    return removed
  }

  // MARK: Fetch UIImage from Cache

  func image(for request: PHAssetImageRequest, withIdentifier identifier: String? = nil) -> UIImage? {
    let requestIdentifier = imageCacheKey(for: request, withIdentifier: identifier)
    return image(withIdentifier: requestIdentifier)
  }

  func image(withIdentifier identifier: String) -> UIImage? {
    var image: UIImage?

    synchronizationQueue.sync(flags: [.barrier]) {
      if let cachedImage = self.cachedImages[identifier] {
        image = cachedImage.accessImage()
      }
    }

    return image
  }

  // MARK: UIImage Cache Keys

  func imageCacheKey(for request: PHAssetImageRequest, withIdentifier identifier: String?) -> String {
    var key = "\(request.asset.localIdentifier)-\(request.targetSize)-\(request.contentMode.stringRepresentation)"

    if let identifier = identifier {
      key += "-\(identifier)"
    }

    return key
  }
}

// MARK: Getters
extension AutoPurgingPHAssetImageCache {

  /// The current total memory usage in bytes of all images stored within the cache.
  var memoryUsage: UInt64 {
    var memoryUsage: UInt64 = 0
    synchronizationQueue.sync(flags: [.barrier]) { memoryUsage = self.currentMemoryUsage }

    return memoryUsage
  }
}

// MARK: - CachedImage
private extension AutoPurgingPHAssetImageCache {
  class CachedImage {
    let image: UIImage
    let identifier: String
    let totalBytes: UInt64
    var lastAccessDate: Date

    init(_ image: UIImage, identifier: String) {
      self.image = image
      self.identifier = identifier
      lastAccessDate = Date()

      totalBytes = {
        let size = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
        let bytesPerPixel: CGFloat = 4
        let bytesPerRow = size.width * bytesPerPixel
        let totalBytes = UInt64(bytesPerRow) * UInt64(size.height)
        return totalBytes
      }()
    }

    func accessImage() -> UIImage {
      lastAccessDate = Date()
      return image
    }
  }
}

extension PHImageContentMode {
  // `"\(contentMode)"` always becomes `"PHImageContentMode"`, so add the property to fix it
  var stringRepresentation: String {
    let result: String
    switch self {
    case .aspectFill:
      result = "aspectFill"
    case .aspectFit:
      result = "aspectFit"
    case .default:
      result = "default"
    @unknown default:
      result = "unknown"
    }
    return result
  }
}
