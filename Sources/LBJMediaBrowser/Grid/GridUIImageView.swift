import SwiftUI

struct GridUIImageView<Content: View>: View {
  let image: MediaUIImage
  let content: (MediaLoadedResult) -> Content
  
  var body: some View {
    content(.image(image: image, uiImage: image.uiImage))
  }
}

extension GridUIImageView where Content == GridMediaLoadedResultView {
  init(image: MediaUIImage) {
    self.init(image: image, content: { GridMediaLoadedResultView(result: $0) })
  }
}

struct GridUIImageView_Previews: PreviewProvider {
  static var previews: some View {
    GridUIImageView(image: MediaUIImage.templates[0])
  }
}
