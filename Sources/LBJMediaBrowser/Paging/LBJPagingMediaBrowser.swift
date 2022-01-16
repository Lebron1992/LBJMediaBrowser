import SwiftUI

/// 一个以分页模式浏览媒体的对象。
/// An object that browse the medias in paging mode.
public struct LBJPagingMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  var onTapMedia: (Media) -> Void = { _ in }

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  @ObservedObject
  private var browser: LBJPagingBrowser

  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (_ error: Error, _ retry: @escaping () -> Void) -> Failure
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
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (_ error: Error, _ retry: @escaping () -> Void) -> Failure,
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
            case let image as MediaImage:
              imageView(for: image)
            case let video as MediaVideo:
              videoView(for: video)
            default:
              EmptyView()
            }
          }
          .frame(size: geometry.size)
          .tag(index)
          .gesture(
            TapGesture()
              .onEnded { onTapMedia(media) }
          )
        }
      }
      .background(Color.black)
      .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
      .ignoresSafeArea()
      .environmentObject(browser)
    }
  }

  private var currentPage: Binding<Int> {
    .init(get: { browser.currentPage }, set: { browser.setCurrentPage($0) })
  }
}

// MARK: - Subviews
private extension LBJPagingMediaBrowser {

  @ViewBuilder
  func imageView(for image: MediaImage) -> some View {
    switch image {
    case let uiImage as MediaUIImage:
      UIImageView(image: uiImage, content: content)

    case let gifImage as MediaGifImage:
      GifImageView(image: gifImage, in: .paging, content: content)

    case let urlImage as MediaURLImage:
      URLImageView(
        urlImage: urlImage,
        targetSize: .larger,
        placeholder: placeholder,
        progress: progress,
        failure: failure,
        content: content
      )
        .environmentObject(mediaBrowserEnvironment.urlImageLoader)

    case let assetImage as MediaPHAssetImage:
      PHAssetImageView(
        assetImage: assetImage,
        targetSize: .larger,
        placeholder: placeholder,
        progress: progress,
        failure: failure,
        content: content
      )
        .environmentObject(mediaBrowserEnvironment.assetImageLoader)

    default:
      EmptyView()
    }
  }

  @ViewBuilder
  func videoView(for video: MediaVideo) -> some View {
    switch video {
    case let urlVideo as MediaURLVideo:
      URLVideoView(
        urlVideo: urlVideo,
        imageTargetSize: .larger,
        placeholder: placeholder,
        content: content
      )
        .environmentObject(mediaBrowserEnvironment.urlImageLoader)

    case let assetVideo as MediaPHAssetVideo:
      PHAssetVideoView(
        assetVideo: assetVideo,
        maxThumbnailSize: UIScreen.main.bounds.size,
        placeholder: placeholder,
        failure: failure,
        content: content
      )
        .environmentObject(mediaBrowserEnvironment.assetVideoLoader)

    default:
      EmptyView()
    }
  }
}

#if DEBUG
struct LBJPagingMediaBrowser_Previews: PreviewProvider {
  static var previews: some View {
    let mixed = [MediaUIImage.templates, MediaURLVideo.templates, MediaURLImage.templates]
      .compactMap { $0 as? [Media] }
      .reduce([], +)
    let browser = LBJPagingBrowser(medias: mixed, currentPage: 0)
    browser.autoPlayVideo = true
    return LBJPagingMediaBrowser(browser: browser)
  }
}
#endif
