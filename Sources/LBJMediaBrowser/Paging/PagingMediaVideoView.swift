import SwiftUI
import AVKit

struct PagingMediaVideoView: View {

  let video: MediaVideoType

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
    switch video.status {
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
        .scaleEffect(Constant.progressScale)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }

  @ViewBuilder
  func loadedView(previewImage: UIImage?, videoUrl: URL) -> some View {
    Group {
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
          PlayButton(size: Constant.playButtonSize) {
            handlePlayButtonAction(videoUrl: videoUrl)
          }
        }
      }
    }
    .onChange(of: browser.currentPage) { _ in
      execute(after: 0.3) {
        if browser.playVideoOnAppear && isThePlayingVideo {
          if let player = avPlayer {
            player.play()
          } else {
            handlePlayButtonAction(videoUrl: videoUrl)
          }
        }
      }
    }
  }

  func failedView(error: Error) -> some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      PagingMediaErrorView(error: error)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }
}

private extension PagingMediaVideoView {
  func handlePlayButtonAction(videoUrl: URL) {
    avPlayer = AVPlayer(url: videoUrl)
    hasTappedPlayButton = true
    avPlayer?.play()
  }

  var isThePlayingVideo: Bool {
    switch (video, browser.playingVideo) {
    case (let v1 as MediaURLVideo, let v2 as MediaURLVideo):
      return v1.isTheSameAs(v2)

    case (let v1 as MediaPHAssetVideo, let v2 as MediaPHAssetVideo):
      return v1.isTheSameAs(v2)

    default:
      return false
    }
  }
}

private extension PagingMediaVideoView {
  enum Constant {
    static let progressScale: CGFloat = 1.5
    static let playButtonSize: CGFloat = 50
  }
}

struct PagingMediaVideoView_Previews: PreviewProvider {
  static var previews: some View {
    let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
    let video = MediaURLVideo(
      previewImageUrl: URL(string: "https://www.example.com/test.png")!,
      videoUrl: url,
      status: .loaded(previewImage: MediaUIImage.uiImages.first!.uiImage, videoUrl: url)
    )
    PagingMediaVideoView(video: video)
      .environmentObject(PagingBrowser(medias: [video]))
  }
}
