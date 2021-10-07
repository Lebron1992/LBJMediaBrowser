import SwiftUI

public struct LBJPagingMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var browser: LBJPagingBrowser

  private let placeholder: () -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaResult) -> Content

  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.browser = browser
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

  public var body: some View {
    GeometryReader { geometry in
      TabView(selection: currentPage) {
        ForEach(0..<browser.medias.count, id: \.self) { index in
          let media = browser.medias[index]
          Group {
            switch media {
            case let image as MediaImageType:
              PagingImageView(
                image: image,
                placeholder: placeholder,
                progress: progress,
                failure: failure,
                content: content
              )
            case let video as MediaVideoType:
              PagingVideoView(
                video: video,
                placeholder: placeholder,
                failure: failure,
                content: content
              )
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
    let browser = LBJPagingBrowser(medias: mixed, currentPage: 0)
    browser.playVideoOnAppear = true
    return LBJPagingMediaBrowser(browser: browser)
  }
}
#endif
