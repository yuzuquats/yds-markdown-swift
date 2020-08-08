import Foundation
import SwiftUI

public struct Page<Content, NavigationContent> : View where Content : View, NavigationContent : View
{
  public let navigationContent: NavigationContent
  public let content: Content
  
  @inlinable public init(
    navigationContent: NavigationContent,
    @ViewBuilder content: () -> Content)
  {
    self.navigationContent = navigationContent
    self.content = content()
  }
  
  public var body: some View
  {
    ZStack(alignment: .topLeading) {
      self.content
        .padding(.top, 40)
      
      VStack(alignment: .leading) {
        Spacer() // TODO: necessary?
        
        HStack {
          self.navigationContent
        }
        .padding(.leading, 80)
        .padding(.trailing, 20)
        .padding(.vertical, 0)
        .frame(minWidth: 0,
               maxWidth: .infinity,
               minHeight: 0,
               maxHeight: .infinity,
               alignment: .leading)
        
        Spacer() // TODO: necessary?
        
        // TODO: create divider component
        Rectangle()
          .fill(Color.init(white: 0.90))
          .frame(height: 1)
          .padding(0)
      }
      .frame(minWidth: 0,
             maxWidth: .infinity,
             minHeight: 40,
             maxHeight: 40,
             alignment: .leading)
    }
  }
}
