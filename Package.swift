// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "SwiftScriptDemos",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // Pin to Subprocess 0.1.0 release
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", exact: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "ls",
            dependencies: [.product(name: "Subprocess", package: "swift-subprocess")]
        ),
        .executableTarget(
            name: "zipdir",
            dependencies: [.product(name: "Subprocess", package: "swift-subprocess")]
        ),
        .executableTarget(
            name: "git-diff",
            dependencies: [.product(name: "Subprocess", package: "swift-subprocess")]
        ),
        .executableTarget(
            name: "thumbs-video",
            dependencies: [.product(name: "Subprocess", package: "swift-subprocess")]
        ),
    ]
)
