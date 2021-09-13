import UIKit

extension Media {
  struct LoadedContent: Hashable {
    let uiImage: UIImage
  }
}

// MARK: - Templates
extension Media.LoadedContent {
  static let uiImages = (1...3)
    .compactMap { UIImage(named: "IMG_000\($0)", in: .module, compatibleWith: nil) }
    .map { Media.LoadedContent(uiImage: $0) }
}
