import SwiftUI

public struct GridMediaErrorView: View {
  public var body: some View {
    Image(systemName: "multiply")
      .foregroundColor(.white)
      .font(.system(size: Constant.multiplyFontSize, weight: .light))
  }
}

private extension GridMediaErrorView {
  enum Constant {
    static let multiplyFontSize: CGFloat = 40
  }
}

#if DEBUG
struct GridMediaErrorView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaErrorView()
      .padding()
      .background(.black)
  }
}
#endif
