import Combine
import SwiftUI

open class LBJGridMediaBrowserDataSource<SectionType: GridSection>: ObservableObject {

  @Published
  public private(set) var sections: [SectionType]

  let placeholderProvider: (Media) -> AnyView
  let progressProvider: (Float) -> AnyView
  let failureProvider: (Error) -> AnyView
  let contentProvider: (MediaLoadedResult) -> AnyView
  let sectionHeaderProvider: (SectionType) -> AnyView
  let pagingMediaBrowserProvider: (Int) -> AnyView

  public init(
    sections: [SectionType],
    placeholderProvider: ((Media) -> AnyView)? = nil,
    progressProvider: ((Float) -> AnyView)? = nil,
    failureProvider: ((Error) -> AnyView)? = nil,
    contentProvider: ((MediaLoadedResult) -> AnyView)? = nil,
    sectionHeaderProvider: ((SectionType) -> AnyView)? = nil,
    pagingMediaBrowserProvider: ((Int) -> AnyView)? = nil
  ) {
    self.sections = sections

    self.placeholderProvider = placeholderProvider ?? { _ in
      MediaPlaceholderView()
        .asAnyView()
    }

    self.progressProvider = progressProvider ?? {
      LoadingProgressView(
        progress: $0,
        size: LBJGridMediaBrowserConstant.progressSize
      )
        .asAnyView()
    }

    self.failureProvider = failureProvider ?? { _ in
      GridMediaErrorView()
        .asAnyView()
    }

    self.contentProvider = contentProvider ?? {
      GridMediaLoadedResultView(result: $0)
        .asAnyView()
    }

    self.sectionHeaderProvider = sectionHeaderProvider ?? { _ in
      EmptyView()
        .asAnyView()
    }

    self.pagingMediaBrowserProvider = pagingMediaBrowserProvider ?? { _ in AnyView(EmptyView()) }
  }
}

// MARK: - Manage Sections
extension LBJGridMediaBrowserDataSource {
  public var numberOfMedias: Int {
    sections.reduce(0) { $0 + $1.medias.count }
  }

  public var numberOfSections: Int {
    sections.count
  }

  public func numberOfMedias(in section: SectionType) -> Int {
    medias(in: section).count
  }

  public func medias(in section: SectionType) -> [Media] {
    sections.first(where: { $0 == section })?.medias ?? []
  }

  public func media(at index: Int, in section: SectionType) -> Media? {
    let mediasInSection = medias(in: section)
    return (0..<mediasInSection.count) ~= index ? mediasInSection[index] : nil
  }

  public func appendSection(_ section: SectionType) {
    guard sections.contains(section) == false else { return }
    sections.append(section)
  }

  public func insertSection(_ section: SectionType, before: SectionType) {
    guard
      sections.contains(section) == false,
      let beforeIndex = sections.firstIndex(of: before)
    else {
      return
    }
    sections.insert(section, at: beforeIndex)
  }

  public func insertSection(_ section: SectionType, after: SectionType) {
    guard
      sections.contains(section) == false,
      let afterIndex = sections.firstIndex(of: after)
    else {
      return
    }
    sections.insert(section, at: afterIndex + 1)
  }
}
