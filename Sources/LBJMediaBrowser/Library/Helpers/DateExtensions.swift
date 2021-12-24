import Foundation

extension Date {
  var isPast: Bool {
    isPast(referenceDate: Date())
  }

  var isFuture: Bool {
    !isPast
  }

  func isPast(referenceDate: Date) -> Bool {
    timeIntervalSince(referenceDate) <= 0
  }
}
