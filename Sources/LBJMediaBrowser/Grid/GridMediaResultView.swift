import SwiftUI

public struct GridMediaResultView: View {
  let result: MediaResult

  public var body: some View {
    switch result {
    case .image(_, let uiImage):
      Image(uiImage: uiImage)
        .resizable()
    case .video(_, let previewImage, _):
      ZStack {
        if let image = previewImage {
          Image(uiImage: image)
            .resizable()
        }
        PlayButton(size: Constant.playButtonSize)
      }
    }
  }
}

extension GridMediaResultView {
  enum Constant {
    static let playButtonSize: CGFloat = 30
  }
}

struct GridMediaResultView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaResultView(result: .video(
      video: MediaURLVideo.urlVideos[0],
      previewImage: nil,
      videoUrl: .init(string: "https://www.example.com/test.mp4")!
    ))
  }
}
