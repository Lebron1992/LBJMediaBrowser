import UIKit

public enum MediaImageStatus {
  case idle
  case loading(Float)
  case loaded(UIImage)
  case failed(MediaLoadingError)
}
