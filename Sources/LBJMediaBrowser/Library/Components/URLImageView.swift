import SwiftUI

struct URLImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageDownloader = URLImageDownloader()

  private let urlImage: MediaURLImage
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    urlImage: MediaURLImage,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.urlImage = urlImage
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content

    let url = urlImage.thumbnailUrl ?? urlImage.imageUrl
    imageDownloader.setImageUrl(url)
  }

  var body: some View {
    ZStack {
      switch imageDownloader.imageStatus {
      case .idle:
        placeholder(urlImage)

      case .loading(let progress):
        if progress > 0 && progress < 1 {
          self.progress(progress)
        } else {
          placeholder(urlImage)
        }

      case .loaded(let uiImage):
        content(.image(image: urlImage, uiImage: uiImage))

      case .failed(let error):
        failure(error)
          .environmentObject(imageDownloader as MediaLoader)
      }
    }
    .onAppear {
        imageDownloader.startDownload()
    }
    .onDisappear {
      imageDownloader.cancelDownload()
    }
  }
}
