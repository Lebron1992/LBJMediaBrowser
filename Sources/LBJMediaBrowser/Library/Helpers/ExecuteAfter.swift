import Foundation

func execute(after interval: TimeInterval, block: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: block)
}
