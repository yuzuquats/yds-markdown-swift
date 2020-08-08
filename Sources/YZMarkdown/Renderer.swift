import Foundation

import Toml
import Down
import SwiftUI
import YZImage
import YZDesignSystem

public class Renderer: Visitor {
  
  // Environment Variables For Running
  private var rootPath: URL
  
  private var depth = 0
  
  private var emphasis = false
  private var strong = false
  private var code = false
  private var link: Down.Link? = nil
  private var style: TextStyles? = nil
  
  private var listDepth = 0
  private var listTight = false
  private var listOrder: [Down.List.ListType] = []
  private var listMarker: String? = nil
  
  private var codeBlockConfigurations: Dictionary<String, Toml?> = Dictionary()
  private var currentCodeBlockConfiguration: Toml?
  
  public init(rootPath: URL) {
    self.rootPath = rootPath
  }
  
  private func report(_ node: Node) -> SwiftUI.Text {
    return Text("\(String(reflecting: node))")
  }
  
  private func debugReportWithChildren(_ node: Node, needsPadding: Bool) -> AnyView? {
    return reportWithChildren(node, child: AnyView(report(node)), needsPadding: needsPadding)
  }
  
  private func reportWithChildren(_ node: Node, child: AnyView?, needsPadding: Bool) -> AnyView? {
    depth += 1
    let children: [AnyView] = visitChildren(of: node).compactMap{ $0 }
    depth -= 1
    return AnyView(
      VStack(alignment: .leading, spacing: 0) {
        if child != nil  {
          child
        }
        ForEach(
          0..<children.count, id: \.self) { index in
          children[index]
        }
      }
      .padding(.leading, needsPadding ? 20 : 0)
    )
  }
  
  // MARK: - Visitor
  
  public typealias Result = AnyView?
  
  public func visit(document node: Document) -> AnyView?
  {
    depth += 1
    let children: [AnyView] = visitChildren(of: node).compactMap{ $0 }
    depth -= 1
    return AnyView(
      DocumentView(
        node: node,
        children: children,
        rootPath: rootPath,
        configurations: codeBlockConfigurations)
    )
  }
  
  public func visit(blockQuote node: BlockQuote) -> AnyView?
  {
    // TODO:
    return debugReportWithChildren(node, needsPadding: true)
  }
  
  public func visit(list node: Down.List) -> AnyView?
  {
    let previousListTight = listTight
    listDepth += 1
    listOrder.append(node.listType)
    listTight = node.isTight
    let child = reportWithChildren(node, child: nil, needsPadding: true)
    listTight = previousListTight
    listOrder.removeLast()
    listDepth -= 1
    return child
  }
  
  public func visit(item node: Item) -> AnyView?
  {
    let listType: Down.List.ListType? = listOrder.popLast()
    if let listType = listType {
      switch listType {
        case .bullet:
          listMarker = ListMarker.markerForDepth(depth: listDepth)
          listOrder.append(listType)
        case .ordered(let start):
          listMarker = "\(start)."
          listOrder.append(Down.List.ListType.ordered(start: start + 1))
      }
    }
    return reportWithChildren(node, child: nil, needsPadding: false)
  }
  
  public func visit(codeBlock node: CodeBlock) -> AnyView?
  {
    let lines = node.literal?.split(separator: "\n") ?? [" "]
    codeBlockConfigurations[node.literal ?? ""] = currentCodeBlockConfiguration
    currentCodeBlockConfiguration = nil
    return AnyView(
      // TODO: maybe we can optimize this to avoid the extra inits?
      CodeBlockView(lines: lines.map(String.init))
    )
  }
  
  public func visit(htmlBlock node: HtmlBlock) -> AnyView?
  {
    if let string = node.literal {
      let candidate = string.replacingOccurrences(of: "\n", with: "")
      let prefix = "<!-- ```toml"
      let suffix = "-->"
      if candidate.hasPrefix(prefix) && candidate.hasSuffix(suffix) {
        let endIndex = candidate.count - suffix.count
        let tomlString = candidate[prefix.count..<endIndex]
        do {
          currentCodeBlockConfiguration = try Toml(withString: tomlString)
          print("Parsed TomL: \(String(describing: currentCodeBlockConfiguration))")
        } catch {
          print("Error: failed to parse \(tomlString)")
        }
      }
    }
    // Not Supported
    return reportWithChildren(node, child: nil, needsPadding: false)
  }
  
