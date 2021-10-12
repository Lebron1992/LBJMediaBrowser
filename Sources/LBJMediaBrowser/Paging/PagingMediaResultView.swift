import SwiftUI
import LBJImagePreviewer

public struct PagingMediaResultView: View {
  let result: MediaResult

  public var body: some View {
    switch result {
    case .image(_, let uiImage):
      PagingImageResultView(uiImage: uiImage)
    case .video(let video, let previewImage, let videoUrl):
      PagingVideoResultView(video: video, previewImage: previewImage, videoUrl: videoUrl)
    }
  }
}

struct PagingMediaResultView_Previews: PreviewProvider {
  static var previews: some View {
    let image = MediaUIImage.templates[0]
    PagingMediaResultView(result: .image(image: image, uiImage: image.uiImage))

    let video = MediaURLVideo.templates[0]
    PagingMediaResultView(result: .video(video: video, previewImage: nil, videoUrl: video.videoUrl))
  }
}
