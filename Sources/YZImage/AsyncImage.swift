import SwiftUI

public struct AsyncImage<Placeholder: View>: View {
  @ObservedObject private var loader: ImageLoader
  private let placeholder: Placeholder?
  private let configuration: (Image) -> AnyView
  
  public init(url: URL, cache: ImageCache? = nil, placeholder: Placeholder? = nil, configuration: @escaping (Image) -> AnyView = { AnyView($0) }) {
    loader = ImageLoader(url: url, cache: cache)
    self.placeholder = placeholder
    self.configuration = configuration
  }
  
  public var body: some View {
    image
      .onAppear(perform: loader.load)
      .onDisappear(perform: loader.cancel)
  }
  
  private var image: some View {
    Group {
      if loader.image != nil {
        configuration(Image(nsImage: loader.image!))
      } else {
        placeholder
      }
    }
  }
}

