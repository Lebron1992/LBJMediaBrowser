import UIKit

public struct MediaUIImage {
  let uiImage: UIImage

  public init(uiImage: UIImage) {
    self.uiImage = uiImage
  }
}

// MARK: - MediaType
extension MediaUIImage: MediaType {
  public var status: MediaStatus {
    .loaded(uiImage)
  }
}

// MARK: - Hashable
extension MediaUIImage: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uiImage)
  }
}

// MARK: - Templates
extension MediaUIImage {
  static let uiImages = (1...3)
    .compactMap { UIImage(named: "IMG_000\($0)", in: .module, compatibleWith: nil) }
    .map { MediaUIImage(uiImage: $0) }
}
