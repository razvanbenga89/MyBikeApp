// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyBikeApp",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
      .library(name: "AppFeature", targets: ["AppFeature"]),
      .library(name: "Theme", targets: ["Theme"]),
      .library(name: "Localization", targets: ["Localization"]),
      .library(name: "BikesFeature", targets: ["BikesFeature"]),
      .library(name: "RidesFeature", targets: ["RidesFeature"]),
      .library(name: "Storage", targets: ["Storage"]),
      .library(name: "Models", targets: ["Models"]),
      .library(name: "BikesRepo", targets: ["BikesRepo"]),
      .library(name: "BikesRepoLive", targets: ["BikesRepoLive"]),
      .library(name: "RidesRepo", targets: ["RidesRepo"]),
      .library(name: "RidesRepoLive", targets: ["RidesRepoLive"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.0"),
      .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.4.5"),
      .package(url: "https://github.com/exyte/PopupView.git", from: "2.4.2")
    ],
    targets: [
      .target(name: "BikesFeature", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Theme",
        "Localization",
        "Models",
        "BikesRepo",
        "RidesFeature"
      ]),
      .target(name: "RidesFeature", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Theme",
        "Localization",
        "Models",
        "BikesRepo",
        "RidesRepo"
      ]),
      .target(name: "AppFeature", dependencies: [
        "BikesFeature",
        "RidesFeature",
        "Theme"
      ]),
      .target(name: "Theme", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        "PopupView"
      ]),
      .target(
        name: "Localization",
        dependencies: [],
        resources: [.process("Resources")]
      ),
      .target(
        name: "Storage",
        dependencies: [
          "Models"
        ]
      ),
      .target(
        name: "Models",
        dependencies: []
      ),
      .target(name: "BikesRepo", dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]),
      .target(name: "BikesRepoLive", dependencies: [
        "Storage",
        "BikesRepo"
      ]),
      .target(name: "RidesRepo", dependencies: [
        "Models",
        .product(name: "Dependencies", package: "swift-dependencies")
      ]),
      .target(name: "RidesRepoLive", dependencies: [
        "Storage",
        "RidesRepo"
      ]),
    ]
)
