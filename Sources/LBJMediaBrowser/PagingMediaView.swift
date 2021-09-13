import SwiftUI
import LBJImagePreviewer

struct PagingMediaView: View {

  let content: Media.LoadedContent

  var body: some View {
    LBJUIImagePreviewer(uiImage: content.uiImage)
  }
}

#if DEBUG
struct PagingMediaView_Previews: PreviewProvider {
  static var previews: some View {
    PagingMediaView(content: .uiImages.first!)
  }
}
#endif
