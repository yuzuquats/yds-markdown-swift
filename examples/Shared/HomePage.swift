import SwiftUI
import YZDesignSystem

struct PageView: View & Identifiable {
  var backgroundColor: Color
  var id: Int
  
  var body: some View {
    VStack {
      Spacer()
      ZStack {
        YZElevatedView(width: 200, height: 200, cornerRadius: 36, backgroundColor: backgroundColor)
        YZDepressedView(width: 180, height: 180, cornerRadius: 24, backgroundColor: backgroundColor)
        Text("Hello")
          .font(.largeTitle)
          .foregroundColor(.secondary)
      }
      Spacer()
      
    }
  }
}

struct HomePage: View {
  
  @State var selection: Int = 0
  
  //  let backgroundColor: Color = Color.init(UIColor(rgb: 0xf4f8fe))
  //  let backgroundColor: Color = Color.init(UIColor(rgb: 0xecf0f3))
  let backgroundColor: Color = Color.init(white: 0.95)
  //  let backgroundColor: Color = .red
  
  var body: some View {
//    YZTabbar(backgroundColor: self.backgroundColor) {
//      YZSwiftUIPagerView(index: self.$selection, pages: [
//        PageView(backgroundColor: self.backgroundColor, id: 0),
//        PageView(backgroundColor: self.backgroundColor, id: 1),
//        PageView(backgroundColor: self.backgroundColor, id: 2),
//      ])
//    }
    PageView(backgroundColor: self.backgroundColor, id: 0)
  }
}
