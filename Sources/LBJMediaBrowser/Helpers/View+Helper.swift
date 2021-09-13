import SwiftUI

extension View {
    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }
}
