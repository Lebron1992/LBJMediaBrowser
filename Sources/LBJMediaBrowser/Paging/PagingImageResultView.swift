import SwiftUI
import LBJImagePreviewer

struct PagingImageResultView: View {
  let result: ImageLoadedResult

  var body: some View {
    switch result {
    case .still(let uIImage):
      LBJUIImagePreviewer(uiImage: uIImage)
    case .gif(let data):
      LBJGIFImagePreviewer(imageData: data)
    }
  }
}

struct PagingImageResultView_Previews: PreviewProvider {
  static var previews: some View {
    let uiImage = UIImage(named: "IMG_0001", in: .module, compatibleWith: nil)!
    PagingImageResultView(result: .still(uiImage))
  }
}
