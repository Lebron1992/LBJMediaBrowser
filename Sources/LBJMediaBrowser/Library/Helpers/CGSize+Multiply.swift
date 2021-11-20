import CoreGraphics

extension CGSize {
  public static func * (size: CGSize, by: CGFloat) -> CGSize {
    .init(width: size.width * by, height: size.height * by)
  }
}
