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
      if progress > 0 && progress < 1 {
        MediaLoadingProgressView(progress: progress)
          .frame(size: Constant.progressSize)
          .onDisappear {
            imageDownloader.cancelDownload()
          }
      } else {
        Color.clear
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

private extension GridMediaURLImageView {
  enum Constant {
    static let progressSize = CGSize(width: 40, height: 40)
  }
}

struct GridMediaURLImageView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaURLImageView(urlImage: MediaURLImage.urlImages[0])
  }
}
