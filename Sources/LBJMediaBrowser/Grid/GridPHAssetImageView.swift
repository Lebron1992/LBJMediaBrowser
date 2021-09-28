import SwiftUI

struct GridPHAssetImageView: View {

  @ObservedObject
  private var imageManager: AssetImageManager

  init(assetImage: MediaPHAssetImage) {
    imageManager = AssetImageManager(assetImage: assetImage)
  }

  var body: some View {
    switch imageManager.imageStatus {
    case .idle:
      GridMediaPlaceholder()
        .onAppear {
          imageManager.startRequestImage()
        }

    case .loading(let progress):
      MediaLoadingProgressView(progress: progress)
        .frame(size: .init(width: 40, height: 40))
        .onDisappear {
          imageManager.cancelRequest()
          imageManager.reset()
        }

    case .loaded(let uiImage):
      Image(uiImage: uiImage)
        .resizable()
        .onDisappear {
          imageManager.reset()
        }

    case .failed:
      GridErrorView()
        .onDisappear {
          imageManager.reset()
        }
    }
  }
}
