import UIKit

public enum MediaVideoStatus {
  case idle
  case loaded(previewImage: UIImage?, videoUrl: URL)
  case failed(Error)
}

extension MediaVideoStatus: Equatable {
  public static func == (lhs: MediaVideoStatus, rhs: MediaVideoStatus) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (loaded(let li, let lv), .loaded(let ri, let rv)):
      return li == ri && lv == rv
    case (.failed(let le), .failed(let re)):
      return le.localizedDescription == re.localizedDescription
    default:
      return false
    }
  }
}
