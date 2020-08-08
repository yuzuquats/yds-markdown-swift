import AppKit

public protocol ImageCache {
    subscript(_ url: URL) -> NSImage? { get set }
}

public struct TemporaryImageCache: ImageCache {
    private let cache = NSCache<NSURL, NSImage>()
    
    public subscript(_ key: URL) -> NSImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}
