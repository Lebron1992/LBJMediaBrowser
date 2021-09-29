import Foundation

extension LBJGridMediaBrowser: Buildable {
  public func browseInPageOnTapItem(_ value: Bool = true) -> Self {
    mutating(keyPath: \.browseInPageOnTapItem, value: value)
  }
}
