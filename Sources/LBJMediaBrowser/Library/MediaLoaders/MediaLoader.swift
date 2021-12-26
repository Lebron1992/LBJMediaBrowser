import Photos

class MediaLoader<Status, RequestID>: ObservableObject {

  let requestQueue: DispatchQueue = {
    let name = String(format: "com.lebron.LBJMediaBrowser.MediaLoader.requestQueue.\(UUID().uuidString)")
    return DispatchQueue(label: name, attributes: .concurrent)
  }()

  @Published
  private(set) var statusCache = SafeDictionary<String, Status>()

  private(set) var requestIdCache = SafeDictionary<String, RequestID>()

  func isLoading(forKey key: String) -> Bool {
    requestIdCache[key] != nil
  }

  func updateStatus(_ status: Status, forKey key: String) {
    DispatchQueue.main.async {
      self.statusCache[key] = status
    }
  }

  func removeStatus(forKey key: String) {
    statusCache.removeValue(forKey: key)
  }

  func updateRequestId(_ requestId: RequestID, forKey key: String) {
    DispatchQueue.main.async {
      self.requestIdCache[key] = requestId
    }
  }

  func removeRequestId(forKey key: String) {
    requestIdCache.removeValue(forKey: key)
  }
}
