import Foundation
import SwiftUI

@available(macOS, introduced: 11)
public struct Button : View
{
  @State private var pressed = false
  @State private var hovered = false
  private let completion: () -> Void

  public init(completion: @escaping () -> Void = {})
  {
    self.completion = completion
  }
  
  public var body: some View
  {
    HStack {
      Image(systemName: "rectangle.rightthird.inset.fill")
        .font(.system(size: 16.0))
        .foregroundColor(Color.init(white: 0.5))
    }
    .background(
      RoundedRectangle(cornerRadius: 4)
        .fill(pressed
          ? Color.init(white: 0.82)
          : hovered ? Color.init(white: 0.90) : Color.clear)
        .padding(.vertical, -4)
        .padding(.horizontal, -8)
    )
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .onHover { isHovered in
      self.hovered = isHovered
    }
    .gesture(
      DragGesture(minimumDistance: 0)
        .onChanged({ _ in
          if !pressed {
            pressed = true
          }
        })
        .onEnded { _ in
          if pressed {
            pressed = false
          }
        }
        .simultaneously(
          with:
            TapGesture()
            .onEnded({ _ in
              self.completion()
            }))
    )
  }
}
