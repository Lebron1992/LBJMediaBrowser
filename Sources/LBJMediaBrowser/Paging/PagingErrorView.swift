import SwiftUI

struct PagingErrorView: View {

  @EnvironmentObject
  private var browser: PagingBrowser

  let error: MediaLoadingError

  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "multiply")
        .foregroundColor(.white)
        .font(.system(size: 80, weight: .light))

      Text(error.localizedDescription)
        .foregroundColor(.white)

      Button {
        browser.loadMedia(at: browser.currentPage, withAdjacent: false)
      } label: {
        Text("Retry")
          .font(.system(size: 16, weight: .regular))
          .foregroundColor(.black)
          .frame(size: .init(width: 100, height: 40))
          .background(.white)
          .cornerRadius(20)
      }
    }
  }
}

struct PagingErrorView_Previews: PreviewProvider {
  static var previews: some View {
    PagingErrorView(error: .invalidURL("fakeUrl"))
      .padding()
      .background(.black)
  }
}
