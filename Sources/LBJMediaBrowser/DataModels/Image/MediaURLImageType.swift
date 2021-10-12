import Foundation

public protocol MediaURLImageType: MediaImageType {
  var url: URL { get }
  var thumbnailURL: URL? { get }
}
