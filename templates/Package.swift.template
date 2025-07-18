// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AzureCommunicationUI",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        // Azure Communication Services Calling SDK (XCFramework binary)
        .library(
            name: "AzureCommunicationCalling",
            targets: ["AzureCommunicationCalling"]
        ),
        // Azure Communication UI Calling Library (XCFramework binary with embedded FluentUI)
        .library(
            name: "AzureCommunicationUICalling",
            targets: ["AzureCommunicationUICallingBinary", "AzureCommunicationCommon", "AzureCore", "FluentUI"]
        ),
        // Azure Communication UI Chat Library (XCFramework binary with embedded FluentUI)
        .library(
            name: "AzureCommunicationUIChat",
            targets: ["AzureCommunicationUIChatBinary", "AzureCommunicationChat", "Trouter", "AzureCommunicationCommon", "AzureCore", "FluentUI"]
        ),
        // Azure Communication UI Common Library (from local sources)
        .library(
            name: "AzureCommunicationUICommon",
            targets: ["AzureCommunicationUICommon"]
        ),
    ],
    dependencies: [
        // No external dependencies needed - using local sources and XCFrameworks
    ],
    targets: [
        // MARK: - Binary Targets (XCFrameworks)
        
        // AzureCommunicationCalling binary target (Azure Communication Services Calling SDK)
        .binaryTarget(
            name: "AzureCommunicationCalling",
            path: "spm-generated/XCFrameworks/AzureCommunicationCalling.xcframework"
        ),
        
        // AzureCommunicationUICalling binary target (Calling UI Library)
        .binaryTarget(
            name: "AzureCommunicationUICallingBinary",
            path: "spm-generated/XCFrameworks/AzureCommunicationUICalling.xcframework"
        ),
        
        // AzureCommunicationUIChat binary target (Chat UI Library)
        .binaryTarget(
            name: "AzureCommunicationUIChatBinary",
            path: "spm-generated/XCFrameworks/AzureCommunicationUIChat.xcframework"
        ),
        
        // AzureCommunicationChat binary target (Chat SDK)
        .binaryTarget(
            name: "AzureCommunicationChat",
            path: "spm-generated/XCFrameworks/AzureCommunicationChat.xcframework"
        ),
        
        
        // AzureCommunicationCommon binary target (Azure Communication Common)
        .binaryTarget(
            name: "AzureCommunicationCommon",
            path: "spm-generated/XCFrameworks/AzureCommunicationCommon.xcframework"
        ),
        
        // AzureCore binary target (Azure Core)
        .binaryTarget(
            name: "AzureCore",
            path: "spm-generated/XCFrameworks/AzureCore.xcframework"
        ),
        
        // Trouter binary target (Azure Communication Services Trouter)
        .binaryTarget(
            name: "Trouter",
            path: "spm-generated/XCFrameworks/Trouter.xcframework"
        ),
        
        // MARK: - Source Targets (Local)
        
        
        // AzureCommunicationUICommon from local sources
        .target(
            name: "AzureCommunicationUICommon",
            path: "AzureCommunicationUI/sdk/AzureCommunicationUICommon/Sources/AzureCommunicationUICommon",
            linkerSettings: [
                .linkedFramework("UIKit", .when(platforms: [.iOS]))
            ]
        ),
        
        // FluentUI minimal module interface (no implementation)
        .target(
            name: "FluentUI",
            dependencies: ["FluentUIResources"],
            path: "FluentUI_Minimal/ios/FluentUI"
        ),
        
        // FluentUIResources minimal module interface (no resources)
        .target(
            name: "FluentUIResources",
            path: "FluentUI_Minimal/apple"
        )
    ]
)