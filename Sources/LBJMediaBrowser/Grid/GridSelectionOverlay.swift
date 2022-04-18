import SwiftUI

struct GridSelectionOverlay<SectionType: LBJMediaSectionType>: View {

  let media: MediaType
  let section: SectionType
  let status: SelectionStatus

  @EnvironmentObject
  private var selectionManager: LBJMediaSelectionManager<SectionType>

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topTrailing) {
        background
        checkmark
      }
    }
  }

  @ViewBuilder
  private var background: some View {
    switch status {
    case .disabled:
      Color.white
        .opacity(GridSelectionOverlayConstants.whiteBackgroundOpacity)
    case .unselected:
      Color.clear
    case .selected:
      Color.black
        .opacity(GridSelectionOverlayConstants.blackBackgroundOpacity)
    }
  }

  @ViewBuilder
  private var checkmark: some View {
    Image(systemName: status.isSelected ? "checkmark.circle.fill" : "checkmark.circle")
      .resizable()
      .frame(size: GridSelectionOverlayConstants.checkmarkSize)
      .padding(GridSelectionOverlayConstants.checkmarkPadding)
      .onTapGesture(perform: toggleSelection)
  }

  private func toggleSelection() {
    guard status.isDisabled == false else { return }

    if status.isSelected {
      selectionManager.deselect(media, in: section)
    } else {
      selectionManager.select(media, in: section)
    }
  }
}

enum GridSelectionOverlayConstants {
  static let whiteBackgroundOpacity: CGFloat = 0.7
  static let blackBackgroundOpacity: CGFloat = 0.4
  static let checkmarkSize: CGSize = .init(width: 20, height: 20)
  static let checkmarkPadding: CGFloat = 5
}
