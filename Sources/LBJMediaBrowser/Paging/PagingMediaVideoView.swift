import SwiftUI
import AVKit

struct PagingMediaVideoView: View {

  let status: MediaVideoStatus

  @EnvironmentObject
  private var browser: PagingBrowser

  @State
  private var hasTappedPlayButton = false

  @State
  private var avPlayer: AVPlayer?

  var body: some View {
    content
      .onDisappear {
        avPlayer?.pause()
      }
  }
}

// MARK: - Display Content
private extension PagingMediaVideoView {
  @ViewBuilder
  var content: some View {
    switch status {
    case .idle:
      Color.clear
    case .loaded(let previewImage, let videoUrl):
      loadedView(previewImage: previewImage, videoUrl: videoUrl)
    case .failed(let error):
      failedView(error: error)
    }
  }

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

  @ViewBuilder
  func loadedView(previewImage: UIImage?, videoUrl: URL) -> some View {
    if hasTappedPlayButton {
      if let player = avPlayer {
        VideoPlayer(player: player)
      }
    } else {
      ZStack {
        if let preview = previewImage {
          Image(uiImage: preview)
            .resizable()
            .aspectRatio(contentMode: .fit)
        }
        PlayButton(size: 50) {
          avPlayer = AVPlayer(url: videoUrl)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // wait for the view rebuild completion triggered by avPlayer channges
            hasTappedPlayButton = true
            avPlayer?.play()
          }
        }
      }
    }
  }

  func failedView(error: Error) -> some View {
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
      videoUrl: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
    )
//    PagingMediaVideoView(status: .loading)
//    PagingMediaVideoView(status: .failed(.invalidURL("fakeUrl")))
  }
}
