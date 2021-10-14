import UIKit

/// 标识媒体成功加载完成的结果的常量。
/// Constants identifying the loaded result of a media.
public enum MediaLoadedResult {

  /// 图片成功加载完成的结果。
  /// The successfully loaded result of an image.
  /// - image: 图片类型。An image of `MediaImageType`.
  /// - uiImage: 加载完成后的图片。A successfully loaded image.
  case image(image: MediaImageType, uiImage: UIImage)

  /// 视频成功加载完成的结果。
  /// The successfully loaded result of a video.
  /// - video: 视频类型。A video of `MediaVideoType`.
  /// - previewImage: 加载完成后的预览图。A successfully loaded preview image of the video.
  /// - videoUrl: 加载完成后的视频路径。A successfully loaded url of the video.
  case video(video: MediaVideoType, previewImage: UIImage?, videoUrl: URL)
}
