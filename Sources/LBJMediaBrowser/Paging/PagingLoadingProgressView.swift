import SwiftUI

public struct PagingLoadingProgressView: View {
  let progress: Float

  public var body: some View {
    GeometryReader { geo in
      let frame = geo.frame(in: .local)
      LoadingProgressView(progress: progress)
        .frame(size: Constant.progressSize)
        .position(x: frame.midX, y: frame.midY)
    }
    .background(.black)
  }
}

private extension PagingLoadingProgressView {
  enum Constant {
    static let progressSize: CGSize = .init(width: 40, height: 40)
  }
}

struct PagingLoadingProgressView_Previews: PreviewProvider {
  static var previews: some View {
    PagingLoadingProgressView(progress: 0.5)
  }
}
