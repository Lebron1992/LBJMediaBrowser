import Foundation

extension LBJGridMediaBrowser: Buildable {
  public func browseInPagingOnTapItem(_ value: Bool = true) -> Self {
    mutating(keyPath: \.browseInPagingOnTapItem, value: value)
  }

  public func playVideoOnAppearInPaging(_ value: Bool = true) -> Self {
    mutating(keyPath: \.playVideoOnAppearInPaging, value: value)
  }
}

