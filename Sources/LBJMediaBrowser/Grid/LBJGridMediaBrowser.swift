import SwiftUI

/// 一个以网格模式浏览媒体的对象。
/// An object that browsers the medias in grid mode.
public struct LBJGridMediaBrowser<SectionType: LBJMediaSectionType>: View {

  var minItemSize = LBJGridMediaBrowserConstant.minItemSize
  var itemSpacing = LBJGridMediaBrowserConstant.itemSapcing

  var browseInPagingOnTapItem = true

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  @ObservedObject
  private var browser: LBJGridBrowser<SectionType>

  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - browser: 管理网格模式浏览的类型。The type that manages the grid browser.
  public init(browser: LBJGridBrowser<SectionType>) {
    self.browser = browser
  }

  public var body: some View {
    ScrollView {
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: minItemSize.width), spacing: itemSpacing)],
        spacing: itemSpacing
      ) {
        ForEach(browser.dataSource.sections) { sectionView(for: $0) }
      }
      .padding(0)
    }
  }
}

// MARK: - Subviews
private extension LBJGridMediaBrowser {
  func sectionView(for section: SectionType) -> some View {
    Section(header: browser.dataSource.sectionHeaderProvider(section)) {
      ForEach(0..<section.medias.count, id: \.self) { index in
        itemView(for: section.medias[index], in: section)
      }
    }
  }

  @ViewBuilder
  func itemView(for media: MediaType, in section: SectionType) -> some View {
    if browseInPagingOnTapItem, let index = browser.dataSource.indexInAllMedias(for: media) {
      NavigationLink(destination: browser.dataSource.pagingMediaBrowserProvider(browser, index)) {
        mediaView(for: media, in: section)
      }
    } else {
      mediaView(for: media, in: section)
    }
  }

  @ViewBuilder
  func mediaView(for media: MediaType, in section: SectionType) -> some View {
    ZStack {
      switch media {
      case let image as MediaImageType:
        imageView(for: image)
      case let video as MediaVideoType:
        videoView(for: video)
      default:
        EmptyView()
      }
      if browser.selectionManager.selectionMode != .disabled {
        let status = browser.selectionManager.selectionStatus(for: media, in: section)
        browser.dataSource.selectionOverlayProvider(media, section, status)
          .environmentObject(browser.selectionManager)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(minItemSize.width / minItemSize.height, contentMode: .fill)
    .background(Color.black)
    .environmentObject(browser.dataSource)
  }

  @ViewBuilder
  func imageView(for image: MediaImageType) -> some View {
    Group {
      switch image {
      case let uiImage as MediaUIImage:
        UIImageView(image: uiImage, content: browser.dataSource.contentProvider)

      case let gifImage as MediaGifImage:
        GifImageView(image: gifImage, in: .grid, content: browser.dataSource.contentProvider)

      case let urlImage as MediaURLImage:
        URLImageView(
          urlImage: urlImage,
          targetSize: .thumbnail,
          placeholder: browser.dataSource.placeholderProvider,
          progress: browser.dataSource.progressProvider,
          failure: { error, _ in browser.dataSource.failureProvider(error) },
          content: browser.dataSource.contentProvider
        )
          .environmentObject(mediaBrowserEnvironment.urlImageLoader)

      case let assetImage as MediaPHAssetImage:
        PHAssetImageView(
          assetImage: assetImage,
          targetSize: .thumbnail,
          placeholder: browser.dataSource.placeholderProvider,
          progress: browser.dataSource.progressProvider,
          failure: { error, _ in browser.dataSource.failureProvider(error) },
          content: browser.dataSource.contentProvider
        )
          .environmentObject(mediaBrowserEnvironment.assetImageLoader)

      default:
        EmptyView()
      }
    }
    .aspectRatio(contentMode: .fill)
    .frame(minWidth: minItemSize.width, minHeight: minItemSize.height, alignment: .center)
    .clipped()
  }

  @ViewBuilder
  func videoView(for video: MediaVideoType) -> some View {
    Group {
      switch video {
      case let urlVideo as MediaURLVideo:
        URLVideoView(
          urlVideo: urlVideo,
          imageTargetSize: .thumbnail,
          placeholder: browser.dataSource.placeholderProvider,
          content: browser.dataSource.contentProvider
        )
          .environmentObject(mediaBrowserEnvironment.urlImageLoader)

      case let assetVideo as MediaPHAssetVideo:
        PHAssetVideoView(
          assetVideo: assetVideo,
          maxThumbnailSize: .init(width: 200, height: 200),
          placeholder: browser.dataSource.placeholderProvider,
          failure: { error, _ in browser.dataSource.failureProvider(error) },
          content: browser.dataSource.contentProvider
        )
          .environmentObject(mediaBrowserEnvironment.assetVideoLoader)

      default:
        EmptyView()
      }
    }
    .aspectRatio(contentMode: .fill)
    .frame(minWidth: minItemSize.width, minHeight: minItemSize.height, alignment: .center)
    .clipped()
  }
}

enum LBJGridMediaBrowserConstant {
  static let minItemSize: CGSize = .init(width: 80, height: 80)
  static let itemSapcing: CGFloat = 2
  static let progressSize: CGSize = .init(width: 40, height: 40)
}

#if DEBUG
struct LBJGridMediaBrowser_Previews: PreviewProvider {
  static var previews: some View {
    let dataSource = LBJGridMediaBrowserDataSource(
      sections: TitledMediaSection.templates,
      sectionHeaderProvider: { Text($0.title).asAnyView() }
    )
    let browser = LBJGridBrowser(dataSource: dataSource)
//    let dataSource = LBJGridMediaBrowserDataSource(medias: MediaUIImage.templates)
    return LBJGridMediaBrowser(browser: browser)
  }
}
#endif
