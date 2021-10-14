import SwiftUI

/// 一个以分页模式浏览媒体的对象。
/// An object that browse the medias in paging mode.
public struct LBJPagingMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var browser: LBJPagingBrowser

  private let placeholder: () -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that manages the media paging browser.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
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
      .background(Color.black)
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
//    LBJPagingMediaBrowser(browser: .init(medias: MediaUIImage.templates, currentPage: 0))
//    LBJPagingMediaBrowser(browser: .init(medias: MediaURLImage.templates, currentPage: 0))
    let mixed = [MediaUIImage.templates, MediaURLVideo.templates, MediaURLImage.templates]
//    let mixed = [MediaURLVideo.templates]
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)
    let browser = LBJPagingBrowser(medias: mixed, currentPage: 0)
    browser.autoPlayVideo = true
    return LBJPagingMediaBrowser(browser: browser)
  }
}
#endif
