public protocol MediaType {
  var status: MediaStatus { get }
}

protocol MediaStatusEditable: MediaType, Buildable {
  var status: MediaStatus { get set }
}

extension MediaStatusEditable {
  func status(_ value: MediaStatus) -> Self {
    mutating(keyPath: \.status, value: value)
  }
}
