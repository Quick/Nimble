// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "Nimble",
    platforms: [
      .macOS(.v10_10), .iOS(.v9), .tvOS(.v9)
    ],
    products: [
        .library(name: "Nimble", targets: ["Nimble"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: [
        .target(
            name: "Nimble",
            dependencies: [
                .product(name: "CwlPreconditionTesting", package: "CwlPreconditionTesting",
                         condition: .when(platforms: [.macOS, .iOS])),
                .product(name: "CwlPosixPreconditionTesting", package: "CwlPreconditionTesting",
                         condition: .when(platforms: [.tvOS]))
            ],
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "NimbleTests",
            dependencies: ["Nimble"],
            exclude: ["objc", "Info.plist"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