  public func visit(customBlock node: CustomBlock) -> AnyView?
  {
    // TODO: Not Supported
    return debugReportWithChildren(node, needsPadding: false)
  }
  
  public func visit(paragraph node: Paragraph) -> AnyView?
  {
    depth += 1
    let children: [AnyView] = visitChildren(of: node).compactMap{ $0 }
    depth -= 1
    let view = AnyView(
      HStack(alignment: .top, spacing: 0) {
        if listMarker != nil {
          HStack {
            Text(listMarker!)
              .applyTextStyle(style: style ?? .p)
          }
            .frame(
              minWidth: 24,
              idealWidth: nil,
              maxWidth: nil,
              minHeight: nil,
              idealHeight: nil,
              maxHeight: nil,
              alignment: .topLeading)
        }
        
        ForEach(0..<children.count, id: \.self) { index in
          children[index]
        }
      }
    )
    listMarker = nil
    return view
  }
  
  public func visit(heading node: Heading) -> AnyView?
  {
    depth += 1
    style = TextStyles.all[node.headingLevel]
    let children: [AnyView] = visitChildren(of: node).compactMap{ $0 }
    depth -= 1
    let child = AnyView(
      HStack(alignment: .top, spacing: 0) {
        Text(node.cmarkNode.title ?? "")
          .applyTextStyle(style: style ?? .p)
        
        ForEach(0..<children.count, id: \.self) { index in
          children[index]
        }
      }.applyPaddingForTextStyle(style: style ?? .p)
    )
    style = nil
    return child
  }
  
  public func visit(thematicBreak node: ThematicBreak) -> AnyView?
  {
    return AnyView(
      Rectangle()
        .fill(Color.init(white: 0.90))
        .frame(height: 2)
        .padding(.vertical, 8)
    )
  }
  
  public func visit(text node: Down.Text) -> AnyView?
  {
    var text = Text(node.cmarkNode.literal ?? "")
      .applyTextStyle(style: style ?? .p)
      .fontWeight(strong ? .semibold : .regular)

    if emphasis {
      text = text.italic()
    }
    
    if let _ = link {
      text = text.foregroundColor(Color.blue)
    }

    return AnyView(text)
  }
  
  public func visit(softBreak node: SoftBreak) -> AnyView?
  {
    return nil
  }
  
  public func visit(lineBreak node: LineBreak) -> AnyView?
  {
    // TODO: Not entirely accurate - this will hard break with a VStack but not an HStack
    return AnyView(Text("").applyTextStyle(style: style ?? .p))
  }
  
  public func visit(code node: Code) -> AnyView?
  {
    // RFC: using negative padding here - is thtere a bettter way for this?
    let horizontalPadding: CGFloat = 3.0
    return
      AnyView(
        HStack {
          Text(node.literal ?? "")
            .font(.system(.body, design: .monospaced))
            .background(
              RoundedRectangle(cornerRadius: 2)
                .fill(Color.init(white: 0.88))
                .padding(.horizontal, -horizontalPadding))
        }
        .padding(.horizontal, horizontalPadding)
      )
  }
  
  public func visit(htmlInline node: HtmlInline) -> AnyView?
  {
    // TODO: Not supported
    return AnyView(report(node))
  }
  
  public func visit(customInline node: CustomInline) -> AnyView?
  {
    // TODO: Not supported
    return AnyView(report(node))
  }
  
  public func visit(emphasis node: Emphasis) -> AnyView?
  {
    emphasis = true
    let children = reportWithChildren(node, child: nil, needsPadding: false)
    emphasis = false
    return children
  }
  
  public func visit(strong node: Strong) -> AnyView?
  {
    strong = true
    let children = reportWithChildren(node, child: nil, needsPadding: false)
    strong = false
    return children
  }
  
  public func visit(link node: Down.Link) -> AnyView?
  {
    link = node
    let children = reportWithChildren(node, child: nil, needsPadding: false)
    link = nil
    return children
  }
  
  public func visit(image node: Down.Image) -> AnyView?
  {
    AnyView(AsyncImage(
      url: URL(string: node.url ?? "")!,
      // TODO: better placeholder
      placeholder: Text("Loading ..."),
      configuration: {
        AnyView(
          $0
            .resizable()
            .aspectRatio(contentMode: .fit))
      }
      // TODO: what aspect ratio do we use
    ).frame(width: 200))
  }
}

public struct DocumentView : View
{
  let node: Node
  let children: [AnyView]
  let rootPath: URL
  
