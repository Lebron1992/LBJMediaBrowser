import SwiftUI

private struct LBJMediaBrowserEnvironmentKey: EnvironmentKey {
  static let defaultValue: LBJMediaBrowserEnvironment = .init()
}

public extension EnvironmentValues {
  var mediaBrowserEnvironment: LBJMediaBrowserEnvironment {
    get { self[LBJMediaBrowserEnvironmentKey.self] }
    set { self[LBJMediaBrowserEnvironmentKey.self] = newValue }
  }
}
