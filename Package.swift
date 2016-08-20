import PackageDescription

let package = Package(
    name: "Nimble",
    exclude: [
      "Sources/NimbleObjectiveC",
      "Tests/NimbleTests/objc"
    ]
)
