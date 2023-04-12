// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Nimble",
    platforms: [
      .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "Nimble",
            targets: {
                var targets: [String] = ["Nimble"]
 #if os(macOS)
                targets.append("NimbleObjectiveC")
 #endif
                return targets
            }()
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", .upToNextMajor(from: "2.1.0")),
    ],
    targets: {
        var testHelperDependencies: [PackageDescription.Target.Dependency] = ["Nimble"]
        #if os(macOS)
        testHelperDependencies.append("NimbleObjectiveC")
        #endif
        var targets: [Target] = [
            .target(
                name: "Nimble",
                dependencies: [
                    .product(name: "CwlPreconditionTesting", package: "CwlPreconditionTesting",
                             condition: .when(platforms: [.macOS, .iOS, .macCatalyst])),
                    .product(name: "CwlPosixPreconditionTesting", package: "CwlPreconditionTesting",
                             condition: .when(platforms: [.tvOS, .watchOS]))
                ],
                exclude: ["Info.plist"]
            ),
            .target(
                name: "NimbleSharedTestHelpers",
                dependencies: testHelperDependencies
            ),
            .testTarget(
                name: "NimbleTests",
                dependencies: ["Nimble", "NimbleSharedTestHelpers"],
                exclude: ["Info.plist"]
            ),
        ]
#if os(macOS)
        targets.append(contentsOf: [
            .target(
                name: "NimbleObjectiveC",
                dependencies: ["Nimble"]
            ),
            .testTarget(
                name: "NimbleObjectiveCTests",
                dependencies: ["NimbleObjectiveC", "Nimble", "NimbleSharedTestHelpers"]
            )
        ])
 #endif
        return targets
    }(),
    swiftLanguageVersions: [.v5]
)
