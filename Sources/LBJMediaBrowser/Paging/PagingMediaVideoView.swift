import SwiftUI
import AVKit

struct PagingMediaVideoView: View {

  let status: MediaVideoStatus

  @EnvironmentObject
  private var browser: PagingBrowser

  @State
  private var hasTappedPlayButton = false

  var body: some View {
    switch status {
    case .idle:
      Color.clear
    case .loading:
      loadingView
    case .loaded(let previewImage, let videoUrl):
      loadedView(previewImage: previewImage, videoUrl: videoUrl)
    case .failed(let error):
      failedView(error: error)
    }
  }
}

// MARK: - Display Content
private extension PagingMediaVideoView {
  var loadingView: some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .white))
        .scaleEffect(1.5)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }

  func loadedView(previewImage: UIImage?, videoUrl: URL) -> some View {
    Group {
      if hasTappedPlayButton {
        VideoPlayer(player: AVPlayer(url: videoUrl))
      } else {
        ZStack {
          if let preview = previewImage {
            Image(uiImage: preview)
              .resizable()
              .aspectRatio(contentMode: .fit)
          }
          playButton
        }
      }
    }
    .onDisappear {
      hasTappedPlayButton = false
    }
  }

  var playButton: some View {
    Button {
      hasTappedPlayButton = true
    } label: {
      Image(systemName: "play.circle")
        .font(.system(size: 50, weight: .light))
        .foregroundColor(.white)
    }
  }

  func failedView(error: MediaLoadingError) -> some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      PagingErrorView(error: error)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }
}

struct PagingMediaVideoView_Previews: PreviewProvider {
  static var previews: some View {
    PagingMediaVideoView(status: .loaded(
      previewImage: MediaUIImage.uiImages.first!.uiImage,
      videoUrl: URL(string: "http://www.example.com/test.mp4")!)
    )
    PagingMediaVideoView(status: .loading)
    PagingMediaVideoView(status: .failed(.invalidURL("fakeUrl")))
  }
}
