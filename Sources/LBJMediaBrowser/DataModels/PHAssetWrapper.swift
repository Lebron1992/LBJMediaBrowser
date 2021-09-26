import Photos

typealias PHAssetID = String

struct PHAssetWrapper {
  let id: PHAssetID
  let asset: PHAssetType

  init(id: String = UUID().uuidString, asset: PHAssetType) {
    self.id = id
    self.asset = asset
  }
}
