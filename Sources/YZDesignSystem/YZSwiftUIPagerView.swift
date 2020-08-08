import SwiftUI

final class IntContainer {
  var value: Int = 0
}

final class FloatContainer {
  var value: CGFloat = 0
}

public struct YZSwiftUIPagerView<Content: View & Identifiable>: View {
  
  @Binding public var index: Int
  @State private var offset: CGFloat = 0
  @State private var isGestureActive: Bool = false
  
  @State private var waitingForGestureCompletion : IntContainer = IntContainer()
  @State private var previousIndex : IntContainer = IntContainer()
  @State private var indexFromGesture : IntContainer = IntContainer()
  
  public init(index: Binding<Int>, pages: [Content]) {
    _index = index
    self.pages = pages
  }

  public var pages: [Content]
  
  static func bezierBlend(t: CGFloat) -> CGFloat
  {
    return t * t * (3 - 2 * t)
  }
  
  private func calculateNormalizedProgress(indexToUse: Int, width: CGFloat) -> CGFloat
  {
    let progress = abs(self.offset / width + CGFloat(indexToUse))
    return YZSwiftUIPagerView.bezierBlend(t: progress)
  }
  
  private func calculateOffset(width: CGFloat) -> CGFloat
  {
    return self.isGestureActive ? self.offset : -width * CGFloat(self.index)
  }
  
  private func calculateScale(progress: CGFloat, selectedIndex: Int) -> CGFloat
  {
    if self.index != selectedIndex {
      return 0.9 + 0.1 * progress
    } else {
      return 1 - 0.1 * progress
    }
  }
  
  private func scrollView(progress: CGFloat, width: CGFloat) -> some View
  {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(alignment: .center, spacing: 0) {
        ForEach(0 ..< self.pages.count) { i in
          self.pages[i]
            .frame(width: width, height: nil)
            .scaleEffect(self.calculateScale(progress: progress, selectedIndex: i))
            .animation(.linear(duration: 0.3))
        }
      }
    }
    .content.offset(x: self.calculateOffset(width: width))
    .frame(width: width, height: nil, alignment: .leading)
    .highPriorityGesture(
      DragGesture()
        .onChanged({ value in
          self.isGestureActive = true
          self.indexFromGesture.value = self.index
          self.offset = value.translation.width + -width * CGFloat(self.index)
        })
        .onEnded({ value in
          if -value.predictedEndTranslation.width > width / 2, self.index < self.pages.endIndex - 1 {
            self.index += 1
          }
          if value.predictedEndTranslation.width > width / 2, self.index > 0 {
            self.index -= 1
          }
          withAnimation(.linear(duration: 0.3)) { self.offset = -width * CGFloat(self.index) }
          DispatchQueue.main.async { self.isGestureActive = false }
        }))
  }
  
  public var body: some View
  {
    GeometryReader { geometry -> AnyView in
      let previousIndex = self.previousIndex.value
      var normalizedProgress: CGFloat = self.calculateNormalizedProgress(indexToUse: self.isGestureActive ? self.indexFromGesture.value : self.index, width: geometry.size.width)
      if previousIndex != self.index || self.waitingForGestureCompletion.value == 1 {
        if normalizedProgress != 0 {
          self.waitingForGestureCompletion.value = 1
        } else {
          self.waitingForGestureCompletion.value = 0
        }
        normalizedProgress = 0
      }
      self.previousIndex.value = self.index
      return AnyView(
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
          self.scrollView(progress: normalizedProgress, width: geometry.size.width)
          
          Text("\(normalizedProgress) - \(self.index) - \(geometry.size.width)")
            .padding(12)
        }
      )
    }
  }
}

public struct YZPagerContainerView<Content> : Identifiable & View where Content : View {
  public var backgroundColor: Color
  public var id: Int
  var contentBuilder: () -> Content
  
  public init(backgroundColor: Color,
              id: Int,
              @ViewBuilder content: @escaping () -> Content) {
    self.backgroundColor = backgroundColor
    self.id = id
    contentBuilder = content
  }
  
  public var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .fill(backgroundColor)
        .padding(4)
      
      contentBuilder()
        .padding(4)
    }
  }
}
