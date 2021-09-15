import UIKit

public struct MediaUIImage {
  let uiImage: UIImage

  public init(uiImage: UIImage) {
    self.uiImage = uiImage
  }
}

// MARK: - MediaImageType
extension MediaUIImage: MediaImageType {
  public var status: MediaImageStatus {
    .loaded(uiImage)
  }
}

// MARK: - Templates
extension MediaUIImage {
  static let uiImages = (1...3)
    .compactMap { UIImage(named: "IMG_000\($0)", in: .module, compatibleWith: nil) }
    .map { MediaUIImage(uiImage: $0) }
}
