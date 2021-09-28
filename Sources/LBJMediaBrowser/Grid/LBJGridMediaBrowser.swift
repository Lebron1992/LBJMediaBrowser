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
    GeometryReader { geometry in
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
}

// MARK: - Subviews
private extension LBJGridMediaBrowser {
  @ViewBuilder
  func item(for media: MediaType) -> some View {
    Group {
      switch media {
      case let mediaImage as MediaImageType:
        GridMediaImageView(mediaImage: mediaImage)
      default:
        EmptyView()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .aspectRatio(1, contentMode: .fill)
    .background(.black)
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
    LBJGridMediaBrowser(medias: MediaUIImage.uiImages)
    LBJGridMediaBrowser(medias: MediaURLImage.urlImages)
  }
}
#endif
