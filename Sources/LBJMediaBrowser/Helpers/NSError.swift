import Foundation

#if DEBUG
extension NSError {
  static let unknownError = NSError(
    domain: "",
    code: -1,
    userInfo: [NSLocalizedDescriptionKey: "Unknown error"]
  )
}
#endif
