import SwiftUI

public struct LBJGridMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  var minItemSize = LBJGridMediaBrowserConstant.minItemSize

  var itemSpacing = LBJGridMediaBrowserConstant.itemSapcing

  var browseInPagingOnTapItem = true

  var playVideoOnAppearInPaging = false

  private let medias: [MediaType]
  private let placeholder: () -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaResult) -> Content

  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    self.medias = medias
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

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
  func item(for media: MediaType) -> some View {
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
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(1, contentMode: .fill)
    .background(.black)
  }

  @ViewBuilder
  func imageView(for image: MediaImageType) -> some View {
    Group {
      switch image {
      case let uiImage as MediaUIImage:
        GridUIImageView(image: uiImage, content: content)

      case let urlImage as MediaURLImage:
        GridURLImageView(
          urlImage: urlImage,
          placeholder: placeholder,
          progress: progress,
          failure: failure,
          content: content
        )

      case let assetImage as MediaPHAssetImage:
        GridPHAssetImageView(
          assetImage: assetImage,
          placeholder: placeholder,
          progress: progress,
          failure: failure,
          content: content
        )

      default:
        EmptyView()
      }
    }
    .aspectRatio(contentMode: .fill)
    .frame(minWidth: minItemSize, minHeight: minItemSize, alignment: .center)
    .clipped()
  }

  @ViewBuilder
  func videoView(for video: MediaVideoType) -> some View {
    Group {
      switch video {
      case let urlVideo as MediaURLVideo:
        GridURLVideoView(
          urlVideo: urlVideo,
          placeholder: placeholder,
          content: content
        )

      case let assetVideo as MediaPHAssetVideo:
        GridPHAssetVideoView(
          assetVideo: assetVideo,
          placeholder: placeholder,
          failure: failure,
          content: content
        )

      default:
        EmptyView()
      }
    }
    .aspectRatio(contentMode: .fill)
    .frame(minWidth: minItemSize, minHeight: minItemSize, alignment: .center)
    .clipped()
  }

  func pagingMediaBrowser(page: Int) -> some View {
    let browser = PagingBrowser(medias: medias, currentPage: page)
    browser.playVideoOnAppear = playVideoOnAppearInPaging
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
    let mixed = [MediaUIImage.uiImages, MediaURLImage.urlImages, MediaURLVideo.urlVideos]
      .compactMap { $0 as? [MediaType] }
      .reduce([], +)
    LBJGridMediaBrowser(medias: mixed)
  }
}
#endif
