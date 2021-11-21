import AVFoundation
import UIKit

protocol ThumbnailGeneratorType {
  func thumbnail(for url: URL) -> UIImage?
}

struct ThumbnailGenerator: ThumbnailGeneratorType {

  func thumbnail(for url: URL) -> UIImage? {
    let generator: AVAssetImageGenerator = {
      let generator = AVAssetImageGenerator(asset: AVAsset(url: url))
      generator.appliesPreferredTrackTransform = true
      generator.maximumSize = CGSize(width: 200, height: 200)
      return generator
    }()

    let time = CMTime(value: 1, timescale: 30)

    if let img = try? generator.copyCGImage(at: time, actualTime: nil) {
      return UIImage(cgImage: img)
    }

    return nil
  }
}
