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
    var result: ImageLoadedResult?
    switch browseMode {
    case .grid:
      if let uiImage = image.stillImage {
        result = .still(uiImage)
      }
    case .paging:
      if let data = image.gifData {
        result = .gif(data)
      }
    }
    return ZStack {
      if let result = result {
        content(.image(image: image, result: result))
      }
    }
  }
}
