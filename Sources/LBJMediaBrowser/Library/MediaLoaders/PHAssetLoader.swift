import Photos

class PHAssetLoader<Status>: ObservableObject {

  let requestQueue: DispatchQueue = {
    let name = String(format: "com.lebron.lbjmediabrowser.requestqueue-%08x%08x", arc4random(), arc4random())
    return DispatchQueue(label: name, attributes: .concurrent)
  }()

  @Published
  private(set) var statusCache: [String: Status] = [:]

  private(set) var requestIdCache: [String: PHImageRequestID] = [:]

  func isLoading(forKey key: String) -> Bool {
    requestIdCache[key] != nil
  }

  func updateStatus(_ status: Status, forKey key: String) {
    statusCache[key] = status
  }

  func removeStatus(forKey key: String) {
    statusCache.removeValue(forKey: key)
  }

  func updateRequestId(_ requestId: PHImageRequestID, forKey key: String) {
    requestIdCache[key] = requestId
  }

  func removeRequestId(forKey key: String) {
    requestIdCache.removeValue(forKey: key)
  }
}
