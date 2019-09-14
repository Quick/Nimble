// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Nimble",
    platforms: [
      .macOS(.v10_10), .iOS(.v8), .tvOS(.v9)
    ],
    products: [
        .library(name: "Nimble", targets: ["Nimble"]),
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .exact("2.0.0-beta.1")),
    ],
    targets: [
        .target(
            name: "Nimble", 
            dependencies: {
                #if os(macOS)
                return ["CwlPreconditionTesting", "CwlPosixPreconditionTesting"]
                #else
                return []
                #endif
            }()
        ),
        .testTarget(
            name: "NimbleTests", 
            dependencies: ["Nimble"], 
            exclude: ["objc"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
