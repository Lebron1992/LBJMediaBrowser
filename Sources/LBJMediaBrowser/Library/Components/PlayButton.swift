import SwiftUI

struct PlayButton: View {
  let size: CGFloat
  let action: (() -> Void)?

  init(size: CGFloat, action: (() -> Void)? = nil) {
    self.size = size
    self.action = action
  }
  
  var body: some View {
    Button {
      action?()
    } label: {
      Image(systemName: "play.circle")
        .font(.system(size: size, weight: .light))
        .foregroundColor(.white)
    }
    .disabled(action == nil)
  }
}
