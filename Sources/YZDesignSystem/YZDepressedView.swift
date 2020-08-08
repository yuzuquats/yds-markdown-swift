import SwiftUI

public struct YZDepressedView: View {
  
  public var width: CGFloat
  public var height: CGFloat
  public var cornerRadius: CGFloat
  public var backgroundColor: Color
  public var style: RoundedCornerStyle = .continuous
  
  // @todo: jfc, xcode is fucking clowny
  // These need to be manually written or generated if they're used
  // by another module:
  // https://stackoverflow.com/questions/26224693/how-can-i-make-the-memberwise-initialiser-public-by-default-for-structs-in-swi
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
        .stroke(
          LinearGradient(
            gradient: Gradient(colors: [Color.init(white: 0.4), backgroundColor]),
            startPoint: UnitPoint(x: 0.2, y: 0.2),
            endPoint: UnitPoint(x: 0.6, y: 0.6)
          ),
          lineWidth: 4)
        .blur(radius: 4)
        .frame(width: width, height:height)
      
      // white shadow
      RoundedRectangle(cornerRadius: cornerRadius, style: style)
        .stroke(
          LinearGradient(
            gradient: Gradient(colors: [.white, backgroundColor]),
            startPoint: UnitPoint(x: 0.8, y: 0.8),
            endPoint: UnitPoint(x: 0.6, y: 0.6)
          ),
          lineWidth: 4)
        .blur(radius: 4)
        .frame(width: width, height:height)
    }
    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: style))
  }
}
