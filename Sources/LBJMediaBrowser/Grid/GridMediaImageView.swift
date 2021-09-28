import SwiftUI

struct GridMediaImageView: View {
  let mediaImage: MediaImageType

  var body: some View {
    switch mediaImage {
    case let uiImage as MediaUIImage:
      Image(uiImage: uiImage.uiImage).resizable()

    case let urlImage as MediaURLImage:
      GridMediaURLImageView(urlImage: urlImage)

    default:
      EmptyView()
    }
  }
}

struct GridMediaImageView_Previews: PreviewProvider {
  static var previews: some View {
    GridMediaImageView(mediaImage: MediaUIImage.uiImages[0])
  }
}
