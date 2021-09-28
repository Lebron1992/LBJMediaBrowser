import SwiftUI

struct GridMediaURLVideoView: View {
  let urlVideo: MediaURLVideo

  var body: some View {
    ZStack {
      if let previewUrl = urlVideo.previewImageUrl {
        GridMediaURLImageView(urlImage: .init(url: previewUrl))
      }
      PlayButton(size: Constant.playButtonSize)
    }
  }
}

private extension GridMediaURLVideoView {
  enum Constant {
    static let playButtonSize: CGFloat = 30
  }
}

struct GridMediaURLVideoView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaURLVideoView(urlVideo: MediaURLVideo.urlVideos[0])
  }
}
