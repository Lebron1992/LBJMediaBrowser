public protocol MediaType { }

extension MediaType {
  var isImage: Bool {
    self is MediaImageType
  }

  var isVideo: Bool {
    self is MediaVideoType
  }
}
