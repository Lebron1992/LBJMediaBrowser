import Foundation

public protocol MediaURLVideoType: MediaVideoType {
  var previewImageUrl: URL? { get }
  var videoUrl: URL { get }
}
