import UIKit

public struct MediaURLImage: MediaStatusEditable {

  let url: String
  public internal(set) var status: MediaStatus = .idle

  public init(url: String) {
    self.url = url
  }
}

// MARK: - Templates
extension MediaURLImage {
  static let urlImages = [
    "https://i.picsum.photos/id/249/1000/2000.jpg?hmac=LuHPEUVkziRf9usKW97DBxEzcifzgiCiRtm8vuJNZ9Q",
    "https://i.picsum.photos/id/17/1000/1000.jpg?hmac=5FRnLOBphDqiw_x9GZSSzNW0nfUgQ7kAVZdigKUxZvg",
    "https://www.example.com/test.png",
    "https://i.picsum.photos/id/62/1000/1500.jpg?hmac=6RG38x1oSbkw0aEoiHACAHEbUczQo_wXH22k0EWrueg",
    "https://i.picsum.photos/id/573/2000/3000.jpg?hmac=zWDJVoZPjb0L4jo_u7oXLC4m1dVJdI6Taoqu_6Ur1fM",
    "https://i.picsum.photos/id/988/1200/1300.jpg?hmac=TY3ULGEPR0nHWAYN8iqJZ0tHr4OK4MhBC5BgMiRV5Ls",
    "https://i.picsum.photos/id/1050/2000/1500.jpg?hmac=1wCAxLdsQCb2Yg99hfj0J-dCOshexlB3cKYM_pQOofw",
    "https://i.picsum.photos/id/287/1200/1600.jpg?hmac=nGoOXgqOvwXAOSfKNgRjmnCAj_Z85vau56xcj13KGR0",
    "https://i.picsum.photos/id/550/1400/2500.jpg?hmac=wz6FC8u4baJmQU-B4-OOyu8nMXO-b7VmupGSt7wi-oE",
    "https://i.picsum.photos/id/260/1200/500.jpg?hmac=ZMJeETUAlzrHjlwB72i76bB0zJjzpyPB1BVNwunC3uY"
  ]
    .map { MediaURLImage(url: $0) }
}
