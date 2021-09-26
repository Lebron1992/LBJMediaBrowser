import UIKit

public enum MediaImageStatus {
  case idle
  case loading(Float)
  case loaded(UIImage)
  case failed(Error)
}

extension MediaImageStatus: Equatable {
  public static func == (lhs: MediaImageStatus, rhs: MediaImageStatus) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle):
      return true
    case (.loading(let lf), .loading(let rf)):
      return lf == rf
    case (loaded(let li), .loaded(let ri)):
      return li == ri
    case (.failed(let le), .failed(let re)):
      return le.localizedDescription == re.localizedDescription
    default:
      return false
    }
  }
}
