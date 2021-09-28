import SwiftUI

struct GridPHAssetVideoView: View {

  @ObservedObject
  private var videoManager: AssetVideoManager

  init(assetVideo: MediaPHAssetVideo) {
    videoManager = AssetVideoManager(assetVideo: assetVideo)
  }

  var body: some View {
    switch videoManager.videoStatus {
    case .idle:
      GridMediaPlaceholder()
        .onAppear {
          videoManager.startRequestVideoUrl()
        }

    case .loaded(let previewImage, _):
      ZStack {
        if let previewImage = previewImage {
          Image(uiImage: previewImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
        }
        PlayButton(size: 30)
      }

    case .failed:
      GridErrorView()
    }
  }
}
