import Foundation
import CryptoKit

extension String {
  var md5: String {
    guard let data = data(using: .utf8) else {
      return self
    }
    let result = Insecure.MD5.hash(data: data)
      .reduce("") { $0 + String(format: "%02x", $1) }
    return result
  }
}
