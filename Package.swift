// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SwiftDependencyManager",
    products: [
        .executable(name: "sdm", targets: ["SwiftDependencyManager"]),
        .library(name: "SwiftDependencyManagerKit", type: .dynamic, targets: ["SwiftDependencyManagerKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/kiliankoe/CLISpinner.git", .upToNextMinor(from: "0.3.5")),
        .package(url: "https://github.com/fmccann/Clibgit2.git", .branch("master")),
        .package(url: "https://github.com/Flinesoft/HandySwift.git", .upToNextMajor(from: "2.6.0")),
        .package(url: "https://github.com/JamitLabs/MungoHealer.git", .upToNextMajor(from: "0.3.0")),
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.5.2")),
        .package(url: "https://github.com/onevcat/Rainbow.git", .upToNextMajor(from: "3.1.4")),
        .package(url: "https://github.com/jakeheis/SwiftCLI.git", .upToNextMajor(from: "5.1.2")),
        .package(url: "https://github.com/jdfergason/swift-toml.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "SwiftDependencyManager",
            dependencies: ["SwiftDependencyManagerKit"]
        ),
        .target(
            name: "SwiftDependencyManagerKit",
            dependencies: [
                "CLISpinner",
                "HandySwift",
                "MungoHealer",
                "PromiseKit",
                "Rainbow",
                "SwiftCLI",
                "Toml"
            ]
        ),
        .testTarget(
            name: "SwiftDependencyManagerKitTests",
            dependencies: ["SwiftDependencyManagerKit", "HandySwift", "PromiseKit"]
        )
    ]
)
