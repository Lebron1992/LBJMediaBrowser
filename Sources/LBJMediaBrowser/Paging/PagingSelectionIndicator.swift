//import SwiftUI
//
//struct PagingSelectionIndicator<Content: View> {
//  let alignment: Alignment
//  let content: (SelectionStatus) -> Content
//
//  init(
//    alignment: Alignment = .topLeading,
//    @ViewBuilder content: @escaping (SelectionStatus) -> Content
//  ) {
//    self.alignment = alignment
//    self.content = content
//  }
//}
//
//struct PagingSelectionIndicatorDefault: View {
//  let status: SelectionStatus
//
//  @EnvironmentObject
//  private var browser: LBJPagingBrowser
//
//  var body: some View {
//    Group {
//      switch status {
//      case .disabled:
//        EmptyView()
//      case .unselected:
//        Image(systemName: "checkmark.circle")
//      case .selected:
//        Image(systemName: "checkmark.circle.fill")
//      }
//    }
//    .resizable()
//    .frame(size: Constants.checkmarkSize)
//    .padding(Constants.checkmarkPadding)
//    .onTapGesture(perform: toggleSelection)
//  }
//
//  private func toggleSelection() {
//    guard status.isDisabled == false else { return }
//
//    if status.isSelected {
//      browser.dataSource.deselect(media, in: section)
//    } else {
//      browser.dataSource.select(media, in: section)
//    }
//  }
//}
//
//extension PagingSelectionIndicatorDefault {
//  enum Constants {
//    static let checkmarkSize: CGSize = .init(width: 20, height: 20)
//    static let checkmarkPadding: CGFloat = 5
//  }
//}