  let configurations: Dictionary<String, Toml?>
  @State var outputMap: Dictionary<String, [String]> = Dictionary()
  
  public init(
    node: Node,
    children: [AnyView],
    rootPath: URL,
    configurations: Dictionary<String, Toml?> = Dictionary()
  )
  {
    self.node =  node
    self.children = children
    self.rootPath = rootPath
    self.configurations = configurations
  }
  
  func getCodeBlock(index: Int) -> CodeBlock?
  {
    node.children[index] as? CodeBlock
  }
  
  public var body: some View
  {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(
        0..<children.count, id: \.self) { index -> AnyView in
        let codeBlock: CodeBlock? = getCodeBlock(index: index)
        return AnyView(
          HStack(alignment: .top) {
            self.contextBox(codeBlock: codeBlock)
            VStack {
              children[index]
              if codeBlock != nil {
                CodeBlockView(lines: outputMap[codeBlock?.literal ?? ""] ?? [""])
              }
            }
          }
        )
      }
    }
  }
  
  func contextBox(codeBlock: CodeBlock?) -> some View
  {
    ZStack(alignment: .topLeading) {
      // TODO: breaking this down into a single if/else statement causes
      // the button to disappear...
      if codeBlock != nil {
        // TODO: need a button with hover state
        Button(
          action: {
            guard let key = codeBlock?.literal else {
              return
            }
            
            let configuration = configurations[codeBlock?.literal ?? ""]
            let environmentConfiguration: Toml? = configuration??.table("environment")
            let environmentVariablesConfiguration: [[String]] = environmentConfiguration?.array("variables") ?? []
            let environmentVariables: Dictionary<String, String> =
              Dictionary(uniqueKeysWithValues: environmentVariablesConfiguration.map {
                ($0.get(index: 0) ?? "", $0.get(index: 2) ?? "")
              })
            
            self.outputMap[key] = []
            let commands = codeBlock?.literal?.split(separator: "\n") ?? []
            print("\n\nRunning Command Group: \(commands)")
            print("Variables: \(String(describing: environmentVariables))")
            print("----")
            
            commands.forEach { command in
              var commandComponents: [String] = command.split(separator: " ").map(String.init)
              commandComponents = commandComponents.map { string in
                if string.hasPrefix("$") {
                  return environmentVariables[string[1...]] ?? ""
                } else {
                  return string
                }
              }
              
              print("Running Command: \(commandComponents)")
              
              let pipe = Pipe()
              shell(commandComponents,
                    currentDirectoryURL: rootPath,
                    pipe: pipe)
              
              let data = pipe.fileHandleForReading.readDataToEndOfFile()
              if let string = String(data: data, encoding: String.Encoding.utf8) {
                let resultLines = string.split(separator: "\n")
                resultLines.forEach { line in
                  self.outputMap[key]?.append(String.init(line))
                }
              }
            }
          }) {
          Text("Run")
        }
        .buttonStyle(FlatButtonStyle())
      }
    }
    .padding(.vertical, 12)
    .frame(width: 120, height: 0, alignment: .topLeading)
  }
  
  @discardableResult
  func shell(_ args: [String], currentDirectoryURL: URL, pipe: Pipe) -> Int32 {
    let task = Process()
    task.currentDirectoryURL = currentDirectoryURL
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
  }
}

struct CodeBlockView : View {
  
  let lines: [String]
  init(lines: [String]) {
    // TODO: fix jank when lines == empty
    self.lines = lines.count > 0 ? lines : [" "]
  }
  
  var body: some View {
    // TODO: hscroll this in case line is too long?
    VStack(alignment: .leading) {
      ForEach(lines, id: \.self) { line in
        Text(line)
          .font(.system(.body, design: .monospaced))
      }
    }
    .frame(
      minWidth: 0,
      idealWidth: .infinity,
      maxWidth: .infinity,
      minHeight: nil,
      idealHeight: nil,
      maxHeight: nil,
      alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 4)
        .fill(Color.init(white: 0.94))
        .padding(.vertical, -12)
        .padding(.horizontal, -16)
    )
    .padding(.vertical, 12 + 8)
    .padding(.horizontal, 16)
  }
}

// TODO: move this to YZDesignSystem
struct FlatButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .foregroundColor(Color.init(white: 0.24))
      .background(configuration.isPressed ? Color.init(white: 0.8) : Color.init(white: 0.94))
      .cornerRadius(6.0)
  }
}

