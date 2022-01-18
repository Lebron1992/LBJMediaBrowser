import MobileCoreServices
import Photos

extension PHAsset {
  @objc
  var isGif: Bool {
    let resources = PHAssetResource.assetResources(for: self)
    for resource in resources where resource.isGif {
      return true
    }
    return false
  }
}

extension PHAssetResource {
  var isGif: Bool {
    uniformTypeIdentifier == kUTTypeGIF as String
  }
}
