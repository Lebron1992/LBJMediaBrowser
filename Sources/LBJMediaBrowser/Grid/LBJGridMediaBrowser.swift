import SwiftUI

/// 网格媒体浏览器的 section 类型。The section type in grid browser.
public typealias LBJGridMediaBrowserSectionType = GridSection & Equatable & Hashable & Identifiable

/// 一个以网格模式浏览媒体的对象。
/// An object that browsers the medias in grid mode.
public struct LBJGridMediaBrowser<SectionType: LBJGridMediaBrowserSectionType>: View {

  /// 网格媒体浏览器的数据源类型。The type of the data source in grid browser.
  public typealias DataSource = LBJGridMediaBrowserDataSource<SectionType>

  var minItemSize = LBJGridMediaBrowserConstant.minItemSize
  var itemSpacing = LBJGridMediaBrowserConstant.itemSapcing

  var browseInPagingOnTapItem = true

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  @ObservedObject
  private var dataSource: DataSource

  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameter dataSource: `LBJGridMediaBrowserDataSource` 对象。A `LBJGridMediaBrowserDataSource` object.
  public init(dataSource: DataSource) {
    self.dataSource = dataSource
  }

  public var body: some View {
    ScrollView {
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: minItemSize.width), spacing: itemSpacing)],
        spacing: itemSpacing
      ) {
        ForEach(dataSource.sections) { sectionView(for: $0) }
      }
      .padding(0)
    }
  }
}

// MARK: - Subviews
private extension LBJGridMediaBrowser {
  func sectionView(for section: SectionType) -> some View {
    Section(header: dataSource.sectionHeaderProvider(section)) {
      ForEach(0..<dataSource.numberOfMedias(in: section), id: \.self) { index in
        if let media = dataSource.media(at: index, in: section) {
          itemView(for: media, in: section)
        }
      }
    }
  }

  @ViewBuilder
  func itemView(for media: MediaType, in section: SectionType) -> some View {
    if browseInPagingOnTapItem, let index = dataSource.indexInAllMedias(for: media) {
      NavigationLink(destination: dataSource.pagingMediaBrowserProvider(dataSource.allMedias, index)) {
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
      dataSource.selectionOverlay(for: media, in: section)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(minItemSize.width / minItemSize.height, contentMode: .fill)
    .background(Color.black)
    .environmentObject(dataSource)
  }

  @ViewBuilder
  func imageView(for image: MediaImageType) -> some View {
    Group {
      switch image {
      case let uiImage as MediaUIImage:
        UIImageView(image: uiImage, content: dataSource.contentProvider)

      case let gifImage as MediaGifImage:
        GifImageView(image: gifImage, in: .grid, content: dataSource.contentProvider)

      case let urlImage as MediaURLImage:
        URLImageView(
          urlImage: urlImage,
          targetSize: .thumbnail,
          placeholder: dataSource.placeholderProvider,
          progress: dataSource.progressProvider,
          failure: { error, _ in dataSource.failureProvider(error) },
          content: dataSource.contentProvider
        )
          .environmentObject(mediaBrowserEnvironment.urlImageLoader)

      case let assetImage as MediaPHAssetImage:
        PHAssetImageView(
          assetImage: assetImage,
          targetSize: .thumbnail,
          placeholder: dataSource.placeholderProvider,
          progress: dataSource.progressProvider,
          failure: { error, _ in dataSource.failureProvider(error) },
          content: dataSource.contentProvider
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
          placeholder: dataSource.placeholderProvider,
          content: dataSource.contentProvider
        )
          .environmentObject(mediaBrowserEnvironment.urlImageLoader)

      case let assetVideo as MediaPHAssetVideo:
        PHAssetVideoView(
          assetVideo: assetVideo,
          maxThumbnailSize: .init(width: 200, height: 200),
          placeholder: dataSource.placeholderProvider,
          failure: { error, _ in dataSource.failureProvider(error) },
          content: dataSource.contentProvider
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
      sections: TitledGridSection.templates,
      sectionHeaderProvider: { Text($0.title).asAnyView() },
      selectionMode: .any(max: nil)
    )
//    let dataSource = LBJGridMediaBrowserDataSource(medias: MediaUIImage.templates)
    return LBJGridMediaBrowser(dataSource: dataSource)
  }
}
#endif
