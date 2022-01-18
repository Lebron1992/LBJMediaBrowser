import SwiftUI

/// 一个在网格模式下显示媒体加载成功的对象。
/// An object that displays the loaded result of a media in grid mode.
public struct GridMediaLoadedResultView: View {
  let result: MediaLoadedResult

  public var body: some View {
    switch result {
    case .stillImage(_, let uiImage):
      Image(uiImage: uiImage)
        .resizable()
    case .gifImage(_, let data):
      if let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
          .resizable()
      }
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

extension GridMediaLoadedResultView {
  enum Constant {
    static let playButtonSize: CGFloat = 30
  }
}

struct GridMediaResultView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaLoadedResultView(result: .video(
      video: MediaURLVideo.templates[0],
      previewImage: nil,
      videoUrl: .init(string: "https://www.example.com/test.mp4")!
    ))
  }
}
