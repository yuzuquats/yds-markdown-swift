import AppKit
import SwiftUI

public struct YZVisualEffectViewMacOS: NSViewRepresentable {
  public typealias NSViewType = NSVisualEffectView
  
  public var material: NSVisualEffectView.Material?

  public init(
    material: NSVisualEffectView.Material?)
  {
    self.material = material
  }
  
  public func makeNSView(context: NSViewRepresentableContext<Self>) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.blendingMode = .behindWindow
    view.state = .active
    return view
  }

  public func updateNSView(_ nsView: NSVisualEffectView, context: NSViewRepresentableContext<Self>) {
    nsView.material = material!
  }
}
