import SwiftUI

public struct YZElevatedView: View {

  public var width: CGFloat
  public var height: CGFloat
  public var cornerRadius: CGFloat
  public var backgroundColor: Color
  public var style: RoundedCornerStyle = .continuous

  public init(width: CGFloat,
              height: CGFloat,
              cornerRadius: CGFloat,
              backgroundColor: Color,
              style: RoundedCornerStyle = .continuous)
  {
    self.width = width
    self.height = height
    self.cornerRadius = cornerRadius
    self.backgroundColor = backgroundColor
    self.style = style
  }

  public var body: some View {
    ZStack {
      // black shadow
      RoundedRectangle(cornerRadius: cornerRadius, style: style)
        .fill(backgroundColor)  // TODO(jameskao): aliasing reveals bg color
        .shadow(color: Color.init(white: 0.7), radius: 8, x: 4, y: 4)
        .frame(width: width, height:height)

      // white shadow
      RoundedRectangle(cornerRadius: cornerRadius, style: style)
        .fill(backgroundColor)  // TODO(jameskao): aliasing reveals bg color
        .shadow(color: Color.init(white: 1), radius: 8, x: -4, y: -4)
        .frame(width: width, height:height)

      // dark gradient
      RoundedRectangle(cornerRadius: cornerRadius, style: style)
        .fill(Color.clear)  // TODO(jameskao): BG defaults to black and shows nothing otherwise
        .background(
          LinearGradient(
            gradient: Gradient(colors: [Color.init(white: 0.88), backgroundColor]),
            startPoint: UnitPoint(x: 0, y: 0),
            endPoint: UnitPoint(x: 0.8, y: 0.8)
          ))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
        .frame(width: width, height:height)
    }
  }
}
