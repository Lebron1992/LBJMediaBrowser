import UIKit

/// 标识媒体成功加载完成的结果的常量。
/// Constants identifying the loaded result of a media.
public enum MediaLoadedResult {

  /// 静态图片成功加载完成的结果。
  /// The successfully loaded result of a still image.
  /// - image: 图片类型。An image of `MediaImage`.
  /// - uiImage: 加载完成后的图片结果。A successfully loaded result of image.
  case stillImage(image: MediaImage, uiImage: UIImage)

  /// 动态图片成功加载完成的结果。
  /// The successfully loaded result of a gif image.
  /// - image: 图片类型。An image of `MediaImage`.
  /// - data: 动态图片的数据。The data of a gif image..
  case gifImage(image: MediaImage, data: Data)

  /// 视频成功加载完成的结果。
  /// The successfully loaded result of a video.
  /// - video: 视频类型。A video of `MediaVideo`.
  /// - previewImage: 加载完成后的预览图。A successfully loaded preview image of the video.
  /// - videoUrl: 加载完成后的视频路径。A successfully loaded url of the video.
  case video(video: MediaVideo, previewImage: UIImage?, videoUrl: URL)
}
