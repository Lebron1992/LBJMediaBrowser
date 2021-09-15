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
      .ignoresSafeArea()
      .environmentObject(browser)
    }
  }

  private var currentPage: Binding<Int> {
    .init(get: { browser.currentPage }, set: { browser.setCurrentPage($0) })
  }
}

private extension LBJPagingMediaBrowser {
  func mediaContent(
    for media: MediaType,
    at index: Int,
    in geometry: GeometryProxy
  ) -> some View {
    PagingMediaView(status: media.status)
      .frame(size: geometry.size)
      .tag(index)
      .onAppear { browser.loadMedia(at: index) }
  }
}

#if DEBUG
struct LBJPagingMediaBrowser_Previews: PreviewProvider {
  static var previews: some View {
//    LBJPagingMediaBrowser(browser: .init(medias: MediaUIImage.uiImages, currentPage: 0))
//    LBJPagingMediaBrowser(browser: .init(medias: MediaURLImage.urlImages, currentPage: 0))
    let mixed = [MediaUIImage.uiImages, MediaURLImage.urlImages]
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)
    LBJPagingMediaBrowser(browser: .init(medias: mixed.shuffled(), currentPage: 0))
  }
}
#endif
