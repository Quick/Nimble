// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Nimble",
    platforms: [
      .macOS(.v10_12), .iOS(.v10), .tvOS(.v10)
    ],
    products: [
        .library(name: "Nimble", targets: ["Nimble"]),
    ],
    dependencies: [
        .package(url: "https://github.com/norio-nomura/XCTAssertCrash.git", .exact("0.1.0")),
    ],
    targets: [
        .target(
            name: "Nimble", 
            dependencies: ["XCTAssertCrash"]
        ),
        .testTarget(
            name: "NimbleTests", 
            dependencies: ["Nimble"], 
            exclude: ["objc"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
