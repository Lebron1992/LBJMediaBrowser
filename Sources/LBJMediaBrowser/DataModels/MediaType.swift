public protocol MediaType {
  var status: MediaStatus { get }
}

extension MediaType {
  var isLoading: Bool {
    switch status {
    case .loading: return true
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

// MARK: - MediaStatusEditable

protocol MediaStatusEditable: MediaType, Buildable {
  var status: MediaStatus { get set }
}

extension MediaStatusEditable {
  func status(_ value: MediaStatus) -> Self {
    mutating(keyPath: \.status, value: value)
  }
}
