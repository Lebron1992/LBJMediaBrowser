import SwiftUI
import LBJImagePreviewer

/// 一个在分页模式下显示媒体加载成功的对象。
/// An object that displays the loaded result of a media in  paging mode.
public struct PagingMediaLoadedResultView<SectionType: LBJMediaSectionType>: View {
  let result: MediaLoadedResult

  public var body: some View {
    switch result {
    case .stillImage(_, let uiImage):
      LBJUIImagePreviewer(uiImage: uiImage)
    case .gifImage(_, let data):
      LBJGIFImagePreviewer(imageData: data)
    case .video(let video, let previewImage, let videoUrl):
      PagingVideoResultView<SectionType>(video: video, previewImage: previewImage, videoUrl: videoUrl)
    }
  }
}

struct PagingMediaResultView_Previews: PreviewProvider {
  static var previews: some View {
    let image = MediaUIImage.templates[0]
    PagingMediaLoadedResultView<SingleMediaSection>(result: .stillImage(image: image, uiImage: image.uiImage))

    let video = MediaURLVideo.templates[0]
    PagingMediaLoadedResultView<SingleMediaSection>(result: .video(video: video, previewImage: nil, videoUrl: video.videoUrl))
  }
}
