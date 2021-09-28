import SwiftUI

public struct LBJGridMediaBrowser: View {

  private let medias: [MediaType]
  private let minItemSize: CGFloat
  private let itemSpacing: CGFloat

  public init(
    medias: [MediaType],
    minItemSize: CGFloat = Constant.minItemSize,
    itemSpacing: CGFloat = Constant.itemSapcing
  ) {
    self.medias = medias
    self.minItemSize = minItemSize
    self.itemSpacing = itemSpacing
  }

  public var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: minItemSize), spacing: itemSpacing)], spacing: itemSpacing) {
        ForEach(0..<medias.count, id: \.self) { index in
          item(for: medias[index])
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
        Image(uiImage: uiImage.uiImage).resizable()

      case let urlImage as MediaURLImage:
        GridMediaURLImageView(urlImage: urlImage)

      case let assetImage as MediaPHAssetImage:
        GridPHAssetImageView(assetImage: assetImage)

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
    switch video {
    case let urlVideo as MediaURLVideo:
      GridMediaURLVideoView(urlVideo: urlVideo)

    case let assetVideo as MediaPHAssetVideo:
      GridPHAssetVideoView(assetVideo: assetVideo)

    default:
      EmptyView()
    }
  }
}

extension LBJGridMediaBrowser {
  public enum Constant {
     public static let minItemSize: CGFloat = 80
     public static let itemSapcing: CGFloat = 2
  }
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
