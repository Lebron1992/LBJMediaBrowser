import SwiftUI

/// 一个以分页模式浏览媒体的对象。
/// An object that browse the medias in paging mode.
public struct LBJPagingMediaBrowser<SectionType: LBJMediaSectionType>: View {

  var onTapMedia: (MediaType) -> Void = { _ in }

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  @ObservedObject
  private var browser: LBJPagingBrowser<SectionType>

  /// 创建 `LBJPagingBrowser` 对象。Creates a `LBJPagingBrowser` object.
  /// - Parameters:
  ///   - browser: 管理分页模式浏览的对象。An object that manages the media paging browser.
  public init(browser: LBJPagingBrowser<SectionType>) {
    self.browser = browser
  }

  public var body: some View {
    TabView(selection: currentPage) {
      ForEach(0..<browser.dataSource.allMedias.count, id: \.self) { index in
        let media = browser.dataSource.allMedias[index]
        itemView(for: media, at: index)
      }
    }
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    .environmentObject(browser)
  }

  private var currentPage: Binding<Int> {
    .init(get: { browser.currentPage }, set: { browser.setCurrentPage($0) })
  }
}

// MARK: - Subviews
private extension LBJPagingMediaBrowser {

  @ViewBuilder
  func itemView(for media: MediaType, at index: Int) -> some View {
    ZStack {
      Group {
        switch media {
        case let image as MediaImageType:
          imageView(for: image)
        case let video as MediaVideoType:
          videoView(for: video)
        default:
          EmptyView()
        }
      }
      .tag(index)
      .gesture(
        TapGesture()
          .onEnded { onTapMedia(media) }
      )
      if browser.selectionManager.selectionMode != .disabled,
         let section = browser.dataSource.sections.first(where: { $0.contains(media) }) {
        let status = browser.selectionManager.selectionStatus(for: media, in: section)
        switch status {
        case .disabled:
          Text("disabled")
        case .unselected:
          Text("unselected")
        case .selected:
          Text("selected")
        }
//        browser.dataSource.selectionOverlayProvider(media, section, status)
//          .environmentObject(browser.selectionManager)
      }
    }
  }

  @ViewBuilder
  func imageView(for image: MediaImageType) -> some View {
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
  func videoView(for video: MediaVideoType) -> some View {
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
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)
    let browser = LBJPagingBrowser(dataSource: .init(medias: mixed))
    return LBJPagingMediaBrowser(browser: browser)
      .background(Color.black)
  }
}
#endif
