import SwiftUI

struct GridErrorView: View {
  var body: some View {
    Image(systemName: "multiply")
      .foregroundColor(.white)
      .font(.system(size: 40, weight: .light))
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
