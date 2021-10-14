import AVKit
import SwiftUI

struct PagingVideoResultView: View {

  let video: MediaVideoType
  let previewImage: UIImage?
  let videoUrl: URL

  @EnvironmentObject
  private var browser: LBJPagingBrowser

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

  @ViewBuilder
  var content: some View {
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
        if browser.autoPlayVideo && isThePlayingVideo {
          if let player = avPlayer {
            player.play()
          } else {
            handlePlayButtonAction(videoUrl: videoUrl)
          }
        }
      }
    }
  }
}

private extension PagingVideoResultView {
  func handlePlayButtonAction(videoUrl: URL) {
    avPlayer = AVPlayer(url: videoUrl)
    hasTappedPlayButton = true
    avPlayer?.play()
  }

  var isThePlayingVideo: Bool {
    switch (video, browser.playingVideo) {
    case (let v1 as MediaURLVideo, let v2 as MediaURLVideo):
      return v1 == v2

    case (let v1 as MediaPHAssetVideo, let v2 as MediaPHAssetVideo):
      return v1 == v2

    default:
      return false
    }
  }
}

private extension PagingVideoResultView {
  enum Constant {
    static let playButtonSize: CGFloat = 50
  }
}

struct PagingVideoResultView_Previews: PreviewProvider {
  static var previews: some View {
    let video = MediaURLVideo.templates[0]
    PagingVideoResultView(
      video: video,
      previewImage: nil,
      videoUrl: video.videoUrl
    )
  }
}
