import SwiftUI

public struct YZClockView: View & Identifiable {
  
  public var backgroundColor: Color
  public var id: Int
  
  public var body: some View {
    VStack {
      Spacer()
      ZStack {
        YZElevatedView(
          width: 300,
          height: 300,
          cornerRadius: 150,
          backgroundColor: backgroundColor,
          style: .circular)
        YZDepressedView(
          width: 280,
          height: 280,
          cornerRadius: 140,
          backgroundColor: backgroundColor,
          style: .circular)
      }
      Spacer()
    }
  }
}
