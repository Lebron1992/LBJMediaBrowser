enum AssetImageRequestTargetType {
  case thumbnail
  case full

  var isThumbnail: Bool {
    self == .thumbnail
  }
}
