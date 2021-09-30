import SwiftUI

public struct GridErrorView: View {
  public var body: some View {
    Image(systemName: "multiply")
      .foregroundColor(.white)
      .font(.system(size: Constant.multiplyFontSize, weight: .light))
  }
}

private extension GridErrorView {
  enum Constant {
    static let multiplyFontSize: CGFloat = 40
  }
}

#if DEBUG
struct GridErrorView_Previews: PreviewProvider {
  static var previews: some View {
    GridErrorView()
      .padding()
      .background(.black)
  }
}
#endif
