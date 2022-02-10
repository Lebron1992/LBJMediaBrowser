import CoreGraphics

extension LBJGridMediaBrowser: Buildable {

  /// 设置媒体的最小尺寸。
  /// Sets the min item size.
  /// - Parameter value: 媒体的最小尺寸。The min item size.
  public func minItemSize(_ value: CGSize) -> Self {
    mutating(keyPath: \.minItemSize, value: value)
  }

  /// 设置媒体之间的间隔。
  /// Sets the item spacing.
  /// - Parameter value: 媒体之间的间隔。The item spacing.
  public func itemSpacing(_ value: CGFloat) -> Self {
    mutating(keyPath: \.itemSpacing, value: value)
  }

  /// 设置是否在点击媒体时进入分页模式浏览。
  /// Sets wheather browse in paging mode on tap item.
  /// - Parameter value: 是否进入分页模式，默认是 `true`。 `true` if  should browse in paging mode, `true` by default.
  ///
  /// 必须把 `LBJGridMediaBrowser` 嵌入到 `NavigationView` 中才有效。
  /// Only available when the `LBJGridMediaBrowser` is embbed in the `NavigationView`.
  public func browseInPagingOnTapItem(_ value: Bool = true) -> Self {
    mutating(keyPath: \.browseInPagingOnTapItem, value: value)
  }
}

