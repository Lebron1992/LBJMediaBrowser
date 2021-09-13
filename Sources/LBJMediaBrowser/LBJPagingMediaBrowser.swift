import SwiftUI

public struct LBJPagingMediaBrowser: View {

  @ObservedObject
  public var browser: PagingBrowser

  public var body: some View {
    GeometryReader { geometry in
      TabView(selection: currentPage) {
        ForEach(0..<browser.medias.count, id: \.self) { index in
          let media = browser.medias[index]
          mediaContent(for: media, at: index, in: geometry)
        }
      }
      .background(.black)
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
  }

  private var currentPage: Binding<Int> {
    .init(get: { browser.currentPage }, set: { browser.setCurrentPage($0) })
  }
}

private extension LBJPagingMediaBrowser {
  func mediaContent(for media: Media, at index: Int, in geometry: GeometryProxy) -> some View {
    Group {
      if let content = media.loadedContent {
        PagingMediaView(content: content)
      } else {
        Color.clear
      }
    }
    .frame(size: geometry.size)
    .tag(index)
    .onAppear { browser.loadMedia(at: index) }
    .onDisappear { browser.cancelLoadingMedia(at: index) }
  }
}

#if DEBUG
struct LBJPagingMediaBrowser_Previews: PreviewProvider {
  static var previews: some View {
    LBJPagingMediaBrowser(browser: .init(medias: Media.uiImages, currentPage: 0))
  }
}
#endif