public class TextStyles {
  var fontWeight: Font.Weight
  var fontSize: CGFloat
  var topPadding: CGFloat
  var bottomPadding: CGFloat
  
  public init(
    fontSize: CGFloat,
    fontWeight: Font.Weight,
    topPadding: CGFloat,
    bottomPadding: CGFloat
  )
  {
    self.fontWeight = fontWeight
    self.fontSize = fontSize
    self.topPadding = topPadding
    self.bottomPadding = bottomPadding
  }
  
  public static let p  = TextStyles(fontSize: 14, fontWeight: .regular, topPadding: 0, bottomPadding: 0)
  public static let h1 = TextStyles(fontSize: 36, fontWeight: .bold, topPadding: 16, bottomPadding: 12)
  public static let h2 = TextStyles(fontSize: 30, fontWeight: .bold, topPadding: 12, bottomPadding: 12)
  public static let h3 = TextStyles(fontSize: 24, fontWeight: .semibold, topPadding: 10, bottomPadding: 10)
  public static let h4 = TextStyles(fontSize: 20, fontWeight: .semibold, topPadding: 8, bottomPadding: 8)
  public static let h5 = TextStyles(fontSize: 18, fontWeight: .semibold, topPadding: 6, bottomPadding: 6)
  public static let h6 = TextStyles(fontSize: 16, fontWeight: .semibold, topPadding: 4, bottomPadding: 4)
  
  public static let all = [p, h1, h2, h3, h4, h5, h6]
}

extension SwiftUI.View {
  public func applyPaddingForTextStyle(style: TextStyles) -> some View {
    return self
      .padding(.top, style.topPadding)
      .padding(.bottom, style.bottomPadding)
  }
}

extension SwiftUI.Text {
  public func applyTextStyle(style: TextStyles?) -> SwiftUI.Text {
    if let style = style {
      return self
        .fontWeight(style.fontWeight)
        .font(Font.system(size: style.fontSize, design: .default))
    }
    return self
  }
}

public class ListMarker {
  public static func markerForDepth(depth: Int) -> String?
  {
    if depth == 0 {
      return nil
    }
    
    let index = depth - 1 % 3
    if index == 0 {
      return "\u{2022}" // circle bullet •
    } else if index == 1 {
      return "\u{25E6}" // empty bullet ◦
    } else if index == 2 {
      return "\u{25AA}" // square middle bullet ▪︎
    } else {
      return "\u{2022}" // circle bullet •
    }
  }
}

// TODO: move to utils
extension String {
//  subscript (bounds: CountableClosedRange<Int>) -> String {
//    let start = index(startIndex, offsetBy: bounds.lowerBound)
//    let end = index(startIndex, offsetBy: bounds.upperBound)
//    return String(self[start...end])
//  }
//
//  subscript (bounds: CountableRange<Int>) -> String {
//    let start = index(startIndex, offsetBy: bounds.lowerBound)
//    let end = index(startIndex, offsetBy: bounds.upperBound)
//    return String(self[start..<end])
//  }
  
  subscript (_ index: Int) -> String {
    return String(self[self.index(startIndex, offsetBy: index)])
  }
  
  subscript (_ range: CountableRange<Int>) -> String {
    let lowerBound = index(startIndex, offsetBy: range.lowerBound)
    let upperBound = index(startIndex, offsetBy: range.upperBound)
    return String(self[lowerBound..<upperBound])
  }
  
  subscript (_ range: CountableClosedRange<Int>) -> String {
    let lowerBound = index(startIndex, offsetBy: range.lowerBound)
    let upperBound = index(startIndex, offsetBy: range.upperBound)
    return String(self[lowerBound...upperBound])
  }
  
  subscript (_ range: CountablePartialRangeFrom<Int>) -> String {
    return String(self[index(startIndex, offsetBy: range.lowerBound)...])
  }
  
  subscript (_ range: PartialRangeUpTo<Int>) -> String {
    return String(self[..<index(startIndex, offsetBy: range.upperBound)])
  }
  
  subscript (_ range: PartialRangeThrough<Int>) -> String {
    return String(self[...index(startIndex, offsetBy: range.upperBound)])
  }
}

extension Array where Self.Element : Equatable {
  
  // Safely lookup an index that might be out of bounds,
  // returning nil if it does not exist
  func get(index: Int) -> Element? {
    if 0 <= index && index < count {
      return self[index]
    } else {
      return nil
    }
  }
}
