import Foundation

final class LBJURLCache {
  static let shared = LBJURLCache()

  private(set) var cachedUrls: [String: URL]

  init(urls: [String: URL] = [:]) {
    cachedUrls = urls
  }

  func add(_ url: URL, withIdentifier identifier: String) {
    cachedUrls[identifier] = url
  }

  func url(withIdentifier identifier: String) -> URL? {
    cachedUrls[identifier]
  }
}
