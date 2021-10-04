import UIKit

public enum MediaResult {
  case image(image: MediaImageType, uiImage: UIImage)
  case video(video: MediaVideoType, previewImage: UIImage?, videoUrl: URL)
}
