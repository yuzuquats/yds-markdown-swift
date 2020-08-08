import Foundation

import Down
import SwiftUI

public class YZMarkdownDebugRenderer: Visitor {
  
  private var depth = 0
  
  public init() {}
  
  private func report(_ node: Node) -> SwiftUI.Text {
    return Text("\(String(reflecting: node))")
  }
  
  private func reportWithChildren(_ node: Node) -> AnyView {
    let thisNode = report(node)
    depth += 1
    let children: [AnyView] = visitChildren(of: node)
    depth -= 1
    return AnyView(
      VStack(alignment: .leading) {
        thisNode
        ForEach(
          0..<children.count, id: \.self) { index in
          children[index]
        }
      }
      .padding(.leading, 20)
    )
  }
  
  // MARK: - Visitor
  
  public typealias Result = AnyView
  
  public func visit(document node: Document) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(blockQuote node: BlockQuote) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(list node: Down.List) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(item node: Item) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(codeBlock node: CodeBlock) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(htmlBlock node: HtmlBlock) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(customBlock node: CustomBlock) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(paragraph node: Paragraph) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(heading node: Heading) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(thematicBreak node: ThematicBreak) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(text node: Down.Text) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(softBreak node: SoftBreak) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(lineBreak node: LineBreak) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(code node: Code) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(htmlInline node: HtmlInline) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(customInline node: CustomInline) -> AnyView {
    return AnyView(report(node))
  }
  
  public func visit(emphasis node: Emphasis) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(strong node: Strong) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(link node: Down.Link) -> AnyView {
    return reportWithChildren(node)
  }
  
  public func visit(image node: Down.Image) -> AnyView {
    return reportWithChildren(node)
  }
}
