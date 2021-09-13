import Combine
import SwiftUI
import UIKit

public final class PagingBrowser: ObservableObject {

  @Published
  public private(set) var currentPage: Int = 0

  @Published
  private(set) var medias: [Media]

  public init(medias: [Media], currentPage: Int = 0) {
    self.medias = medias
    self.currentPage = validatedPage(currentPage)
  }

  // TODO: 手动改变 page 时，动画无效。原因是 medias 数据发生改变
  public func setCurrentPage(_ page: Int, animated: Bool = true) {
    if animated {
      withAnimation {
        currentPage = validatedPage(page)
      }
    } else {
      currentPage = validatedPage(page)
    }

    loadMedia(at: currentPage)
  }
}

// MARK: - Loading Media
extension PagingBrowser {
  func loadMedia(at index: Int) {
    let indicesToLoad = (
      index - PagingBrowser.Constant.mediaPreloadSize
      ...
      index + PagingBrowser.Constant.mediaPreloadSize
    )

    indicesToLoad.forEach { indexToLoad in
      guard let media = media(at: indexToLoad) else {
        return
      }
      medias[indexToLoad].loadedContent = .init(uiImage: media.uiImage)
    }
  }

  func cancelLoadingMedia(at index: Int) {

  }
}

// MARK: - Helper Methods
private extension PagingBrowser {
  func media(at index: Int) -> Media? {
    guard index >= 0 && index < medias.count else {
      return nil
    }
    return medias[index]
  }

  func validatedPage(_ page: Int) -> Int {
    min(medias.count - 1, max(0, page))
  }
}

private extension PagingBrowser {
  enum Constant {
    static let mediaPreloadSize = 2
  }
}
