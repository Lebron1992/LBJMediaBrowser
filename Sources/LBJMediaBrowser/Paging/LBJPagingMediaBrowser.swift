import SwiftUI

public struct LBJPagingMediaBrowser: View {

  @ObservedObject
  private var browser: PagingBrowser

  public init(browser: PagingBrowser) {
    self.browser = browser
  }

  public var body: some View {
    GeometryReader { geometry in
      TabView(selection: currentPage) {
        ForEach(0..<browser.medias.count, id: \.self) { index in
          let media = browser.medias[index]
          Group {
            switch media {
            case let mediaImage as MediaImageType:
              PagingMediaImageView(status: mediaImage.status)
            case let mediaVideo as MediaVideoType:
              PagingMediaVideoView(video: mediaVideo)
            default:
              EmptyView()
            }
          }
          .frame(size: geometry.size)
          .tag(index)
        }
      }
      .background(.black)
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      .ignoresSafeArea()
      .environmentObject(browser)
      .onAppear {
        browser.loadMedia(at: currentPage.wrappedValue)
      }
    }
  }

  private var currentPage: Binding<Int> {
    .init(get: { browser.currentPage }, set: { browser.setCurrentPage($0) })
  }
}

#if DEBUG
struct LBJPagingMediaBrowser_Previews: PreviewProvider {
  static var previews: some View {
//    LBJPagingMediaBrowser(browser: .init(medias: MediaUIImage.uiImages, currentPage: 0))
//    LBJPagingMediaBrowser(browser: .init(medias: MediaURLImage.urlImages, currentPage: 0))
    let mixed = [MediaUIImage.uiImages, MediaURLVideo.urlVideos, MediaURLImage.urlImages]
//    let mixed = [MediaURLVideo.urlVideos]
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)
    let browser = PagingBrowser(medias: mixed, currentPage: 0)
    browser.playVideoOnAppear = true
    return LBJPagingMediaBrowser(browser: browser)
  }
}
#endif
