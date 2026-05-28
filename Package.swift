// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClipboardManager",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "ClipboardManager",
            path: "ClipboardManager",
            exclude: [
                "Info.plist",
                "ClipboardManager.entitlements",
                "Resources",
            ],
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("AppKit"),
            ]
        )
    ]
)
