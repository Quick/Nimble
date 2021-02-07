// swift-tools-version:5.2
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
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/johnno1962/Fortify.git", .upToNextMajor(from: "2.1.4")),
    ],
    targets: [
        .target(
            name: "Nimble", 
            dependencies: {
                #if os(macOS)
                return [
                    "CwlPreconditionTesting",
                    .product(name: "CwlPosixPreconditionTesting", package: "CwlPreconditionTesting"),
                    "Fortify",
                ]
                #else
                return ["Fortify"]
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
