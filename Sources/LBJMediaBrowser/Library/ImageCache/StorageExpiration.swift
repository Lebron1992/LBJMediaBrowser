import Foundation

public enum StorageExpiration {
  case never
  case seconds(TimeInterval)
  case days(Int)
  case date(Date)

  var expirationDateSinceNow: Date {
    expirationDateSince(Date())
  }

  func expirationDateSince(_ date: Date) -> Date {
    switch self {
    case .never:
      return .distantFuture
    case .seconds(let seconds):
      return date.addingTimeInterval(seconds)
    case .days(let days):
      let seconds = TimeConstants.secondsInOneDay * TimeInterval(days)
      return date.addingTimeInterval(seconds)
    case .date(let date):
      return date
    }
  }
}
