public enum MediaLoadingError: Error {
  case invalidURL(String)
  case commonError(Error)

  var localizedDescription: String {
    switch self {
    case .invalidURL(let urlString):
      return "Invalid url string: \(urlString)"
    case .commonError(let error):
      return error.localizedDescription
    }
  }
}
