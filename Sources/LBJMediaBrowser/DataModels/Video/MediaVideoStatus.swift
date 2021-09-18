import UIKit

public enum MediaVideoStatus {
  case idle
  case loaded(previewImage: UIImage?, videoUrl: URL)
  case failed(Error)
}
