// swift-tools-version:4.2
import PackageDescription

let package = Package(
	name: "CwlCatchException",
	products: [
		.library(name: "CwlCatchException", type: .dynamic, targets: ["CwlCatchException"]),
	],
	targets: [
		.target(name: "CwlCatchException", dependencies: [.target(name: "CwlCatchExceptionSupport")]),
		.target(name: "CwlCatchExceptionSupport"),
		.testTarget(name: "CwlCatchExceptionTests", dependencies: [.target(name: "CwlCatchException")])
	]
)
