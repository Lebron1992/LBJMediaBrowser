public protocol MediaVideoType: MediaType {
  var status: MediaVideoStatus { get }
}

extension MediaVideoType {
  var isIdle: Bool {
    switch status {
    case .idle:    return true
    default:       return false
    }
  }

  var isLoaded: Bool {
    switch status {
    case .loaded: return true
    default:      return false
    }
  }
}

// MARK: - MediaImageStatusEditable

protocol MediaVideoStatusEditable: MediaVideoType, Buildable {
  var status: MediaVideoStatus { get set }
}

extension MediaVideoStatusEditable {
  func status(_ value: MediaVideoStatus) -> Self {
    mutating(keyPath: \.status, value: value)
  }
}
