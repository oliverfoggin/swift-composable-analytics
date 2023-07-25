// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "swift-composable-analytics",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	products: [
		.library(name: "ComposableAnalytics", targets: ["ComposableAnalytics"]),
	],
	dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "release/1.0"),
	],
	targets: [
		.target(
			name: "ComposableAnalytics",
			dependencies: [
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
			]
		)
	]
)
