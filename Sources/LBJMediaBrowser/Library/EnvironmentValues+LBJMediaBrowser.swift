import SwiftUI

private struct LBJMediaBrowserEnvironmentKey: EnvironmentKey {
  static let defaultValue: LBJMediaBrowserEnvironment = .init()
}

public extension EnvironmentValues {

  /// 当前媒体浏览器所用到的全局变量和单例的集合。
  /// The current collection of all global variables and singletons that the media browser uses.
  var mediaBrowserEnvironment: LBJMediaBrowserEnvironment {
    get { self[LBJMediaBrowserEnvironmentKey.self] }
    set { self[LBJMediaBrowserEnvironmentKey.self] = newValue }
  }
}
