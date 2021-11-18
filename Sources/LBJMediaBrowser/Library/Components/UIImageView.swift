import SwiftUI

struct UIImageView<Content: View>: View {
  let image: MediaUIImage
  let content: (MediaLoadedResult) -> Content
  
  var body: some View {
    content(.image(image: image, uiImage: image.uiImage))
  }
}
