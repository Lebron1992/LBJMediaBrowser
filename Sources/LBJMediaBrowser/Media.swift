import UIKit

public struct Media {
  let uiImage: UIImage
  var loadedContent: LoadedContent?

  public init(uiImage: UIImage) {
    self.uiImage = uiImage
  }
}

extension Media: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(uiImage)
  }
}

// MARK: - Templates
extension Media {
  static let uiImages = (1...3)
    .compactMap { UIImage(named: "IMG_000\($0)", in: .module, compatibleWith: nil) }
    .map { Media(uiImage: $0) }
}
