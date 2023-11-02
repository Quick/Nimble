// swift-tools-version:5.5
import PackageDescription

let package = Package(
	name: "CwlCatchException",
	products: [
		.library(name: "CwlCatchException", targets: ["CwlCatchException"]),
	],
	targets: [
		.target(name: "CwlCatchException", dependencies: [.target(name: "CwlCatchExceptionSupport")]),
		.target(name: "CwlCatchExceptionSupport"),
		.testTarget(name: "CwlCatchExceptionTests", dependencies: [.target(name: "CwlCatchException")])
	]
)
