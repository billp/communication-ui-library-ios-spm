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
  - `AzureCommunicationUICalling` (Calling UI Library)
  - `AzureCommunicationUIChat` (Chat UI Library)
  - `AzureCommunicationChat` (Chat SDK)
  - `Trouter` (Azure Communication Services Trouter - Required for Chat)
  - `FluentUI` (Microsoft FluentUI components)
  - `AzureCommunicationCommon` (Common SDK)
  - `AzureCore` (Core SDK)

### Phase 4: SPM Package Generation
- ✅ Creates complete SPM package structure
- ✅ Copies all XCFrameworks with proper paths
- ✅ Includes source code for common components
- ✅ Generates Package.swift from template

### Phase 5: Validation & Testing
- ✅ Tests package resolution with Swift Package Manager
- ✅ Validates XCFramework architectures
- ✅ Generates documentation and test files

## 📱 Generated Package Features

### Available Products
- **AzureCommunicationCalling** - Azure Communication Services Calling SDK
- **AzureCommunicationUICalling** - Complete calling UI experience (includes FluentUI)
- **AzureCommunicationUIChat** - Complete chat UI experience (includes FluentUI and Trouter)
- **AzureCommunicationUICommon** - Common utilities and components
- **FluentUI** - Microsoft FluentUI components (available as standalone library)

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

### Help
```bash
./generate-spm-package.sh --help
```

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
import AzureCommunicationUICalling    // Calling UI Library (includes FluentUI)
import AzureCommunicationUIChat       // Chat UI Library (includes FluentUI)
import AzureCommunicationUICommon     // Common utilities
import FluentUI                       // Microsoft FluentUI (direct access)
```