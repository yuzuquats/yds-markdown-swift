// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "YZDesignSystem",
  platforms: [
    .macOS(.v10_15), .iOS(.v13), .tvOS(.v13)
  ],
  products: [
    .library(
      name: "YZDesignSystem",
      targets: [
        "YZDesignSystem",
      ]),
    .library(
      name: "YZDesignSystemMacOS",
      targets: [
        "YZDesignSystemMacOS",
        "YZImage",
    ]),
    // TODO: MacOS only
    .library(
      name: "YZMarkdown",
      targets: [
        "YZMarkdown",
    ]),
  ],
  dependencies: [
    // Upstream
    .package(url: "http://github.com/jdfergason/swift-toml", from: "1.0.0"),
//    .package(url: "https://github.com/iwasrobbed/Down", from: "0.9.3"),
    // Local
    .package(path: "ThirdParty/Down")
  ],
  targets: [
    .target(
      name: "YZDesignSystemMacOS",
      path: "Sources/YZDesignSystem",
      sources: [
        "Commands.swift",
        "YZVisualEffectViewMacOS.swift",
      ]
    ),
    .target(
      name: "YZDesignSystem",
      path: "Sources/YZDesignSystem",
      sources: [
        "Button.swift",
        "Page.swift",
        "Utils.swift",
        "YZClockView.swift",
        "YZDepressedView.swift",
        "YZDesignSystem.swift",
        "YZElevatedView.swift",
        "YZTabBar.swift",
        "YZSwiftUIPagerView.swift",
      ]
    ),
    .target(
      name: "YZImage",
      path: "Sources/YZImage",
      sources: [
        "AsyncImage.swift",
        "EnvironmentValues+ImageCache.swift",
        "ImageCache.swift",
        "ImageLoader.swift",
      ]
    ),
    .target(
      name: "YZMarkdown",
      dependencies: [
        "Toml",
        "Down",
        "YZImage",
        "YZDesignSystem",
      ],
      path: "Sources/YZMarkdown",
      sources: [
        "YZMarkdownParser.swift",
        "YZMarkdownView.swift",
        "Renderer.swift",
        "YZMarkdownDebugRenderer.swift",
      ]
    ),
    .testTarget(
      name: "YZDesignSystemTests",
      dependencies: ["YZDesignSystem"]),
  ]
)
