import SwiftUI

struct UIImageView<Content: View>: View {
  let image: MediaUIImage
  let content: (MediaLoadedResult) -> Content
  
  var body: some View {
    content(.stillImage(image: image, uiImage: image.uiImage))
  }
}
