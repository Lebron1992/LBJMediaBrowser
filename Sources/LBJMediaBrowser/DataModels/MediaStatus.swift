import UIKit

public enum MediaStatus {
  case idle
  case loading(Float)
  case loaded(UIImage)
  case failed(MediaLoadingError)
}
