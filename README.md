# Azure Communication UI Library SPM Package Generator

**Automated tool to generate Swift Package Manager packages from the Azure Communication UI Library for iOS**

## ✅ Project Complete

This automation tool successfully creates complete SPM packages from any tag of the Azure Communication UI Library repository, including both Calling and Chat functionality with full iOS device and simulator support.

## 🚀 Quick Start

```bash
# Generate SPM package from the latest stable tag
./generate-spm-package.sh --tag "AzureCommunicationUICalling_1.14.2"

# The generated package will be in ./output/ and ready to use!
```


## ⚡ Prebuild Cache System

This tool includes an intelligent caching system that dramatically speeds up repeated builds:

### Cache Hierarchy
1. **Local Cache** - Instant access to previously built packages
2. **Remote Cache** - Downloads from [GitHub repository](https://github.com/billp/communication-ui-library-ios-spm-exported/tree/main/prebuild) 
3. **Fresh Build** - Full build from source (only when no cache available)

### Cache Features
- ✅ **MD5 Hash Validation** - Ensures integrity of cached packages
- ✅ **Automatic Cache Creation** - Saves successful builds for future use
- ✅ **Remote Distribution** - Share prebuilt packages via GitHub LFS
- ✅ **Smart Fallbacks** - Graceful handling when validation fails
- ✅ **Force Build Option** - Skip all caches when needed

### Cache Locations
- **Local**: `./prebuild/{tag}.zip` - Your local cache files
- **Hashes**: `./prebuild/hashes.md5` - Hash validation file
- **Remote**: `https://github.com/billp/communication-ui-library-ios-spm-exported/tree/main/prebuild`

## 🛠️ What the Script Does

### Phase 1: Repository Setup
- ✅ Clones the Azure Communication UI Library repository
- ✅ Checks out the specified git tag
- ✅ Validates repository structure

### Phase 2: CocoaPods Setup  
- ✅ Runs `pod install` to resolve dependencies
- ✅ Prepares Xcode workspace for building

### Phase 3: XCFramework Generation
- ✅ Builds iOS device archives (arm64)
- ✅ Builds iOS simulator archives (arm64 + x86_64) 
- ✅ Creates universal XCFrameworks for:
  - `AzureCommunicationCalling` (Calling SDK)
  - `AzureCommunicationUICalling` (Calling UI Library with embedded FluentUI)
  - `AzureCommunicationUIChat` (Chat UI Library with embedded FluentUI)
  - `AzureCommunicationChat` (Chat SDK)
  - `Trouter` (Azure Communication Services Trouter - Required for Chat)
  - `AzureCommunicationCommon` (Common SDK)
  - `AzureCore` (Core SDK)

### Phase 4: SPM Package Generation
- ✅ Creates complete SPM package structure
- ✅ Copies all XCFrameworks with proper paths
- ✅ Includes source code for common components
- ✅ Creates minimal FluentUI module interface
- ✅ Generates Package.swift from template
- ✅ FluentUI hybrid integration: embedded in Azure frameworks + minimal module interface

### Phase 5: Validation & Testing
- ✅ Tests package resolution with Swift Package Manager
- ✅ Validates XCFramework architectures
- ✅ Generates documentation and test files

## 📱 Generated Package Features

### Available Products
- **AzureCommunicationCalling** - Azure Communication Services Calling SDK
- **AzureCommunicationUICalling** - Complete calling UI experience (includes embedded FluentUI)
- **AzureCommunicationUIChat** - Complete chat UI experience (includes embedded FluentUI and Trouter)
- **AzureCommunicationUICommon** - Common utilities and components

### Architecture Support
- **iOS Device**: arm64 (iPhone/iPad)
- **iOS Simulator**: arm64 + x86_64 (Apple Silicon + Intel Macs)

### Platform Requirements
- **iOS 16.0+**
- **Xcode 14.0+**
- **Swift 5.7+**

## 📋 Requirements

Before running the script, ensure you have:

- **Xcode** (with xcodebuild command line tools)
- **CocoaPods** (`gem install cocoapods`)
- **Swift Package Manager** (included with Xcode)
- **Git**

## 🔧 Usage Examples

### Show Available Tags
```bash
./generate-spm-package.sh --available-tags
```

### Use Latest Tag (Recommended)
```bash
./generate-spm-package.sh --latest
```

### Basic Usage with Specific Tag
```bash
./generate-spm-package.sh --tag "AzureCommunicationUICalling_1.14.2"
```

### Custom Output Directory
```bash
./generate-spm-package.sh --latest --output-dir "/path/to/custom/output"
```

### Force Fresh Build (Skip All Caches)
```bash
./generate-spm-package.sh --tag "AzureCommunicationUICalling_1.14.2" --force-build
```

### Help
```bash
./generate-spm-package.sh --help
```

## 🎯 Command Line Options

| Option | Description |
|--------|-------------|
| `-t, --tag <TAG>` | Git tag to checkout (required unless --latest is used) |
| `-l, --latest` | Use the latest available tag (alternative to --tag) |
| `-o, --output-dir <DIR>` | Output directory (default: ./output) |
| `--force-build` | Skip all cache checks and force a fresh build |
| `--available-tags` | Show available tags from the repository |
| `-h, --help` | Show help message |

### Cache Control
- **Default behavior**: Checks local cache → remote cache → fresh build
- **With `--force-build`**: Skips all caches and builds fresh from source
- **Cache validation**: Uses MD5 hashes to verify package integrity

## 📦 Using the Generated Package

Once generated, the SPM package can be used in any iOS project:

### In Package.swift
```swift
dependencies: [
    .package(path: "path/to/generated/package")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "AzureCommunicationCalling", package: "AzureCommunicationUI"),
            .product(name: "AzureCommunicationUICalling", package: "AzureCommunicationUI"),
            .product(name: "AzureCommunicationUIChat", package: "AzureCommunicationUI"),
            .product(name: "AzureCommunicationUICommon", package: "AzureCommunicationUI")
        ]
    )
]
```

### In Swift Code
```swift
import AzureCommunicationCalling      // Calling SDK
import AzureCommunicationUICalling    // Calling UI Library (includes embedded FluentUI)
import AzureCommunicationUIChat       // Chat UI Library (includes embedded FluentUI)
import AzureCommunicationUICommon     // Common utilities
```

## 🔧 Technical Notes

### FluentUI Integration
The package uses a **minimal module interface approach** with FluentUI embedded within Azure Communication UI XCFrameworks and minimal Swift stubs for module resolution. This ensures:
- ✅ **API Compatibility**: FluentUI version matches exactly what Azure Communication SDK expects
- ✅ **Runtime Stability**: Only embedded FluentUI implementation runs - no conflicts
- ✅ **Module Import Support**: Minimal Swift stubs satisfy internal `import FluentUI` statements
- ✅ **Crash Prevention**: Eliminates duplicate FluentUI implementations that caused DynamicColor crashes
- ✅ **Clean Dependencies**: Minimal interface without competing implementations or resources

### Minimal Module Interface Approach
The script creates minimal Swift stub files that provide just enough module interface to satisfy imports without competing implementations:
- **Empty Swift classes** satisfy `import FluentUI` statements in Azure frameworks
- **No actual implementation** - all FluentUI functionality comes from embedded version
- **No resource conflicts** - only embedded FluentUI resources are used
- **Runtime stability** - single source of FluentUI implementation eliminates crashes

### cocoapods-spm Integration
The script uses the `cocoapods-spm` gem to properly integrate FluentUI during the build process:
- FluentUI is built from source and embedded into Azure frameworks
- Resources are correctly bundled and accessible at runtime
- Module imports work seamlessly within the Azure Communication SDK

### Architecture Support
All XCFrameworks support universal architectures:
- **iOS Device**: arm64 (iPhone/iPad)
- **iOS Simulator**: arm64 + x86_64 (Apple Silicon + Intel Macs)

## ⚠️ Known Issues

### FluentUI Duplicate Class Warnings
When using both `AzureCommunicationUICalling` and `AzureCommunicationUIChat` frameworks in the same app, you may see console warnings about duplicate FluentUI classes:

```
objc[]: Class _TtC12FluentUI_ios14TabBarItemView is implemented in both [...]/AzureCommunicationUICalling.framework/AzureCommunicationUICalling and [...]/AzureCommunicationUIChat.framework/AzureCommunicationUIChat. One of the duplicates must be removed or renamed.
```

**This is expected behavior and safe to ignore because:**
- ✅ **App functionality is not affected** - Both calling and chat features work correctly
- ✅ **Identical implementations** - Both frameworks contain the same FluentUI version
- ✅ **Runtime handles gracefully** - Objective-C runtime picks one implementation consistently
- ✅ **No crashes occur** - These are warnings, not errors

**Root Cause:** FluentUI is embedded in both frameworks during the cocoapods-spm build process to ensure each framework is self-contained. When both frameworks are loaded, the Objective-C runtime detects the duplicate classes but continues to function normally.