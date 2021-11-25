import Photos

extension PHImageContentMode {
  // `"\(contentMode)"` always becomes `"PHImageContentMode"`, so add the property to fix it
  var stringRepresentation: String {
    let result: String
    switch self {
    case .aspectFill:
      result = "aspectFill"
    case .aspectFit:
      result = "aspectFit"
    case .default:
      result = "default"
    @unknown default:
      result = "unknown"
    }
    return result
  }
}
