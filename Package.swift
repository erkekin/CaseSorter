// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CaseSorter",
  products: [
    .library(
      name: "CaseSorter",
      targets: ["CaseSorter"]),

    .executable(
      name: "caseSorter-swift",
      targets: ["caseSorter-swift"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50000.0"))
  ],
  targets: [
    .target(
      name: "CaseSorter",
      dependencies: ["SwiftSyntax"]),
    .testTarget(
      name: "CaseSorterTests",
      dependencies: ["CaseSorter"]),
    .target(
      name: "caseSorter-swift",
      dependencies: ["CaseSorter", "SwiftSyntax"]),
  ]
)
