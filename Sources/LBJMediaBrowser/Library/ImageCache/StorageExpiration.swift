import Foundation

/// 表示缓存的过期策略。
/// Represents the expiration strategy in cache.
public enum StorageExpiration {

  /// 永不过期。never expires.
  case never

  /// 指定的秒数后过期。Expires after the given seconds.
  case seconds(TimeInterval)

  /// 指定的天数后过期。Expires after the given days.
  case days(Int)

  /// 指定的日期后过期。Expires after the given date.
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
