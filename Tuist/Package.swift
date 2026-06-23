// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
      .package(
        url: "https://github.com/mattgallagher/CwlCatchException",
        .upToNextMajor(from: "2.1.2")
      ),
      .package(
        url: "https://github.com/mattgallagher/CwlPreconditionTesting",
        .upToNextMajor(from: "2.2.0")
      ),
    ]
)
