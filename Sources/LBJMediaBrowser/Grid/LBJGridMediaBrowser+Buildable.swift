import CoreGraphics

extension LBJGridMediaBrowser: Buildable {
  public func minItemSize(_ value: CGFloat) -> Self {
    mutating(keyPath: \.minItemSize, value: value)
  }

  public func itemSpacing(_ value: CGFloat) -> Self {
    mutating(keyPath: \.itemSpacing, value: value)
  }

  public func browseInPagingOnTapItem(_ value: Bool = true) -> Self {
    mutating(keyPath: \.browseInPagingOnTapItem, value: value)
  }

  public func playVideoOnAppearInPaging(_ value: Bool = true) -> Self {
    mutating(keyPath: \.playVideoOnAppearInPaging, value: value)
  }
}

