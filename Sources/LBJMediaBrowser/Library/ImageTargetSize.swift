enum ImageTargetSize {
  case thumbnail
  case larger

  var isThumbnail: Bool {
    self == .thumbnail
  }
}
