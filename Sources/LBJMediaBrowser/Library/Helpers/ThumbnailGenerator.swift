import AVFoundation
import UIKit

protocol ThumbnailGeneratorType {
  func thumbnail(for url: URL, maximumSize: CGSize) -> UIImage?
}

struct ThumbnailGenerator: ThumbnailGeneratorType {

  func thumbnail(for url: URL, maximumSize: CGSize) -> UIImage? {
    let generator: AVAssetImageGenerator = {
      let generator = AVAssetImageGenerator(asset: AVAsset(url: url))
      generator.appliesPreferredTrackTransform = true
      generator.maximumSize = maximumSize
      return generator
    }()

    let time = CMTime(value: 1, timescale: 30)

    if let img = try? generator.copyCGImage(at: time, actualTime: nil) {
      return UIImage(cgImage: img)
    }

    return nil
  }
}
