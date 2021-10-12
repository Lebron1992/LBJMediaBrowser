import UIKit

public struct MediaUIImage: MediaUIImageType {

  public let id = UUID().uuidString
  public let uiImage: UIImage

  public init(uiImage: UIImage) {
    self.uiImage = uiImage
  }
}

// MARK: - Equatable
extension MediaUIImage: Equatable { }

// MARK: - Templates
extension MediaUIImage {
  static let templates = (1...3)
    .compactMap { UIImage(named: "IMG_000\($0)", in: .module, compatibleWith: nil) }
    .map { MediaUIImage(uiImage: $0) }
}
