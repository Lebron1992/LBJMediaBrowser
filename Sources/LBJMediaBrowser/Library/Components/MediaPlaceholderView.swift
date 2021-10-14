import SwiftUI

/// 一个显示媒体处于未处理状态时的对象。
/// An object that displays the media when it's in idle.
public struct MediaPlaceholderView: View {
  public var body: some View {
    Color.clear
  }
}

struct MediaPlaceholderView_Previews: PreviewProvider {
  static var previews: some View {
    MediaPlaceholderView()
  }
}
