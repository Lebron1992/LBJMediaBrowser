import SwiftUI

/// 一个显示媒体加载进度的对象。
/// An object that displays the loading progress.
public struct LoadingProgressView: View {

  let progress: Float
  let lineWidth: CGFloat
  let tintColor: Color
  let size: CGSize?

  init(
    progress: Float,
    lineWidth: CGFloat = 4,
    tintColor: Color = .white,
    size: CGSize? = nil
  ) {
    self.progress = progress
    self.lineWidth = lineWidth
    self.tintColor = tintColor
    self.size = size
  }

  public var body: some View {
    if let size = size {
      content
        .frame(width: size.width, height: size.height)
    } else {
      content
    }
  }
  
  var content: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: lineWidth)
        .foregroundColor(tintColor)
        .opacity(0.3)

      Circle()
        .trim(from: 0, to: CGFloat(min(progress, 1)))
        .stroke(style: StrokeStyle(
          lineWidth: lineWidth,
          lineCap: .round,
          lineJoin: .round
        ))
        .foregroundColor(tintColor)
        .rotationEffect(.init(degrees: -90))
    }
  }
}

struct MediaLoadingProgressView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      LoadingProgressView(progress: 0.5)
      LoadingProgressView(progress: 0)
    }
      .foregroundColor(.white)
      .frame(width: 40, height: 40)
      .padding()
      .background(Color.black)
  }
}
