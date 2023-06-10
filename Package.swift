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
      .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
      .library(name: "Storage", targets: ["Storage"]),
      .library(name: "Models", targets: ["Models"]),
      .library(name: "BikesRepo", targets: ["BikesRepo"]),
      .library(name: "BikesRepoLive", targets: ["BikesRepoLive"]),
      .library(name: "RidesRepo", targets: ["RidesRepo"]),
      .library(name: "RidesRepoLive", targets: ["RidesRepoLive"]),
      .library(name: "UserDefaultsConfig", targets: ["UserDefaultsConfig"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "0.1.0"),
      .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.4.5"),
      .package(url: "https://github.com/aheze/Popovers", from: "1.3.2")
    ],
    targets: [
      .target(name: "BikesFeature", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Theme",
        "Localization",
        "Models",
        "BikesRepo",
        "RidesFeature",
        "UserDefaultsConfig"
      ]),
      .target(name: "RidesFeature", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Theme",
        "Localization",
        "Models",
        "BikesRepo",
        "RidesRepo",
        "UserDefaultsConfig"
      ]),
      .target(name: "SettingsFeature", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        "Theme",
        "Localization",
        "Models",
        "Storage",
        "BikesRepo",
        "UserDefaultsConfig"
      ]),
      .target(name: "AppFeature", dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        "BikesFeature",
        "RidesFeature",
        "SettingsFeature",
        "Theme"
      ]),
      .target(name: "Theme", dependencies: [
        .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
        "Popovers"
      ]),
      .target(
        name: "Localization",
        dependencies: [],
        resources: [.process("Resources")]
      ),
      .target(
        name: "Storage",
        dependencies: [
          "Models",
          "UserDefaultsConfig"
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
      .target(name: "UserDefaultsConfig", dependencies: [
        "Models"
      ])
    ]
)
