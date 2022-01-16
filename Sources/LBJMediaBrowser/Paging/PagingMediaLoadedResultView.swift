import SwiftUI
import LBJImagePreviewer

/// 一个在分页模式下显示媒体加载成功的对象。
/// An object that displays the loaded result of a media in  paging mode.
public struct PagingMediaLoadedResultView: View {
  let result: MediaLoadedResult

  public var body: some View {
    switch result {
    case .image(_, let result):
      PagingImageResultView(result: result)
    case .video(let video, let previewImage, let videoUrl):
      PagingVideoResultView(video: video, previewImage: previewImage, videoUrl: videoUrl)
    }
  }
}

struct PagingMediaResultView_Previews: PreviewProvider {
  static var previews: some View {
    let image = MediaUIImage.templates[0]
    PagingMediaLoadedResultView(result: .image(image: image, result: .still(image.uiImage)))

    let video = MediaURLVideo.templates[0]
    PagingMediaLoadedResultView(result: .video(video: video, previewImage: nil, videoUrl: video.videoUrl))
  }
}
