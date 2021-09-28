import SwiftUI
import LBJImagePreviewer

struct PagingMediaImageView: View {

  @EnvironmentObject
  private var browser: PagingBrowser

  let status: MediaImageStatus

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
private extension PagingMediaImageView {
  func loadingView(progress: Float) -> some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      MediaLoadingProgressView(progress: progress)
        .frame(size: Constant.progressSize)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }

  func loadedView(uiImage: UIImage) -> some View {
    LBJUIImagePreviewer(uiImage: uiImage)
  }

  func failedView(error: Error) -> some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      PagingErrorView(error: error)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }
}

private extension PagingMediaImageView {
  enum Constant {
    static let progressSize: CGSize = .init(width: 100, height: 40)
  }
}

#if DEBUG
struct PagingMediaView_Previews: PreviewProvider {
  static var previews: some View {
    PagingMediaImageView(status: MediaUIImage.uiImages.first!.status)
    PagingMediaImageView(status: .loading(0.5))
    PagingMediaImageView(status: .failed(NSError.unknownError))
  }
}
#endif
