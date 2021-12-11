import SwiftUI

struct PHAssetImageView<Placeholder: View, Progress: View, Failure: View, Content: View>: View {

  @ObservedObject
  private var imageManager = AssetImageManager()

  private let assetImage: MediaPHAssetImage
  private let targetType: AssetImageRequestTargetType
  private let placeholder: (Media) -> Placeholder
  private let progress: (Float) -> Progress
  private let failure: (Error) -> Failure
  private let content: (MediaLoadedResult) -> Content

  init(
    assetImage: MediaPHAssetImage,
    targetType: AssetImageRequestTargetType,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) {
    self.assetImage = assetImage
    self.targetType = targetType
    self.placeholder = placeholder
    self.progress = progress
    self.failure = failure
    self.content = content
    imageManager.setAssetImage(assetImage, targetType: targetType)
  }

  var body: some View {
    switch imageManager.imageStatus {
    case .idle:
      placeholder(assetImage)
        .onAppear {
          imageManager.startRequestImage(targetType: targetType)
        }

    case .loading(let progress):
      if progress > 0 && progress < 1 {
        self.progress(progress)
          .onDisappear {
            imageManager.cancelRequest()
          }
      } else {
        placeholder(assetImage)
      }

    case .loaded(let uiImage):
      content(.image(image: assetImage, uiImage: uiImage))
        .onDisappear {
          imageManager.reset()
        }

    case .failed(let error):
      failure(error)
        .environmentObject(imageManager as MediaLoader)
        .onDisappear {
          imageManager.reset()
        }
    }
  }
}
