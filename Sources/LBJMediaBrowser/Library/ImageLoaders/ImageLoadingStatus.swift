import UIKit

enum ImageLoadingStatus {
  case inProgress(Task<UIImage, Error>)
  case failed(Error)

  var isInProgress: Bool {
    switch self {
    case .inProgress:
      return true
    default:
      return false
    }
  }
}
