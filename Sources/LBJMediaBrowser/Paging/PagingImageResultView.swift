import SwiftUI
import LBJImagePreviewer

struct PagingImageResultView: View {
  let uiImage: UIImage

  var body: some View {
    LBJUIImagePreviewer(uiImage: uiImage)
  }
}

struct PagingImageResultView_Previews: PreviewProvider {
  static var previews: some View {
    let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)
    PagingImageResultView(uiImage: uiImage)
  }
}
