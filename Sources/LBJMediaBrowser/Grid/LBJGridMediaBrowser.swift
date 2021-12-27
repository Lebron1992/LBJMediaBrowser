import SwiftUI

/// 一个以网格模式浏览媒体的对象。
/// An object that browsers the medias in grid mode.
public struct LBJGridMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  var minItemSize = LBJGridMediaBrowserConstant.minItemSize

  var itemSpacing = LBJGridMediaBrowserConstant.itemSapcing

  var browseInPagingOnTapItem = true

  var autoPlayVideoInPaging = false

  private let medias: [Media]
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  /// 创建 `LBJGridMediaBrowser` 对象。Creates a `LBJGridMediaBrowser` object.
  /// - Parameters:
  ///   - medias: 要浏览的媒体数组。The medias to be browsed.
  ///   - placeholder: 用于显示媒体处于未处理状态时的代码块。A block object that displays the media in idle.
  ///   - progress: 用于显示媒体处于加载中的代码块。A block object that displays the media in progress.
  ///   - failure: 用于显示媒体处于加载失败时的代码块。A block object that displays the media in failure.
  ///   - content: 用于显示媒体处于加载完成时的代码块。A block object that displays the media in loaded.
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.medias = medias
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

  @Environment(\.mediaBrowserEnvironment)
  private var mediaBrowserEnvironment: LBJMediaBrowserEnvironment

  public var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: minItemSize), spacing: itemSpacing)], spacing: itemSpacing) {
        ForEach(0..<medias.count, id: \.self) { index in
          if browseInPagingOnTapItem {
            NavigationLink(destination: pagingMediaBrowser(page: index)) {
              item(for: medias[index])
            }
          } else {
            item(for: medias[index])
          }
        }
      }
      .padding(0)
    }
  }
}

// MARK: - Subviews
private extension LBJGridMediaBrowser {
  @ViewBuilder
  func item(for media: Media) -> some View {
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
    .aspectRatio(1, contentMode: .fill)
    .background(Color.black)
  }

  @ViewBuilder
  func imageView(for image: MediaImage) -> some View {
    Group {
      switch image {
      case let uiImage as MediaUIImage:
        UIImageView(image: uiImage, content: content)

      case let urlImage as MediaURLImage:
        URLImageView(
          urlImage: urlImage,
          targetSize: .thumbnail,
          placeholder: placeholder,
          progress: progress,
          failure: { error, _ in failure(error) },
          content: content
        )
          .environmentObject(mediaBrowserEnvironment.urlImageLoader)

      case let assetImage as MediaPHAssetImage:
        PHAssetImageView(
          assetImage: assetImage,
          targetSize: .thumbnail,
          placeholder: placeholder,
          progress: progress,
          failure: { error, _ in failure(error) },
          content: content
        )
          .environmentObject(mediaBrowserEnvironment.assetImageLoader)

      default:
        EmptyView()
      }
    }
    .aspectRatio(contentMode: .fill)
    .frame(minWidth: minItemSize, minHeight: minItemSize, alignment: .center)
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
          placeholder: placeholder,
          content: content
        )
          .environmentObject(mediaBrowserEnvironment.urlImageLoader)

      case let assetVideo as MediaPHAssetVideo:
        PHAssetVideoView(
          assetVideo: assetVideo,
          maxThumbnailSize: .init(width: 200, height: 200),
          placeholder: placeholder,
          failure: { error, _ in failure(error) },
          content: content
        )
          .environmentObject(mediaBrowserEnvironment.assetVideoLoader)

      default:
        EmptyView()
      }
    }
    .aspectRatio(contentMode: .fill)
    .frame(minWidth: minItemSize, minHeight: minItemSize, alignment: .center)
    .clipped()
  }

  func pagingMediaBrowser(page: Int) -> some View {
    let browser = LBJPagingBrowser(medias: medias, currentPage: page)
    browser.autoPlayVideo = autoPlayVideoInPaging
    return LBJPagingMediaBrowser(browser: browser)
  }
}

enum LBJGridMediaBrowserConstant {
  static let minItemSize: CGFloat = 80
  static let itemSapcing: CGFloat = 2
  static let progressSize: CGSize = .init(width: 40, height: 40)
}

#if DEBUG
struct LBJGridMediaBrowser_Previews: PreviewProvider {
  static var previews: some View {
    let mixed = [MediaUIImage.templates, MediaURLImage.templates, MediaURLVideo.templates]
      .compactMap { $0 as? [Media] }
      .reduce([], +)
    LBJGridMediaBrowser(medias: mixed)
  }
}
#endif
