import Foundation
@testable import LBJMediaBrowser

struct MockPHAsset: PHAssetType {
  let id: Int32
}

extension MockPHAsset: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
