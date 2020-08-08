import SwiftUI

public struct YZTabbar<Content: View>: View {
  
  public let tabbarHeight: CGFloat = 52
  
  public var content: Content
  public var backgroundColor: Color
  
  public init(
    backgroundColor: Color,
    @ViewBuilder content: () -> Content)
  {
    self.backgroundColor = backgroundColor
    self.content = content()
  }
  
  public var body: some View
  {
    ZStack {
      backgroundColor
        .edgesIgnoringSafeArea(.vertical)
      
      GeometryReader { geometry in
        VStack {
          self.content
            .frame(width: geometry.size.width,
                   height: geometry.size.height - self.tabbarHeight,
                   alignment: .top)
          YZElevatedView(width: geometry.size.width - 48,
                         height: self.tabbarHeight,
                         cornerRadius: 12,
                         backgroundColor: self.backgroundColor)
          Spacer(minLength: 8)
        }
      }
    }
  }
}
