import Foundation

import Down
import SwiftUI

public struct YZMarkdownParser {
  
  public static func parse(text: String) {
    let down = DownRenderer(markdownString: text)
    let ast = try? down.toAST()
    if let ast = ast {
//      let document = Document(cmarkNode: ast)
//      let visitor = DebugVisitor()
//      let result = document.accept(visitor)
//
//      print(result)
    }
  }
  
  public static func debugParse(text: String) {
    let down = DownRenderer(markdownString: text)
    let ast = try? down.toAST()
    if let ast = ast {
      let document = Document(cmarkNode: ast)
      let visitor = DebugVisitor()
      let result = document.accept(visitor)
      
      print(result)
    }
  }
  
  public static func debugParseAndRenderView(
    rootPath: URL,
    text: String) -> AnyView
  {
    let down = DownRenderer(markdownString: text)
    let ast = try? down.toAST()
    if let ast = ast {
      let document = Document(cmarkNode: ast)
      let visitor = Renderer(rootPath: rootPath)
      return document.accept(visitor)!
    }
    return AnyView(Rectangle().fill(Color.red))
  }
}


//  private var indent: String {
//    return String(repeating: "    ", count: depth)
//  }
