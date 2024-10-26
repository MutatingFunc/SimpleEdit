// swift-tools-version: 5.10

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "SimpleEdit",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .iOSApplication(
            name: "SimpleEdit",
            targets: ["AppModule"],
            bundleIdentifier: "James.SimpleEdit",
            teamIdentifier: "VKFDYMU9HJ",
            displayVersion: "2.0",
            bundleVersion: "6",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            capabilities: [
                .fileAccess(.userSelectedFiles, mode: .readWrite)
            ],
            appCategory: .utilities,
            additionalInfoPlistContentFilePath: "Info.plist"
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
