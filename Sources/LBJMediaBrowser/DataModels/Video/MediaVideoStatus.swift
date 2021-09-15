import UIKit

public enum MediaVideoStatus {
  case idle
  case loading
  case loaded(previewImage: UIImage?, videoUrl: URL)
  case failed(MediaLoadingError)
}
