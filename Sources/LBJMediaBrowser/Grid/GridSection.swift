public protocol GridSection: Identifiable, Equatable {
  var medias: [Media] { get }
}

// MARK: - Template
enum GridSectionTemplate: GridSection, CaseIterable {
  case uiImage
  case urlImage
  case urlVideo

  var medias: [Media] {
    switch self {
    case .uiImage:
      return MediaUIImage.templates
    case .urlImage:
      return MediaURLImage.templates
    case .urlVideo:
      return MediaURLVideo.templates
    }
  }

  var id: GridSectionTemplate {
    self
  }

  var title: String {
    switch self {
    case .uiImage:
      return "UIImages"
    case .urlImage:
      return "URLImages"
    case .urlVideo:
      return "URLVideos"
    }
  }
}
