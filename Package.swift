// swift-tools-version:5.4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftXMLParserDemo",
    dependencies: [
        .package(url: "https://github.com/stefanspringer1/SwiftXMLParser", from: "0.1.33"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftXMLParserDemo",
            dependencies: ["SwiftXMLParser"]),
        .testTarget(
            name: "SwiftXMLParserDemoTests",
            dependencies: ["SwiftXMLParserDemo"]),
    ]
)
