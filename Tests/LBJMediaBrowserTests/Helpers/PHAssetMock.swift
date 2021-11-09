import Photos

final class PHAssetMock: PHAsset {

  let id: Int32
  let assetType: PHAssetMediaType

  init(id: Int32, assetType: PHAssetMediaType) {
    self.id = id
    self.assetType = assetType
  }

  override var mediaType: PHAssetMediaType {
    assetType
  }

  // MARK: Fix error: Must have a uuid if no _objectID (NSInternalInconsistencyException)

  // Refers to: https://stackoverflow.com/questions/59517411/getting-must-have-a-uuid-if-no-objectid-exception-when-inserting-object-into

  let _localIdentifier: String   = UUID().uuidString
  let _hash: Int                 = UUID().hashValue

  override var localIdentifier: String {
    _localIdentifier
  }

  override var hash: Int {
    _hash
  }

  override func isEqual(_ object: Any?) -> Bool {
    guard let object = object as? PHAssetMock else {
      return false
    }
    return self.localIdentifier == object.localIdentifier
  }
}

extension PHAssetMock {
  static func == (lhs: PHAssetMock, rhs: PHAssetMock) -> Bool {
    lhs.id == rhs.id && lhs.assetType == rhs.assetType
  }
}
