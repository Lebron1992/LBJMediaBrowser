import UIKit
@testable import LBJMediaBrowser

struct ThumbnailGeneratorMock: ThumbnailGeneratorType {
   private let uiImage: UIImage?

  init(_ uiImage: UIImage?) {
    self.uiImage = uiImage
  }

  func thumbnail(for url: URL) -> UIImage? {
    uiImage
  }
}
