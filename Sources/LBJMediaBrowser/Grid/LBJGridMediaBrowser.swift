import SwiftUI

/// 一个以网格模式浏览媒体的对象。
/// An object that browsers the medias in grid mode.
public struct LBJGridMediaBrowser<SectionType: GridSection>: View {

  public typealias DataSource = LBJGridMediaBrowserDataSource<SectionType>

  var minItemSize = LBJGridMediaBrowserConstant.minItemSize
  var itemSpacing = LBJGridMediaBrowserConstant.itemSapcing

  var browseInPagingOnTapItem = true
  var autoPlayVideoInPaging = false

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  @ObservedObject
  private var dataSource: DataSource

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
          itemView(for: media, at: index)
        }
      }
    }
  }

  @ViewBuilder
  func itemView(for media: Media, at index: Int) -> some View {
    if browseInPagingOnTapItem {
      NavigationLink(destination: dataSource.pagingMediaBrowserProvider(index)) {
        mediaView(for: media)
      }
    } else {
      mediaView(for: media)
    }
  }

  @ViewBuilder
  func mediaView(for media: Media) -> some View {
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(minItemSize.width / minItemSize.height, contentMode: .fill)
    .background(Color.black)
  }

  @ViewBuilder
  func imageView(for image: MediaImage) -> some View {
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
  func videoView(for video: MediaVideo) -> some View {
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
      sections: GridSectionTemplate.allCases,
      sectionHeaderProvider: { Text($0.title).asAnyView() }
    )
    return LBJGridMediaBrowser(dataSource: dataSource)
  }
}
#endif
