import SwiftUI

/// 一个以分页模式浏览媒体的对象。
/// An object that browse the medias in paging mode.
public struct LBJPagingMediaBrowser: View {

  var onTapMedia: (Media) -> Void = { _ in }

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  @ObservedObject
  private var browser: LBJPagingBrowser

  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that manages the media paging browser.
  public init(browser: LBJPagingBrowser) {
    self.browser = browser
  }

  public var body: some View {
    GeometryReader { geometry in
      TabView(selection: currentPage) {
        ForEach(0..<browser.dataSource.medias.count, id: \.self) { index in
          let media = browser.dataSource.medias[index]
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
      UIImageView(image: uiImage, content: browser.dataSource.contentProvider)

    case let gifImage as MediaGifImage:
      GifImageView(image: gifImage, in: .paging, content: browser.dataSource.contentProvider)

    case let urlImage as MediaURLImage:
      URLImageView(
        urlImage: urlImage,
        targetSize: .larger,
        placeholder: browser.dataSource.placeholderProvider,
        progress: browser.dataSource.progressProvider,
        failure: browser.dataSource.failureProvider,
        content: browser.dataSource.contentProvider
      )
        .environmentObject(mediaBrowserEnvironment.urlImageLoader)

    case let assetImage as MediaPHAssetImage:
      PHAssetImageView(
        assetImage: assetImage,
        targetSize: .larger,
        placeholder: browser.dataSource.placeholderProvider,
        progress: browser.dataSource.progressProvider,
        failure: browser.dataSource.failureProvider,
        content: browser.dataSource.contentProvider
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
        placeholder: browser.dataSource.placeholderProvider,
        content: browser.dataSource.contentProvider
      )
        .environmentObject(mediaBrowserEnvironment.urlImageLoader)

    case let assetVideo as MediaPHAssetVideo:
      PHAssetVideoView(
        assetVideo: assetVideo,
        maxThumbnailSize: UIScreen.main.bounds.size,
        placeholder: browser.dataSource.placeholderProvider,
        failure: browser.dataSource.failureProvider,
        content: browser.dataSource.contentProvider
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
    let browser = LBJPagingBrowser(dataSource: .init(medias: mixed))
    return LBJPagingMediaBrowser(browser: browser)
  }
}
#endif
