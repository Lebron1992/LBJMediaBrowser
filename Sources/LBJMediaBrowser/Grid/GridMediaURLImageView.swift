import SwiftUI

struct GridMediaURLImageView<Progress: View, Failure: View>: View {

  @ObservedObject
  private var imageDownloader: URLImageDownloader

  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  
  init(
    urlImage: MediaURLImage,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure
  ) {
    let url = urlImage.thumbnailURL ?? urlImage.url
    self.imageDownloader = URLImageDownloader(imageUrl: url)
    self.progress = progress
    self.failure = failure
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
        self.progress(progress)
          .frame(size: GridMediaURLImageViewConstant.progressSize)
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

    case .failed(let error):
      failure(error)
    }
  }
}

enum GridMediaURLImageViewConstant {
  static let progressSize = CGSize(width: 40, height: 40)
}

struct GridMediaURLImageView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaURLImageView(
      urlImage: MediaURLImage.urlImages[0],
      progress: { MediaLoadingProgressView(progress: $0) },
      failure: { _ in GridErrorView() }
    )
  }
}
