import XCTest

extension XCTestCase {
  func wait(interval: TimeInterval = 0.1, completion: @escaping (() -> Void)) {
    let exp = expectation(description: "")
    DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
      completion()
      exp.fulfill()
    }
    waitForExpectations(timeout: interval)
  }
}
