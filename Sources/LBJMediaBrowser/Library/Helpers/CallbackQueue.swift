import Foundation

enum CallbackQueue {
  case main
  case current
  case dispatch(DispatchQueue)

  func execute(_ block: @escaping () -> Void) {
    switch self {
    case .main:
      DispatchQueue.main.async { block() }
    case .current:
      block()
    case .dispatch(let queue):
      queue.async { block() }
    }
  }

  var queue: DispatchQueue {
    switch self {
    case .main:                return .main
    case .current:             return OperationQueue.current?.underlyingQueue ?? .main
    case .dispatch(let queue): return queue
    }
  }
}
