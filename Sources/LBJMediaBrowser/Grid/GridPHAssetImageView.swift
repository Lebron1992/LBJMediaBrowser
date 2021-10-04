import SwiftUI

struct GridPHAssetImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageManager: AssetImageManager
  
  private let assetImage: MediaPHAssetImage
  private let placeholder: () -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaResult) -> Content

  init(
    assetImage: MediaPHAssetImage,
    @ViewBuilder placeholder: @escaping () -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaResult) -> Content
  ) {
    imageManager = AssetImageManager(assetImage: assetImage)
    self.assetImage = assetImage
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
  }

  var body: some View {
    switch imageManager.imageStatus {
    case .idle:
      placeholder()
        .onAppear {
          imageManager.startRequestImage()
        }

    case .loading(let progress):
      if progress > 0 && progress < 1 {
        self.progress(progress)
          .onDisappear {
            imageManager.cancelRequest()
          }
      } else {
        Color.clear
      }

    case .loaded(let uiImage):
      content(.image(image: assetImage, uiImage: uiImage))
        .onDisappear {
          imageManager.reset()
        }

    case .failed(let error):
      failure(error)
        .onDisappear {
          imageManager.reset()
        }
    }
  }
}
