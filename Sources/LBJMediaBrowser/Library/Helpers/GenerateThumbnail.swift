import AVFoundation
import UIKit

func generateThumbnailForPHAsset(with url: URL) -> UIImage? {
    let asset = AVAsset(url: url)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    generator.maximumSize = CGSize(width: 200, height: 200)
    let time = CMTime(value: 1, timescale: 30)

    if let img = try? generator.copyCGImage(at: time, actualTime: nil) {
        return UIImage(cgImage: img)
    }

    return nil
}
