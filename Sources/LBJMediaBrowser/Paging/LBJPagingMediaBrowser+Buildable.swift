extension LBJPagingMediaBrowser: Buildable {

  /// 设置点击 Media 时执行的操作。
  /// Sets the action to execute when media tapped.
  /// - Parameter value: 要执行的操作。The action to execute.
  public func onTapMedia(_ value: @escaping (Media) -> Void) -> Self {
    mutating(keyPath: \.onTapMedia, value: value)
  }
}
