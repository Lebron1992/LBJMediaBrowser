import AVKit
import SwiftUI

struct PagingVideoResultView<SectionType: LBJMediaSectionType>: View {

  let video: MediaVideoType
  let previewImage: UIImage?
  let videoUrl: URL

  @EnvironmentObject
  private var browser: LBJPagingBrowser<SectionType>

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
          if let preview = previewImage ?? UIColor.black.toImage() {
            Image(uiImage: preview)
              .resizable()
              .aspectRatio(contentMode: .fit)
          }
          PlayButton(size: PagingVideoResultViewConstant.playButtonSize) {
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
    guard let videoAtCurrentPage = browser.dataSource.media(at: browser.currentPage) as? MediaVideoType else {
      return false
    }
    return video.equalsTo(videoAtCurrentPage)
  }
}

enum PagingVideoResultViewConstant {
  static let playButtonSize: CGFloat = 50
}

struct PagingVideoResultView_Previews: PreviewProvider {
  static var previews: some View {
    let video = MediaURLVideo.templates[0]
    PagingVideoResultView<SingleMediaSection>(
      video: video,
      previewImage: nil,
      videoUrl: video.videoUrl
    )
  }
}
