import SwiftUI

struct GridMediaURLImageView: View {

  @ObservedObject
  private var imageDownloader: URLImageDownloader

  init(urlImage: MediaURLImage) {
    let url = urlImage.thumbnailURL ?? urlImage.url
    imageDownloader = URLImageDownloader(imageUrl: url)
  }

  var body: some View {
    switch imageDownloader.imageStatus {
    case .idle:
      GridMediaPlaceholder()
        .onAppear {
          imageDownloader.startDownload()
        }

    case .loading(let progress):
      MediaLoadingProgressView(progress: progress)
        .frame(size: .init(width: 40, height: 40))
        .onDisappear {
          imageDownloader.cancelDownload()
        }

    case .loaded(let uiImage):
      Image(uiImage: uiImage)
        .resizable()
        .onDisappear {
          imageDownloader.reset()
        }

    case .failed:
      GridErrorView()
    }
  }
}

struct GridMediaURLImageView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaURLImageView(urlImage: MediaURLImage.urlImages[0])
  }
}
