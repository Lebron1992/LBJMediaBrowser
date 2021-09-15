public protocol MediaImageType: MediaType {
  var status: MediaImageStatus { get }
}

extension MediaImageType {
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

// MARK: - MediaImageStatusEditable

protocol MediaImageStatusEditable: MediaImageType, Buildable {
  var status: MediaImageStatus { get set }
}

extension MediaImageStatusEditable {
  func status(_ value: MediaImageStatus) -> Self {
    mutating(keyPath: \.status, value: value)
  }
}
