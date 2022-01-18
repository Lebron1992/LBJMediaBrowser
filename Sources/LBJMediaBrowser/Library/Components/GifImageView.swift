import SwiftUI

struct GifImageView<Content: View>: View {
  let image: MediaGifImage
  let browseMode: BrowseMode
  let content: (MediaLoadedResult) -> Content

  init(
    image: MediaGifImage,
    in browseMode: BrowseMode,
    content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.image = image
    self.browseMode = browseMode
    self.content = content
  }

  var body: some View {
    switch browseMode {
    case .grid:
      if let uiImage = image.stillImage {
        content(.stillImage(image: image, uiImage: uiImage))
      }
    case .paging:
      if let data = image.gifData {
        content(.gifImage(image: image, data: data))
      }
    }
  }
}
