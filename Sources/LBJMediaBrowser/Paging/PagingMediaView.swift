import SwiftUI
import LBJImagePreviewer

struct PagingMediaView: View {

  @EnvironmentObject
  private var browser: PagingBrowser

  let status: MediaStatus

  var body: some View {
    switch status {
    case .idle:
      Color.clear
    case .loading(let progress):
      loadingView(progress: progress)
    case .loaded(let uIImage):
      loadedView(uiImage: uIImage)
    case .failed(let error):
      failedView(error: error)
    }
  }
}

// MARK: - Display Content
private extension PagingMediaView {
  func loadingView(progress: Float) -> some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
        MediaLoadingProgressView(progress: progress)
          .frame(width: 40, height: 40)
          .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }

  func loadedView(uiImage: UIImage) -> some View {
    LBJUIImagePreviewer(uiImage: uiImage)
  }

  func failedView(error: MediaLoadingError) -> some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      PagingErrorView(error: error)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }
}

#if DEBUG
struct PagingMediaView_Previews: PreviewProvider {
  static var previews: some View {
    PagingMediaView(status: MediaUIImage.uiImages.first!.status)
    PagingMediaView(status: .loading(0.5))
    PagingMediaView(status: .failed(.invalidURL("fakeUrl")))
  }
}
#endif
