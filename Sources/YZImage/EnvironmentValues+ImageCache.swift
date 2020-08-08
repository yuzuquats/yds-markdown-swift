import SwiftUI

public struct ImageCacheKey: EnvironmentKey {
  public static let defaultValue: ImageCache = TemporaryImageCache()
}

public extension EnvironmentValues {
  public var imageCache: ImageCache {
    get { self[ImageCacheKey.self] }
    set { self[ImageCacheKey.self] = newValue }
  }
}

